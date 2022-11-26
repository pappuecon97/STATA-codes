************** HW: loop for repeating numbers **********

forvalues i = 1/15{
	forvalues j = 1/`i'{
	display `j' _continue
	display " " _continue
	}
display _newline	
}


