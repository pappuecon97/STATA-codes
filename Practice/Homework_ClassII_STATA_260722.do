/******************************************************************************
*Title: Homework of STATA II class by Tanvir bhaiya
*Created by: Md Johirul Islam
*Created on: STATA15
*Last Modified on: 26/07/22
*Last Modified by: MJI
*Purpose : Creating categorical variables using condition	
******************************************************************************/

*********Housekeeping **********
clear all
set more off
version 15

**** Current directory
cd "G:\My Drive\YRF Class"

*****Global directory
global data_HH "G:\My Drive\YRF Class\STATA\Data\HH_SEC_1A.dta"

*load dataset
use "$data_HH", clear

*keep required variables for the homework
keep s1aq00 s1aq01 s1aq03 s1aq05 

********create var for male marrital status*************

gen male_st =. 
replace male_st = 1 if s1aq01 == 1 & s1aq05 ==1
replace male_st = 0 if s1aq01 == 1 & s1aq05 !=1

*replace missing values of male_st by extended missing values
replace male_st = .n if male_st==.

*labelling variable name
label var male_st "Male marital status"

*labelling value
label define marr_st 1"Married" 0"Unmarried/Others" .n"Not Applicable"
label val male_st marr_st

************ create var for female marrital status *********

gen female_st =.
replace female_st = 1 if s1aq01 == 2 & s1aq05 ==1
replace female_st = 0 if s1aq01 == 2 & s1aq05 !=1

*replace missing values of female_st by extended missing values
replace female_st = .n if female_st==.

*labelling variable name
label var female_st "Female marital status"

*labelling value
label val female_st marr_st

**********Create var for age group **********

gen age_grp = 1 if s1aq03<=12 
replace age_grp = 2 if s1aq03>=13 & s1aq03 <=19
replace age_grp = 3 if s1aq03>=20 & s1aq03 <=40 
replace age_grp = 4 if s1aq03>=40 & s1aq03 <.

*labelling variable name
label var age_grp "Age by category"

*labelling value
label define age_la 1"Child" 2"Teen" 3"Youth" 4"Old"
label val age_grp age_la

*browse data
br

*tabulate by age and male marital st
tab age_grp male_st

*tabulate by age and female marital st
tab age_grp female_st

*save new dataset
save "Stata_ClassII_HHdta.dta", replace





