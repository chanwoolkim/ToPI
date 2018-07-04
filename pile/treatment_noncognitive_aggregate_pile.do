* ----------------------------------------- *
* Graphs of treatment effects - non-cognitive
* Author: Chanwool Kim
* ----------------------------------------- *

clear all

* ------------ *
* Prepare matrix

local nrow				3

foreach age of numlist 2 3 {
	foreach p of global programs {

		cd "$data_analysis"
		use "`p'-noncog-pile.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_`age' = J(`nrow', 5, .) // for randomisation variable
		qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval

		local row = 1

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global bayley_types {
			qui matrix `p'R_`age'[`row',1] = `row'

			capture confirm variable norm_bayley_`r'`age'y
			if !_rc {
				* Randomisation variable
				qui regress norm_bayley_`r'`age'y R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`row',2] = r[1,1]
				qui matrix `p'R_`age'[`row',3] = r[5,1]
				qui matrix `p'R_`age'[`row',4] = r[6,1]
				qui matrix `p'R_`age'[`row',5] = r[4,1]
			}

			local row = `row' + 1
		}

		cd "$data_analysis"

		svmat `p'R_`age', names(col)
		rename `p'R_`age'num row_`age'
		keep row_`age' `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
		keep if row_`age' != .
		save "`p'-noncog-agg-`age'", replace
	}

	cd "$data_analysis"

	use ehscenter-noncog-agg-`age', clear

	foreach p of global programs {
		merge 1:1 row_`age' using `p'-noncog-agg-`age', nogen nolabel
	}

	rename row_`age' row
	save noncog-pile-agg-`age', replace
}

* --------*
* Questions

foreach age of numlist 2 3 {
	cd "$data_analysis"
	use noncog-pile-agg-`age', clear
	include "${code_path}/function/noncognitive_agg"
	save noncog-pile-agg-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 2 3 {
	cd "$data_analysis"
	use noncog-pile-agg-`age', clear
	include "${code_path}/function/significance"

	include "${code_path}/function/noncognitive_agg_graph"

	cd "$pile_out"
	graph export "noncognitive_pile_R_agg_`age'.pdf", replace

	cd "$pile_git_out"
	graph export "noncognitive_pile_R_agg_`age'.png", replace

	include "${code_path}/function/noncognitive_agg_graph_sep"

	cd "$pile_out"
	graph export "noncognitive_pile_R_agg_`age'_sep.pdf", replace

	cd "$pile_git_out"
	graph export "noncognitive_pile_R_agg_`age'_sep.png", replace
}
