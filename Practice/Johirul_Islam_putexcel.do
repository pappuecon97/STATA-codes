/******************************************************************************
*Title: Task4.3 of STATA class by Tanvir bhaiya
*Created by: Md Johirul Islam
*Created on: STATA15
*Last Modified on: 12/08/22
*Last Modified by: MJI
*Purpose : Making summary table by putexcel
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

************Creating summary table ******************

putexcel set "$tables/hies_sum_table_putexcel.xls", replace
putexcel E3 = "Male Headed HH"
putexcel E3:F3, merge
putexcel G3 = "Female Headed HH"
putexcel G3:H3, merge
putexcel I3 = "Overall"
putexcel I3:J3, merge
putexcel D4 = "Variables"
putexcel D5 = "Food Grain Expenditure"
putexcel D6 = "Fish Expenditure"
putexcel D7 = "Meat Expenditure"
putexcel D8 = "Vegetables Expenditure"
putexcel D9 = "Other Expenditure"
putexcel D10 = "Total Expenditure"
putexcel D11 = "Per capita Expenditure"

putexcel E4 = "Mean"
putexcel F4 = "SD"
putexcel G4 = "Mean"
putexcel H4 = "SD"
putexcel I4 = "Mean"
putexcel J4 = "SD"

*add values
local vars "exp_food exp_fish exp_meat exp_veg exp_others total_exp percap_hh"

local i = 5

foreach j of local vars{
    qui ttest `j', by(hh_type)
	putexcel E`i' = `r(mu_2)', nformat(number_d2)
	putexcel F`i' = `r(sd_2)', nformat(number_d2)
	putexcel G`i' = `r(mu_1)', nformat(number_d2)
	putexcel H`i' = `r(sd_1)', nformat(number_d2)
	qui summ `j'
	putexcel I`i' = `r(mean)', nformat(number_d2)
	putexcel J`i' = `r(sd)', nformat(number_d2)
	
	local i = `i' +1
}

*per capita total exp
putexcel save






