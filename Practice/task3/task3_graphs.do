*****************Graph*************
*HIES HH consumption graphs 

/******************************************************************************
*Title: Task3 of STATA class by Tanvir bhaiya
*Created by: Md Johirul Islam
*Created on: STATA15
*Last Modified on: 12/08/22
*Last Modified by: MJI
*Purpose : Analysis of HIES Datasets for HH consumption goods	
******************************************************************************/

*******************Current directory******************
cd "G:\My Drive\YRF Class\STATA\task3"

**********************Global directory*******************
global raw_dir 			"G:\My Drive\YRF Class\STATA\task3\01_raw"
global clean_dir 		"G:\My Drive\YRF Class\STATA\task3\02_clean"
global data_H_roster 	"C:\Users\Dell\Dropbox\My PC (DESKTOP-JT78TJM)\Downloads\HH_SEC_1A_1.dta" 
global data_H_cons 		"G:\My Drive\YRF Class\STATA\task3\01_raw\HH_SEC_9A2.dta"


use "$clean_dir/final_hies.dta", clear 

set scheme burd4 //burd4 and burd6 are good
graph set window fontface "Georgia" //font style

graph bar (mean) exp_food exp_fish exp_meat exp_veg exp_others, over(hh_type, gap(*2) label(labsize(small))) ///
					blabel(bar, format(%9.0f)) ///
					ytitle("") subtitle("", justification(centre) bexpand size(1)) ///
					title("Daily average expenditure of household by household head type", justification(center) margin(b+4 t-1 l-1) bexpand size(medium))  ///
					note("Source: HIES", size(vsmall)) ///
						legend(order(1 "Food" 2 "Fish" 3 "Meat" 4 "Vegetables" 5 "Others") row(1) pos(bottom) size(small)) ///
						ysc(off) ysca(noline) //remode y-axis "xsc(off)" for x-axis  ///
						forval i=1/`.Graph.plotregion1.barlabels.arrnels' {
    gr_edit .plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'/-"
} // add dollar/taka sign to barlabel

graph export "$clean_dir\hh_exp_by_hh_type2.png", replace 

						
	***********use asjad naqbi scheme****
	
	
set scheme tab2 // to install it type: ssc install schemepack

graph bar (mean) exp_food exp_fish exp_meat exp_veg exp_others, over(hh_type, gap(*2) label(labsize(small))) ///
					blabel(bar, format(%9.0f)) ///
					ytitle("") subtitle("", justification(centre) bexpand size(1)) ///
					title("Daily average expenditure of household by household head type", justification(center) margin(b+4 t-1 l-1) bexpand size(medium))  ///
					note("Source: HIES data. This graph is created for STATA HW by Tanvir Bhai", size(vsmall)) ///
						legend(order(1 "Food" 2 "Fish" 3 "Meat" 4 "Vegetables" 5 "Others") row(1) pos(bottom) size(small)) ///
						ysc(off) ysca(noline) scheme(burd11) //remode y-axis "xsc(off)" for x-axis  ///

graph export "$clean_dir\hh_exp_by_hh_type2.png", replace

