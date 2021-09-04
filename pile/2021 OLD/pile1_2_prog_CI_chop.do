* ------------------------------------- *
* PILE PLOT WITH CONFIDENCE INTERVAL 	*
*	Intent to Treat					 	*
* Author: Andrés                     	*	
* ------------------------------------- *

* Requires manual inputs:
clear all

local prog1 ehscenter
local prog2 ihdp
local prog3 ihdp
local prog4 abc

local out1 ppvt
local out2 sb
local out3 ppvt
local out4 sb

local ehscenter_ppvt	ppvt3y
local ihdp_sb			sb3y	
local ihdp_ppvt			ppvt3y
local abc_sb 			sb3y

local rows=4

* ------------ * Base ITT * ------------ * 

* Prepare matrix *

cd "$data_working"
local row = 1
	matrix R = J(`rows', 5, .)
		matrix colnames R = numR coeffR lowerR upperR pvalR

	forv p =1/`rows' {
		use "`prog`p''-topi.dta", clear
		di `"ITT: `prog`p'' ``prog`p''_`out`p''' "'
		regress ``prog`p''_`out`p''' R
				qui matrix list r(table)
				qui matrix r = r(table)
				qui matrix R[`row',1] = `row'
				qui matrix R[`row',2] = r[1,1]
				qui matrix R[`row',3] = r[5,1]
				qui matrix R[`row',4] = r[6,1] 
				qui matrix R[`row',5] = r[4,1]
				local row = `row' + 1
		}

		svmat R, names(col)
		keep numR coeffR lowerR upperR pvalR
		keep if numR != .

* Prepare Graph *
label define Outcomes	///
1 "EHS CENTER PPVT Age 3"		///
2 "IHDP SB Age 3"		///
3 "IHDP PPVT Age 3"		///
4 "ABC SB Age 3"		
label values numR Outcomes

twoway (scatter numR coeffR,ylabel(,val angle(360)) ) (rcap lowerR upperR numR, horizontal) ///
	,graphregion(fcolor(white)) legend(off) ytitle("")
	
cd "$out"
	graph export "pile1_itt.pdf", replace
cd "$git_out"
	graph export "pile2_itt.pdf", replace

* ------------ * Chopped ITT * ------------ * 

* Prepare matrix *

cd "$data_working"
local row = 1
	matrix R = J(`rows', 5, .)
		matrix colnames R = numR coeffR lowerR upperR pvalR

	forv p =1/`rows' {
		use "`prog`p''-topi.dta", clear
		di `"ITT: `prog`p'' ``prog`p''_`out`p''' "'
		if "`prog`p''"=="ihdp" drop if twin==1 //drops all twins (redundant)
		regress ``prog`p''_`out`p''' R if bw>2000 & black==1
				qui matrix list r(table)
				qui matrix r = r(table)
				qui matrix R[`row',1] = `row'
				qui matrix R[`row',2] = r[1,1]
				qui matrix R[`row',3] = r[5,1]
				qui matrix R[`row',4] = r[6,1] 
				qui matrix R[`row',5] = r[4,1]
				local row = `row' + 1
		}

		svmat R, names(col)
		keep numR coeffR lowerR upperR pvalR
		keep if numR != .
		

* Prepare Graph *
label define Outcomes	///
1 "EHS CENTER PPVT Age 3"		///
2 "IHDP SB Age 3"		///
3 "IHDP PPVT Age 3"		///
4 "ABC SB Age 3"		
label values numR Outcomes

twoway (scatter numR coeffR,ylabel(,val angle(360)) ) (rcap lowerR upperR numR, horizontal) ///
	,graphregion(fcolor(white)) legend(off) ytitle("")
	
cd "$out"
	graph export "pile2_itt_chop.pdf", replace
cd "$git_out"
	graph export "pile2_itt_chop.pdf", replace
