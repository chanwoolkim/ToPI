* ------------------------------------- *
* PILE PLOT WITH CONFIDENCE INTERVAL 	*
*	Intent to Treat					 	*
* Author: Andrés                     	*	
* ------------------------------------- *

* Requires manual inputs:
clear all

local prog1 ehscenter
local prog2 ihdp

local out1 kidi
local out2 kidi

local ehscenter_kidi	norm_kidi_total2y
local ihdp_kidi			kidi_accuracy24

local rows=2

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
1 "EHS CENTER KIDI Age 3"		///
2 "IHDP KIDI Age 3"		
label values numR Outcomes

twoway (scatter numR coeffR,ylabel(,val angle(360)) ) (rcap lowerR upperR numR, horizontal) ///
	if numR<=1.1 | numR>=1.9 ///
	,graphregion(fcolor(white)) legend(off) ytitle("")
	
cd "$out"
	graph export "kidi.pdf", replace
cd "$git_out"
	graph export "kidi.pdf", replace

