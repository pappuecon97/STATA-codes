/******************************************************************************
*Title: Task4.2 of STATA class by Tanvir bhaiya
*Created by: Md Johirul Islam
*Created on: STATA15
*Last Modified on: 20/08/22
*Last Modified by: MJI
*Purpose : Making regression table by outreg2 	
******************************************************************************/

*******************Current directory******************
cd "G:\My Drive\YRF Class\STATA\task3"

**********************Global directory*******************
global raw_dir 			"G:\My Drive\YRF Class\STATA\task3\01_raw"
global clean_dir 		"G:\My Drive\YRF Class\STATA\task3\02_clean"
global data_H_roster 	"G:\My Drive\YRF Class\STATA\task3\01_raw\HH_SEC_1A.dta" 
global data_H_cons 		"G:\My Drive\YRF Class\STATA\task3\01_raw\HH_SEC_9A2.dta"
global tables 			${clean_dir}\table


*load data
use "$clean_dir/final_hies.dta", clear

*regression tables
foreach x of varlist exp_food exp_fish exp_meat exp_veg exp_others{
	capture noisily erase "$tables/hies_regtable_outreg2.xls"
	qui reg `x' fem male hh_type
	outreg2 using "$tables/hies_regtable_outreg2.xls", append
}





*alt reg table in diff sheet of the same excel file

local i "exp_food"
local j "exp_fish exp_meat exp_veg exp_others"
foreach x of varlist exp_food exp_fish exp_meat exp_veg exp_others{
	qui reg `x' fem male hh_type
	if `x' == `i'{
	outreg2 using "$tables/hies_sum_table_putexcel.xls", replace
	}
	else if `x' == `j'{
		outreg2 using "$tables/hies_sum_table_putexcel.xls", append
	}
}



