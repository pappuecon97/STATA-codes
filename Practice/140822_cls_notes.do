************** Class notes ***********
***********Topic: Loops, put excel, outreg *************
**********date: 14/8/22 *************


*commands to look
*asdoc, estout
*asdoc khub important ja next exam e lagbe.

************looop *************

*for each by varlist
foreach X of varlist var1, var2
*for each by number list
foreach x of numlist 1/15 

*for each by local 
local vars "occu1, occu2, occu3 ....." 
foreach X of local vars{
	
}

*for each jevabe kaaj nai: 
*suppose, amra occu1, occu2,..... occu15 er jonno agri er var create korbo

*agri code
agri=15
housemaid=30
shookeeper= 10

*gen var using loop
gen agri=0
gen housemaid=0
gen shokeeper=0

*loop
foreach X of numlist 1/15{
	replace agri=1 if occu`X' ==15
	replace housemaid=1 if occu`X' ==30
	replace shopkeeper=1 if occu`X' ==10
}

*alt way to do the same thing
foreach X of varlist occu1 occu2 occu3..... occu15{
	replace agri=1 if `X' ==15
	replace housemaid=1 if `X' ==30
	replace shopkeeper=1 if `X' ==10
}
*using local 
local vars "occu1 occu2 occu3 occu4 ......... occu15"
foreach X of local vars{
	replace agri=1 if `X' ==15
	replace housemaid=1 if `X' ==30
	replace shopkeeper=1 if `X' ==10
}

*suppose var hocche 10 ta and occu 15 
*ekhane amra nested loop use korbo
foreach x of numlist 1/15{
	foreach y of varlist agri housemaid shokeeper sweeper ....{
		replace `y'=1 if `x'==15 
		replace `y'=1 if `x'==30
			replace `y'=1 if `x'==10
	}
}


*hw: hint- 15 porjonto missing value diye data create kora. loop and dimension. display command lagbe 


**************outreg2 ************

*suppose reg run korbo
reg price foreign mpg

*ehon amra excel table akare ei result save korbo
outreg2 using table_name.xls, replace

*suppose amra 10 ta run kori. 
*2nd reg 
reg weight  foreach
outreg2 using table_name.xls, append

*quitely cmmnd
qui reg price foreign mpg 

**************put excel *****
*data call korbo 1st, then var creation

*create excel file 
 





