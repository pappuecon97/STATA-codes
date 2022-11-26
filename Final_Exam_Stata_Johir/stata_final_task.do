/******************************************************************************
*Title: STATA final task given by Tanvir bhai
*Created by: Md Johirul Islam
*Created on: STATA17
*Last Modified on: 23/10/22
*Last Modified by: MJI
*Purpose : Analysis of 
******************************************************************************/

*********Housekeeping **********
clear all
set more off
version 17

**** Current directory
cd "G:\My Drive\YRF Class\STATA\Final_Exam_Stata_Johir"

/*
1. Create a panel data household level. The required variables in that data are
Treatment status, Number of household member. Highest year of education of the household members, Household income, respondent's education, respondent's age, respondent's marital status, male ratio(total male/total household member), female ratio, and adult ratio, treatment_status

*/

*****************************Data crunching of baseline ********

*use data of baseline
use "G:\My Drive\YRF Class\STATA\Final_Exam_Stata_Johir\wsdfm_baseline.dta", clear 


*keep necessary vars
keep idno section2_lino_1 section2_1_col7_1 section9_4_q3 s6_1 section6_1_col1_1 section6_1_col9_1 section6_1_col10_1 section6_1_col12_1 section6_1_col1_2 section6_1_col9_2 section6_1_col10_2 section6_1_col12_2 section6_1_col1_3 section6_1_col9_3 section6_1_col10_3 section6_1_col12_3 section6_2_q1 section2_1_col6_1 section2_1_col6_2 section2_1_col6_3 section2_1_col6_4 section2_1_col6_5 section2_1_col6_6 section2_1_col6_7 section2_1_col6_8 section2_1_col6_9 section2_1_col6_10 section2_1_col6_11 section2_lino_2 section2_lino_3 section2_lino_4 section2_lino_5 section2_lino_6 section2_lino_7 section2_lino_8 section2_lino_9 section2_lino_10 section2_lino_11 section2_1_col3_1 section2_1_col3_2 section2_1_col3_3 section2_1_col3_4 section2_1_col3_5 section2_1_col3_6 section2_1_col3_7 section2_1_col3_8 section2_1_col3_9 section2_1_col3_10 section2_1_col3_11 section2_1_col4_1 section2_1_col5_1 section2_1_col8_1 section2_1_col4_2 section2_1_col5_2 section2_1_col8_2 section2_1_col4_3 section2_1_col5_3 section2_1_col8_3 section2_1_col4_4 section2_1_col5_4 section2_1_col8_4 section2_1_col4_5 section2_1_col5_5 section2_1_col8_5 section2_1_col4_6 section2_1_col5_6 section2_1_col8_6 section2_1_col4_7 section2_1_col5_7 section2_1_col8_7 section2_1_col4_8 section2_1_col5_8 section2_1_col8_8 section2_1_col4_9 section2_1_col5_9 section2_1_col8_9 section2_1_col4_10 section2_1_col5_10 section2_1_col8_10 section2_1_col4_11 section2_1_col5_11 section2_1_col8_11 section2_1_col7_1 section2_1_col7_2 section2_1_col7_3 section2_1_col7_4 section2_1_col7_5 section2_1_col7_6 section2_1_col7_7 section2_1_col7_8 section2_1_col7_9 section2_1_col7_10 section2_1_col7_11 consent section2_1_col1_1 section2_1_col1_2 section2_1_col1_3 section2_1_col1_4 section2_1_col1_5 section2_1_col1_6 section2_1_col1_7 section2_1_col1_8 section2_1_col1_9 section2_1_col1_10 section2_1_col1_11

*drop 
drop section2_1_col8_1 section2_1_col8_2 section2_1_col8_3 section2_1_col8_4 section2_1_col8_5 section2_1_col8_6 section2_1_col8_7 section2_1_col8_8 section2_1_col8_9 section2_1_col8_10 section2_1_col8_11

*drop 
drop section2_lino_1 section2_lino_2 section2_lino_3 section2_lino_4 section2_lino_5 section2_lino_6 section2_lino_7 section2_lino_8 section2_lino_9 section2_lino_10 section2_lino_11

*drop 
drop section6_1_col1_1 section6_1_col12_1 section6_1_col1_2 section6_1_col12_2 section6_1_col1_3 section6_1_col12_3 section6_2_q1 section9_4_q3 s6_1

*check for duplicates in id 
duplicates tag idno, gen(dup)
tab dup 

*drop missing ids 
drop if idno==. 
drop dup

*keep only consent yes
keep if consent==1

*rename by assigning baseline symbol
forvalues i = 1/7{
    forvalues j =1/11{
	    capture noisily rename section2_1_col`i'_`j' section2_`i'_`j'_19
	}
    
}

*rename 
forvalues i = 9/10{
    forvalues j =1/11{
	    capture noisily rename section6_1_col`i'_`j' section6_`i'_`j'_19
	}
    
}


*number of female , male, total number
gen total_mem = 0
gen male_mem =0
gen fem_mem=0 
gen adult_num = 0

forvalues i =  1/11{
    replace total_mem = total_mem +1 if section2_3_`i'_19 !=.
	replace male_mem = male_mem +1 if section2_3_`i'_19== 2
	replace fem_mem = fem_mem +1 if section2_3_`i'_19== 1
	capture noisily replace adult_num = adult_num + 1 if section2_4_`i'_19 >=18 & section2_4_`i' !=.
}

*male ratio  
gen male_ratio = male_mem/total_mem

*female ratio 
gen fem_ratio = fem_mem/total_mem

*adult ratio 
gen adult_ratio = adult_num/total_mem


*assign baseline suffix to the rest
foreach x of varlist total_mem male_mem fem_mem adult_num{
    rename `x' `x'_19
}

*household income 

    egen hh_income_month = rowtotal(section6_9_1_19 section6_9_2_19 section6_9_3_19)
	egen hh_income_year = rowtotal(section6_10_1_19 section6_10_2_19 section6_10_3_19)

replace hh_income_month= 0 if hh_income_month==.
replace hh_income_year=0 if hh_income_year==.

*highest education of hh member 
egen highest_educ = rowmax(section2_7_1_19 section2_7_2_19 section2_7_3_19 section2_7_4_19 section2_7_5_19 section2_7_6_19 section2_7_7_19 section2_7_8_19 section2_7_9_19 section2_7_10_19 section2_7_11_19)


*correction for highest education

forvalues i = 1/11{
	replace highest_educ = 13 if section2_7_`i'_19 ==13 & inlist(highest_educ, 14, 15) 
	replace highest_educ = 12 if section2_7_`i'_19 ==12 & inlist(highest_educ, 14, 15)
}


*label highest_educ 
label var highest_educ "highest level of education by a member in hh"
la define highest_educ_label ///
						0"Lower than class 1" ///
						1"Class 1" ///
						2"Class 2" ///
						3"Class 3" ///
						4"Class 4" ///
						5"Class 5" ///
						6"Class 6" ///
						7"Class 7" ///
						8"Class 8" ///
						9"Class 9" ///
						10"SSC/Dhakhil" ///
						11"HSC/Alim" ///
						12"BA/BSc/Bcom/Fazil" ///
						13"MA/MSc/Mcom/Kamil" ///
						14 "Diploma/Vocational" ///
						15 "Hafiz"
lab value highest_educ highest_educ_label

*save baseline data 
save "final_task_baseline.dta", replace 




*****************************Endline********************

*load data
use "G:\My Drive\YRF Class\STATA\Final_Exam_Stata_Johir\wsdfm_followup.dta", clear

*keep necessary vars
keep idno section2_1_col7_1 section2_1_col7_2 section2_1_col7_3 section2_1_col7_4 section2_1_col7_5 section2_1_col7_6 section2_1_col7_7 section2_1_col7_8 section2_1_col7_9 section2_1_col7_10 section2_1_col7_11 section2_1_col7_12 section2_1_col4* section2_1_col3* section6_1_col9* s6_4 consent

*check for duplicates in id 
duplicates tag idno, gen(dup)
tab dup 

*drop missing ids 
drop if idno==. 
drop dup

*drop no consent 
keep if consent ==1

*rename by assigning baseline symbol section2 
foreach i in 3 4 7{
    forvalues j =1/12{
	    capture noisily rename section2_1_col`i'_`j' section2_`i'_`j'_21
	}
    
}

*rename for section6
foreach i in 9{
    forvalues j =1/3{
	    capture noisily rename section6_1_col`i'_`j' section6_`i'_`j'_21
	}
    
}

*hh income
egen hh_income_month_21= rowtotal(section6_9_1_21 section6_9_2_21 section6_9_3_21)

replace hh_income_month_21= 0 if hh_income_month==.

*convert per month to year 
gen hh_income_year_21 = 12*hh_income_month


*number of female , male, total number
gen total_mem = 0
gen male_mem =0
gen fem_mem=0 
gen adult_num = 0

forvalues i =  1/12{
    replace total_mem = total_mem +1 if section2_3_`i'_21 !=.
	replace male_mem = male_mem +1 if section2_3_`i'_21== 2
	replace fem_mem = fem_mem +1 if section2_3_`i'_21== 1
	capture noisily replace adult_num = adult_num + 1 if section2_4_`i'_21 >=18 & section2_4_`i' !=.
}

*male ratio  
gen male_ratio = male_mem/total_mem

*female ratio 
gen fem_ratio = fem_mem/total_mem

*adult ratio 
gen adult_ratio = adult_num/total_mem


*assign endline suffix to the rest
foreach x of varlist total_mem male_mem fem_mem adult_num male_ratio fem_ratio adult_ratio{
    rename `x' `x'_21
}


*drop  duplicates 
duplicates drop idno, force

*save endline data 
save "final_task_endline.dta", replace 



*****************merge**********

*merge two data 
merge 1:1 idno using "final_task_baseline.dta"

*drop unmatched to make the panel balanced 
keep if _merge==3
drop _merge

*merge for treatment assignment
merge 1:1 idno using "G:\My Drive\YRF Class\STATA\Final_Exam_Stata_Johir\treatment_no_dup.dta"

keep if _merge==3
drop _merge

*save final one
save "final_task_panel_hhlevel.dta", replace 

**********************Regression ***********

*use 
use "final_task_panel_hhlevel.dta", clear

*keeping necessary vars for the 
keep idno hh_income_year_21 hh_income_year male_ratio treatment total_mem_19 male_mem_19 fem_mem_19 adult_num_19

*rename baseline inc 
rename hh_income_year hh_income_year_19 

*reshape for endline and baseline 

reshape long hh_income_year_ , i(idno) j(year) 



*gen baseline income 
gen baseline_inc = hh_income_year_ if year ==19 
replace baseline_inc =  hh_income_year_ if year ==21

*reg 
xtset idno year
xtreg hh_income_year_ treatment baseline_inc total_mem_19 male_mem_19 male_ratio

outreg2 using "G:\My Drive\YRF Class\STATA\final_task_stata_reg.xls", replace ctitle(Model 1, OLS) label bdec(3) sdec(2) addnote() ///
		title(Table 1: Regression of income and its factors) r2
xtreg hh_income_year_ treatment baseline_inc total_mem_19 male_mem_19 male_ratio, fe //assigning fixed effect 
outreg2 using "G:\My Drive\YRF Class\STATA\final_task_stata_reg.xls", append ctitle(Model 2, FE) label bdec(3) sdec(2) addnote() r2



***********************Graphs***********

**color
global skyblue "86 180 233"
global blue "0 114 178"
global teal "17 222 245"
global orange "213 94 0"
global green "0 158 115"
global yellow "230 159 0"
global purple "204 121 167"
global lavendar "154 121 204"


label def treat 1"Treatment" 0"Control" 
la value treatment treat 

label define yea 19"Baseline" 21"Follow up"
la val year yea 

set scheme burd6 //burd4 and burd6 are good
graph set window fontface "Georgia" //font style

graph bar (mean) hh_income_year_, over(treatment, label(labsize(small))) ascategory bar(1, fcolor("$green")) bar(1, fcolor("$purple"))  /// 
					over(year, gap() label(labsize(medium), )) ///
					blabel(bar, format(%9.0f)) ///
					ytitle("") subtitle("", justification(centre) bexpand size(1)) ///
					title(" Avg. income disaggregaion by baseline and endline", justification(center) margin(b+4 t-1 l-1) bexpand size(medium))  ///
					note(, size(vsmall)) ///
						legend(order(1 "Baseline" 2 "Follow up") row(1) pos(bottom) size(small)) ///
						ysc(off) ysca(noline) //remode y-axis "xsc(off)" for x-axis  ///
						forval i=1/`.Graph.plotregion1.barlabels.arrnels' {
    gr_edit .plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'/-"
} // add dollar/taka sign to barlabel

graph export "graph_task_final.png", replace 


**********************Individual level data ******************

*load data 
use "final_task_panel_hhlevel.dta", clear 

*keep necessary vars
keep idno treatment section2_3_1_19 section2_3_2_19 section2_3_3_19 section2_3_4_19 section2_3_5_19 section2_3_6_19 section2_3_7_19 section2_3_8_19 section2_3_9_19 section2_3_10_19 section2_3_11_19 section2_3_1_21 section2_3_2_21 section2_3_3_21 section2_3_4_21 section2_3_5_21 section2_3_6_21 section2_3_7_21 section2_3_8_21 section2_3_9_21 section2_3_10_21 section2_3_11_21 section2_3_12_21 section2_4_1_21 section2_4_2_21 section2_4_3_21 section2_4_4_21 section2_4_5_21 section2_4_6_21 section2_4_7_21 section2_4_8_21 section2_4_9_21 section2_4_10_21 section2_4_11_21 section2_4_12_21 section2_4_1_19 section2_4_2_19 section2_4_3_19 section2_4_4_19 section2_4_5_19 section2_4_6_19 section2_4_7_19 section2_4_8_19 section2_4_9_19 section2_4_10_19 section2_4_11_19 section2_6_1_19 section2_6_2_19 section2_6_3_19 section2_6_4_19 section2_6_5_19 section2_6_6_19 section2_6_7_19 section2_6_8_19 section2_6_9_19 section2_6_10_19 section2_6_11_19 section2_1_1_19 section2_1_2_19 section2_1_3_19 section2_1_4_19 section2_1_5_19 section2_1_6_19 section2_1_7_19 section2_1_8_19 section2_1_9_19 section2_1_10_19 section2_1_11_19
 

*gen var for year missing 
local x "age gender marital name"

foreach i of local x{
	gen `i'_12_19=.
}

*****rename vars

*gender 
foreach i in 19 21{
	forvalues j = 1/12{
		capture noisily rename section2_3_`j'_`i' gender_`j'_`i'
	}
}

*age 
foreach i in 19 21{
	forvalues j = 1/11{
		rename section2_4_`j'_`i' age_`j'_`i'
	}
}

rename section2_4_12_21 age_12_21

*marital status 
foreach i in 19 21{
	forvalues j = 1/12{
		capture noisily rename section2_6_`j'_`i' marital_`j'_`i'
	}
}

*gen another var for name _21 
foreach i in 19{
	forvalues j = 1/12{
		capture noisily gen section2_1_`j'_21 = section2_1_`j'_`i'
	}
}

*name
foreach i in 19 21{
	forvalues j = 1/12{
		capture noisily rename section2_1_`j'_`i' name_`j'_`i'
	}
}

*gen another 
gen name_12_21 = name_12_19

*reshape to panel 
reshape long age_1_ age_2_ age_3_ age_4_ age_5_ age_6_ age_7_ age_8_ age_9_ age_10_ age_11_ age_12_ gender_1_ gender_2_ gender_3_ gender_4_ gender_5_ gender_6_ gender_7_ gender_8_ gender_9_ gender_10_ gender_11_ gender_12_ marital_1_ marital_2_ marital_3_ marital_4_ marital_5_ marital_6_ marital_7_ marital_8_ marital_9_ marital_10_ marital_11_ marital_12_ name_1_ name_2_ name_3_ name_4_ name_5_ name_6_ name_7_ name_8_ name_9_ name_10_ name_11_ name_12_, i(idno) j(year) 

*rename for another reshaping 

forvalues i =1/12{
	capture noisily rename age_`i' age`i'
}
forvalues i =1/12{
	capture noisily rename gender_`i' gender`i'
}
forvalues i =1/12{
	capture noisily rename marital_`i' marital`i'
}
forvalues i =1/12{
	capture noisily rename name_`i' name`i'
}

*rename the rest ones 

local vars "gender age name marital"
foreach i of local vars{
	rename `i'_1_ `i'1
}

*tostring name12
tostring name12, gen(name12_)
drop name12 
rename name12_ name12 

*create unique id for reshaping 
egen hh_id = concat(idno year), punct("_")
drop idno 
order hh_id year 


*reshape to individual level 
reshape long age name gender marital, i(hh_id) j(member_id)

*sorting
sort hh_id member_id

*save individual level data 
save "final_task_panel_individual_level.dta", replace 


