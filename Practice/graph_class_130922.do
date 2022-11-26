************* Graph class: 13/09/22 *************
/*
frequently used plot types:
barplot; pie; scatter; histogram; scatter; line; boxplot 

usage of barplot: 

*/

*sysuse auto, replace
*webuse nlswork, clear
*save nlswork, replace
use nlswork, clear

***bar plot (freq)

graph bar (count), over(nev_mar)

*bar (percent)
graph bar, over(nev_mar) over(race) over(collgrad) ylabel(0(10)100)

label define nev_mar 0"Unmarried" 1"Married"
label val nev_mar nev_mar
label define grad 0"Not graduate" 1"Graduate"
label val collgrad grad

*bar chart e xtitle dewa jay na. 
*pie
graph pie, over(nev_mar)

*statsby command??? 
*rcap command???