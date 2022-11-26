****copy and reassinging var label after collapse ****

*load data
webuse reshape1, clear


*reshape 
reshape long inc ue, i(id) j(year)

*lab var
lab var id "person's id"
lab var year "year"
lab var  sex "Gender of a person"
lab var inc "Income of the individual"
lab var ue "Umployment status"

************these are the codes to copy and paste var label************

*copy var label 
foreach i of var * {
        local l`i' : variable label `i'
            if `"`l`i''"' == "" {
            local l`i' "`i'"
        }
}

collapse inc (first) sex, by(id)

*attach var label
foreach i of var *{
        label var `i' "`l`i''"
}


