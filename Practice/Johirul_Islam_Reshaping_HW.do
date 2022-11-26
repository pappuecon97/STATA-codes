/******************************************************************************
*Title: Homework of STATA III class by Tanvir bhaiya
*Created by: Md Johirul Islam
*Created on: STATA15
*Last Modified on: 06/08/22
*Last Modified by: MJI
*Purpose : Reshaping data from wide to long and viceversa 	
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

*keep relevant variables
keep hhold-s1aq06

*check duplicates in the id
codebook hhold

*check where the exact duplicates are
duplicates tag hhold, gen(dup)
tab dup

*check direct duplicates
duplicates report hhold

*remove duplicates
duplicates drop  hhold s1aq00, force

*********Reshaping from long to wide ***********

*Check missing var in the suffix var
mdesc 

*remove missing val from Id code var
drop if s1aq00==.

*drop respondent id
drop s1aq0a

*reshape from long to wide
reshape wide s1aq01 s1aq02 s1aq03 s1aq04 s1aq05 s1aq06, i(hhold) j(s1aq00)


*save the reshaped data (long to wide)
save "HIES_wide.dta", replace


******************Reshaping from wide to long ********************
reshape long s1aq01 s1aq02 s1aq03 s1aq04 s1aq05 s1aq06, i(hhold) j(Member_id)

*remove missing obs because of the reshaping
drop if s1aq01==.

*save the reshaped (wide to long)
save "HIES_long.dta", replace

