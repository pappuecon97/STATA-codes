/******************************************************************************
*Title: Task3 of STATA class by Tanvir bhaiya
*Created by: Md Johirul Islam
*Created on: STATA17
*Last Modified on: 22/10/22
*Last Modified by: MJI
*Purpose : Analysis of DHS model data Household Member Datasets. 
******************************************************************************/


*cd
cd "G:\My Drive\YRF Class\STATA"

*data
use "G:\My Drive\YRF Class\STATA\Practice Data\zz_2016_DHS_10212022_18434\hh_member\ZZPR62FL.DTA", clear

*create main_id
egen main_id= concat(hv001 hv002 hv003), punct("_")

*keeping necesary vars
keep hv002 hv003 hv009 hv201 hv205 hv207 hv208 hv209 hv210 hv211 hv212 hv219 hv217 hv220 hv218 hv221 hv227 hv243a hv243b hv243c hv243d hv244 hv245 hv246 hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j hml1 hml1a hml2 hv101 hv104 ha2 ha3 ha11 ha5 ha13 ha35 ha40 ha41 ha53 ha55 ha56 ha57 ha63 hc2 hc53 hc55 hc56 hc57 hc11 hc72 hc73 hb35 hb40 hb41 hb53 hb55 hb56 hb57 hb63 hml6 hml19 hml20 hml32 hml32a hml32b hml32c hml33 hml35 main_id hv001

*drop extra vars
drop hv207 hv208 hv209 hv210 hv211 hv212 hv221 hv243a hv243b hv243c hv243d

*create var hh_type
gen hh_type =1 if hv101==1 & hv104==1
replace hh_type=0 if hv101==1 & hv104==2


*****Assets and total number of assets ***
preserve

*copy var label 
foreach i of var * {
        local l`i' : variable label `i'
            if `"`l`i''"' == "" {
            local l`i' "`i'"
        }
}

*collapse
collapse (first) hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j hv205 hv227 hml1 hh_type hv002 hv003 hv001, by(main_id)

*attach var label
foreach i of var *{
        label var `i' "`l`i''"
}

*sort by main_id
sort hv001 hv002 hv003 

*gen total number of livestock vars
egen total_liv= rowtotal(hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j)

*drop hh_type missing values
drop if hh_type==.

*create sum table by hh_type on necesary vars
bys hh_type: outreg2 using "G:\My Drive\YRF Class\STATA\dhs_assets_tab.xls", replace sum(log) keep(hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j) eqkeep(mean sd) title(Table 1: Summary statistics of assets by household head gender) label

/*
*using asdoc
bys hh_type: asdoc sum hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j, save(dhs_sum_table.doc) replace 
*/

*label val
la define hh_tt 0"Female Head" 1"Male Head" 
la value hh_type hh_tt

save "dhs_hh_level_final.dta", replace


****************************Graphs***********

*manupulation for graphs

*copy var label 
foreach i of var * {
        local l`i' : variable label `i'
            if `"`l`i''"' == "" {
            local l`i' "`i'"
        }
}

*collapse
collapse (sum) hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j, by(hh_type)

*attach var label
foreach i of var *{
        label var `i' "`l`i''"
}


*label hh_type
la value hh_type hh_tt

*ownership of livestock by hh_type
graph bar (mean) hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j, over(hh_type, gap(*2) label(labsize(small))) ///
					blabel(bar, format(%9.0f)) ///
					ytitle("") subtitle("", justification(centre) bexpand size(1)) ///
					title("Average Livestock Ownership by Household Head Gender", justification(center) margin(b+4 t-1 l-1) bexpand size(medium))  ///
					note("Source: DHS data. This graph is created for Priscilla Tahsin", size(vsmall)) ///
						legend(order(1 "Cow" 2 "Horse/Donkey" 3 "Goat" 4 "Sheep" 5 "Chicken" 6 "Pig" 7 "Rabbit" 8 "Rodent" 9 "Bird") row() pos(bottom) size(small)) ///
						ysc(off) ysca(noline) scheme(tab2) //remode y-axis "xsc(off)" for x-axis 


*save graph 
graph export "dhs_hh_asset_ownership.png", replace
		

*for total number of assets
use "dhs_hh_level_final.dta", clear

*total livestock by hh_type
graph bar (sum) total_liv, over(hh_type, gap(*2) label(labsize(small))) ///
					blabel(bar, format(%9.0f)) ///
					ytitle("") subtitle("", justification(centre) bexpand size(1)) ///
					title("Average Total Livestock Ownership by Household Head Gender", justification(center) margin(b+4 t-1 l-1) bexpand size(medium))  ///
					note("Source: DHS data. This graph is created for Priscilla Tahsin", size(vsmall)) ///
						legend(order() row() pos(bottom) size(small)) ///
						ysc(off) ysca(noline) scheme(tab3) //remode y-axis "xsc(off)" for x-axis 

*save graph 
graph export "dhs_total_asset_ownership.png", replace

********for toilet facility 

preserve

collapse (sum) hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j, by(hv205 hh_type)

drop if hh_type==.

*labelling
label define hv205_label ///
					11 "flush to piped sewer system" ///
					12 "flush to septic tank" ///
					13 "flush to pit latrine" ///
					14 "flush to somewhere else" ///
					15 "flush, don't know where" ///
					21 "ventilated improved pit latrine (vip)" ///
					22 "pit latrine with slab" ///
					23 "pit latrine without slab/open pit" ///
					31 "no facility/bush/field" ///
					41 "composting toilet" ///
					42 "bucket toilet" ///
					43 "hanging toilet/latrine" ///
					96 "Other" 
					
label val hv205 hv205_label

*graph 

local vars "hv246b hv246c hv246d hv246e hv246f hv246g hv246h hv246i hv246j"
			
				
*save graph 
graph export "dhs_toilet_facilty.png", replace

restore
