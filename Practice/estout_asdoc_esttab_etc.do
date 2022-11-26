/************************************************************
Practice of estout, esttab, asdoc, levelsof, putexcel, outreg 
*/************************************************************

*cd
cd "G:\My Drive\YRF Class\STATA"


**************Estout******************

*load data
sysuse auto, clear

*run reg
reg price weight mpg 

*store estimates
estimates store m1 //m1 is the stored file name

*run another reg
reg price weight mpg foreign 

*store again in another name
estimates store m2 //m2 is the stored file name

*save the reg using estout
estout * // * means it will store all the stored estimates

*drop stored estimates
estimates drop * 

***********using eststo 

*data
sysuse auto, clear

*reg using eststo
eststo: qui reg price weight mpg 

eststo: qui reg price weight mpg foreign 

*save
estout 

*save in a file
estout using estout_output.xlsx, replace 

*clear store 
eststo clear


*******esttab***********

*Standard errors, p-values, and summary statistics

*data
sysuse auto, clear

*reg using eststo
eststo: qui reg price weight mpg 

eststo: qui reg price weight mpg foreign

*save
esttab using esttab_output.txt, replace se ar2

/*
The t-statistics can also be replaced by p-values (option p), confidence intervals (option ci), or any parameter statistics contained in the estimates (see the aux() option). Further summary statistics options are, for example, pr2 for the pseudo R-squared and bic for Schwarz's information criterion. Moreover, there is a generic scalars() option to include any other scalar statistics contained in the stored estimates. For instance, to print p-values and add the overall F-statistic and information on the degrees of freedom, type:
*/
 
esttab, p scalars(F df_m df_r)

*numeric format and side by side

esttab, b(a6) p(4) r2(4) nostar wide // b is for coeff format, p is for pvalue, wide means report p value side by side of estimates. 

*Labels, titles, and notes

esttab, label title(Regression results of price and it's factors) nonumbers ///
addnote("Source: auto.dta") mtitles("Model A" "Model B") se ar2 
eststo clear 

*The label option supports factor variables and interactions in Stata 11 or newer:
*load data
sysuse auto, clear

eststo: reg price mpg i.foreign 

eststo: reg price c.mpg##i.foreign 

esttab, varwidth(25)

esttab, varwidth(25) label //add label 

esttab, varwidth(25) label nobaselevels interaction(" X ") //change the symbol between interaction terms
						
esttab, plain //create plain table
eststo clear 


*compressed table

eststo: reg price mpg 
eststo: reg price mpg weight
eststo: reg price mpg weight foreign 
eststo: reg price mpg weight foreign displacement 
eststo: reg price mpg weight foreign displacement c.mpg##i.foreign

esttab, nobaselevels label interaction(" X ") compress 


*significance star
esttab, nobaselevels label interaction(" X ") compress star(* 0.10 ** 0.05 *** 0.01)

*export to excel sheet

esttab using estout_full_reg_table.csv, replace nobaselevels label interaction(" X ") ///
		compress star(* 0.10 ** 0.05 *** 0.01) /// 
		title(Table 1: Regression results of price and it's factors) nonumbers ///
		addnote("Source: auto.dta") mtitles("Model A" "Model B" "Model C" "Model D" "Model E") se ar2 

*use with LaTeX
esttab using example.tex, label replace booktabs ///
		alignment(D{.}{.}{-1}) width(0.8\hsize) ///
		title(Table 1: Regression results of price and it's factors\label{tab1}) ///
		nobaselevels interaction(" X ") ///
		compress star(* 0.10 ** 0.05 *** 0.01) ///
		addnote("Source: auto.dta") /// 
		mtitles("Model A" "Model B" "Model C" "Model D" "Model E") se ar2 

		
		
		
********Summary statistics****
sysuse census, clear
foreach x of varlist pop-popurban death-divorce {
 replace `x' = `x' / 1000
}

tabstat pop pop65p medage death marriage divorce, c(stat) stat(sum mean sd min max n)

est clear  // clear the stored estimates

estpost tabstat pop pop65p medage death marriage divorce, c(stat) stat(sum mean sd min max n)

ereturn list // list the stored locals

// basic
   esttab, cells("sum mean sd min max count")
// some options added
   esttab, cells("sum mean sd min max count") nonumber ///
   nomtitle nonote noobs label
// formatted
   esttab, ///
   cells("sum(fmt(%6.0fc)) mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max      count") nonumber ///
   nomtitle nonote noobs label collabels("Sum" "Mean" "SD" "Min" "Max" "N")
   
   *convert to latex
   esttab using "./graphs/guide80/table1.tex", replace ////
 cells("sum(fmt(%6.0fc)) mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max count") nonumber ///
  nomtitle nonote noobs label booktabs ///
  collabels("Sum" "Mean" "SD" "Min" "Max" "N")
  
  *add caption and labels
  esttab using "./graphs/guide80/table1_title.tex", replace ////
 cells("sum(fmt(%6.0fc)) mean(fmt(%6.2fc)) sd(fmt(%6.2fc)) min max count")   nonumber ///
  nomtitle nonote noobs label booktabs ///
  collabels("Sum" "Mean" "SD" "Min" "Max" "N")  ///
  title("Table 1 with title generated in Stata \label{table1stata}")
		
		
***********Outreg2***********

**********************Global directory*******************
global raw_dir 			"G:\My Drive\YRF Class\STATA\task3\01_raw"
global clean_dir 		"G:\My Drive\YRF Class\STATA\task3\02_clean"
global data_H_roster 	"G:\My Drive\YRF Class\STATA\task3\01_raw\HH_SEC_1A.dta" 
global data_H_cons 		"G:\My Drive\YRF Class\STATA\task3\01_raw\HH_SEC_9A2.dta"
global tables 			${clean_dir}\table



cd "G:\My Drive\YRF Class\STATA"


*load data
use "$clean_dir/final_hies.dta", clear

*regression tables
foreach x of varlist exp_food exp_fish exp_meat exp_veg exp_others{
	capture noisily erase "$tables/hies_regtable_outreg2_2.xls"
	qui reg `x' fem male hh_type
	outreg2 using "$tables/hies_regtable_outreg2_2.xls", append
}













*load data
sysuse auto.dta, clear

*reg 
reg price mpg headroom trunk weight displacement foreign
outreg2 using "G:\My Drive\YRF Class\STATA\outreg_prac2.xls", replace ctitle(Model 1, OLS) label bdec(3) sdec(2) addnote(Price is the dependent variable.) ///
		title(Table 1: Regression of Price and its factors) adjr2 addstat("F-Stat",e(F),"Prob > F",e(p),"Degree of Freedom",e(df_r))

reg price mpg headroom trunk weight displacement foreign, robust //to show robust se 

* ctitle means column headings; label means using given var label; dec() option is used to adjust decimal places in the estimates; bdec() defines coefficients decimal places; sdec() defines decimal places of SE; addnote() is used to add notes; nonotes() is used to remove any notes including the default one; title() is used to add table title; adjr2 is used to report adjusted r2; nor2 removes reporting r2; 'sideway' reports SE in side of coeff; 'noparen' removes parentheses from SE; To add more statistics, we need to specify an option called addstat() with the names and macros (we can get these macros from result section of help regress) of each new statistic that we require typed inside the parenthesis; 'nose' removes SE from report; to show several other stat, we can sue stat(coef, beta, se, ci); we can define CL by level() & significance level by alpha(), and symbol(***, **) asterisk(tstat) to add * to tstat; we can use 'keep' & 'drop' option to keep or remove specific var from the reg table; 
outreg2 using "G:\My Drive\YRF Class\STATA\outreg_prac2.xls", append ctitle(Model 2, Robust) label bdec(3) sdec(2) nor2 sideway noparen level(90) alpha(0.01, 0.05)


*check all stats macros
ereturn list


************Standard codes Reg Table by Outreg2***********

*webuse
webuse nlswork, clear 

local i "price"
local j "price"
foreach x in price{
	qui reg `x' mpg headroom trunk weight displacement foreign
	if `x' == `i'{
	outreg2 using "$tables/hies_sum_table_putexcel.xls", replace
	}
	else if `x' == `j'{
		outreg2 using "$tables/hies_sum_table_putexcel.xls", append
	}
}


*********Summary table by outreg2 **************

*eqkeep is used to keep only statistics, to keeo vr we use keep or drop command

outreg2  using "G:\My Drive\YRF Class\STATA\outreg_prac_sum_table.xls", replace sum(log) keep(age ln_wage hours ttl_exp wks_ue) eqkeep(N mean sd) title(Summary Statistics)


*To obtain summary statistics for variables and observations used in a regression only we first run the regression, then use the outreg2 command right after it with an option of sum;
regress ln_wage race age nev_mar collgrad 
outreg2 using "G:\My Drive\YRF Class\STATA\outreg_prac_sum_table_regvars.xls", replace sum


*sum stat by group 
lab define marr_st 0"Unmarried" 1"Married"
la val nev_mar marr_st

bys nev_mar: outreg2  using "G:\My Drive\YRF Class\STATA\outreg_prac_sum_table.xls", replace sum(log) keep(age ln_wage hours ttl_exp wks_ue) eqkeep(N mean sd) title(Summary Statistics)


/*
****Export multiple tables in one excel file

use http://www.stata-press.com/data/r13/ibm, clear

tsset t

generate ibmadj = ibm - irx
generate spxadj = spx - irx

local dep ibmadj
local indep spxadj irx

quietly : newey `dep' `indep', lag(3) force
outreg2 using "Table1", replace dta dec(2)  tstat

use "Table1_dta.dta", clear
export excel using Need_help.xls , sheet("Table1")
*/


