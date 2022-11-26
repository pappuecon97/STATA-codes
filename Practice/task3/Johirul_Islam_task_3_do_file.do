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

*******************Crunching household roster ********************

***load data 
use "$data_H_roster", clear 

*keep required vars
keep hhold s1aq00 s1aq01 s1aq02

*gen var for number of hh male and female member. 
gen fem = 1 if s1aq01 ==2
gen male = 1 if s1aq01 ==1


*gen var for hhold head
gen hh_type =1 if s1aq01 ==1 & s1aq02==1 
replace hh_type=0 if s1aq01 ==2 & s1aq02==1 

*calculate per hh number of members
bys hhold: gen per_hh_mem = _N

*collapse
collapse (sum) fem male (first) hh_type per_hh_mem, by(hhold)

*label value of hh_type
la define hh_type_la 1"Male Head" 0"Female Head"
la val hh_type hh_type_la

*drop missing var of hh_type
drop if hh_type==.

*drop duplicates in id
duplicates drop hhold, force

*save the hh_roster dataset
save "$clean_dir/hh_roster.dta", replace 


****************Crunching consumption dataset *****************

*load dataset for consumption 
use "$data_H_cons", clear 

*keep required vars
keep hhold item s9a2q04

*drop anomalies
drop if item == 25 & item == 999

*rename vars
rename s9a2q04 value

*sorting vars by hhold and item
sort hhold item 

*collaspe by hhold and item
collapse (sum) value, by(hhold item)

*create var for food grain, fish, 
gen f_cat = 1 if inrange(item, 11, 24)
replace f_cat = 2 if inrange(item, 41, 58)
replace f_cat = 3 if inrange(item, 71,77)
replace f_cat = 4 if inrange(item, 81, 89) | inrange(item, 91,97)
replace f_cat = 5 if inrange(item, 30, 36) | inrange(item, 60, 63) | inrange(item, 100,237)

*label f_cat val
la define f_cat_la 1"food_grain" 2"fish" 3"meat" 4"veg" 5"Others"
la val f_cat f_cat_la

*collapse by hhold
collapse (sum) value, by(hhold f_cat)

************Reshaping data ***************

*check for missing id
mdesc

*drop missing f_cat values
drop if f_cat==.

*reshape from long to wide 
reshape wide value, i(hhold) j(f_cat)

*renaming new vars
rename value1 exp_food
rename value2 exp_fish 
rename value3 exp_meat
rename value4 exp_veg
rename value5 exp_others

*label vars
la var exp_food 	"Expenditure on food grain"
la var exp_fish 	"Expenditure on fish"
la var exp_meat 	"Expenditure on meat"
la var exp_veg 		"Expenditure on vegetables"
la var exp_others 	"Expenditure on others"


*save the hh consumption dataset
save "$clean_dir/hh_cons_cln.dta", replace 


*********************** Merging two datasets ***************************
/*
egen ID=concat(main_id se_slno), punct("_")
*/

*merge
merge 1:1 hhold using "$clean_dir/hh_roster.dta" 
list 

*order by hhold and hh_type
order hhold hh_type per_hh_mem

*keep just male headed and female headed household
drop if hh_type==.

*drop unnecessary vars
drop _merge

*save merged dataset
save "$clean_dir/merged_hies_cons.dta", replace


********************Analysis ******************

*total expenditure for a hh
egen total_exp = rowtotal(exp_food exp_fish exp_meat exp_veg exp_others)

*per capita hh exp
gen percap_hh = total_exp/per_hh_mem

*food_grain exp summary
summ exp_food if hh_type==1
summ exp_food if hh_type==0
summ exp_food

*fish summary
summ exp_fish if hh_type==1
summ exp_fish if hh_type==0
summ exp_fish

*meat summary
summ exp_meat if hh_type==1
summ exp_meat if hh_type==0
summ exp_meat

*veg summary
summ exp_veg if hh_type==1
summ exp_veg if hh_type==0
summ exp_veg

*other exp summary
summ exp_others if hh_type==1
summ exp_others if hh_type==0
summ exp_others

*total_exp summary
summ total_exp if hh_type==1
summ total_exp if hh_type==0
summ total_exp

*per cap exp summary 
summ percap_hh if hh_type==1
summ percap_hh if hh_type==0
summ percap_hh

*total per cap hh expenditure
egen tot_ppexp =total(percap_hh)

*save final_data
save "$clean_dir/final_hies.dta", replace


