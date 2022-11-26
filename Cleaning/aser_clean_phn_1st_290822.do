/******************************************************************************************************************
*Title: ASER Phone based Validation
*Created by: Md Johirul Islam
*Created on: STATA17
*Last Modified on: 21/11/22
*Last Modified by: MJI
*Purpose : Basic cleaning of phone 1st dataset
*Edits 
	- [MM/DD/YY] - [editor's initials]: Added / Changed....
	
*****************************************************************************************************************/

*Directories
	global base_dir "X:\Google Drive File Stream (johirul.islam@bracu.ac.bd)\My Drive\BIGD\ASER"
	global data_dir				${base_dir}/03_data 
	global raw_data_dir 		${data_dir}/01_raw
	global clean_data_dir		${data_dir}/02_clean
	global analysis_dir   		${base_dir}/04_analysis
	global analysis_do_dir  	${analysis_dir}/01_pgms 
	global analysis_log_dir 	${analysis_dir}/02_logs 
	global analysis_output_dir 	${analysis_dir}/03_output 
	global table 				${analysis_output_dir}/01_tables
	global figure 				${analysis_output_dir}/02_Figures 



*load dataset
use "$raw_data_dir\Phone_based_ASER_Assessment_July_2022_ 7 Sep 2022_clean", clear

*keep if all consent-yes
keep if child_consent==1 & exta_e1==1 & exta_m1==1

*check again for missing val in bq1, eq1, and mq1
mdesc

*de-identifying data
drop enu_code enu_name enu_gen hhh_name child_name_pull mobile_pull num_label mobile_pull2 num_label2 sms_num new_number sms_num_f instancename formdef_version survey_day enum_comment enum_comments starttime submissiondate endtime interviewdate date1 date2 date3 key child_name phone_call call_try2 phone_call2 d1fcall d1fcallyes d1fcallno d1scall d1scallyes d1scallno d2fcall d2fcallyes d2fcallno d2scall d2scallyes d2scallno d3fcall d3fcallyes d3fcallno d3scall d3scallyes d3scallno f_call_status

*merge only those phone_1st in person ids 
merge 1:1 main_id using "$raw_data_dir\for_merge\aser_phn1st_ip_ids.dta" 

*keep only matched ones 
keep if _merge==3

*gen survey mode variable
gen survey_mode = 3 if _merge==3 
la define surv_mod 3"phone first" 
la val survey_mode surv_mod



******************* Household module ****************

*encoding string vars 
	foreach i in 3 5 6 7{
	encode iq`i',gen(iq_`i')
}

foreach x of varlist saq5ot saq5aot saq7ot saq11ot saq12ot{
	encode `x', gen(`x'_1)
}

foreach j of varlist child_grade_21 child_age_pull main_id{
	destring `j', gen(`j'_1)
}

foreach i in 11 12{
	encode saq`i', gen(saq_`i')
}

foreach i in 11 12{
	order saq_`i', after(saq`i')
}

/*
list of strings: iq5 iq7 iq6 iq3 iq8 iq10 treatment saq5ot saq5aot saq7ot saq11ot saq12ot child_grade_21 child_age_pull main_id

*/

*formatting of vars
format %38s iq3
format %56.0g saq5
format %35.0g saq5a
format %50.0g saq6
format %55.0g saq7
format %6.0g child_consent
format %57.0g saq7ot_1
format %60.0g saq11ot_1
format %35.0g saq7
format %14s saq5aot
format %28s saq7ot
format %33s saq11ot
format %10s child_consent_no


**********cleaning/incorporating others section from variables ***

recode saq5 555=2 if saq5ot_1==2 
//private school to private non-residential school

recode saq7 555=.n if inlist(saq7ot_1, 1,2,3,6,9,10,25,26,27)
// recode as .n since sample info is incorrect 

recode saq7 555= 4 if inlist(saq7ot_1, 4,18,21)
recode saq7 555= 1 if inlist(saq7ot_1, 7, 14)

///gen var for vacation and rain category
foreach i in 25 26{
	gen saq11_`i' =.
}
 order saq11_25 saq11_26, after(saq11_24)
 la var saq11_25 "Went for a vacation/feast"
 la var saq11_26 "Because of Rain/Flood" 
 
///vacation part of saq11_ot
replace saq11_25= 1 if inrange(saq11ot_1,5,12) | inlist(saq11ot_1, 14, 45)
replace saq11_25= 0 if saq_11 !=. & saq11_25 !=1
la val saq11_25 yesnom

///rain/flood part of saq11_ot 
replace saq11_26= 1 if inrange(saq11ot_1,15, 24) | inlist(saq11ot_1, 28,40,41) 
replace saq11_26= 0 if saq_11 !=. & saq11_26 !=1
la val saq11_26 yesnom

///cant bear cost 
replace saq11_2 = 1 if saq11ot_1 == 35 

///take care of sick family members
replace saq11_9 = 1 if inlist(saq11ot_1, 25, 27) 

///school is far away 
replace saq11_12 = 1 if inlist(saq11ot_1, 39) 

///isnt motivated to study (before covid)
replace saq11_14 = 1 if inlist(saq11ot_1, 1) 

///works in family business
replace saq11_17 = 1 if inlist(saq11ot_1, 3) 

///not mandatory to go to school every day 
replace saq11_20 = 1 if inlist(saq11ot_1, 26, 37)




*renaming vars
rename iq_5 district
rename iq_6 sub_district
rename iq_7 union
rename iq_3 village
rename idno hh_id 
rename child_age_pull_1 child_age 
rename consent consent_hh



/*
variables needed to be renamed: 
idno child_age_pull_1 consent saq3 saq4 saq5 saq5ot saq5a saq5aot saq6 saq7 saq9 saq10 saq11 saq12

*/


***********renaming test variables according to questionnaire*************
	
	************Bangla module *************
	
	foreach i in 3{
	rename bq`i'_time_use bq1_time
	la var bq1_time "time taken to ans aser bang_word(sec)"
	rename bq`i'_count bq1_score
	la var bq1_score "total score for aser bang_word"
	forval j=1/5 {
	rename bq`i'_`j' bq_1_`j'
	la var bq_1_`j' "ASER Bangla word `j'"
	}
	}

	foreach i in 4{
	rename bq`i'_time_use bq2_time
	la var bq2_time "time taken to ans aser bang_letter(sec)"
	rename bq`i'_count bq2_score
	la var bq2_score "total score of aser bang_letter"
	forval j=1/5 {
	rename bq`i'_`j' bq_2_`j'
	la var bq_2_`j' "ASER Bangla letter `j'"
	}
	}	
	
	foreach i in 1{
	rename bq`i'_`i' bq_3_`i'
	la var bq_3_`i' "ASER Bangla paragraph `i'"
	rename bq`i'_time_use bq3_time
	la var bq3_time "time taken to ans aser bang.para1(sec)"
	rename bq`i'_count bq3_score
	la var bq3_score "total score of aser bangla para1"
	}

	
	foreach i in 2{
	rename bq`i'_1 bq_4_1
	la var bq_4_1 "ASER Bangla paragraph 2"
	rename bq`i'_time_use bq4_time
	la var bq4_time "time taken to ans aser bang para2(sec)"
	rename bq`i'_count bq4_score
	la var bq4_score "total score of aser bang.para2"
	}
	
	forval i=5/8{
	rename bq`i'_time_use bq`i'_time
	la var bq`i'_time "time taken to ans bq`i'(sec)"
	rename bq`i'_count bq`i'_score
	la var bq`i'_score "total score of bq`i'"
	}
	
	forval i=1/8{ 
	order bq`i'_time, after(bq`i'_score)
	}

	label variable bq5_1 "LA_q1_bangla_letter"
	label variable bq6_1 "LA_q2_bangla_spell"
	label variable bq7_1 "LA_q3_bangla_comp1 "
	label variable bq8_1 "LA_q4_bangla_comp2 "
	
	forval i=5/8{
	ren bq`i'_1 bq_`i'_1
	}

	
	*Recoding bqi_score to correct for missing value 
	forval i = 3/8{
	replace bq`i'_score =. if bq_`i'_1 ==. 
	}
	forval i = 1/5{
	replace bq2_score =. if bq_2_`i' ==.
	}
	
	forval i = 1/5{
	replace bq1_score =. if bq_1_`i' ==.	
	}

	***************English module****************
	
	foreach i in 6{
	rename eq`i'_time_use eq9_time
	la var eq9_time "time taken to ans aser eng.word(sec)"
	rename eq`i'_count eq9_score
	la var eq9_score "total score of aser eng.word"
	forval j=1/5 {
	ren eq`i'_`j' eq_9_`j'
	}
	}

	foreach i in 5{
	rename eq`i'_time_use eq10_time
	la var eq10_time "time taken to ans aser eng.letter(sec)"
	rename eq`i'_count eq10_score
	la var eq10_score "total score of aser eng.letter"
	forval j=1/5 {
	rename eq`i'_`j' eq_10_`j'
	}
	}
	
	
	foreach i in 7{
	rename eq`i'_time_use eq11_time
	la var eq11_time "time taken to ans aser eng.word.meaning(sec)"
	rename eq`i'_count eq11_score
	la var eq11_score "total score of aser eng.wm"
	forval j=1/5 {
	rename eq`i'_`j' eq_11_`j'
	}
	}

	foreach i in 8{
	rename eq`i'_time_use eq12_time
	la var eq12_time "time taken to ans aser eng.sent(sec)"
	rename eq`i'_count eq12_score
	la var eq12_score "total score of aser eng.sent"
	forval j=1/4 {
	rename eq`i'_`j' eq_12_`j'
	}
	}
	
	foreach i in 9{
	rename eq`i'_time_use eq13_time
	la var eq13_time "time taken to ans aser eng.sent.meaning(sec)"
	rename eq`i'_count eq13_score
	la var eq13_score "total score of aser eng.sent.meaning"
	forval j=1/4 {
	rename eq`i'_`j' eq_13_`j'
	}
	}	
	
	foreach i in 14{
	foreach j in a b{
	rename eq`i'`j'_time_use eq`i'`j'_time
	la var eq`i'`j'_time "time taken to answer eq`i'`j'(sec)"
	rename eq`i'`j'_count eq`i'`j'_score
	la var eq`i'`j'_score "total score of eq`i'`j'"
	}
	}
	
	*recoding eq_score for missing value 
	foreach i in 14{
		foreach j in a b{
	replace eq`i'`j'_score =. if eq`i'`j'_1 ==.
		}
	}
	
	*labelling
	forval i=15/16{
	rename eq`i'_time_use eq`i'_time
	la var eq`i'_time "time taken to answer eq`i'(sec)"
	rename eq`i'_count eq`i'_score
	la var eq`i'_score "total score of eq`i'"
	}
	
	*recoding eq_score for missing value 
	forval i = 15/16{
	replace eq`i'_score =. if eq`i'_1 ==.
	}
		
	*reordering variables	
	foreach i in 9 10 11 12 13 14a 14b 15 16{ 
	order eq`i'_time,after(eq`i'_score)
	}
	
	*renaming variables 
	foreach i in 14a 14b 15 16{ 
	ren eq`i'_1 eq_`i'_1
	}

*****************Mathematics module**************
	
	foreach i in 12{
	rename mq`i'_time_use mq17_time
	la var mq17_time "time taken to ans aser math.ddr(sec)"
	rename mq`i'_count mq17_score
	la var mq17_score "total score of aser math.ddr"
	forval j=1/5 {
	rename mq`i'_`j' mq_17_`j'
	}
	}
	
	
	foreach i in 13{
	rename mq`i'_time_use mq18_time
	la var mq18_time "time taken to answer aser math.sdr(sec)"
	rename mq`i'_count mq18_score
	la var mq18_score "total score of aser math.sdr"
	forval j=1/5 {
	rename mq`i'_`j' mq_18_`j'
	}
	}
	
	foreach i in 10{
	foreach j in 1 {
	rename mq`i'1_time_use mq19_`j'_time
	la var mq19_`j'_time "time taken to ans mathsub_`j'(sec)"
	rename mq`i'`j'_count mq19_`j'_score
	la var mq19_`j'_score "total score of mathsub_`j'"
	rename mq`i'`j'_1 mq_19_`j'
	la var mq_19_`j' "ASER math sub`j'"
	replace mq19_`j'_score =. if mq_19_`j'==.
	}
	}
	
	
	foreach i in 10{
	foreach j in 2 {
	rename mq`i'`j'_time_use mq19_`j'_time
	la var mq19_`j'_time "time taken to answer mathsub_`j'(sec)"
	rename mq`i'`j'_count mq19_`j'_score
	la var mq19_`j'_score "total score of mathsub_`j'"
	rename mq`i'`j'_1 mq_19_`j'
	la var mq_19_`j' "ASER math sub`j'"
	replace mq19_`j'_score =. if mq_19_`j'==.
	}
	}
	
	
	
	foreach i in 11{
	foreach j in 1 {
	rename mq`i'1_time_use mq20_`j'_time
	la var mq20_`j'_time "time taken to ans mathdiv_`j'(sec)"
	rename mq`i'`j'_count mq20_`j'_score
	la var mq20_`j'_score "total score of mathdiv_`j'"
	rename mq`i'`j'_1 mq_20_`j'
	la var mq_20_`j' "ASER div`j'"
	replace mq20_`j'_score =. if mq_20_`j'==.
	}
	}
	
	
	foreach i in 11{
	foreach j in 2 {
	rename mq`i'`j'_time_use mq20_`j'_time
	la var mq20_`j'_time "time taken to ans mathdiv_`j'(sec)"
	rename mq`i'`j'_count mq20_`j'_score
	la var mq20_`j'_score "total score of mathdiv_`j'"
	rename mq`i'`j'_1 mq_20_`j'
	la var mq_20_`j' "ASER div`j'"
	replace mq20_`j'_score =. if mq_20_`j'==.
	}
	}
	
	
	foreach i in 21 22{
	foreach j in a b{
	rename mq`i'`j'_time_use mq`i'`j'_time
	la var mq`i'`j'_time "time taken to answer mq`i'`j'(sec)"
	rename mq`i'`j'_count mq`i'`j'_score
	la var mq`i'`j'_score "total score of mq`i'`j'"
	}
	}
	
	*recoding for missing value
	foreach i in 21 22{
		foreach j in a b{
		replace mq`i'`j'_score =. if mq`i'`j'_1==.
		}
	}
	
	*ordering variable
	foreach i in 17 18 21a 21b 22a 22b{ 
	order mq`i'_time,after(mq`i'_score)
	}
	
	foreach i in 19_1 19_2 20_1 20_2{ 
	order mq`i'_time, after(mq`i'_score)
	}
	
	*renaming 
	foreach i in 21a 21b 22a 22b{
	ren mq`i'_1 mq_`i'_1
	}
	
	*ordering variable
	foreach i of varlist village district sub_district union{ 
	order `i', after(iq7)
	}
	


*********check for duplicates*
*check
unique main_id

/*
Note: No duplicates. 
*/



**************** Logic Tests **********************
/* 
To check if the values observed in the data make sense given other values.
1. check age and grade consistency
2. check age (5-18)
3. check whether there is any missing values in variables that shouldn't have missing values. 
4. check any anomalies 

*/

*generate var for total score of mq19, mq20, mq21, mq22 , eq14 

///for mq19 
gen mq19_total = mq19_1_score + mq19_2_score 
order mq19_total, after(mq19_2_time)
la var mq19_total "total score of mq19-sub"

///for mq20 
gen mq20_total = mq20_1_score + mq20_2_score 
order mq20_total, after(mq20_2_time)
la var mq20_total "total score of mq20-div"

///for mq21 
gen mq21_total = mq21a_score + mq21b_score 
order mq21_total, after(mq21b_time)
la var mq21_total "total score of mq21"

///for mq22 
gen mq22_total = mq22a_score + mq22b_score 
order mq22_total, after(mq22b_time)
la var mq22_total "total score of mq22"

///for eq14 
gen eq14_total = eq14a_score + eq14b_score 
order eq14_total, after(eq14b_time)
la var eq14_total "total score of eq14"


*check for unwanted missing values 
cls 

mdesc 
//electricity section (q2*,q3, q8) has unwanted missing values 
//age has no missing, but 95 missing values for grade is for those who are not enrolled currently. 


*save the missing value table
translate @Results "$analysis_log_dir\missing_table_aser_phn_1st.txt", replace

*check age and grade inconsistency
fre age if saq6==0 
fre age if saq6==1
fre age if saq6==2

/*
Note: there are 5 children aged 8-9 study in nursery; 4 children aged 11-13 study in class 1; 2 children aged 12 and 14 study in class 2.  
*/






***************Skipping Logic***************
/*
1. assign extended values for skipping variable
2. check whether it is consistent 
3. if inconsistency is found, report in a excel sheet
*/

*identify saq4 skip codes 
unab saq4_skip : saq5 saq5a saq5ot_1 saq5aot_1 saq7ot_1 saq11ot_1 saq6 saq7 saq9 saq10 saq_11 saq11_*
foreach var of local saq4_skip{
	replace `var' = .s if saq4 == 0 
}

///saq4 skipping code for saq12
local vars "saq_12 saq12_1 saq12_2 saq12_3 saq12_4 saq12_5 saq12_6 saq12_7 saq12_8 saq12_9 saq12_10 saq12_11 saq12_12 saq12_13 saq12_14 saq12_15 saq12_16 saq12_17 saq12_18 saq12_19 saq12_555 saq12ot_1" 

foreach x of local vars{
	replace `x' =.s if saq4==1 
}



/*	
** Now check to confirm that 
foreach var of local saq4_skip{
	assert `var' == .s if saq4 == 0

	*Tag variables if this fails
	if _rc == 9 gen `var'_nos = `var' != .s & saq4 == 0

	*Controlling for other options
	else if !_rc di "No errors in `var'"
	else exit _rc // exit with an error if a different error than the assert failing
}
*/


///identify saq5 skipping codes 
replace saq5a = .s if inlist(saq5, 1,2,3,4,10,51,555)
 
///identify saq6 skipping codes 
replace saq7 = .s if saq7 ==. // no need to check for the consistency 

///identify saq10 skipping code 
local vars "saq_11 saq11_1 saq11_2 saq11_3 saq11_4 saq11_5 saq11_6 saq11_7 saq11_8 saq11_9 saq11_10 saq11_11 saq11_12 saq11_13 saq11_14 saq11_15 saq11_16 saq11_17 saq11_18 saq11_19 saq11_20 saq11_21 saq11_22 saq11_23 saq11_24 saq11_25 saq11_26 saq11_555"

foreach x of local vars{
	replace `x' = .s if saq9 == saq10 & saq10 != .s 

}


//////////// Bangla test skipping codes ////////////

///identify bq_1 skipping codes 
forvalues i = 1/5{
	replace bq_2_`i' = .s if bq1_score >=4
}

foreach i in score time{
	replace bq2_`i' = .s if bq1_score >=4
}

///bq1 skipping codes for bq3
replace bq_3_1 = .s if bq1_score <4 
replace bq3_score = .s if bq1_score <4 

///bq2 skipping codes 
local vars "bq_3_1 bq3_score bq3_time bq_4_1 bq4_score bq4_time bq_5_1 bq5_score bq5_time bq_6_1 bq6_score bq6_time bq_7_1 bq7_score bq7_time bq_8_1 bq8_score bq8_time" 

foreach x of local vars{
	replace `x' = .s if bq2_score != .s & bq2_score !=. 
}

///bq3 skipping codes 
replace bq_4_1 = .s if bq3_score== 0 
replace bq4_score = .s if bq3_score==0 


////////////////// English test skipping codes ////////////////

///eq9 skipping codes 
forvalues i = 1/5{
	replace eq_10_`i' = .s if eq9_score >=4 
}
foreach i in score time{
	replace eq10_`i' = .s if eq9_score >=4 
}

///eq10 skipping codes 
local vars "eq_11_1 eq_11_2 eq_11_3 eq_11_4 eq_11_5 eq11_score eq11_time eq_12_1 eq_12_2 eq_12_3 eq_12_4 eq12_score eq12_time eq_13_1 eq_13_2 eq_13_3 eq_13_4 eq13_score eq13_time eq_14a_1 eq14a_score eq14a_time eq_14b_1 eq14b_score eq14b_time eq14_total eq_15_1 eq15_score eq15_time eq_16_1 eq16_score eq16_time"

foreach x of local vars{
	replace `x' = .s if eq10_score !=.s & eq10_score !=. 
}


///eq11 skipping codes 
forvalues i = 1/4{
	foreach j in 12 13{
		replace eq_`j'_`i' = .s if eq11_score <4 
	}
}

foreach i in score time{
	foreach j in 12 13{
		replace eq`j'_`i' = .s if eq11_score <4
	}
}

///eq12 skipping codes 
forvalues i = 1/4{
	replace eq_13_`i' = .s if eq12_score <3 
}

foreach i in score time{
	replace eq13_`i' = .s if eq12_score <3 
}



////////////////// Math skipping codes ////////////

///mq17 skipping code 
forvalues i = 1/5{
	replace mq_18_`i' = .s if mq17_score >=4 
}
foreach i in score time{
	replace mq18_`i' = .s if mq17_score >=4  
}

///mq18 skipping code 
local vars "mq_19_1 mq19_1_score mq19_1_time mq_19_2 mq19_2_score mq19_2_time mq19_total mq_20_1 mq20_1_score mq20_1_time mq_20_2 mq20_2_score mq20_2_time mq20_total mq_21a_1 mq21a_score mq21a_time mq_21b_1 mq21b_score mq21b_time mq21_total mq_22a_1 mq22a_score mq22a_time mq_22b_1 mq22b_score mq22b_time mq22_total"

foreach x of local vars{
	replace `x' = .s if mq18_score !=.s & mq18_score !=.
}


///mq19 skipping code 

*assigning skipping codes 
local vars "mq_20_1 mq20_1_score mq20_1_time mq_20_2 mq20_2_score mq20_2_time mq20_total"

foreach x of local vars{
	replace `x' =.s if mq19_total <1 
}



*save the data 
save "$clean_data_dir\aser_phn_1st_cleaned.dta", replace 


