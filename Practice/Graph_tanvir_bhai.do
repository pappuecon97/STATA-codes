
*sysuse auto, replace
webuse nlswork, clear
save nlswork, replace
use nlswork, clear



******** Bar plot (Frequency)
set scheme burd4
graph bar (count), over(nev_mar)

label define nev_mar 0 "Married" 1 "Unmarried"
label values nev_mar nev_mar

label define collgrad 0 "Not grad" 1 "Grad"
label values collgrad collgrad

******** pie chart
graph pie, over(nev_mar)

graph pie, over(nev_mar) by(race)


******** Bar plot (Frequency)
graph bar (count), over(nev_mar) by(race)


graph bar (count), over(nev_mar) over(race)

******** Bar plot (Percentage)
graph bar (percent), over(nev_mar) over(race)

********

******** title, x-axis label, y-axis label etc
graph bar (percent), over(nev_mar) over(race) title("This is a trial title") xtitle("This is a trial X-title") ytitle("This is a trial Y-title")


******** xtitle doesn't work for bar chart (No idea why). Instead we use b1title()
graph bar (percent), over(nev_mar) over(race) title("This is a trial title") b1title("This is a trial X-title") ytitle("This is a trial Y-title")


******** yscale, ylab
graph bar (percent), over(nev_mar) over(race) title("This is a trial title") b1title("This is a trial X-title") ytitle("This is a trial Y-title") yscale(range(0,100))

graph bar (percent), over(nev_mar) over(race) title("This is a trial title") b1title("This is a trial X-title") ytitle("This is a trial Y-title") yscale(range(0,100)) ylabel(#10)

graph bar (percent), over(nev_mar) over(race) title("This is a trial title") b1title("This is a trial X-title") ytitle("This is a trial Y-title") yscale(range(0,100)) ylabel(0 "0%" 10 "10%" 20 "20%" 50 "50%" 80 "80%" 90 "90%" 100 "100%" )

graph hbar (percent), over(nev_mar) over(race) title("This is a trial title") b1title("This is a trial X-title") ytitle("This is a trial Y-title") yscale(range(0,100)) ylabel(0 "0%" 10 "10%" 20 "20%" 50 "50%" 80 "80%" 90 "90%" 100 "100%" )


*********** bar plot average
graph bar (mean) age, over(nev_mar) over(race) title("This is a trial title") b1title("This is a trial X-title") ytitle("This is a trial Y-title")

graph hbar (mean) age, over(nev_mar) over(race) title("This is a trial title") ytitle("This is a trial Y-title")


*********** Bar plot stacked
tab nev_mar, gen(mar)
rename mar1 Married
rename mar2 Unmarried

graph bar Married Unmarried, over(race) stack ylabel(0 "0%" 0.25 "25%" 0.50 "50%" 0.75 "75%" 1 "100%" )


graph bar Married Unmarried, over(race) stack ylabel(0 "0%" 0.25 "25%" 0.50 "50%" 0.75 "75%" 1 "100%" ) legend(order (1 "Married" 2 "Unmarried"))



******************************** Codes from Wahed bhai
sysuse auto, replace

**color
global skyblue "86 180 233"
global blue "0 114 178"
global teal "17 222 245"
global orange "213 94 0"
global green "0 158 115"
global yellow "230 159 0"
global purple "204 121 167"
global lavendar "154 121 204"

**sequential color
global blue1 "158 202 225"
global blue2 "66 146 198"
global blue3 "8 81 156"

global purple1 "188 189 220"
global purple2 "128 125 186"
global purple3 "84 39 143"





**let's use price in thousands for a better scaling of xaxis
gen price_in_k=price/1000


*now create a scatter graph. 

*notice there is no ytitle, it is delibarately done. I want all my labels and axes to be vertical so that I do not have to rotate my neck to read anything
*so, ytilte is embedded into the title


twoway  (scatter mpg price_in_k, color("$blue")) ///
,xlabel(0(5)20,) ///
legend(order() row() pos() size()) ///
ytitle("") subtitle("", justification(left) margin(b+10 t-1 l-1) bexpand size(1)) ///
ylabel(0(10)50,labsize(small)) title("Mileage (miles per gallon) of cars of different prices", justification(left) margin(b+1 t-1 l-1) bexpand size(small))  ///
graphregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white)) ///
plotregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white))       xtitle(Price (in thousands), size(small)) ///
note(, size(vsmall)) ///
caption(, size(vsmall))


*now I will do a bar graph. I want to see average price and mpg by foreign. If you use the "graph bar" command, it automatically uses the mean, but I will use //
*twoway bar, for which you need to create the mean. SO I will collapse the data



collapse mpg price_in_k, by(foreign)

**If I create a bar graph now, it will do stacked, and is not that nice. However, see where I put the legend to make it easier to read

twoway  (bar mpg foreign, color("$blue")  lcolor(black)) ///
(bar price_in_k foreign, color("$purple")  lcolor(black)) ///
,xlabel(0 "Domestic"  1"Foreign",) ///
legend(order(1 "Mileage (mpg)" 2 "Price (in thousands)") row(2) pos(4) size()) ///
ytitle("") subtitle("", justification(left) margin(b+1 t-1 l-1) bexpand size(1)) ///
ylabel(0(10)30,labsize(small)) title("Mileage and price of cars of different origins", justification(left) margin(b+1 t-1 l-1) bexpand size(small))  ///
graphregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white)) ///
plotregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white)) note(, size(vsmall)) ///
caption(, size(vsmall))


*Now I will do some data manupulation to make a graph that looks better, is more presentable 
*inspired by this blog: https://blogs.worldbank.org/impactevaluations/tools-trade-graphing-impacts-standard-error-bars





ren mpg y1
ren price_in_k y2

reshape long y, i(foreign) j(outcome)  // becuase I will plot bars side by side

**Create a group variable that will help with how the bars appear

egen foreign_outcome=group(foreign outcome)  // the order of this matters. try doing group(outcome foreign) and see what happens

replace foreign_outcome=foreign_outcome+1 if foreign==1 //  This puts spaces in between outcomes 

*now plot 

twoway  (bar y foreign_outcome if outcome==1, color("$blue")) ///
(bar y foreign_outcome if outcome==2, color("$purple")) ///
,xlabel(1.5 "Domestic" 4.5 "Foreign",) ///
legend(order(1 "Mileage (mpg)" 2 "Price (in thousands)" ) row(1) pos(6) size()) ///
ytitle("") subtitle("", justification(left) margin(b+1 t-1 l-1) bexpand size(1)) ///
ylabel(0(10)30,labsize(small)) title("Mileage and price of cars of different origins", justification(left) margin(b+1 t-1 l-1) bexpand size(small))  ///
graphregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white)) ///
plotregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white))       xtitle("", size(small)) ///
note(, size(vsmall)) ///
caption(, size(vsmall))

*In this graph, it is hard to compare the same outcome of foreign and domestic cars as they are not side by side. So, I do not like it. So I do the ///
*following. 


egen outcome_foreign=group(outcome foreign)   

replace outcome_foreign=outcome_foreign+1 if outcome==2  //  This puts spaces in between outcomes 

*now plot 

twoway  (bar y outcome_foreign if foreign==0, color("$blue")) ///
(bar y outcome_foreign if foreign==1, color("$purple")) ///
,xlabel(1.5 "Mileage (mpg)" 4.5 "Price (in thousands)",) ///
legend(order(1 "Domestic" 2 "Foreign") row(1) pos(6) size()) ///
ytitle("") subtitle("", justification(left) margin(b+1 t-1 l-1) bexpand size(1)) ///
ylabel(0(10)30,labsize(small)) title("Mileage and price of cars of different origins", justification(left) margin(b+1 t-1 l-1) bexpand size(small))  ///
graphregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white)) ///
plotregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white)) xtitle("", size(small)) ///
note(, size(vsmall)) ///
caption(, size(vsmall)) 


**I also want  the values at the top of the bar

clonevar yval=y
format yval %9.1f  // because I want them to look pretty


twoway  (bar y outcome_foreign if foreign==0, color("$blue")) ///
(bar y outcome_foreign if foreign==1, color("$purple")) ///
(scatter y outcome_foreign, msymbol(i) mlabel(yval) mlabposition(12)) ///  change mlabposition if 6 if you want the values to be inside
,xlabel(1.5 "Mileage (mpg)" 4.5 "Price (in thousands)",) ///
legend(order(1 "Domestic" 2 "Foreign") row(1) pos(6) size()) ///
ytitle("") subtitle("", justification(left) margin(b+1 t-1 l-1) bexpand size(1)) ///
ylabel(0(10)30,labsize(small)) title("Mileage and price of cars of different origins", justification(left) margin(b+1 t-1 l-1) bexpand size(small))  ///
graphregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white)) ///
plotregion(color(white) fcolor(white) icolor(white) ifcolor(white) lcolor(white) ilcolor(white))       xtitle("", size(small)) ///
note(, size(vsmall)) ///
caption(, size(vsmall))

**This one, I like!
  
/*remove comment, insert proper filepath and file name
graph save "$base_dir/", replace
graph export  "$base_dir/", replace width(800)
*/

