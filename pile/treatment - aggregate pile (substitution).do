* ---------------------------------------------------------------- *
* Graphs of treatment effects - aggregate pile (substitution effect)
* Author: Chanwool Kim
* Date Created: 22 Jan 2018
* Last Update: 4 Mar 2018
* ---------------------------------------------------------------- *

clear all

* ------------ *
* Prepare matrix

local 1_name		early
local 3_name		later
local 1_nrow : list sizeof global(early_home_types)
local 3_nrow : list sizeof global(later_home_types)

foreach p of global programs {
	cd "$pile_working"
	use "`p'-home-agg-pile.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_1 = J(7, 5, .) // for randomisation variable
		qui matrix `p'R_3 = J(8, 5, .) // for randomisation variable
		
		qui matrix colnames `p'R_1 = `p'R_1num `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
		qui matrix colnames `p'R_3 = `p'R_3num `p'R_3coeff `p'R_3lower `p'R_3upper `p'R_3pval
		
		local row_1 = 1
		local row_3 = 1
		
		if "`p'" == "abc" {
			qui matrix `p'R_6m = J(7, 5, .) // for randomisation variable
			qui matrix colnames `p'R_6m = `p'R_6mnum `p'R_6mcoeff `p'R_6mlower `p'R_6mupper `p'R_6mpval
			
			local row_6m = 1
		}

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global early_home_types {
			qui matrix `p'R_1[`row_1',1] = `row_1'
			
			capture confirm variable norm_home_`r'1y
				if !_rc {
				* Randomisation variable
				qui xi: regress norm_home_`r'1y i.R*bw if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_1[`row_1',2] = r[1,3]
				qui matrix `p'R_1[`row_1',3] = r[5,3]
				qui matrix `p'R_1[`row_1',4] = r[6,3]
				qui matrix `p'R_1[`row_1',5] = r[4,3]
				
				local row_1 = `row_1' + 1
				}
					
				else {
				local row_1 = `row_1' + 1
				}
			
			if "`p'" == "abc" {
				qui matrix `p'R_6m[`row_6m',1] = `row_6m'
				
				capture confirm variable norm_home_`r'6m
					if !_rc {
					* Randomisation variable
					qui xi: regress norm_home_`r'6m i.R*bw if !missing(D)
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)

					qui matrix `p'R_6m[`row_6m',2] = r[1,3]
					qui matrix `p'R_6m[`row_6m',3] = r[5,3]
					qui matrix `p'R_6m[`row_6m',4] = r[6,3]
					qui matrix `p'R_6m[`row_6m',5] = r[4,3]
					
					local row_6m = `row_6m' + 1
					}
						
					else {
					local row_6m = `row_6m' + 1
					}
			}
		}

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global later_home_types {
			qui matrix `p'R_3[`row_3',1] = `row_3'
				
			capture confirm variable norm_home_`r'3y
				if !_rc {
				* Randomisation variable
				qui xi: regress norm_home_`r'3y i.R*bw if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_3[`row_3',2] = r[1,3]
				qui matrix `p'R_3[`row_3',3] = r[5,3]
				qui matrix `p'R_3[`row_3',4] = r[6,3]
				qui matrix `p'R_3[`row_3',5] = r[4,3]

				local row_3 = `row_3' + 1
				}
					
				else {
				local row_3 = `row_3' + 1
				}
			}
			
		cd "$pile_working"
		
		if "`p'" == "abc" {
			svmat `p'R_6m, names(col)
			rename `p'R_6mnum row_6m
			keep row_6m `p'R_6mcoeff `p'R_6mlower `p'R_6mupper `p'R_6mpval
			keep if row_6m != .
			save "`p'-pile-agg-sub-6m", replace
		}

		svmat `p'R_1, names(col)
		rename `p'R_1num row_1
		keep row_1 `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
		keep if row_1 != .
		save "`p'-pile-agg-sub-1", replace

		svmat `p'R_3, names(col)
		rename `p'R_3num row_3
		keep row_3 `p'R_3coeff `p'R_3lower `p'R_3upper `p'R_3pval
		keep if row_3 != .
		save "`p'-pile-agg-sub-3", replace
}

cd "$pile_working"

* Randomisation

use abc-pile-agg-sub-6m, clear
rename row_6m row
save abc-agg-pile-sub-6m, replace

foreach p of global programs_merge {
	use `p'-pile-agg-sub-1, clear

	foreach t of global `p'_type {
		merge 1:1 row_1 using `p'-pile-agg-sub-1, nogen nolabel
	}

	rename row_1 row
	save `p'-agg-pile-sub-1, replace

	use `p'-pile-agg-sub-3, clear

	foreach t of global `p'_type {
		merge 1:1 row_3 using `p'-pile-agg-sub-3, nogen nolabel
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
		replace scale = "Development Materials" if scale_num == "2"
		replace scale = "Family Culture" if scale_num == "3"
		replace scale = "Lack of Hostility" if scale_num == "4"
		replace scale = "Learning Stimulation" if scale_num == "5"
		replace scale = "Opportunities for Variety" if scale_num == "6"
		replace scale = "Warmth" if scale_num == "7"

		save `p'-agg-pile-sub-6m, replace
	}

	use `p'-agg-pile-sub-1, clear

	tostring row, gen(scale_num)

	replace scale = "Total Score" if scale_num == "1"
	replace scale = "Development Materials" if scale_num == "2"
	replace scale = "Family Culture" if scale_num == "3"
	replace scale = "Lack of Hostility" if scale_num == "4"
	replace scale = "Learning Stimulation" if scale_num == "5"
	replace scale = "Opportunities for Variety" if scale_num == "6"
	replace scale = "Warmth" if scale_num == "7"

	save `p'-agg-pile-sub-1, replace

	use `p'-agg-pile-sub-3, clear

	tostring row, gen(scale_num)

	replace scale = "Total Score" if scale_num == "1"
	replace scale = "Development Materials" if scale_num == "2"
	replace scale = "Family Culture" if scale_num == "3"
	replace scale = "Housing" if scale_num == "4"
	replace scale = "Lack of Hostility" if scale_num == "5"
	replace scale = "Learning Stimulation" if scale_num == "6"
	replace scale = "Opportunities for Variety" if scale_num == "7"
	replace scale = "Warmth" if scale_num == "8"

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
			gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
			gen `p'Rinsig = .
			gen `p'R0_1 = .
			gen `p'R0_05 = .
			replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
			replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
			replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
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
