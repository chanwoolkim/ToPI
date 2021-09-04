* ----------------------------------- *
* Graphs of treatment effects - outcome
* Author: Chanwool Kim
* ----------------------------------- *

clear all

* ------------ *
* Prepare matrix

local nrow : list sizeof global(outcome_types)

foreach age of numlist 3 {
	foreach p of global programs {

		cd "$data_analysis"
		use "`p'-home-agg-pile.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_`age' = J(`nrow', 5, .) // for randomisation variable
		qui matrix `p'D_`age' = J(`nrow', 5, .) // for participation variable

		qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
		qui matrix colnames `p'D_`age' = `p'D_`age'num `p'D_`age'coeff `p'D_`age'lower `p'D_`age'upper `p'D_`age'pval

		local row_`age' = 1

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global outcome_types {
			qui matrix `p'R_`age'[`row_`age'',1] = `row_`age''
			qui matrix `p'D_`age'[`row_`age'',1] = `row_`age''

			capture confirm variable `r'`age'y
			if !_rc {
				* Randomisation variable
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

		cd "$data_analysis"

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

	cd "$data_analysis"

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
* Questions

foreach age of numlist 3 {
	cd "$data_analysis"
	use outcome-pile-`age', clear
	include "${code_path}/function/outcome"
	save outcome-pile-`age', replace

	use outcome-pile-D-`age', clear
	include "${code_path}/function/outcome"
	save outcome-pile-D-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 3 {
	cd "$data_analysis"
	use outcome-pile-`age', clear
	include "${code_path}/function/significance"

	include "${code_path}/function/outcome_graph"

	cd "$pile_out"
	graph export "outcome_pile_R_`age'.pdf", replace

	cd "$pile_git_out"
	graph export "outcome_pile_R_`age'.png", replace

	include "${code_path}/function/outcome_graph_sep"

	cd "$pile_out"
	graph export "outcome_pile_R_`age'_sep.pdf", replace

	cd "$pile_git_out"
	graph export "outcome_pile_R_`age'_sep.png", replace
}
