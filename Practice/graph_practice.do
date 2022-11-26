**scheme set
set scheme s2color8


line le_male-le_wfemale year, text(42 1920 "{bf: 1918} {it: Influenza} Pandemic", place(3))

scatter le year if year >=1950 ///
|| lfit le year if year >=1950


scatter le_male le_female year ///
|| lfit le_male year if year >=1925 & year <1950 ///
|| lfit le_male year if year >=1950 ///
|| lfit le_female year if year >=1925 & year <1950 ///
|| lfit le_female year if year >=1950


*legend off and add title
scatter le_male le_female year if year >= 1950 ///
|| lfit le_male year if year >= 1950 ///
|| lfit le_female year if year >= 1950, title("US Male and Female Life Expectancy, 1950-2000") text(75 1978 "Female", place(3)) text(68 1978 "Male", place(3)) legend(off)

*CI, labelling axes, 

twoway (lfitci lexp safewater if region == 2) ///
		(scatter lexp safewater if region ==2), ///
		ytitle("Life Expectancy at birth") ///
		xtitle("Safe water access") ///
		legend(ring(0) pos(5) order(2 "Linear fit" 1 "95% CI"))


*markers labelling

twoway (lfitci lexp safewater if region == 2) ///
		(scatter lexp safewater if region ==2 | region ==3, mlabel(country)), ///
		ytitle("Life Expectancy at birth") ///
		xtitle("Safe water access") ///
		legend(ring(0) pos(5) order(2 "Linear fit" 1 "95% CI")) ///
		plotregion(margin(r+10))

		

twoway (scatter lexp safewater if region ==2, mlabel(country)) ///
		(scatter lexp safewater if region ==3, mlabel(country)), ///
		ytitle("Life Expectancy at birth") ///
		xtitle("Safe water access") ///
		legend(ring(0) pos(5) order(1 "North America" 2 "South America") cols(1))
		


		
