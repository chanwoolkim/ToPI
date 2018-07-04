* ---------------------------------------------------------------- *
* Graphs of treatment effects - aggregate pile (substitution effect)
* Author: Chanwool Kim
* ---------------------------------------------------------------- *

clear all

* ------------ *
* Prepare matrix

local nrow : list sizeof global(home_types)

foreach age of numlist 1 3 {
	foreach p of global programs_merge {
		foreach t of global `p'_type {
			cd "$data_analysis"
			use "`p'`t'-home-agg-pile.dta", clear

			* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
			qui matrix `p'`t'R_`age' = J(`nrow', 5, .) // for randomisation variable

			qui matrix colnames `p'`t'R_`age' = `p'`t'R_`age'num `p'`t'R_`age'coeff `p'`t'R_`age'lower `p'`t'R_`age'upper `p'`t'R_`age'pval

			local row_`age' = 1

			if "`p'" == "abc" {
				qui matrix `p'`t'R_6m = J(`nrow', 5, .) // for randomisation variable
				qui matrix colnames `p'`t'R_6m = `p'`t'R_6mnum `p'`t'R_6mcoeff `p'`t'R_6mlower `p'`t'R_6mupper `p'`t'R_6mpval

				local row_6m = 1
			}

			* Loop over rows to fill in values into the empty matrix.
			foreach r of global home_types {
				qui matrix `p'`t'R_`age'[`row_`age'',1] = `row_`age''

				capture confirm variable norm_home_`r'`age'y
				if !_rc {
					* Randomisation variable
					qui xi: regress norm_home_`r'`age'y i.R*bw if !missing(D)
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)

					qui matrix `p'`t'R_`age'[`row_`age'',2] = r[1,3]
					qui matrix `p'`t'R_`age'[`row_`age'',3] = r[5,3]
					qui matrix `p'`t'R_`age'[`row_`age'',4] = r[6,3]
					qui matrix `p'`t'R_`age'[`row_`age'',5] = r[4,3]

					local row_`age' = `row_`age'' + 1
				}

				else {
					local row_`age' = `row_`age'' + 1
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

			cd "$data_analysis"

			if "`p'" == "abc" {
				svmat `p'`t'R_6m, names(col)
				rename `p'`t'R_6mnum row_6m
				keep row_6m `p'`t'R_6mcoeff `p'`t'R_6mlower `p'`t'R_6mupper `p'`t'R_6mpval
				keep if row_6m != .
				save "`p'`t'-pile-agg-sub-6m", replace
			}

			svmat `p'`t'R_`age', names(col)
			rename `p'`t'R_`age'num row_`age'
			keep row_`age' `p'`t'R_`age'coeff `p'`t'R_`age'lower `p'`t'R_`age'upper `p'`t'R_`age'pval
			keep if row_`age' != .
			save "`p'`t'-pile-agg-sub-`age'", replace
		}
	}
}

cd "$data_analysis"

* Randomisation

use abc-pile-agg-sub-6m, clear
rename row_6m row
save abc-agg-pile-sub-6m, replace

foreach age of numlist 1 3 {
	foreach p of global programs_merge {
		use `p'-pile-agg-sub-`age', clear

		foreach t of global `p'_type {
			merge 1:1 row_`age' using `p'`t'-pile-agg-sub-`age', nogen nolabel
		}

		rename row_`age' row
		save `p'-agg-pile-sub-`age', replace
	}
}

* --------*
* Questions

foreach p of global programs_merge {
	cd "$data_analysis"

	if "`p'" == "abc" {
		use `p'-agg-pile-sub-6m, clear
		include "${code_path}/function/home_agg"
		save `p'-agg-pile-sub-6m, replace
	}

	foreach age of numlist 1 3 {
		use `p'-agg-pile-sub-`age', clear
		include "${code_path}/function/home_agg"
		save `p'-agg-pile-sub-`age', replace
	}
}

* ----------------- *
* Execution - P-value

foreach p of global programs_merge {
	foreach age of numlist 1 3 {
		* Randomisation

		cd "$data_analysis"
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

cd "$data_analysis"
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
	cd "$data_analysis"
	use ehs-agg-pile-sub-`age', clear

	graph dot ehsRinsig ehsR0_1 ehsR0_05 ///
		ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
		ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
		ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05, ///
		marker(1,msize(large) msymbol(D) mlc(red) mfc(red*0) mlw(thick)) marker(2,msize(large) msymbol(D) mlc(red) mfc(red*0.5) mlw(thick)) marker(3,msize(large) msymbol(D) mlc(red) mfc(red) mlw(thick)) ///
		marker(4,msize(large) msymbol(O) mlc(red) mfc(red*0) mlw(thick)) marker(5,msize(large) msymbol(O) mlc(red) mfc(red*0.5) mlw(thick)) marker(6,msize(large) msymbol(O) mlc(red) mfc(red) mlw(thick)) ///
		marker(7,msize(large) msymbol(T) mlc(red) mfc(red*0) mlw(thick)) marker(8,msize(large) msymbol(T) mlc(red) mfc(red*0.5) mlw(thick)) marker(9,msize(large) msymbol(T) mlc(red) mfc(red) mlw(thick)) ///
		marker(10,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thick)) marker(11,msize(large) msymbol(S) mlc(red) mfc(red*0.5) mlw(thick)) marker(12,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thick)) ///
		over(scale, label(labsize(large)) sort(scale_num)) ///
		legend (order (3 "EHS-All" 6 "EHS-Center" 9 "EHS-Home" 12 "EHS-Mixed") size(medsmall)) yline(0) ylabel(#4, labsize(medsmall)) ///
		ylabel($sub_axis_range) ///
		graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "ehs_sub_agg_pile_R_`age'.pdf", replace

	cd "$pile_git_out/substitution"
	graph export "ehs_sub_agg_pile_R_`age'.png", replace
}

* IHDP
foreach age of numlist 1 3 {
	cd "$data_analysis"
	use ihdp-agg-pile-sub-`age', clear

	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05, ///
		marker(1,msize(large) msymbol(D) mlc(green) mfc(green*0) mlw(thick)) marker(2,msize(large) msymbol(D) mlc(green) mfc(green*0.5) mlw(thick)) marker(3,msize(large) msymbol(D) mlc(green) mfc(green) mlw(thick)) ///
		over(scale, label(labsize(large)) sort(scale_num)) ///
		legend (order (3 "IHDP") size(medsmall)) yline(0) ylabel(#1, labsize(medsmall)) ///
		ylabel($sub_axis_range) ///
		graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "ihdp_sub_agg_pile_R_`age'.pdf", replace

	cd "$pile_git_out/substitution"
	graph export "ihdp_sub_agg_pile_R_`age'.png", replace
}

* ABC
foreach age in 6m 1 3 {
	cd "$data_analysis"
	use abc-agg-pile-sub-`age', clear

	graph dot abcRinsig abcR0_1 abcR0_05, ///
		marker(1,msize(large) msymbol(D) mlc(blue) mfc(blue*0) mlw(thick)) marker(2,msize(large) msymbol(D) mlc(blue) mfc(blue*0.5) mlw(thick)) marker(3,msize(large) msymbol(D) mlc(blue) mfc(blue) mlw(thick)) ///
		over(scale, label(labsize(large)) sort(scale_num)) ///
		legend (order (3 "ABC") size(medsmall)) yline(0) ylabel(#1, labsize(medsmall)) ///
		ylabel($sub_axis_range) ///
		graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "abc_sub_agg_pile_R_`age'.pdf", replace

	cd "$pile_git_out/substitution"
	graph export "abc_sub_agg_pile_R_`age'.png", replace
}

* CARE
foreach age in 1 3 {
	cd "$data_analysis"
	use care-agg-pile-sub-`age', clear

	graph dot careRinsig careR0_1 careR0_05 ///
		carebothRinsig carebothR0_1 carebothR0_05 ///
		carehomeRinsig carehomeR0_1 carehomeR0_05, ///
		marker(1,msize(large) msymbol(D) mlc(purple) mfc(purple*0) mlw(thick)) marker(2,msize(large) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(thick)) marker(3,msize(large) msymbol(D) mlc(purple) mfc(purple) mlw(thick)) ///
		marker(4,msize(large) msymbol(D) mlc(purple) mfc(purple*0) mlw(thick)) marker(5,msize(large) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(thick)) marker(6,msize(large) msymbol(D) mlc(purple) mfc(purple) mlw(thick)) ///
		marker(7,msize(large) msymbol(D) mlc(purple) mfc(purple*0) mlw(thick)) marker(8,msize(large) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(thick)) marker(9,msize(large) msymbol(D) mlc(purple) mfc(purple) mlw(thick)) ///
		over(scale, label(labsize(large)) sort(scale_num)) ///
		legend (order (3 "CARE-All" 6 "CARE-Both" 9 "CARE-Home") size(medsmall)) yline(0) ylabel(#3, labsize(medsmall)) ///
		ylabel($sub_axis_range) ///
		graphregion(fcolor(white))

	cd "$pile_out/substitution"
	graph export "abc_sub_agg_pile_R_`age'.pdf", replace

	cd "$pile_git_out/substitution"
	graph export "abc_sub_agg_pile_R_`age'.png", replace
}
