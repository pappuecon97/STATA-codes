******** Random sampling drawing and Randomization**********

*cd 
cd "K:\My Drive\Temp"

*load data
import excel "C:\Users\Dell\Dropbox\My PC (DESKTOP-JT78TJM)\Downloads\audio_list.xlsx", sheet("Sheet1") firstrow case(lower) clear

*check missing
mdesc

*encode
encode main_id, gen(main_id_1)

*drop missing
drop if main_id_1==.

*random sample
count 

*draw random sample
sample 5

*randomization
isid main_id_1, sort

*set seed 
set seed 58550678

*create random var
 gen random_var = uniform()
 
 *order by random number
 egen ordering = rank(random_var)
 
 *sort
 sort ordering
 
 *Assign observations to control & treatment group based on their ranks 
display _N
gen totalobs = _N

*distrbute treatment and control 
gen treatment = cond( ordering> 0.5*_N , 1 , 0 )

*rename and relabel treatment
rename treatment assign_var
lab define assign_lab 1"Ulfat" 0"Johir"
la val assign_var assign_lab

*drop vars not needed
drop totalobs ordering random_var main_id_1
	
*save data 
export excel using "K:\My Drive\Temp\audio_list_ASER_inperson.xls", firstrow(variables) replace

	
	