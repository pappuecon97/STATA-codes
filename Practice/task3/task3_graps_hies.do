
*****************HIES HH consumption graphs **************


*******************Current directory******************
cd "G:\My Drive\YRF Class\STATA\task3"

**********************Global directory*******************
global raw_dir 			"G:\My Drive\YRF Class\STATA\task3\01_raw"
global clean_dir 		"G:\My Drive\YRF Class\STATA\task3\02_clean"
global data_H_roster 	"C:\Users\Dell\Dropbox\My PC (DESKTOP-JT78TJM)\Downloads\HH_SEC_1A_1.dta" 
global data_H_cons 		"G:\My Drive\YRF Class\STATA\task3\01_raw\HH_SEC_9A2.dta"


*load data
use "$clean_dir/final_hies.dta", clear 

*set color scheme 	
set scheme tab2 // to install it type: ssc install schemepack

graph bar (mean) exp_food exp_fish exp_meat exp_veg exp_others, over(hh_type, gap(*2) label(labsize(small))) ///
					blabel(bar, format(%9.0f)) ///
					ytitle("") subtitle("", justification(centre) bexpand size(1)) ///
					title("Daily average expenditure of household by household head type", justification(center) margin(b+4 t-1 l-1) bexpand size(medium))  ///
					note("Source: HIES data. This graph is created for STATA HW by Tanvir Bhai", size(vsmall)) ///
						legend(order(1 "Food" 2 "Fish" 3 "Meat" 4 "Vegetables" 5 "Others") row(1) pos(bottom) size(small)) ///
						ysc(off) ysca(noline) //remode y-axis "xsc(off)" for x-axis 
*save graph 
graph export "$clean_dir\hh_exp_by_hh_type2.png", replace
		

