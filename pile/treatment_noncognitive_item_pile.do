* ----------------------------------------- *
* Graphs of treatment effects - non-cognitive
* Author: Chanwool Kim
* ----------------------------------------- *

clear all

* ------------ *
* Prepare matrix

local nrow				112
local 5_program_noncog	ihdp
local 8_program_noncog	ihdp /// abc care careboth carehome

foreach age of numlist 5 8 {
	foreach p of local `age'_program_noncog {

		cd "$data_analysis"
		use "`p'-noncog-pile.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_`age' = J(`nrow'+7, 5, .) // for randomisation variable

		qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval

		* Loop over rows to fill in values into the empty matrix.
		forvalues r = 1/`nrow' {
			qui matrix `p'R_`age'[`r',1] = `r'

			capture confirm variable cbcl`age'y_`r'
			if !_rc {
				* Randomisation variable
				qui regress cbcl`age'y_`r' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`r',2] = r[1,1]
				qui matrix `p'R_`age'[`r',3] = r[5,1]
				qui matrix `p'R_`age'[`r',4] = r[6,1]
				qui matrix `p'R_`age'[`r',5] = r[4,1]
			}
		}

		local add_row = `nrow' + 1
		local alphabet a b c d e f g

		foreach v of local alphabet {
			qui matrix `p'R_`age'[`add_row',1] = `add_row'

			capture confirm variable cbcl`age'y_56`v'
			if !_rc {
				* Randomisation variable
				qui regress cbcl`age'y_56`v' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`add_row',2] = r[1,1]
				qui matrix `p'R_`age'[`add_row',3] = r[5,1]
				qui matrix `p'R_`age'[`add_row',4] = r[6,1]
				qui matrix `p'R_`age'[`add_row',5] = r[4,1]

				local add_row = `add_row' + 1
			}

			else {
				local add_row = `add_row' + 1
			}
		}

		cd "$data_analysis"

		svmat `p'R_`age', names(col)
		rename `p'R_`age'num row_`age'
		keep row_`age' `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
		keep if row_`age' != .
		save "`p'-noncog-`age'", replace
	}

	cd "$data_analysis"

	use ihdp-noncog-`age', clear

	foreach p of local `age'_program_noncog {
		merge 1:1 row_`age' using `p'-noncog-`age', nogen nolabel
	}

	rename row_`age' row
	save noncog-pile-`age', replace
}

* --------*
* Questions

foreach age of numlist 5 8 {
	cd "$data_analysis"
	use noncog-pile-`age', clear
	include "${code_path}/function/noncognitive"
	save noncog-pile-`age', replace

	keep if inlist(scale_row, 1, 2, 3)
	save noncog-pile-`age'-1, replace
	use noncog-pile-`age', clear
	keep if inlist(scale_row, 4, 5, 6)
	save noncog-pile-`age'-2, replace
	use noncog-pile-`age', clear
	keep if inlist(scale_row, 7, 8, 9)
	save noncog-pile-`age'-3, replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 5 8 {
	foreach page of numlist 1 2 3 {
		cd "$data_analysis"
		use noncog-pile-`age'-`page', clear

		foreach p of local `age'_program_noncog {
			gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
			gen `p'Rinsig = .
			gen `p'R0_1 = .
			gen `p'R0_05 = .
			replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
			replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
			replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
		}

		include "${code_path}/function/noncognitive_graph"

		cd "$pile_out"
		graph export "noncognitive_pile_R_`age'_`page'.pdf", replace

		cd "$pile_git_out"
		graph export "noncognitive_pile_R_`age'_`page'.png", replace
	}
}
