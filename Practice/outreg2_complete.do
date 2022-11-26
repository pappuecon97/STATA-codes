*load data
sysuse auto.dta, clear

*reg 
reg price mpg headroom trunk weight displacement foreign
outreg2 using "G:\My Drive\YRF Class\STATA\outreg_prac2.xls", replace ctitle(Model 1, OLS) label bdec(3) sdec(2) addnote(Price is the dependent variable.) ///
		title(Table 1: Regression of Price and its factors) adjr2 addstat("F-Stat",e(F),"Prob > F",e(p),"Degree of Freedom",e(df_r))

reg price mpg headroom trunk weight displacement foreign, robust //to show robust se 

* ctitle means column headings; label means using given var label; dec() option is used to adjust decimal places in the estimates; bdec() defines coefficients decimal places; sdec() defines decimal places of SE; addnote() is used to add notes; nonotes() is used to remove any notes including the default one; title() is used to add table title; adjr2 is used to report adjusted r2; nor2 removes reporting r2; 'sideway' reports SE in side of coeff; 'noparen' removes parentheses from SE; To add more statistics, we need to specify an option called addstat() with the names and macros (we can get these macros from result section of help regress) of each new statistic that we require typed inside the parenthesis; 'nose' removes SE from report; to show several other stat, we can sue stat(coef, beta, se, ci); we can define CL by level() & significance level by alpha(), and symbol(***, **) asterisk(tstat) to add * to tstat; we can use 'keep' & 'drop' option to keep or remove specific var from the reg table; 
outreg2 using "G:\My Drive\YRF Class\STATA\outreg_prac2.xls", append ctitle(Model 2, Robust) label bdec(3) sdec(2) nor2 sideway noparen level(90) alpha(0.01, 0.05)


