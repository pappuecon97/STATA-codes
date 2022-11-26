*****Stata class: Intermediate to STATA I *********
*****Date: 07/08/2022 *********



*hw: reshaping, analysis, tables. 

*var description
describe hoh_gender
display hoh_gender

*we can use display command like a calculator
display 789/8

*to check the elements in local or global we can use display cmmnd; show 1st obs
di `key_vars' 


*shift to mata 
m

*within mata stata er shob command kaj kore na. so mata theke ber hoite hobe.
end

*mrtab command- when we have multiple qs, we can see all multiple choices qs
mrtab var1 var2 var3 var4 var5 var6 var7, poly 

*poly dewa hoy jate kore shob obs er response count kore. eta kori jodi single var er jonno dummy na thake.

*mrtab er moddhe % of response er mean hocche koto jon total er response er prekkhite ei ans diche.
*% of clasess hocche total sample er moddhe koro %.

*% of responeses amader kaje lage na. we wont consider it. 

*_n?????
*eta hocche every row er serial number.

*suppose amra serial ta division hishebe korbo.
bys division: gen serial =_n

*div er vitore district onushare serial ta korbo
bys division district: gen serial =_n

*jodi div gula agey thekei unsorted thake tokhon o stata automaticly sort kore nibe. 


*to know the value and value label of a multiple responsed var, we use mrtab

*by sort command- suppose we want see the summary of the variable of interest by every division.
by division, sort: sum var_of_interest

*or 
bys division: summ var_of_interest

*we can cal the number of obs in a category by bys cmmand

*why we do sorting-implivations????

/* 
suppose amader just cat var ache, kintu reshape korar jonno member_id nai. 
tokhon amra bys diye every memebr er jonno serial number create korte parbo. 
*/


*_N????- jotogula obs ache ekta div e shegula ke ekta var e niye ashe. 


*****************Collapse *********

/*
suppose, hhold lvl e emplyment, income based on gender dekhte chai. then we can collapse
je var er kotha bole dibo shegula rakhbe, bakigula drop kore dibe.

collapse muloto oi var er sum kore mean value ta niye ashe. by hhold mane hocche hhold er vitore avg. kore dicche.

jodi output pete chai tokhon 'by' agey thake. 
*/

*supose we want to know avg, male and female income by hhold level- mane protek hhold e avg. male and female income.
collapse female_iga male_iga, by(id_key)

*supose we want total income by hhold
collapse (mean) female_iga male_iga (sum) yearly_income, by(id_key)
*amra jodi mean chai bracket e sheta dibo. jodi 'min' chai sheta bracekt e dibo. 

*jodi hhold e missing thake, then bracket e 'min' dile stata min val 1 hole treatment hishebe nibe
*and 0 hole control hishebe nibe.

* bracket e firstnm mane 1st obs ta nibe.

*putexcel command?????




