* ---------------------------------------------------------------- *
* Graphs of treatment effects - aggregate pile (substitution effect)
* Author: Chanwool Kim
* Date Created: 22 Jan 2018
* Last Update: 11 Feb 2018
* ---------------------------------------------------------------- *

clear all

local matrix_type	R bw interaction

* ------------ *
* Prepare matrix

foreach p of global programs_merge {
	foreach t of global `p'_type {

	cd "$pile_working"
	use "`p'`t'-home-agg-pile.dta", clear
	
		foreach s of local matrix_type {
		
			* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
			qui matrix `p'`t'`s'_1 = J(7, 5, .) // for randomisation variable
			qui matrix `p'`t'`s'_3 = J(9, 5, .) // for randomisation variable
			
			qui matrix colnames `p'`t'`s'_1 = `p'`t'`s'_1num `p'`t'`s'_1coeff `p'`t'`s'_1lower `p'`t'`s'_1upper `p'`t'`s'_1pval
			qui matrix colnames `p'`t'`s'_3 = `p'`t'`s'_3num `p'`t'`s'_3coeff `p'`t'`s'_3lower `p'`t'`s'_3upper `p'`t'`s'_3pval
			
			local row_1 = 1
			local row_3 = 1
			
			if "`p'" == "abc" {
				qui matrix `p'`t'`s'_6m = J(7, 5, .) // for randomisation variable
				qui matrix colnames `p'`t'`s'_6m = `p'`t'`s'_6mnum `p'`t'`s'_6mcoeff `p'`t'`s'_6mlower `p'`t'`s'_6mupper `p'`t'`s'_6mpval
				
				local row_6m = 1
			}
		}

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global early_home_types {
			foreach s of local matrix_type {
				qui matrix `p'`t'`s'_1[`row_1',1] = `row_1'
			}
			
			capture confirm variable norm_home_`r'1y
				if !_rc {
				* Randomisation variable
				qui xi: regress norm_home_`r'1y i.R*bw if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)
				
				qui matrix `p'`t'R_1[`row_1',2] = r[1,1]
				qui matrix `p'`t'R_1[`row_1',3] = r[5,1]
				qui matrix `p'`t'R_1[`row_1',4] = r[6,1]
				qui matrix `p'`t'R_1[`row_1',5] = r[4,1]
				
				qui matrix `p'`t'bw_1[`row_1',2] = r[1,2]
				qui matrix `p'`t'bw_1[`row_1',3] = r[5,2]
				qui matrix `p'`t'bw_1[`row_1',4] = r[6,2]
				qui matrix `p'`t'bw_1[`row_1',5] = r[4,2]

				qui matrix `p'`t'interaction_1[`row_1',2] = r[1,3]
				qui matrix `p'`t'interaction_1[`row_1',3] = r[5,3]
				qui matrix `p'`t'interaction_1[`row_1',4] = r[6,3]
				qui matrix `p'`t'interaction_1[`row_1',5] = r[4,3]
				
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

					qui matrix `p'`t'R_6m[`row_6m',2] = r[1,1]
					qui matrix `p'`t'R_6m[`row_6m',3] = r[5,1]
					qui matrix `p'`t'R_6m[`row_6m',4] = r[6,1]
					qui matrix `p'`t'R_6m[`row_6m',5] = r[4,1]
					
					qui matrix `p'`t'bw_6m[`row_6m',2] = r[1,2]
					qui matrix `p'`t'bw_6m[`row_6m',3] = r[5,2]
					qui matrix `p'`t'bw_6m[`row_6m',4] = r[6,2]
					qui matrix `p'`t'bw_6m[`row_6m',5] = r[4,2]

					qui matrix `p'`t'interaction_6m[`row_6m',2] = r[1,3]
					qui matrix `p'`t'interaction_6m[`row_6m',3] = r[5,3]
					qui matrix `p'`t'interaction_6m[`row_6m',4] = r[6,3]
					qui matrix `p'`t'interaction_6m[`row_6m',5] = r[4,3]
					
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

				qui matrix `p'`t'R_3[`row_3',2] = r[1,1]
				qui matrix `p'`t'R_3[`row_3',3] = r[5,1]
				qui matrix `p'`t'R_3[`row_3',4] = r[6,1]
				qui matrix `p'`t'R_3[`row_3',5] = r[4,1]
				
				qui matrix `p'`t'bw_3[`row_3',2] = r[1,2]
				qui matrix `p'`t'bw_3[`row_3',3] = r[5,2]
				qui matrix `p'`t'bw_3[`row_3',4] = r[6,2]
				qui matrix `p'`t'bw_3[`row_3',5] = r[4,2]

				qui matrix `p'`t'interaction_3[`row_3',2] = r[1,3]
				qui matrix `p'`t'interaction_3[`row_3',3] = r[5,3]
				qui matrix `p'`t'interaction_3[`row_3',4] = r[6,3]
				qui matrix `p'`t'interaction_3[`row_3',5] = r[4,3]

				local row_3 = `row_3' + 1
				}
					
				else {
				local row_3 = `row_3' + 1
				}
			}
			
		cd "$pile_working"
		
		if "`p'" == "abc" {
			foreach s of local matrix_type {
				svmat `p'`t'`s'_6m, names(col)
				rename `p'`t'`s'_6mnum row_6m
				keep row_6m `p'`t'`s'_6mcoeff `p'`t'`s'_6mlower `p'`t'`s'_6mupper `p'`t'`s'_6mpval
				keep if row_6m != .
				save "`p'`t'`s'-pile-agg-sub-6m", replace
			}
		}
		
		foreach s of local matrix_type {
			svmat `p'`t'`s'_1, names(col)
			rename `p'`t'`s'_1num row_1
			keep row_1 `p'`t'`s'_1coeff `p'`t'`s'_1lower `p'`t'`s'_1upper `p'`t'`s'_1pval
			keep if row_1 != .
			save "`p'`t'`s'-pile-agg-sub-1", replace

			svmat `p'`t'`s'_3, names(col)
			rename `p'`t'`s'_3num row_3
			keep row_3 `p'`t'`s'_3coeff `p'`t'`s'_3lower `p'`t'`s'_3upper `p'`t'`s'_3pval
			keep if row_3 != .
			save "`p'`t'`s'-pile-agg-sub-3", replace
		}
	}
}

cd "$pile_working"

* Randomisation

use abcR-pile-agg-sub-6m, clear

foreach s of local matrix_type {
	merge 1:1 row_6m using abc`s'-pile-agg-sub-6m, nogen nolabel
}

rename row_6m row
save abc-agg-pile-sub-6m, replace

foreach p of global programs_merge {
	use `p'R-pile-agg-sub-1, clear

	foreach t of global `p'_type {
		foreach s of local matrix_type {
			merge 1:1 row_1 using `p'`t'`s'-pile-agg-sub-1, nogen nolabel
		}
	}

	rename row_1 row
	save `p'-agg-pile-sub-1, replace

	use `p'R-pile-agg-sub-3, clear

	foreach t of global `p'_type {
		foreach s of local matrix_type {
			merge 1:1 row_3 using `p'`t'-pile-agg-sub-3, nogen nolabel
		}
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

