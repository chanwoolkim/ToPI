* ---------------------------------------------------------------- *
* Graphs of treatment effects - aggregate pile (substitution effect)
* Author: Chanwool Kim
* Date Created: 22 Jan 2018
* Last Update: 1 Mar 2018
* ---------------------------------------------------------------- *

clear all

* ------------ *
* Prepare matrix

foreach p of global programs_merge {
	foreach t of global `p'_type {

	cd "$pile_working"
	use "`p'`t'-home-agg-pile.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'`t'R_1 = J(7, 5, .) // for randomisation variable
		qui matrix `p'`t'R_3 = J(9, 5, .) // for randomisation variable
		
		qui matrix colnames `p'`t'R_1 = `p'`t'R_1num `p'`t'R_1coeff `p'`t'R_1lower `p'`t'R_1upper `p'`t'R_1pval
		qui matrix colnames `p'`t'R_3 = `p'`t'R_3num `p'`t'R_3coeff `p'`t'R_3lower `p'`t'R_3upper `p'`t'R_3pval
		
		local row_1 = 1
		local row_3 = 1
		
		if "`p'" == "abc" {
			qui matrix `p'`t'R_6m = J(7, 5, .) // for randomisation variable
			qui matrix colnames `p'`t'R_6m = `p'`t'R_6mnum `p'`t'R_6mcoeff `p'`t'R_6mlower `p'`t'R_6mupper `p'`t'R_6mpval
			
			local row_6m = 1
		}

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global early_home_types {
			qui matrix `p'`t'R_1[`row_1',1] = `row_1'
			
			capture confirm variable norm_home_`r'1y
				if !_rc {
				* Randomisation variable
				qui xi: regress norm_home_`r'1y i.R*bw if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'`t'R_1[`row_1',2] = r[1,3]
				qui matrix `p'`t'R_1[`row_1',3] = r[5,3]
				qui matrix `p'`t'R_1[`row_1',4] = r[6,3]
				qui matrix `p'`t'R_1[`row_1',5] = r[4,3]
				
				local row_1 = `row_1' + 1
				}
					
				else {
				local row_1 = `row_1' + 1
				}
			
			if "`p'" == "abc" {
				qui matrix `p'`t'R_6m[`row_6m',1] = `row_6m'
				
				capture confirm variable norm_home_`r'6m
					if !_rc {
					* Randomisation variable
					qui xi: regress norm_home_`r'6m i.R*bw if !missing(D)
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)

					qui matrix `p'`t'R_6m[`row_6m',2] = r[1,3]
					qui matrix `p'`t'R_6m[`row_6m',3] = r[5,3]
					qui matrix `p'`t'R_6m[`row_6m',4] = r[6,3]
					qui matrix `p'`t'R_6m[`row_6m',5] = r[4,3]
					
					local row_6m = `row_6m' + 1
					}
						
					else {
					local row_6m = `row_6m' + 1
					}
			}
		}

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global later_home_types {
			qui matrix `p'`t'R_3[`row_3',1] = `row_3'
				
			capture confirm variable norm_home_`r'3y
				if !_rc {
				* Randomisation variable
				qui xi: regress norm_home_`r'3y i.R*bw if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'`t'R_3[`row_3',2] = r[1,3]
				qui matrix `p'`t'R_3[`row_3',3] = r[5,3]
				qui matrix `p'`t'R_3[`row_3',4] = r[6,3]
				qui matrix `p'`t'R_3[`row_3',5] = r[4,3]

				local row_3 = `row_3' + 1
				}
					
				else {
				local row_3 = `row_3' + 1
				}
			}
			
		cd "$pile_working"
		
		if "`p'" == "abc" {
			svmat `p'`t'R_6m, names(col)
			rename `p'`t'R_6mnum row_6m
			keep row_6m `p'`t'R_6mcoeff `p'`t'R_6mlower `p'`t'R_6mupper `p'`t'R_6mpval
			keep if row_6m != .
			save "`p'`t'-pile-agg-sub-6m", replace
		}

		svmat `p'`t'R_1, names(col)
		rename `p'`t'R_1num row_1
		keep row_1 `p'`t'R_1coeff `p'`t'R_1lower `p'`t'R_1upper `p'`t'R_1pval
		keep if row_1 != .
		save "`p'`t'-pile-agg-sub-1", replace

		svmat `p'`t'R_3, names(col)
		rename `p'`t'R_3num row_3
		keep row_3 `p'`t'R_3coeff `p'`t'R_3lower `p'`t'R_3upper `p'`t'R_3pval
		keep if row_3 != .
		save "`p'`t'-pile-agg-sub-3", replace
	}
}

cd "$pile_working"

* Randomisation

use abc-pile-agg-sub-6m, clear
rename row_6m row
save abc-agg-pile-sub-6m, replace

foreach p of global programs_merge {
	use `p'-pile-agg-sub-1, clear

	foreach t of global `p'_type {
		merge 1:1 row_1 using `p'`t'-pile-agg-sub-1, nogen nolabel
	}

	rename row_1 row
	save `p'-agg-pile-sub-1, replace

	use `p'-pile-agg-sub-3, clear

	foreach t of global `p'_type {
		merge 1:1 row_3 using `p'`t'-pile-agg-sub-3, nogen nolabel
	}

	rename row_3 row
	save `p'-agg-pile-sub-3, replace
}

* --------*
* Questions

foreach p of global programs_merge {
	cd "$pile_working"
	
	if "`p'" == "abc" {
		use `p'-agg-pile-sub-6m, clear

		tostring row, gen(scale_num)

		replace scale = "Total Score" if scale_num == "1"
		replace scale = "Parental Warmth" if scale_num == "2"
		replace scale = "Parental Verbal Skills" if scale_num == "3"
		replace scale = "Parental Lack of Hostility" if scale_num == "4"
		replace scale = "Learning/Literacy" if scale_num == "5"
		replace scale = "Activities/Outings" if scale_num == "6"
		replace scale = "Developmental Advance" if scale_num == "7"

		save `p'-agg-pile-sub-6m, replace
	}

	use `p'-agg-pile-sub-1, clear

	tostring row, gen(scale_num)

	replace scale = "Total Score" if scale_num == "1"
	replace scale = "Parental Warmth" if scale_num == "2"
	replace scale = "Parental Verbal Skills" if scale_num == "3"
	replace scale = "Parental Lack of Hostility" if scale_num == "4"
	replace scale = "Learning/Literacy" if scale_num == "5"
	replace scale = "Activities/Outings" if scale_num == "6"
	replace scale = "Developmental Advance" if scale_num == "7"

	save `p'-agg-pile-sub-1, replace

	use `p'-agg-pile-sub-3, clear

	tostring row, gen(scale_num)

	replace scale = "Total Score" if scale_num == "1"
	replace scale = "Learning Stimulation" if scale_num == "2"
	replace scale = "Access to Reading" if scale_num == "3"
	replace scale = "Parental Verbal Skills" if scale_num == "4"
	replace scale = "Parental Warmth" if scale_num == "5"
	replace scale = "Home Exterior" if scale_num == "6"
	replace scale = "Home Interior" if scale_num == "7"
	replace scale = "Outings/Activities" if scale_num == "8"
	replace scale = "Parental Lack of Hostility" if scale_num == "9"

	save `p'-agg-pile-sub-3, replace
}

* ----------------- *
* Execution - P-value

foreach p of global programs_merge {
	foreach age of numlist 1 3 {
		* Randomisation
		
		cd "$pile_working"
		use `p'-agg-pile-sub-`age', clear
		
		foreach t of global `p'_type {
			gen inv_`p'`t'Rcoeff = `p'`t'R_`age'coeff * -1
			gen `p'`t'Rinsig = .
			gen `p'`t'R0_1 = .
			gen `p'`t'R0_05 = .
			replace `p'`t'Rinsig = `p'`t'R_`age'coeff if `p'`t'R_`age'pval > 0.1
			replace `p'`t'R0_1 = `p'`t'R_`age'coeff if `p'`t'R_`age'pval <= 0.1 & `p'`t'R_`age'pval > 0.05
			replace `p'`t'R0_05 = `p'`t'R_`age'coeff if `p'`t'R_`age'pval <= 0.05
		}
		
		save `p'-agg-pile-sub-`age', replace
	}
}

cd "$pile_working"
use abc-agg-pile-sub-6m, clear

gen inv_abcRcoeff = abcR_6mcoeff * -1
gen abcRinsig = .
gen abcR0_1 = .
gen abcR0_05 = .
replace abcRinsig = abcR_6mcoeff if abcR_6mpval > 0.1
replace abcR0_1 = abcR_6mcoeff if abcR_6mpval <= 0.1 & abcR_6mpval > 0.05
replace abcR0_05 = abcR_6mcoeff if abcR_6mpval <= 0.05

save abc-agg-pile-sub-6m, replace

* EHS
foreach age of numlist 1 3 {
	cd "$pile_working"
	use ehs-agg-pile-sub-`age', clear

	graph dot ehsRinsig ehsR0_1 ehsR0_05 ///
			  ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
			  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
			  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05, ///
		  marker(1,msize(large) msymbol(D) mlc(red) mfc(red*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(red) mfc(red*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(red) mfc(red) mlw(thin)) ///
		  marker(4,msize(large) msymbol(O) mlc(red) mfc(red*0) mlw(thin)) marker(5,msize(large) msymbol(O) mlc(red) mfc(red*0.5) mlw(thin)) marker(6,msize(large) msymbol(O) mlc(red) mfc(red) mlw(thin)) ///
		  marker(7,msize(large) msymbol(T) mlc(red) mfc(red*0) mlw(thin)) marker(8,msize(large) msymbol(T) mlc(red) mfc(red*0.5) mlw(thin)) marker(9,msize(large) msymbol(T) mlc(red) mfc(red) mlw(thin)) ///
		  marker(10,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thin)) marker(11,msize(large) msymbol(S) mlc(red) mfc(red*0.5) mlw(thin)) marker(12,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thin)) ///
		  over(scale, label(labsize(vsmall)) sort(scale_num)) ///
		  legend (order (3 "EHS-All" 6 "EHS-Center" 9 "EHS-Home" 12 "EHS-Mixed") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		  ylabel($sub_axis_range) ///
		  graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "ehs_sub_agg_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out/substitution"
	graph export "ehs_sub_agg_pile_R_`age'.png", replace
}

* IHDP
foreach age of numlist 1 3 {
	cd "$pile_working"
	use ihdp-agg-pile-sub-`age', clear

	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05 ///
			  ihdphighRinsig ihdphighR0_1 ihdphighR0_05 ///
			  ihdplowRinsig ihdplowR0_1 ihdplowR0_05, ///
		  marker(1,msize(large) msymbol(D) mlc(green) mfc(green*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(green) mfc(green*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(green) mfc(green) mlw(thin)) ///
		  marker(4,msize(large) msymbol(T) mlc(green) mfc(green*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(green) mfc(green*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(green) mfc(green) mlw(thin)) ///
		  marker(7,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(8,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(9,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
		  over(scale, label(labsize(vsmall)) sort(scale_num)) ///
		  legend (order (3 "IHDP-All" 6 "IHDP-High" 9 "IHDP-Low") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		  ylabel($sub_axis_range) ///
		  graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "ihdp_sub_agg_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out/substitution"
	graph export "ihdp_sub_agg_pile_R_`age'.png", replace
}

* ABC
foreach age in 6m 1 3 {
	cd "$pile_working"
	use abc-agg-pile-sub-`age', clear

	graph dot abcRinsig abcR0_1 abcR0_05, ///
		  marker(1,msize(large) msymbol(D) mlc(blue) mfc(blue*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(blue) mfc(blue*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(blue) mfc(blue) mlw(thin)) ///
		  over(scale, label(labsize(vsmall)) sort(scale_num)) ///
		  legend (order (3 "ABC") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		  ylabel($sub_axis_range) ///
		  graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "abc_sub_agg_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out/substitution"
	graph export "abc_sub_agg_pile_R_`age'.png", replace
}

* CARE
foreach age of numlist 1 3 {
	cd "$pile_working"
	use care-agg-pile-sub-`age', clear

	graph dot careRinsig careR0_1 careR0_05 ///
			  carebothRinsig carebothR0_1 carebothR0_05 ///
			  carehvRinsig carehvR0_1 carehvR0_05, ///
		  marker(1,msize(large) msymbol(D) mlc(purple) mfc(purple*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(purple) mfc(purple) mlw(thin)) ///
		  marker(4,msize(large) msymbol(O) mlc(purple) mfc(purple*0) mlw(thin)) marker(5,msize(large) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(6,msize(large) msymbol(O) mlc(purple) mfc(purple) mlw(thin)) ///
		  marker(7,msize(large) msymbol(T) mlc(purple) mfc(purple*0) mlw(thin)) marker(8,msize(large) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(9,msize(large) msymbol(T) mlc(purple) mfc(purple) mlw(thin)) ///
		  over(scale, label(labsize(vsmall)) sort(scale_num)) ///
		  legend (order (3 "CARE-All" 6 "CARE-Both" 9 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		  ylabel($sub_axis_range) ///
		  graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "care_sub_agg_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out/substitution"
	graph export "care_sub_agg_pile_R_`age'.png", replace
}
