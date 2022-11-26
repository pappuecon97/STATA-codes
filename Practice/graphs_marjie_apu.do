/******************************************************************************************************************
*Title: Back-to-school
*Created by: Marjan Hossain
*Created on: STATA17
*Last Modified on: 5/07/22
*Last Modified by: MH
*Purpose : Graphical analysis
*Edits 
	- [MM/DD/YY] - [editor's initials]: Added / Changed....
	
*****************************************************************************************************************/
**** Assigning directories
		if  "`c(username)'"=="KWR" {
	
			global base_dir  
			
	}	
	
	if  "`c(username)'"=="User" {
	
	global base_dir  G:\My Drive\Econ_cluster\b2s
			
	}
	
	*Directories	
	global data_dir				${base_dir}/03_data 
	global raw_data_dir 		${data_dir}/01_raw/compiled
	global other_data_dir 		${data_dir}/01_raw/childfile
	global clean_data_dir		${data_dir}/02_clean
	global analysis_dir   		${base_dir}/04_analysis
	global analysis_do_dir  	${analysis_dir}/01_pgms 
	global analysis_log_dir 	${analysis_dir}/02_logs 
	global analysis_output_dir 	${analysis_dir}/03_output 
	global table 				${analysis_output_dir}/01_Tables/01_Unformatted
	global figure 				${analysis_output_dir}/02_Figures 

	*Setting colorschemes
	set scheme plottigblind, permanently
	grstyle init
	grstyle color background white

	global skyblue "86 180 233"
	global blue "0 114 178"
	global teal "17 222 245"
	global orange "213 94 0"
	global green "0 158 115"
	global yellow "230 159 0"
	global purple "204 121 167"
	global lavendar "154 121 204"
	global cherry "200 0 0"
    global tangerine "255 86 29"
	global peach "251 162 127"
	global blueberry "64 105 166"
	global slate "106 90 205" 
	global peank "219 112 147"
	
	global qual1 "228 26 28" 
	global qual2 "55 126 184" 
	global qual3 "77 175 74" 
	global qual4 "255 127 0"
	
	 
	
	**sequential color
	global blue1 "158 202 225"
	global blue2 "66 146 198"
	global blue3 "8 81 156"
	
	global purple1 "188 189 220"
	global purple2 "128 125 186"
	global purple3 "84 39 143"
	


	
	
	use "$raw_data_dir/allhh.dta", clear 

*encoding/destringing string variables
	foreach i in iq3 iq4 iq5 iq6 iq7 iq9 iq10 { 
	encode `i', gen(`i'_)
	}

	*renaming and relabelling variables
	ren iq3_ mouza
	ren iq4_ div
	ren iq5_ dist
	ren iq6_ subdist
	ren iq7_ union
	ren iq9_ vill
	ren iq10_ address

	destring childcount, gen(child_count)
	
	la var div "Division's Name "
	la var dist "District's Name"
	la var subdist "Sub-district Name"
	la var union "Union Name"
	la var vill "Village Name"
	
	*renaming and formatting variables
	ren (saq2_1 saq3_1 saq4_1 saq6_1 saq7_1) (resp_name age gender edu_status marital_status)
	
	order key psu main_id idno rmo div dist subdist union vill tot_mem resp_name age gender edu_status marital_status scq23 scq20 scq24_2 scq24_5 scq24_6 scq24_7  child_5_18
	
	
	keep key psu main_id idno rmo div dist subdist union vill tot_mem resp_name age gender edu_status marital_status scq23 scq20 scq24_2 scq24_5 scq24_6 scq24_7 child_5_18
	
	*categorising strata
	recode rmo (1=1 "Rural") (2/9=2 "Urban"), gen(strata)
	
	*categorising education status
	recode edu_status (0 33 50=0 "No formal education") (1/5=1 "Primary") (6/11=2 "Secondary") ///
	(12/14=3 "Higher Secondary.") (15/18=4 "Tertiary") (-999=.), gen(hhedu)
	
	gen internet=1 if scq24_6==1|scq24_7==1
	recode internet .=0
	la val internet internet
	la def internet 1 "Has internet access"
	order internet scq24_6 scq24_7 

	
	*Sample characteristics: Household level: Table1
	eststo clear
	estpost tab div  
	esttab using "$analysis_output_dir\other.csv", cell("b(label(freq)) pct(fmt(2)label(% distribution))") unstack modelwidth(10)varlabels(`e(labels)') eqlabels(`e(eqlabels)') replace

	foreach i in strata gender hhedu marital_status scq23 scq20 scq24_2 internet{
	eststo clear
	estpost tab `i'  
	esttab using "$analysis_output_dir\other.csv", cell("b(label(freq)) pct(fmt(2)label(% distribution))") unstack modelwidth(10)varlabels(`e(labels)') eqlabels(`e(eqlabels)') append 		
	}

	eststo clear	
	
	sum age tot child_5_18
	bys strata: sum tot child_5_18

	*Sample characteristics: Child level 
	use "$clean_data_dir/section_E.dta", clear 
	recode enrol21 (0/999=999) if enrol20==999|enrol19==999

	drop if enrol21==999
	eststo clear
	estpost tab gender  
	esttab using "$analysis_output_dir\child.csv", cell("b(label(freq)) pct(fmt(2)label(% distribution))") unstack modelwidth(10)varlabels(`e(labels)') eqlabels(`e(eqlabels)') replace

	
	foreach i in bc_status marital_status{
	eststo clear
	estpost tab `i'  
	esttab using "$analysis_output_dir\child.csv", cell("b(label(freq)) pct(fmt(2)label(% distribution))") unstack modelwidth(10)varlabels(`e(labels)') eqlabels(`e(eqlabels)') append 		
	}
	eststo clear
	
	sum age21
	
	
	
	
	*use "$clean_data_dir/sece_enrol_classes.dta", clear 
	///////////////cleaning//////////////////
	//////enrolment status as per framework
/*
	recode enrol21 (0/999=999) if enrol20==999|enrol19==999
	
	
	
	gen enrol_stat=.
	recode enrol_stat .=1 if enrol19==1 & enrol20==1 & enrol21==1

	//enrolled in 2019 or 2020 and 2021
	recode enrol_stat .=2 if enrol19==0 & enrol20==1 & enrol21==1
	recode enrol_stat .=4 if enrol19==1 & enrol20==0 & enrol21==1

	//enrolled only in 2021
	recode enrol_stat .=3 if enrol19==0 & enrol20==0 & enrol21==1


	///enrolled in 2019 but not 2021
	recode enrol_stat .=5 if enrol19==1 & enrol20==0 & enrol21==0
	//enrolled in 2019/2020 but not 2021
	recode enrol_stat .=6 if enrol19==1 & enrol20==1 & enrol21==0
	///enrolled in 2020 but not in 2021
	recode enrol_stat .=7 if enrol19==0 & enrol20==1 & enrol21==0

	//never enrolled
	recode enrol_stat .=8 if enrol19==0 & enrol20==0 & enrol21==0

	la val enrol_stat enrol_stat
	la def enrol_stat 1 "Always enrolled" 6 "Exit_2021" 4 "Break_2020" 5 "Exit_2020" 2 "Entry_2020" 7 "Entry_exit_2020" 3 "Entry_2021" 8 "Never enrolled"

	
	recode enrol_stat (1 2 3 4=1 "Enrolled in 2021") (5/7=2 "Not enrolled in 2021") (8=4 "Not enrolled 2019-21"), gen(enrolms)


	tab enrolms

	
	
	*categorising age
	recode age21 (5/11=1 "5 to 11") (12/18=2 "12-18"), gen(age)
	la var age "Children's age"
	
	la val gender gender gender
	la def gender 1 "Boys" 2 "Girls", modify
	
	
	recode level21 (50 999=.)
	
	*categorising strata
	recode rmo (1=1 "Rural") (2/9=2 "Urban"), gen(strata)
	
	
	*/
	
	*enrolment status: add to table 1
	tab enrolms
	
		*enrolment status broken down: Graph 1
		loc i = 1
	 foreach j in age gender strata{
	**options for graph
		if `i' ==3 loc legg `"legend(on cols(1) row(1) pos(6) size())"'
		if `i' ==1 loc legg `"legend(off cols(1) row(3) pos(6) size())"'
		if `i' ==1 loc axis `"ylabel(none, nolabels nogrid) "'
		*if `i' == 1 loc axis `"yla(none) "'
		if `i' ==1 loc note `""'
		lab var enrolms `"`=upper("`j'")'"'
			
			
	**graph    
	catplot enrolms, over(`j', gap(50) label(labsize(med) labcolor(black))) percent(`j') asyvars ///
	stack	showyvars recast(hbar) legend(off) `legg' blabel(bar, position(center) size(small) color (black) format(%3.1f)) ///
		bar(1, bcolor("$qual3")) bar(2, bcolor("$yellow")) ///
		bar(3, bcolor("$peank")) bar(4, bcolor("$orange")) ///
		bar(5, bcolor("$cherry")) bar(6, bcolor("$peank")) ///
		bar(7, bcolor("$")) bar(8, bcolor("$")) ///
		name(enragegenb2s`i', replace) `axis'  plotregion(fcolor(white) lcolor(none)) l1title("`=upper("`j'")'", margin(0 0 0 0 )) ytitle("") yscale(noline)  
			loc plots1b `"`plots1b' enragegenb2s`i' "'
			loc `++i'
		  }	  
		   
		  
	gr combine `plots1b', colfirst ycommon cols(1) imargin(zero) graphregion(margin(r=15 l=15))
 	graph export "${figure}/enrolall.png", replace

		  
		  
	***Another way of depicting enrolment categories
		  
		/*  tab enrolms,gen(enrolms)
		  
		  recode enrolms1-enrolms3 (1=100)
		  la var enrolms1 "Enrolled in 2021"
		  la var enrolms2 "Not Enrolled in 2021"
		  la var enrolms3 "Not enrolled in 2019-21"
		  
		  tab enrolms1*/
		
	*Age and gender and povcat
	graph hbar enrolms1-enrolms3 if gender==1, over(povcat, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enolpov1, replace) nodraw
	
	graph hbar enrolms1-enrolms3 if gender==2, over(povcat, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enolpov2, replace) nodraw
	
		
		graph hbar enrolms1-enrolms3 if age==1, over(povcat, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enolpov3, replace) nodraw
	
		graph hbar enrolms1-enrolms3 if age==2, over(povcat, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enolpov4, replace) nodraw
	
		
		
	
	grc1leg enolpov1 enolpov2 enolpov3 enolpov4, colfirst iscale(*1.02) legendfrom(enolpov1) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

		
		
		
		
		
	*Age and gender
	graph hbar enrolms1-enrolms3 if gender==1, over(strata, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enol1, replace) nodraw
	

	graph hbar enrolms1-enrolms3 if gender==2, over(strata, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enol2, replace) nodraw	
	
		graph hbar enrolms1-enrolms3, over(strata, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enol3, replace) nodraw
	
	graph hbar enrolms1-enrolms3, over(gender, gap(5) ) ///
	asyvars legend (label(1 "Enrolled in 2021 ") label(2 "Not Enrolled in 2021") label(3 "Not enrolled in 2019-21")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	name(enol4, replace) nodraw
	
	

	grc1leg enol1 enol2 enol3 enol4, colfirst iscale(*1.02) legendfrom(enol1) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
	*exploring the highest education qualification if they've not enrolled in 2021, after which they exited.
	/*clonevar exitgrade=edu_status if enrolms==2
	recode exitgrade (33=0) 
	recode exitgrade (0=1) if main_id=="1707_4"
	
	
	clonevar nevergrade=edu_status if enrolms==4
	
*/
	recode exitgrade (0=0 "Pre-Primary/below grade 1") (1/4=1 "Grade 1-4") (5=2 "Grade 5") (6/10=3 "Grade 6-10") (11/14=4 "SSC/HSC") (50=.), gen(droplevel)
	

	recode nevergrade (0=0 "Pre-Primary/below grade 1") (1/4=1 "Grade 1-4") (5=2 "Grade 5") (6/10=3 "Grade 6-10") (11/14=4 "SSC/HSC") (50=.) (33=33 "Never went to school"), gen(never)

	tab never

	//Table 2
	tab droplevel
	
	
		*exit levels broken down: Graph 2-for not enrolled in 2021
		loc i = 1
	 foreach j in gender{
	**options for graph
		if `i' ==3 loc legg `"legend(off cols(1) row(2) pos(6) size())"'
		if `i' ==1 loc legg `"legend(off cols(1) row(3) pos(6) size())"'
		if `i' ==1 loc axis `"ylabel(none, nolabels nogrid) "'
		*if `i' == 1 loc axis `"yla(none) "'
		if `i' ==1 loc note `""'
		lab var droplevel `"`=upper("`j'")'"'
			
			
	**graph    
	catplot droplevel, over(`j', gap(50) label(labsize(small) labcolor(black))) percent(`j') asyvars ///
		 showyvars recast(hbar) legend(off) `legg' blabel(bar, position(outside) size(small) color (black) format(%3.1f)) ///
		bar(1, bcolor("$qual3")) bar(2, bcolor("$skyblue")) ///
		bar(3, bcolor("$yellow")) bar(4, bcolor("$orange")) ///
		bar(5, bcolor("$cherry")) bar(6, bcolor("$peank")) ///
		bar(7, bcolor("$")) bar(8, bcolor("$")) ///
		name(exitgrade`i', replace) `axis'  plotregion(fcolor(white) lcolor(none)) l1title("`=upper("`j'")'", margin(0 0 0 0 )) ytitle("") yscale(noline)  
			loc plots1eb `"`plots1eb' exitgrade`i' "'
			loc `i'
		  }	  
		   
		  
	gr combine `plots1eb', colfirst ycommon cols(1) imargin(zero) graphregion(margin(r=15 l=15))
 	*graph export "${figure}/exitgrade.png", replace
	
	
	
		*never enrolled  levels broken down: Graph 3
		loc i = 1
	 foreach j in gender {
	**options for graph
		if `i' ==2 loc legg `"legend(off cols(1) row(2) pos(6) size())"'
		if `i' ==1 loc legg `"legend(off cols(1) row(3) pos(6) size())"'
		if `i' ==1 loc axis `"ylabel(none, nolabels nogrid) "'
		*if `i' == 1 loc axis `"yla(none) "'
		if `i' ==1 loc note `""'
		lab var never `"`=upper("`j'")'"'
			
			
	**graph    
	catplot never, over(`j', gap(50) label(labsize(small) labcolor(black))) percent(`j') asyvars ///
	 showyvars recast(hbar) legend(off) `legg' blabel(bar, position(outside) size(small) color (black) format(%3.1f)) ///
		bar(1, bcolor("$qual3")) bar(2, bcolor("$skyblue")) ///
		bar(3, bcolor("$yellow")) bar(4, bcolor("$orange")) ///
		bar(5, bcolor("$cherry")) bar(6, bcolor("$peank")) ///
		bar(7, bcolor("$")) bar(8, bcolor("$")) ///
		name(never`i', replace) `axis'  plotregion(fcolor(white) lcolor(none)) l1title("`=upper("`j'")'", margin(0 0 0 0 )) ytitle("") yscale(noline)  
			loc plots1eb `"`plots1eb' never`i' "'
			loc `i'
		  }	  
		   
		  
	gr combine `plots1eb', colfirst ycommon cols(1) imargin(zero) graphregion(margin(r=15 l=15))
 	graph export "${figure}/exitgrade.png", replace
	
	
	
	
*	recode age21 (5/7=1 "5-7") (8/10=2 "8-10") (11/13=3 "11-13") (14/16=4 "14-16") (17/18=5 "16+"), gen(Age)

	
	
	
			*exit levels broken down: Graph 2-for not enrolled in 2021
		loc i = 1
	 foreach j in Age{
	**options for graph
		if `i' ==3 loc legg `"legend(off cols(1) row(1) pos(6) size())"'
		if `i' ==1 loc legg `"legend(off cols(1) row(3) pos(6) size())"'
		if `i' ==1 loc axis `"ylabel(none, nolabels nogrid) "'
		*if `i' == 1 loc axis `"yla(none) "'
		if `i' ==1 loc note `""'
		lab var droplevel `"`=upper("`j'")'"'
			
			
	**graph    
	catplot droplevel, over(`j', gap(50) label(labsize(small) labcolor(black))) percent(`j') asyvars ///
		stack showyvars recast(hbar) legend(off) `legg' blabel(bar, position(center) size(small) color (black) format(%3.1f)) ///
		bar(1, bcolor("$qual3")) bar(2, bcolor("$skyblue")) ///
		bar(3, bcolor("$yellow")) bar(4, bcolor("$orange")) ///
		bar(5, bcolor("$cherry")) bar(6, bcolor("$peank")) ///
		bar(7, bcolor("$")) bar(8, bcolor("$")) ///
		name(exitgrades`i', replace) `axis'  plotregion(fcolor(white) lcolor(none)) l1title("`=upper("`j'")'", margin(0 0 0 0 )) ytitle("") yscale(noline)  
			loc plots1eccb `"`plots1eccb' exitgrades`i' "'
			loc `i'
		  }	  
		   
		  
	*gr combine `plots1eb', colfirst ycommon cols(1) imargin(zero) graphregion(margin(r=15 l=15))
 	*graph export "${figure}/exitgrade.png", replace
	
	
	
		*never enrolled  levels broken down: Graph 3
		loc i = 1
	 foreach j in Age{
	**options for graph
		if `i' ==1 loc legg `"legend(off cols(1) row(1) pos(6) size())"'
		if `i' ==1 loc legg `"legend(off cols(1) row(3) pos(6) size())"'
		if `i' ==1 loc axis `"ylabel(none, nolabels nogrid) "'
		*if `i' == 1 loc axis `"yla(none) "'
		if `i' ==1 loc note `""'
		lab var never `"`=upper("`j'")'"'
			
			
	**graph    
	catplot never, over(`j', gap(50) label(labsize(small) labcolor(black))) percent(`j') asyvars ///
	stack showyvars recast(hbar) legend(off) `legg' blabel(bar, position(center) size(small) color (black) format(%3.1f)) ///
		bar(1, bcolor("$qual3")) bar(2, bcolor("$skyblue")) ///
		bar(3, bcolor("$yellow")) bar(4, bcolor("$orange")) ///
		bar(5, bcolor("$cherry")) bar(6, bcolor("$peank")) ///
		bar(7, bcolor("$")) bar(8, bcolor("$")) ///
		name(nevers`i', replace) `axis'  plotregion(fcolor(white) lcolor(none)) l1title("`=upper("`j'")'", margin(0 0 0 0 )) ytitle("") yscale(noline)  
			loc plots1eccb `"`plots1eccb' nevers`i' "'
			loc `i'
		  }	  
		   
		  
	gr combine `plots1eccb', colfirst ycommon cols(1) imargin(zero) graphregion(margin(r=15 l=15))
 	graph export "${figure}/exitgradess.png", replace
	
	
	
	

	
	
	*reasons for not being currently admitted
	mrtab seq45m_1-seq45m_555, by(gender) col sort des
	
	
	
	
	


		///Table 3

		recode class20 (0 2=0) (1=1), gen(online)
		gen attendance=.
		recode attendance (.=1) if online==0 & att21==0 
		recode attendance (.=3) if online==0 & att21==1
		recode attendance (.=3) if class20==. & att21==1 
		recode attendance (.=1) if online==1 & att21==0
		recode attendance (.=1) if class20==. & att21==0 
		recode attendance (.=4) if online==1 & att21==1

		
		
	

		
		la val attendance attendance


		la def attendance 1 "No online/in-person classes/Irregular" 3 "No online/regular in-person" 4 "Both online/regular in-person", modify
		
	order enrol21 enrolms attendance days21 class20 online 
		
	recode enrol21 att21 class21 (999=.)
	
	tab class21
	tab attendance
	

	*/
	
	///figure 3

	

	tab attendance, gen (atten_)
	recode atten_1-atten_3 (1=100)
			///disaggregating over gender and strata
	
	graph hbar atten_1-atten_3, over(gender, gap(10)) over(age, gap(50)) ///
	  stack asyvars nofill legend (off label(1 "No/irregular class attendance") label(2 "No Online/regular inperson") label(3 "Both online/regular inperson")) ///
	ysca(noline) ylabel(none) blabel(bar, format(%4.1f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$qual3")) ///
	bar(5, bcolor("$skyblue")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white))graphregion(margin(r=20 l=15)) ///
name(attend11, replace)   
	
	graph hbar atten_1-atten_3, over(gender, gap(10)) over(strata, gap(50)) ///
	  stack asyvars nofill legend (off label(1 "No/irregular class attendance") label(2 "No Online/regular inperson") label(3 "Both online/regular inperson")) ///
	ysca(noline) ylabel(none) blabel(bar, format(%4.1f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(attend22, replace) 
	
	 	grc1leg attend11 attend22, colfirst iscale(*1.02) legendfrom(attend11) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=20 l=15))

	
	
	
	
	
	
	

	
	
	
	
	
	
	
	

	
	//tech 

	*categorising age
	*recode age21 (5/11=1 "5 to 11") (12/18=2 "12-18"), gen(age)
	*la var age "Children's age"
	
	*la val gender gender gender
	*la def gender 1 "Boys" 2 "Girls", modify
	
	*recode level21 (50 999=.)
	
	*categorising strata
	*recode rmo (1=1 "Rural") (2/9=2 "Urban"), gen(strata)

	*order scq24c_1 scq24c_2 scq24c_3 scq24c_4 scq24c_5 scq24c_6 scq24c_7  
	*order scq24d_1 scq24e_1 scq24d_3 scq24d_7 scq24e_7 scq24e_3 scq24e_2 scq24d_2 scq24d_4 scq24e_4 scq24d_5 scq24e_5 scq24d_6 scq24e_6

	/*ren (scq24c_1 scq24c_2 scq24c_3 scq24c_4 scq24c_5 scq24c_6 scq24c_7) (radio tv button smart comp wifi mdata)
	
	
	*generating variables for children with access
	gen inter=.
	recode inter .=1 if wifi==1|mdata==1
	recode inter .=0 if wifi==0|mdata==0
	recode inter .=2 if wifi==. & mdata==.


	
	foreach i in radio tv button smart comp{
	 recode `i' (1=1 "Has access") (0=2 "HH access/no child access") (.=3 "No HH/child access"), gen(`i'_ch)
	 tab `i'_ch
	 recode `i'_ch (0/2=.) if enrol21==999
	 tab `i'_ch
	 clonevar `i'_21=`i'_ch if enrol21==1
	 tab `i'_21
	}
	
		foreach i in inter{
	 recode `i' (1=1 "Has access") (0=2 "HH access/no child access") (2=3 "No HH/child access"), gen(`i'_ch)
	 tab `i'_ch
	 recode `i'_ch (0/2=.) if enrol21==999
	 tab `i'_ch
	 clonevar `i'_21=`i'_ch if enrol21==1
	 tab `i'_21
	}
	*/
		foreach i in radio tv button smart inter comp{
	 tab `i'_21 
	}
	
	
	///disaggregating by age
	
	foreach i in tv button smart inter{
	graph hbar (percent), over(`i'_21, gap(5)) over(age, gap(50)) ///
	stack percentages asyvars legend (off label(1 "Has access") label(2 "HH access/no child access") label(3 "No HH/child access") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$qual3")) bar(2, bcolor("$yellow")) bar(3, bcolor("$peank")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(`i', replace) nodraw	   
	}

 	grc1leg tv button smart inter, colfirst iscale(*1.02) legendfrom(tv) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
	///disaggregating by gender
	
	foreach i in tv button smart inter{
	graph hbar (percent), over(`i'_21, gap(5)) over(gender, gap(50)) ///
	stack percentages asyvars legend (off label(1 "Has access") label(2 "HH access/no child access") label(3 "No HH/child access") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$qual3")) bar(2, bcolor("$yellow")) bar(3, bcolor("$peank")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(`i'_gen, replace) nodraw
	   }

 	grc1leg tv_gen button_gen smart_gen inter_gen, colfirst iscale(*1.02) legendfrom(tv_gen) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	 grc1leg tv tv_gen button button_gen smart smart_gen inter inter_gen, colfirst iscale(*1.02) legendfrom(tv_gen) ycommon xcommon cols(2) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	///disaggregating over gender and strata
	foreach i in tv button smart inter{
	graph hbar (percent), over(`i'_21, gap(5)) over(gender, gap(50)) over(strata, gap(200)) ///
	stack percentages asyvars legend (off label(1 "Has access") label(2 "HH access/no child access") label(3 "No HH/child access") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$qual3")) bar(2, bcolor("$yellow")) bar(3, bcolor("$peank")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(`i'_genst, replace) nodraw   
	}

 	grc1leg tv_genst button_genst smart_genst inter_genst, colfirst iscale(*1.02) legendfrom(tv_genst) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
	
	///disaggregating by age and gender
	foreach i in tv button smart inter{
	graph hbar (percent), over(`i'_21, gap(5)) over(age, gap(50)) over(gender, gap(200)) ///
	stack percentages asyvars legend (off label(1 "Has access") label(2 "HH access/no child access") label(3 "No HH/child access") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$qual3")) bar(2, bcolor("$yellow")) bar(3, bcolor("$peank")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(`i'_gena, replace) nodraw
	   
	}

 	grc1leg tv_gena button_gena smart_gena inter_gena, colfirst iscale(*1.02) legendfrom(tv_gena) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
	
	
	
	//calculating usage of tech on learning: radio tv comp internet mobile and smart phones 
	order scq24d_7 scq24d_6 scq24d_3 scq24d_4 scq24d_2 scq24d_5 scq24d_1	 
	egen tot_time21=rowtotal(scq24d_7-scq24d_1)
	gen hrstech21=tot_time21/60
	
	order scq24e_7 scq24e_6 scq24e_3 scq24e_4 scq24e_2 scq24e_5 scq24e_1
	egen tot_time20=rowtotal(scq24e_7-scq24e_1)
	gen hrstech20=tot_time20/60
	
	order tot_time20 hrstech20, aft(scq24e_8)
	order tot_time21 hrstech21, aft(scq24d_8)

	
	recode tot_time20 (0=0) (1/10000=1),gen(tech20)
	recode tot_time21 (0=0) (1/10000=1),gen(tech21)

	clonevar tech_20=tech20 if enrol21==1
	clonevar tech_21=tech21 if enrol21==1
	recode tech_20 tech_21 (1=100)
		
		order radio tv button smart inter comp
		gen accesstech=1 if radio==1|tv==1|button==1|smart==1|inter==1|comp==1
		recode accesstech .=0 if enrol21==1
		recode accesstech 1=. if enrol21!=1

		
			recode tech_20 tech_21 (100=1) if accesstech==1
			recode tech_20 tech_21 (1=100) 
			recode tech_20 tech_21 (0=.) if accesstech==0
	
		  
	///disaggregating by age

	graph hbar tech_20 tech_21, over(age, gap(50)) ///
	  asyvars legend (off label(1 "Used for studies in 2020") label(2 "Used for studies in 2021") label(3 "No HH/child access")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$peank")) bar(2, bcolor("$qual3")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(tech_age, replace) nodraw

 	grc1leg tech_age, colfirst iscale(*1.02) legendfrom(tech_age) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
	///disaggregating by gender

	graph hbar tech_20 tech_21, over(gender, gap(50)) ///
	  asyvars legend (off label(1 "Used for studies in 2020") label(2 "Used for studies in 2021") label(3 "No HH/child access")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$peank")) bar(2, bcolor("$qual3")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(tech_gender, replace) nodraw

 	grc1leg tech_gender, colfirst iscale(*1.02) legendfrom(tech_gender) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	grc1leg tech_age tech_gender, colfirst iscale(*1.02) legendfrom(tech_gender) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))
	
	
	///disaggregating over gender and strata
	graph hbar tech_20 tech_21, over(gender, gap(20)) over(strata, gap(120)) ///
	  asyvars legend (off label(1 "Used for studies in 2020") label(2 "Used for studies in 2021") label(3 "No HH/child access") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$peank")) bar(2, bcolor("$qual3")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(tech_genderst, replace) nodraw

 	grc1leg tech_genderst, colfirst iscale(*1.02) legendfrom(tech_genderst) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

		///disaggregating over gender and age

		graph hbar tech_20 tech_21, over(gender, gap(20)) over(age, gap(120)) ///
	  asyvars legend (off label(1 "Used for studies in 2020") label(2 "Used for studies in 2021") label(3 "No HH/child access") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$peank")) bar(2, bcolor("$qual3")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(tech_genderst, replace) nodraw

 	grc1leg tech_genderst, colfirst iscale(*1.02) legendfrom(tech_genderst) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))


	
		save "$clean_data_dir/section_E.dta", replace 

	
	
	
	
	
 ///analysing learning engagement
 
 	use "$clean_data_dir/edu_time_details.dta", clear 
 	egen child_id=concat(main_id name_child age_child), p(_)
	collapse (sum) educ_time_19 educ_time_20 educ_time_21, by(child_id)
	merge 1:1 child_id using "$clean_data_dir/section_E.dta" 
	drop _merge
 
 
	 clonevar priv19=seq58a if enrol21==1
	 recode priv19 (.=2) if enrol21==1
	 clonevar priv20=seq58b if enrol21==1
	 recode priv20 (.=2) if enrol21==1
	 clonevar priv21=seq58c if enrol21==1
	 recode priv21 (.=2) if enrol21==1

 
 	 clonevar privcost19=seq60a if enrol21==1
	 clonevar privcost20=seq60b if enrol21==1
	 clonevar privcost21=seq60c if enrol21==1

	 
	 foreach i in 19 20 21{
	 winsor privcost`i', gen(wprivcost`i')p(0.01)
	sum wprivcost`i' privcost`i', d
	 }
 

	clonevar gender_rural=gender if strata==1
	clonevar gender_urban=gender if strata==2
	clonevar gender_511=gender if age==1
	clonevar gender_1218=gender if age==2


	la var wprivcost19 "2019"
 	la var wprivcost20 "2020"
	la var wprivcost21 "2021"
	
	
	
	//////////////////////plotting means by gender and strata
	preserve

 collapse (mean) p19=wprivcost19 p20=wprivcost20 p21=wprivcost21 (sd) sd19=wprivcost19 sd20=wprivcost20 sd21=wprivcost21 (count) n19=wprivcost19 n20=wprivcost20 n21=wprivcost21, by(gender strata)	
	
foreach i in 19 20 21{
  gen ucl`i' = p`i' + invttail(n`i',0.025)*sd`i'/sqrt(n`i')
gen lcl`i' = p`i' - invttail(n`i',0.025)*sd`i'/sqrt(n`i')
	  
}	
	
egen gendstrat=group(gender strata)
recode gendstrat (2=5) (4=6) (3=2) 
recode gendstrat (5=4) (6=5)
format p19 p20 p21 %9.0f 


foreach i in 19{
    twoway (bar p`i' gendstrat if gendstrat==1, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' gendstrat if gendstrat==2, barwidth(.8) color("$peank") lcolor(black)) (bar p`i' gendstrat if gendstrat==4, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' gendstrat if gendstrat==5, barwidth(.8) color("$peank") lcolor(black)) (rcap ucl`i' lcl`i' gendstrat,color(black)) (scatter p`i' gendstrat, msymbol(i) mlabel(p`i') mlabcolor(black) mlabposition(1)), ytitle("") yscale() ytitle("Average monthly tuition expenditure (Taka)") ylabel(0 "0" 100 "100" 200 "200" 300 "300" 400 "400" 500 "500" 600 "600" 700 "700" 800 "800" 900 "900" 1000 "1000") xlab(, val ang(45) labsize(small)) legend(off row(1) position(6)) xtitle("") xlabel(1 "Rural boys" 2 "Rural girls" 4 "Urban boys" 5 "Urban girls") title("Monthly exp. in  20`i'") plotregion(fcolor(white)) name(pri`i', replace)
	
}
     
	
foreach i in 20 21{
   twoway (bar p`i' gendstrat if gendstrat==1, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' gendstrat if gendstrat==2, barwidth(.8) color("$peank") lcolor(black)) (bar p`i' gendstrat if gendstrat==4, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' gendstrat if gendstrat==5, barwidth(.8) color("$peank") lcolor(black)) (rcap ucl`i' lcl`i' gendstrat,color(black)) (scatter p`i' gendstrat, msymbol(i) mlabel(p`i') mlabcolor(black) mlabposition(2)), ytitle("") yscale() ylab(none) xlab(, val ang(45) labsize(small)) legend(off row(2) position(6)) xtitle("") xlabel(1 "Rural boys" 2 "Rural girls" 4 "Urban boys" 5 "Urban girls") title("Monthly exp. in  20`i'")plotregion(fcolor(white)) name(pri`i', replace)   
}


	grc1leg pri19 pri20 pri21, colfirst iscale(*1.02) ycommon xcommon rows(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))
	graph export "$figure/privatceexp.png", replace
	
	restore
	
	///////////////////////////By age and gender
preserve
	 collapse (mean) p19=wprivcost19 p20=wprivcost20 p21=wprivcost21 (sd) sd19=wprivcost19 sd20=wprivcost20 sd21=wprivcost21 (count) n19=wprivcost19 n20=wprivcost20 n21=wprivcost21, by(gender age)	
		
	foreach i in 19 20 21{
	gen ucl`i' = p`i' + invttail(n`i',0.025)*sd`i'/sqrt(n`i')
	gen lcl`i' = p`i' - invttail(n`i',0.025)*sd`i'/sqrt(n`i')
		  
	}	
		
egen genage=group(gender age)
recode genage (2=5) (4=6) (3=2) 
recode genage (5=4) (6=5)
format p19 p20 p21 %9.0f 

foreach i in 19 {
twoway (bar p`i' genage if genage==1, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' genage if genage==2, barwidth(.8) color("$peank") lcolor(black)) (bar p`i' genage if genage==4, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' genage if genage==5, barwidth(.8) color("$peank") lcolor(black)) (rcap ucl`i' lcl`i' genage,color(black)) (scatter p`i' genage, msymbol(i) mlabel(p`i') mlabcolor(black) mlabposition(1)), ytitle("") yscale() ytitle("Average monthly tuition expenditure (Taka)") ylabel(0 "0" 100 "100" 200 "200" 300 "300" 400 "400" 500 "500" 600 "600" 700 "700" 800 "800" 900 "900" 1000 "1000") xlab(, val ang(45) labsize(small)) legend(off row(1) position(6)) xtitle("") xlabel(1 "5-11 boys" 2 "5-11 girls" 4 "12-18 boys" 5 "12-18 girls") title("Monthly exp. in 20`i'") plotregion(fcolor(white)) name(privc`i', replace) 
}

foreach i in 20 21 {
twoway (bar p`i' genage if genage==1, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' genage if genage==2, barwidth(.8) color("$peank") lcolor(black)) (bar p`i' genage if genage==4, barwidth(.8) color("$skyblue") lcolor(black)) (bar p`i' genage if genage==5, barwidth(.8) color("$peank") lcolor(black)) (rcap ucl`i' lcl`i' genage,color(black)) (scatter p`i' genage, msymbol(i) mlabel(p`i') mlabcolor(black) mlabposition(1)), ytitle("") yscale() ylab(none) xlab(, val ang(45) labsize(small)) legend(off row(1) position(6)) xtitle("") xlabel(1 "5-11 boys" 2 "5-11 girls" 4 "12-18 boys" 5 "12-18 girls") title("Monthly exp. in 20`i'") plotregion(fcolor(white)) name(privc`i', replace) 
}



	grc1leg privc19 privc20 privc21, colfirst iscale(*1.02) ycommon xcommon rows(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))
	graph export "$figure/privatecexpage.png", replace
	
	restore
	
	


//avg hours studied at home per day in 2019

	winsor seq55a, gen(wseq55a)p(0.01)
	gen study19=wseq55a/60
	
	recode wseq55a (0/55=0 "Little to no studying") (60/120=2 "1-2 hrs") (125/800=3 ">2hrs"), gen(home19)


	*********hrs studied  in 2020*********************
	//avg hours studied at home per day in 2020
	winsor seq55b, gen(wseq55b)p(0.01)
		gen study20=wseq55b/60

	
	recode wseq55b (0/55=0 "Little to no studying") (60/120=2 "1-2 hrs") (125/1000=3 ">2hrs"), gen(home20)



	///////avg hrs studied at home in 2021
	winsor seq55c, gen(wseq55c)p(0.01)
			gen study21=wseq55c/60

	recode wseq55c (0/55=0 "Little to no studying")  (60/120=2 "1-2 hrs") (125/1000=3 ">2hrs"), gen(home21)
 
 
 clonevar home_19=home19 if enrol21==1
 clonevar home_20=home20 if enrol21==1
 clonevar home_21=home21 if enrol21==1
 format home_19 home_20 home_21 %9.0f

tab home_19,gen (home19_)
tab home_20,gen (home20_)
tab home_21,gen (home21_)

recode home19_1-home21_3 (1=100)
 
 	graph hbar home19_1-home19_3, over(gender, gap(50)) ///
	stack asyvars legend ( label(1 "% little/no studying") label(2 "% that studied 1-2hrs") label(3 "% studied for >2hrs")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2019", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(study19, replace) 
 
 
 	graph hbar home20_1-home20_3, over(gender, gap(50)) ///
	stack asyvars legend ( label(1 "% that didn't study") label(2 "% that studied for 1hr") label(3 "% studied for >2hrs")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("2020", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(study20, replace) 

 	graph hbar home21_1-home21_3, over(gender, gap(50)) ///
	stack asyvars legend ( label(1 "% that didn't study") label(2 "% that studied for 1hr") label(3 "% studied for >2hrs")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("2021", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(study21, replace) 

 	grc1leg study19 study20 study21, colfirst iscale(*1.02) legendfrom(study19) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))



/////////////by gender in strata
 	graph hbar home19_1-home19_3, over(gender, gap(20)) over(strata, gap(100)) ///
	stack asyvars legend ( label(1 "% little/no studying") label(2 "% that studied 1-2hrs") label(3 "% studied for >2hrs")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2019", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(study19, replace) 
 
 
 	graph hbar home20_1-home20_3, over(gender, gap(20)) over(strata, gap(100)) ///
	stack asyvars legend ( label(1 "% that didn't study") label(2 "% that studied for 1hr") label(3 "% studied for >2hrs")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("2020", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(study20, replace) 

 	graph hbar home21_1-home21_3, over(gender, gap(20)) over(strata, gap(100)) ///
	stack asyvars legend ( label(1 "% that didn't study") label(2 "% that studied for 1hr") label(3 "% studied for >2hrs")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("2021", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(study21, replace) 

 	grc1leg study19 study20 study21, colfirst iscale(*1.02) legendfrom(study19) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))


 
 
  
  
 **********Adult engagement
 	recode educ_time_19 (0/55=0 "No/little adult engagement") (6/120=2 "1-2 hrs") (125/1000=3 ">2hrs"), gen(hrs19)
	recode educ_time_20 (0/55=0 "No adult engagement") (60/120=2 "1-2 hrs") (125/1000=3 ">2hrs"), gen(hrs20)
	recode educ_time_21 (0/55=0 "No adult engagement")  (60/120=2 "1-2 hrs") (125/1000=3 ">2hrs"), gen(hrs21)

	clonevar hrs_19=hrs19 if enrol21==1
	clonevar hrs_20=hrs20 if enrol21==1
	clonevar hrs_21=hrs21 if enrol21==1

	
	
tab hrs_19,gen (hrs19_)
tab hrs_20,gen (hrs20_)
tab hrs_21,gen (hrs21_)

recode hrs19_1-hrs21_3 (1=100)
 
 	graph hbar hrs19_1-hrs19_3, over(gender, gap(50)) ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2019", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs19, replace) 
 
  	graph hbar hrs20_1-hrs20_3, over(gender, gap(50)) ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2020", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs20, replace) 
 
 	graph hbar hrs21_1-hrs21_3, over(gender, gap(50)) ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(3) pos(6) size()) ///
	title("2021", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs21, replace) 

 	grc1leg hrs19 hrs20 hrs21, colfirst iscale(*1.02) legendfrom(hrs21) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))



/////////////by gender in strata
 	 	graph hbar hrs19_1-hrs19_3, over(gender, gap(20)) over(strata, gap(100))  ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2019", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs19, replace) 
 
  	graph hbar hrs20_1-hrs20_3, over(gender, gap(20)) over(strata, gap(100)) ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2020", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs20, replace) 
 
 	graph hbar hrs21_1-hrs21_3, over(gender, gap(20)) over(strata, gap(100)) ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(3) pos(6) size()) ///
	title("2021", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs21, replace) 

 	grc1leg hrs19 hrs20 hrs21, colfirst iscale(*1.02) legendfrom(hrs21) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))


	
	/////////////by gender in age
 	 	graph hbar hrs19_1-hrs19_3, over(gender, gap(20)) over(age, gap(100))  ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2019", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs19, replace) 
 
  	graph hbar hrs20_1-hrs20_3, over(gender, gap(20)) over(age, gap(100)) ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("2020", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs20, replace) 
 
 	graph hbar hrs21_1-hrs21_3, over(gender, gap(20)) over(age, gap(100)) ///
	stack asyvars legend ( label(1 "% with little/no adult help") label(2 "% that had 1-2hrs adult help") label(3 "% had >2hrs of adult help")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$yellow")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(3) pos(6) size()) ///
	title("2021", justification(center) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(hrs21, replace) 

 	grc1leg hrs19 hrs20 hrs21, colfirst iscale(*1.02) legendfrom(hrs21) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
 

 gen educ_time_19a=educ_time_19/60
  gen educ_time_20a=educ_time_20/60
 gen educ_time_21a=educ_time_21/60

  clonevar adult19=educ_time_19a if enrol21==1
 clonevar adult20=educ_time_20a if enrol21==1
 clonevar adult21=educ_time_21a if enrol21==1

 
 
 ///learning engagement comparison

 
 
 foreach i in hrs_19 hrs_21 hrs_20 home_19 home_20 home_21 {
     
	 tab `i'
 }
 
 
 *types of learning engagement
 
 //private tutoring
 
 gen private=.
 
	recode private .=1 if seq58b==0 & seq58c==1
	recode private .=1 if seq58b==. & seq58c==1
	recode private .=2 if seq58b==1 & seq58c==0
	recode private .=3 if seq58b==1 & seq58c==1
	recode private .=4 if seq58b==0 & seq58c==0
	recode private .=4 if seq58b==. & seq58c==0
	recode private (1/4=.) if enrol21==999
	 la val private private
	 la def private 1 "Only in 2021" 2 "Only in 2020" 3 "Both 2020/2021" 4 "No tuitions", modify
	 
	 
 
 ///adult engagement
 
 gen adult=.

	recode adult .=1 if hrs_20==0 & hrs_21==0 
	recode adult .=2 if hrs_20==0 & hrs_21==1
	recode adult .=3 if hrs_20==0 & hrs_21==2
	recode adult .=10 if hrs_20==0 & hrs_21==3
	recode adult .=7 if hrs_20==1 & hrs_21==2
	recode adult .=11 if hrs_20==1 & hrs_21==3
	recode adult .=12 if hrs_20==2 & hrs_21==3
	
	recode adult .=4 if hrs_20==1 & hrs_21==0 
	recode adult .=5 if hrs_20==2 & hrs_21==0 
	recode adult .=16 if hrs_20==3 & hrs_21==0
	recode adult .=8 if hrs_20==2 & hrs_21==1 
	recode adult .=14 if hrs_20==3 & hrs_21==2
	recode adult .=15 if hrs_20==3 & hrs_21==1

	recode adult .=6 if hrs_20==1 & hrs_21==1
	recode adult .=9 if hrs_20==2 & hrs_21==2
	recode adult .=13 if hrs_20==3 & hrs_21==3
 
 
 recode adult (1=1 "No engagement") (2 3 10 7 11 12=2 "Increased engagement") (4 5 16 8 14 15=3 "Lower engagement") (6 9 13=4 "Unchanged"), gen(engaged)
 
tab engaged
 
			///figure 
	

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 	/*clonevar ner19=level19 if enrol_stat==5
	clonevar ner20=level20 if enrol_stat==6
	clonevar ner20_b=level20 if enrol_stat==7
	
	forval i=0/50 {
	recode ner20 .=`i' if ner20_b==`i'
	}
	
	
	forval i=0/50 {
	recode ner20 .=`i' if ner19==`i'
	}
	tab ner20 */
 
 /*
 	///figure 2: disaggregating levels of non-enrolment
graph hbar exit_1-exit_3 if gender==1, over(strata, gap(5) ) ///
	stack asyvars legend (label(1 "Pre-primary") label(2 "Primary") label(3 "Secondary") label(4 "SSC") label(5 "Higher sec.") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -10 55 "{it:Boys}", orientation(horizontal) size(med)) ///
name(exit1, replace) nodraw

graph hbar exit_1-exit_3 if gender==2, over(strata, gap(5) ) ///
	stack asyvars legend (label(1 "Pre-primary") label(2 "Primary") label(3 "Secondary") label(4 "SSC") label(5 "Higher sec.") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -10 50 "{it:Girls}", orientation(horizontal) size(med)) ///
name(exit2, replace) nodraw

 graph hbar exit_1-exit_3 if gender==1, over(age, gap(5) ) ///
	stack asyvars legend (label(1 "Pre-primary") label(2 "Primary") label(3 "Secondary") label(4 "SSC") label(5 "Higher sec.") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -12 45 "{it:Boys}", orientation(horizontal) size(med)) ///
name(exit3, replace) nodraw

graph hbar exit_1-exit_3 if gender==2, over(age, gap(5) ) ///
	stack asyvars legend (label(1 "Pre-primary") label(2 "Primary") label(3 "Secondary") label(4 "SSC") label(5 "Higher sec.") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -12 43 "{it:Girls}", orientation(horizontal) size(med)) ///
name(exit4, replace) nodraw

 	grc1leg exit1 exit2 exit3 exit4, colfirst iscale(*1.02) legendfrom(exit3) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 	
/*
		  
		  *money reasons
		  
			foreach var in 28 34 35 37 38 45 46 51 {
		 	order seq`var'm_1 seq`var'm_2 seq`var'm_7
			egen mr`var'=rowtotal(seq`var'm_1 seq`var'm_2 seq`var'm_7)
		 }
		  			
			order mr28-mr51

		  
		  	foreach var in 28 34 35 37 38 45 46 51 {
			recode mr`var' (0=.) if seq`var'm_1 ==.
		 }
		  
		  
		  *hh chores/carework
		  	foreach var in 28 34 35 37 38 45 46 51 {
		 	order seq`var'm_3 seq`var'm_6 seq`var'm_13
			egen hhr`var'=rowtotal(seq`var'm_3 seq`var'm_6 seq`var'm_13)
		 }
		  			
			order hhr28-hhr51

		  
		  
		  	foreach var in 28 34 35 37 38 45 46 51 {
			recode hhr`var' (0=.) if seq`var'm_3 ==.
		 }
		  
		  
		  
		  
		 

	
	*reasons for not being in classes in 2020
	forval i=1/31{
		clonevar cl_r_`i'=seq37m_`i' if class20==0
	}
	
	clonevar cl_r_555=seq37m_555 if class20==0
	mrtab cl_r_1-cl_r_555, by(gender) col sort des
	
	encode seq51m_ot,gen(seq51ot)
	mrtab seq51m_1-seq51m_555, by(gender) col sort des
	
	*reasons for not going to classes in 2021

	


 
 //clean the reasons
// recode seq51ot (1 3 8 9 10 11 12 13 14 16 17 18 19 20 191=32 "At relative's house'") (2 6 183=33 "Can't go to school alone") (186 187 188 189 196 197 199 201=40 "SSC/HSC exams done") (4 200 202=41 "SSC examinee") (7 34 35 37 36 38 184 185 10 15=777 "Others"), gen(seq51_m)

 
  	//figure 4
	tab attendance,gen(at_)
	recode at_1-at_5 (1=100)
	
	graph hbar at_1-at_5 if gender==1, over(strata, gap(10) ) ///
	stack asyvars legend (label(1 "No online/offline classes") label(2 "No online/regular offline") label(3 "Yes online/irregular offline") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -10 55 "{it:Boys}", orientation(horizontal) size(med)) ///
name(att1, replace) nodraw

graph hbar at_1-at_5 if gender==2, over(strata, gap(10) ) ///
	stack asyvars legend (label(1 "No online/offline classes") label(2 "No online/regular offline") label(3 "Yes online/irregular offline") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -10 50 "{it:Girls}", orientation(horizontal) size(med)) ///
name(att2, replace) nodraw

 graph hbar at_1-at_5 if gender==1, over(age, gap(10) ) ///
	stack asyvars legend (label(1 "No online/offline classes") label(2 "No online/regular offline") label(3 "Yes online/irregular offline") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(1) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -12 45 "{it:Boys}", orientation(horizontal) size(med)) ///
name(att3, replace) nodraw

graph hbar at_1-at_5 if gender==2, over(age, gap(10)) ///
	stack asyvars legend (label(1 "No online/offline classes") label(2 "No online/regular offline") label(3 "Yes online/irregular offline") label(4 "Both online/offline") label(5 "No online/irregular offline") label(6 "Higher sec.")) ///
	ysca(noline) yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$purple1")) bar(2, bcolor("$teal")) bar(3, bcolor("$qual3")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
	text( -12 43 "{it:Girls}", orientation(horizontal) size(med)) ///
name(att4, replace) nodraw

 	grc1leg att1 att2 att3 att4, colfirst iscale(*1.02) legendfrom(att1) ycommon xcommon cols(1) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

		  
		  
		  
	
		  
		  
		  	
	
	
	
	
	
	
	
	
	
	
	
	gen unme= r(mu_1)- invttail(r(df_t),0.025)*(10.83329)
	
	
mean wprivcost19,over(gender strata) 	
	 marginsplot, xdimension(gender strata) plotopts(gap(10) mlabel(y) msangle(180) mlabformat(%4.0) mlabsize(small) clwidth(none)) xtitle("") yline(0)  title("Estimated means at 95% CI") legend(cols(1) row(1) pos(6) size()) plotregion(fcolor(white)) ci1opts(color(green%70)) plot1opts(lcolor(green)) name(privcost2, replace)

grc1leg privcost2, colfirst iscale(*1.02) legendfrom(privcost2) ycommon xcommon rows(3) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
	
	mean wprivcost20,over(gender strata) 	
	 marginsplot, xdimension(gender strata) plotopts(msize(large) mlabel(y) msangle(180) mlabformat(%4.2) mlabsize(small) clwidth(none)) ylabel(none) xlabel(none) xtitle("") title("") legend(cols(1) row(1) pos(6) size()) plotregion(fcolor(white)) ci1opts(color(blue%70)) plot1opts(lcolor(blue)) name(privcost3, replace)
	
	mean wprivcost21,over(gender strata) 	
	 marginsplot, xdimension(gender strata) plotopts(msize(large) mlabel(y) msangle(180) mlabformat(%4.2) mlabsize(small) clwidth(none)) title("") ylabel(none) xtitle("") legend(cols(1) row(1) pos(6) size()) plotregion(fcolor(white)) ci1opts(color(red%70)) plot1opts(lcolor(red)) name(privcost4, replace)
	
		grc1leg privcost2 privcost3 privcost4, colfirst iscale(*1.02) legendfrom(privcost2) ycommon xcommon rows(3) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
		
	
	
	
	
	
	
	
	
	
	
	
	
*plotting private tuitions over gender across age groups and strata
 
 
 gen diff_IGA=IGA-base_IGA
statsby mean=r(mean) se=r(se) N=r(N), by(groups T1 TG) clear: ci mean diff_IGA
gen se_lower = mean - se
gen se_upper = mean + se
summ mean
gen max=r(max)

 
sum wprivcost19 if gender_rural==1
local gr1_19=r(mean)
local gr1_19se=r(se)
sum wprivcost19 if gender_rural==2
local gr2_19=r(mean)



wprivcost20 wprivcost21
return list


local vary wprivcost19 wprivcost20 wprivcost21
local varx gender gender_rural gender_urban gender_511 gender_1218

 statsby mean=r(mean) se=r(se) N=r(N), by(`varx') subsets nodots:clear:summarize wprivcost19, detail

statsby mean=r(mean) , by(groups gender gender_rural gender_urban gender_511 gender_1218) clear: ci mean wprivcost19
 
gen se_lower = mean - se
gen se_upper = mean + se
summ mean
gen max=r(max)
twoway (bar mean TG if T1==0, color("242 206 174") lcolor(black)) (bar mean TG if T1==1, color("217 91 91") lcolor(black)) (rcap se_upper se_lower TG,color(black)) , ytitle("% point change from baseline") yscale(range(0, . )) ylabel(0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%") legend(row(1) order(1 "Control" 2 "Treatment") position(6)) xlabel(1.5 "Group 2" 4.5 "Group 3", noticks) xtitle("") plotregion(margin(b = 0))
 
 
 
 
 
 

 
   
	   betterbarci wprivcost19 wprivcost20 wprivcost21, over(gender) by(strata) bar format(%4.0f) barc( "pink%40" ) legend(cols(1) row(1) pos(6) size()) plotregion(fcolor(white)) name(privcost2, replace)
	   
	   betterbarci wprivcost19 wprivcost20 wprivcost21, over(gender) by(age) bar format(%4.0f) barc( "pink%40" ) legend(cols(1) row(1) pos(6) size()) plotregion(fcolor(white)) name(privcost3, replace) 
	   
	grc1leg privcost2 privcost3, colfirst iscale(*1.02) legendfrom(privcost3) ycommon xcommon cols(2) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	   betterbarci wprivcost19 wprivcost20 wprivcost21, over(gender) bar n format(%4.0f) barc( "pink%40" ) legend(cols(1) row(1) pos(6) size()) plotregion(fcolor(white)) name(privcost, replace) 
	   
	grc1leg privcost, colfirst iscale(*1.02) legendfrom(privcost) ycommon xcommon cols(2) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

recode seq58a seq58b seq58c (1=100)
	graph bar seq58a seq58b seq58c, bargap(50) ///
	  asyvars legend ( label(1 "% tooks tuitions in 2019") label(2 "% tooks tuitions in 2020") label(3 "% tooks tuitions in 2021")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$qual3")) bar(2, bcolor("$cherry")) bar(3, bcolor("$yellow")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(privtt, replace) nodraw



	graph bar seq58a seq58b seq58c, over(gender, gap(50)) ///
	  asyvars legend ( label(1 "% tooks tuitions in 2019") label(2 "% tooks tuitions in 2020") label(3 "% tooks tuitions in 2021")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$qual3")) bar(2, bcolor("$cherry")) bar(3, bcolor("$yellow")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(privtt2, replace) nodraw






	graph bar seq58a seq58b seq58c, over(gender, gap(50)) over(strata, gap(150)) ///
	  asyvars legend ( label(1 "% tooks tuitions in 2019") label(2 "% tooks tuitions in 2020") label(3 "% tooks tuitions in 2021")) ///
	ysca(noline) nofill yline(0, lcolor(black)) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$qual3")) bar(2, bcolor("$cherry")) bar(3, bcolor("$yellow")) bar(4, bcolor("$yellow")) ///
	bar(5, bcolor("$orange")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(2) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(privtt22, replace) nodraw

 	grc1leg privtt2 privtt22, colfirst iscale(*1.02) legendfrom(privtt2) ycommon xcommon cols(2) ysize(11) imargin(0 0 0 0) graphregion(margin(r=15 l=15))

	
	
	
			*engagement status broken down
		loc i = 1
	 foreach j in age gender strata{
	**options for graph
		if `i' ==3 loc legg `"legend(on cols(1) row(1) pos(6) size())"'
		if `i' ==1 loc legg `"legend(off cols(1) row(3) pos(6) size())"'
		if `i' ==1 loc axis `"ylabel(none, nolabels nogrid) "'
		*if `i' == 1 loc axis `"yla(none) "'
		if `i' ==1 loc note `""'
		lab var engaged `"`=upper("`j'")'"'
			
			
	**graph    
	catplot engaged, over(`j', gap(50) label(labsize(small) labcolor(black))) percent(`j') asyvars stack recast(hbar) legend(off) `legg' blabel(bar, position(center) size(small) color (black) format(%3.1f)) nofill ///
		bar(1, bcolor("$purple2")) bar(2, bcolor("$skyblue")) ///
		bar(3, bcolor("$qual3")) bar(4, bcolor("$orange")) ///
		bar(5, bcolor("$cherry")) bar(6, bcolor("$peank")) ///
		bar(7, bcolor("$")) bar(8, bcolor("$")) ///
		name(engage`i', replace) `axis'  plotregion(fcolor(white) lcolor(none)) l1title("`=upper("`j'")'", margin(0 0 0 0 )) ytitle("") yscale(noline)  
			loc plots1ced `"`plots1ced' engage`i' "'
			loc `++i'
		  }	  
 
	gr combine `plots1ced', colfirst ycommon cols(1) imargin(zero) graphregion(margin(r=15 l=15))
 	graph export "${figure}/engage.png", replace
	
	
 		*private tuitions broken down
		
		loc i = 1
	 foreach j in age gender strata{
	**options for graph
		if `i' ==3 loc legg `"legend(on cols(1) row(1) pos(6) size())"'
		if `i' ==1 loc legg `"legend(off cols(1) row(3) pos(6) size())"'
		if `i' ==1 loc axis `"ylabel(none, nolabels nogrid) "'
		*if `i' == 1 loc axis `"yla(none) "'
		if `i' ==1 loc note `""'
		lab var private `"`=upper("`j'")'"'
			
			
	**graph    
	catplot private, over(`j', gap(50) label(labsize(small) labcolor(black))) percent(`j') asyvars stack recast(hbar) legend(off) `legg' blabel(bar, position(center) size(small) color (black) format(%3.1f)) nofill ///
		bar(1, bcolor("$purple2")) bar(2, bcolor("$skyblue")) ///
		bar(3, bcolor("$qual3")) bar(4, bcolor("$orange")) ///
		bar(5, bcolor("$cherry")) bar(6, bcolor("$peank")) ///
		bar(7, bcolor("$")) bar(8, bcolor("$")) ///
		name(private`i', replace) `axis'  plotregion(fcolor(white) lcolor(none)) l1title("`=upper("`j'")'", margin(0 0 0 0 )) ytitle("") yscale(noline)  
			loc plots1cfd `"`plots1cfd' private`i' "'
			loc `++i'
		  }	  
 
	gr combine `plots1cfd', colfirst ycommon cols(1) imargin(zero) graphregion(margin(r=15 l=15))
 	graph export "${figure}/private.png", replace
	
	
	
	
	
	
	graph hbar (percent), over(attendance, gap(5)) over(age, gap(50)) ///
	 stack percentages asyvars nofill legend (off label(1 "No class attendance") label(2 "Irregular in-person") label(3 "No Online/regular inperson") label(4 "Both online/regular inperson") label(5 "No online/irregular inperson") label(6 "Higher sec.")) ///
	ysca(noline) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(center)) bar(1, bcolor("$cherry")) bar(2, bcolor("$tangerine")) bar(3, bcolor("$yellow")) bar(4, bcolor("$qual3")) ///
	bar(5, bcolor("$skyblue")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(3) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(attend22, replace) nodraw   
	
			///disaggregating over gender and strata
	
	graph bar (percent), over(attendance, gap(5)) over(gender, gap(50)) over(strata, gap(200)) ///
	 percentages asyvars nofill legend (off label(1 "No class attendance") label(2 "Irregular in-person") label(3 "No Online/regular inperson") label(4 "Both online/regular inperson") label(5 "No online/irregular inperson") label(6 "Higher sec.")) ///
	ysca(noline) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$cherry")) bar(2, bcolor("$tangerine")) bar(3, bcolor("$yellow")) bar(4, bcolor("$qual3")) ///
	bar(5, bcolor("$skyblue")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(3) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(attend1, replace) nodraw   
	

	
	///disaggregating by age and gender

	graph bar (percent), over(attendance, gap(5)) over(gender, gap(50)) over(age, gap(200)) ///
	 percentages asyvars nofill legend (off label(1 "No class attendance") label(2 "Irregular in-person") label(3 "No Online/regular inperson") label(4 "Both online/regular inperson") label(5 "No online/irregular inperson") label(6 "Higher sec.")) ///
	ysca(noline) ylabel(none) blabel(bar, format(%4.0f) size(small)color (black) ///
	position(outside)) bar(1, bcolor("$cherry")) bar(2, bcolor("$tangerine")) bar(3, bcolor("$yellow")) bar(4, bcolor("$qual3")) ///
	bar(5, bcolor("$skyblue")) bar(6, bcolor("$cherry")) bar(7, bcolor("$peank")) bar(8, bcolor("$blue3")) /// 
	legend(cols(1) row(3) pos(6) size()) ///
	title("", justification(left) margin(b+1 t-1 l-1) bexpand size(small) ///
	color (black)) ytitle("", size(small))note("",size(small)) plotregion(fcolor(white)) ///
name(attend2, replace) nodraw   
	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  