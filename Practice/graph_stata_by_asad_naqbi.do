*************************
*************************
***                   ***
***   Stata Schemes   ***  v1
***                   ***
***         by        ***
***                   ***
***  The Stata Guide  ***  https://medium.com/the-stata-guide
***    on Medium      ***
***                   ***
***    28-Jun-2021    ***  comments/errors reports: asjadnaqvi@gmail.com
***                   ***
*************************
*************************



clear


// describe the schemes
*net d tsg_schemes, from("https://raw.githubusercontent.com/asjadnaqvi/Stata-schemes/main/schemes/")

// install the schemes
*net install tsg_schemes, from("https://raw.githubusercontent.com/asjadnaqvi/Stata-schemes/main/schemes/") replace

// read the data
use "https://github.com/asjadnaqvi/Stata-schemes/blob/main/scheme_test.dta?raw=true", clear

// you either type:
* set scheme white_tableau 
* set scheme black_tableau 
* set scheme gg_tableau

// or permanently set the theme
* set scheme white_tableau, perm


// or set it in a graph directly
* twoway (scatter var2 date if group==1), scheme(white_tableau)


// Feel free to try these on your own datasets and please report errors if any


set scheme tab2


*****************************************
*********** TEST GRAPHS BELOW ***********
*****************************************



*** Scatter plot

twoway ///
	(scatter var2 date if group==1) ///
	(scatter var2 date if group==2) ///
	(scatter var2 date if group==3) ///
	(scatter var2 date if group==4) ///
	(scatter var2 date if group==5) ///
	(scatter var2 date if group==6) ///
	(scatter var2 date if group==7) ///
	(scatter var2 date if group==8) ///
	(scatter var2 date if group==9) ///
	(scatter var2 date if group==10) ///
	(scatter var2 date if group==11) ///
	(scatter var2 date if group==12) ///
	, ///
		legend(order(1 "group1" 2 "group2" 3 "group3"  4 "group4"  5 "group5" 6 "group6" 7 "group7" 8 "group8" 9 "group9" 10 "group10" 11 "group11" 12 "group12")) ///
		title("Scatter plot") ///
		note("By the Stata Guide") 
		


	
*** Line graph
	
twoway ///
	(line var2 date if group==1) ///
	(line var2 date if group==2) ///
	(line var2 date if group==3) ///
	(line var2 date if group==4) ///
	(line var2 date if group==5) ///
	(line var2 date if group==6) ///
	(line var2 date if group==7) ///
	(line var2 date if group==8) ///
	(line var2 date if group==9) ///
	(line var2 date if group==10) ///
	(line var2 date if group==11) ///
	(line var2 date if group==12) ///
	, ///
		legend(order(1 "group1" 2 "group2" 3 "group3"  4 "group4"  5 "group5" 6 "group6" 7 "group7" 8 "group8" 9 "group9" 10 "group10" 11 "group11" 12 "group12")) ///
		title("Line plot") ///
		note("The Stata Guide", size(vsmall)) 

		

		
		
*** Pie chart
		
graph pie var2 if group <= 10, ///
	over(group) plabel(_all percent, format(%5.2f) position(inside)) ///
	line(lcolor(black) lwidth(vvthin)) 	///                  // outline colors have to be manually added
	title("Pie plot") ///
		note("The Stata Guide", size(vsmall)) 


	
*** Box plot

graph box ///
	var* ///
		, ///
		title("Box plot") ///
		note("The Stata Guide", size(vsmall)) 

*** Histogram

histogram var4, percent ///
	title("Histogram") ///
		note("The Stata Guide", size(vsmall)) 
		
*** Bar graph

graph bar ///
	var* ///
		, ///
		blabel(bar, format(%9.0f)) ///
		title("Bar graph") ///
		note("The Stata Guide", size(vsmall)) 
	

*** Horizontal bar graph

graph hbar (mean) ///
	var* ///
	if group <= 6, ///
		over(group) ///
		percentages stack	///
		legend(order(1 "Var 1" 2 "Var 2" 3 "Var 3"  4 "Var 4"  5 "Var 5" 6 "Var 6") position(bottom) row(1)) ///
		title("Bar graph") ///
		note("The Stata Guide", size(vsmall)) blabel(bar, format(%2.0f) position(center) size(vsmall)) ysc(off) scheme(tab2)
	

*** Confidence bands
	
twoway ///
	(lpolyci var1 var9, fcolor(%80)) ///
	(lpolyci var2 var9, fcolor(%80)) ///
	(lpolyci var3 var9, fcolor(%80)) ///
		, ///
		title("Confidence Interval") ///
		note("The Stata Guide", size(vsmall)) scheme(tab3)
	
	
*** Range graphs	
	
twoway ///
	(rcapsym var2 var3 date if group==1, sort) ///
	(rcapsym var2 var3 date if group==2, sort) ///
		, ///
		title("Range plots") ///
		note("The Stata Guide", size(vsmall)) 
	

*** Area graphs	

twoway ///
	(area den1d den1x, fcolor(%50)) ///
	(area gen2d gen2x, fcolor(%50)) ///
	(area gen3d gen3x, fcolor(%50)), ///
			title("Density plots") ///
			note("The Stata Guide", size(vsmall)) 
			

*** Scatter labels			

twoway ///
	(scatter var2 var1, mlabel(group)) ///
		if date==22320 ///
		, ///
		title("Confidence Interval") ///
		note("The Stata Guide", size(vsmall)) 

		
*** By graphs
		
twoway ///
	(scatter var2 var1) ///
		if group <= 12, ///
		by(group, yrescale xrescale)	///
		by(, title("By graphs") note("The Stata Guide", size(vsmall))) 
			
			
			
			
//// *******  END OF FILE ******* \\\\
			
			
			
			
			