/******************************************************************************
*Title:  Task 1_9_22 of STATA class by Tanvir bhaiya
*Created by: Md Johirul Islam
*Created on: STATA17
*Last Modified on: 12/09/22
*Last Modified by: MJI
*Purpose : changing the place of member Id and occupation code of vars using loop
******************************************************************************/

*load data
use "C:\Users\Dell\Dropbox\My PC (DESKTOP-JT78TJM)\Downloads\task1-9-22.dta", clear

*copy var label
foreach i of var * {
        local l`i' : variable label `i'
            if `"`l`i''"' == "" {
            local l`i' "`i'"
        }
}


/*
*gen var
forvalues i =1/15{
	forvalues j = 1/4{
		gen _s6col4_`i'_`j' = s6col4_`i'_`j' 
	}
}
*/

*drop vars
drop s6col4_1_1 s6col4_1_2 s6col4_1_3 s6col4_1_4 s6col4_2_1 s6col4_2_2 s6col4_2_3 s6col4_2_4 s6col4_3_1 s6col4_3_2 s6col4_3_3 s6col4_3_4 s6col4_4_1 s6col4_4_2 s6col4_4_3 s6col4_4_4 s6col4_5_1 s6col4_5_2 s6col4_5_3 s6col4_5_4 s6col4_6_1 s6col4_6_2 s6col4_6_3 s6col4_6_4 s6col4_7_1 s6col4_7_2 s6col4_7_3 s6col4_7_4 s6col4_8_1 s6col4_8_2 s6col4_8_3 s6col4_8_4 s6col4_9_1 s6col4_9_2 s6col4_9_3 s6col4_9_4 s6col4_10_1 s6col4_10_2 s6col4_10_3 s6col4_10_4 s6col4_11_1 s6col4_11_2 s6col4_11_3 s6col4_11_4 s6col4_12_1 s6col4_12_2 s6col4_12_3 s6col4_12_4 s6col4_13_1 s6col4_13_2 s6col4_13_3 s6col4_13_4 s6col4_14_1 s6col4_14_2 s6col4_14_3 s6col4_14_4 s6col4_15_1 s6col4_15_2 s6col4_15_3 s6col4_15_4

*create hh_id
gen hh_id =_n
order hh_id

*loop to change var name
forvalues i =1/15{
	forvalues j = 1/4{
		rename _s6col4_`i'_`j' s6col4_`j'_`i' 
	}
}

*attach var label
foreach i of var *{
        label var `i' "`l`i''"
}

/*
how can solve the problem of assigning all the labels since vars name now differ?? i need to rename var by _, then rename it again to replace the place of the member d and occu id. 
*/

save "task1-9-22_rename.dta", replace

