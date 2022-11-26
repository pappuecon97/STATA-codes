/******************************************************************************************************************
*Title: ASER Phone based Validation-In person
*Created by: Md Johirul Islam
*Created on: STATA17
*Last Modified on: 17/11/22
*Last Modified by: MJI
*Purpose : Creating a master dataset 
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

*clear 
clear
cls 
	
*append in-person, phn 1st, and phn later dataset
append using "$clean_data_dir\aser_ip_cleaned.dta" ///
				"$clean_data_dir\aser_phn_1st_cleaned.dta" ///
				"$clean_data_dir\aser_phn_later_cleaned.dta", force //ignore str-numeric mismatch 

*drop merge 
drop _merge 

*label survey mode value 
label define phn_ip 3"phone first" 4"phone later", modify 

*order vars
order exta_e1 exta_e1_no, after(bq8_time)
order exta_m1, after(eq16_time)	
				
*save data 
save "$clean_data_dir\aser_cleaned_master_dataset", replace 



				