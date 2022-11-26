****************alternative to reshape*********

*load data
use https://stats.idre.ucla.edu/stat/stata/modules/faminc, clear

*sCount all of the income variables and create a variable for each observations
ds income*           
local copies : word count `r(varlist)'  
expand `copies' 

*Then create a list of all of the vars with each stub and manually expand
gen yearmonth = . // create an empty var that will hold the sub-group identifier (this is the j var in reshape)
foreach var in income {
    
    *Save all of the income variables
    ds `var'_*,                  
    local reshapevarlist `r(varlist)'   

    *remove the stub so that we can have the yearmonth or j identifier foreach var alone while maintaining their order        
    local monthyear = subinstr("`reshapevarlist'", "`var'_", "", .)   
     
    *create an empty version of the stub, this will become the long var
    gen `var' = .      
     
    *Loop through each value 
    forvalues x = 1/`copies' {           
        
        * Replace the variable from the list we defined earlier in the loop
        /* See "h mod" to understand how mod works, but in short "if mod(n, `copies') == `x'"" 
        will only replace the variable for the nth observation in each group defined by
        an ID variable (e.g. the nth or last row created in the expand)
        */
        local currvar : word `x' of `reshapevarlist'         
        replace `var' = `currvar' if mod(_n, `copies') == `x'

        * Generate the identifier variable
        local yearmonth : word `x' of `monthyear' 
        replace yearmonth = `yearmonth' if mod(_n, `copies') == `x'  
        
        *Drop the wide variable
        drop `currvar' 
    }
    // end forval x= 1/`copies'
}
// end foreach var in income



********Extended Missing values **************

*Assign numerical codes
loc idk		-99 99 999	// numerical code for "Don't Know"
loc rf		-77 77 75	// numerical code for "Refuse"
loc na		-88			// numerical code for "Not Applicable"
loc oth		-66			// numerical code for "Other"
loc skip	-70			// numerical code for  "Skip"

* Replace values for each type of refusal across numerical variables
qui ds, not(type string) 
local numvars `r(varlist)'
foreach var of local numvars { 

	** Replace missing values as negative for unlabeled numeric variable above 0 
	if mi("`: value label `var''") { // no labels from SurveyCTO import code
			
		*Skip if value takes less than 0 values
		if `var' < 0 continue 
		
		*now check if value has missing	
		qui sum `var' if inlist(`var', 99, 88, 77, 66)
		if `r(N)' == 0 continue // move to next variable if no values have positive version

		* only change if this is the outlier value conditional on previous being completed
		foreach val of 99 88 77 66 {
			di "`var' has `r(N)' cases of `val'" 
			qui sum `var' 
			qui replace `var' = -`val' if `var' == `val' & (`r(max)' == `val' | `r(min)' == `val') 
		}
		// end foreach val of 99 88 77 66 

	}
	// end if mi("`: value label `var''")

	** Relabel based on missing patterns
	foreach x of local idk {
		replace `var' = .d if `var' == `x' 		// Don't know 
	}
	// end foreach x of local idk
	foreach x of local na {
		replace `var' = .n if `var' == `x' 		// N/A
	}
	// end foreach x of local na
	foreach x of local oth {
		replace `var' = .o if `var' == `x' 		// Other
	}
	// end foreach x of local oth
	foreach x of local rf {
		replace `var' = .r if `var' == `x' 		// Refuse
	}
	// end foreach x of local rf
	foreach x of local skip {
		replace `var' = .s if `var' == `x' 		// Skip
	}
	// end foreach x of local 
} 
// end foreach var of local numvars



***Incoportating other sections****

/*
For example, if a question asked for someone's favorite color, giving the options of blue, red, yellow, green, and other. If someone answered "other" and then wrote "sky blue" for their answer, you would want to recode the original variable for favorite color to say "blue" instead of "other". However, if someone wrote "purple" you could leave their response as is (or, if enough people wrote purple, you could add another category to the variable).



*/


**********Checking Skip logic *********

/*
	In this example, there is a module that asks about business profits only if 
	the respondent has a business. The question that starts a set of questions, 
	b_prof_s*, on business profits is b_prof_yn. All questions should be skipped 
	if  b_prof_yn == 0, but the variables b_prof_s* exist if any respondent has 
	a business.

	First we assign the skip missing value to all observations if they do not
	have a value. Then we run an assert to confirm skips worked as intended. If
	they did not, the user is warned and a dataset is saved. 
*/
** First identify if the respondent has a business and fill skip values
unab bus_items : b_prof_s* // save all business profits questions
foreach var of local bus_items {
	replace `var' = .s if `var' == . & b_prof_yn == 0 // create skip patternm note that `var' == ., not mi(`var') to ensure extended missing values are not overwritten
}


** Now check to confirm that 
foreach var of local bus_items {
	cap assert `var' == .s if b_prof_yn == 0 // don't use capture unless you control for every outcome

	*Tag variables if this fails
	if _rc == 9 gen `var'_nos = `var' != .s & b_prof_yn == 0

	*Controlling for other options
	else if !_rc di "No errors in `var'"
	else exit _rc // exit with an error if a different error than the assert failing
}


** Export a list of each variable and if it were skipped
/* Formatting could be done differently here, the below
   outputs an excel sheet that preserves all other answers
   and is in the wide format.
*/
preserve

	*Save ID and relevant variables
	keep id key startdate b_prof* 

	*Keep relevant observations
	qui ds b_prof_*_nos
	egen tokeep = rowmax(`r(varlist)')
	keep if tokeep == 1
	drop tokeep

	*Order by variable and missing
	foreach var of local bus_items {
		order `var' `var'_nos
	}

	*Save files
	export excel using "${temp}business_skip_errors.xlsx", first(var) replace

restore