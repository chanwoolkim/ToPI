* ----------------------------------- *
* Graphs of treatment effects - outcome
* Author: Chanwool Kim
* ----------------------------------- *

clear all

* ------------ *
* Prepare matrix

local nrow : list sizeof global(outcome_types2)

foreach age of numlist 3 {
	foreach p of global programs {

		cd "$data_working"
		use "`p'-topi.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_`age' = J(`nrow', 5, .) // for randomisation variable
		qui matrix `p'D_`age' = J(`nrow', 5, .) // for participation variable

		qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
		qui matrix colnames `p'D_`age' = `p'D_`age'num `p'D_`age'coeff `p'D_`age'lower `p'D_`age'upper `p'D_`age'pval

		local row_`age' = 1

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global outcome_types2 {
			qui matrix `p'R_`age'[`row_`age'',1] = `row_`age''
			qui matrix `p'D_`age'[`row_`age'',1] = `row_`age''

			capture confirm variable `r'`age'y
			if !_rc {
				* Randomisation variable
				sum `r'`age'y
				replace `r'`age'y= (`r'`age'y-r(mean))/r(sd)
				qui regress `r'`age'y R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`row_`age'',2] = r[1,1]
				qui matrix `p'R_`age'[`row_`age'',3] = r[5,1]
				qui matrix `p'R_`age'[`row_`age'',4] = r[6,1]
				qui matrix `p'R_`age'[`row_`age'',5] = r[4,1]

				* Participation variable (program specific)
				* We only want to do IV regression only if there is significant variability (> 1%)
				count if !missing(`r'`age'y) & !missing(D)
				local nobs = r(N)
				count if R != D & !missing(`r'`age'y) & !missing(D)
				local ndiff = r(N)
				local nprop = `ndiff'/`nobs'

				if `nprop' < 0.01 | `ndiff' < 2 {
					di "Not much variability"
					qui regress `r'`age'y R $covariates if !missing(D)
				}

				else {
					qui ivregress 2sls `r'`age'y (D = R) $covariates if !missing(D)
				}
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'D_`age'[`row_`age'',2] = r[1,1]
				qui matrix `p'D_`age'[`row_`age'',3] = r[5,1]
				qui matrix `p'D_`age'[`row_`age'',4] = r[6,1]
				qui matrix `p'D_`age'[`row_`age'',5] = r[4,1]

				local row_`age' = `row_`age'' + 1
			}

			else {
				local row_`age' = `row_`age'' + 1
			}
		}

		cd "$data_working"

		svmat `p'R_`age', names(col)
		rename `p'R_`age'num row_`age'
		keep row_`age' `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
		keep if row_`age' != .
		save "`p'-pile-outcome-`age'", replace

		clear
		svmat `p'D_`age', names(col)
		rename `p'D_`age'num row_`age'
		keep row_`age' `p'D_`age'coeff `p'D_`age'lower `p'D_`age'upper `p'D_`age'pval
		keep if row_`age' != .
		save "`p'-pile-outcome-D-`age'", replace
	}

	cd "$data_working"

	* Randomisation

	use ehscenter-pile-outcome-`age', clear

	foreach p of global programs {
		merge 1:1 row_`age' using `p'-pile-outcome-`age', nogen nolabel
	}

	rename row_`age' row
	save outcome-pile-`age', replace

	* Participation

	use ehscenter-pile-outcome-D-`age', clear

	foreach p of global programs {
		merge 1:1 row_`age' using `p'-pile-outcome-D-`age', nogen nolabel
	}

	rename row_`age' row
	save outcome-pile-D-`age', replace
}

* --------*
* Questions NOTE: This is the only section that depends on the outcomes.
*Makes sense to have them in a separate function

foreach age of numlist 3 {
	cd "$data_working"
	use outcome-pile-`age', clear
	include "${code_path}/function/outcome2"
	save outcome-pile-`age', replace

	use outcome-pile-D-`age', clear
	include "${code_path}/function/outcome2"
	save outcome-pile-D-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 3 {
	cd "$data_working"
	use outcome-pile-`age', clear

	*include "${code_path}/function/significance"
	foreach p of global programs {
	gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
	gen `p'Rinsig = .
	gen `p'R0_1 = .
	gen `p'R0_05 = .
	replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
	replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
	replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
}

	cd "$out"

graph dot 	ehsRinsig ehsR0_1 ehsR0_05 ///
			ihdpRinsig ihdpR0_1 ihdpR0_05 ///
			abcRinsig abcR0_1 abcR0_05 ///
			careRinsig careR0_1 careR0_05, ///
	marker(1,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(O) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(7,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(8,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(9,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(10,msize(large) msymbol(S) mlc(navy) mfc(navy*0) mlw(thick)) marker(11,msize(large) msymbol(S) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(12,msize(large) msymbol(S) mlc(navy) mfc(navy) mlw(thick)) ///
	over(scale, label(labsize(large)) sort(scale_row)) ///
	legend (order (3 "EHS" 6 "IHDP" 9 "ABC" 12 "CARE") size(medsmall)) yline(0) ylabel(#4, labsize(medsmall)) ///
	ylabel($outcome_axis_range2) ysize(1) xsize(2) ///
	graphregion(fcolor(white)) bgcolor(white)

	graph export "outcome2_pile_R_`age'.pdf", replace
	
graph dot 	ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
			ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
			ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05, ///
	marker(1,msize(large) msymbol(S) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(S) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(S) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(7,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) marker(8,msize(large) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(9,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	over(scale, label(labsize(large)) sort(scale_row)) ///
	legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed") size(medsmall)) yline(0) ylabel(#7, labsize(medsmall)) ///
	ylabel($outcome_axis_range2) ysize(1) xsize(2) ///
	graphregion(fcolor(white)) bgcolor(white)

	graph export "outcome2_pile_R_`age'_ehs.pdf", replace

graph dot 	carebothRinsig carebothR0_1 carebothR0_05 ///
			carehomeRinsig carehomeR0_1 carehomeR0_05, ///
	marker(1,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(O) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
		over(scale, label(labsize(large)) sort(scale_row)) ///
	legend (order (3 "CARE-Both" 6 "CARE-Home" ) size(medsmall)) yline(0) ylabel(#7, labsize(medsmall)) ///
	ylabel($outcome_axis_range2) ysize(1) xsize(2) ///
	graphregion(fcolor(white)) bgcolor(white)

	graph export "outcome2_pile_R_`age'_sep.pdf", replace

graph dot 	ehscenterRinsig ehscenterR0_1 ehscenterR0_05 	///
			ehshomeRinsig ehshomeR0_1 ehshomeR0_05 			///
			ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05 		///
			carebothRinsig carebothR0_1 carebothR0_05 		///
			carehomeRinsig carehomeR0_1 carehomeR0_05, 		///
	marker(1,msize(large) msymbol(o) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(o) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(o) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(t) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(t) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(t) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(7,msize(large) msymbol(d) mlc(navy) mfc(navy*0) mlw(thick)) marker(8,msize(large) msymbol(d) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(9,msize(large) msymbol(d) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(10,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) marker(11,msize(large) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(12,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(13,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(14,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(15,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///	
	over(scale, label(labsize(large)) sort(scale_row)) ///
	legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed" 12 "CARE-Both" 15 "CARE-Home") size(medsmall)) yline(0) ylabel(#7, labsize(medsmall)) ///
	ylabel($outcome_axis_range2) ysize(1) xsize(2) ///
	graphregion(fcolor(white)) bgcolor(white)

	graph export "outcome2_pile_R_`age'_mode.pdf", replace

	}
cap drop scale
cap drop scale_num
cap drop scale_row
cap drop row
