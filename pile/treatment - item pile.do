* ------------------------------------- *
* Graphs of treatment effects - item pile
* Author: Chanwool Kim
* Date Created: 5 Jun 2017
* Last Update: 4 Mar 2018
* ------------------------------------- *

clear all

* ------------ *
* Prepare matrix

local 1_nrow		45
local 3_nrow		55
local 1_name		early
local 3_name		later

foreach age of numlist 1 3 {
	foreach p of global programs {

	cd "$pile_working"
	use "`p'-home-item-pile.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix `p'R_`age' = J(``age'_nrow', 5, .) // for randomisation variable

	qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval

		* Loop over rows to fill in values into the empty matrix.
		forvalues r = 1/``age'_nrow' {
			qui matrix `p'R_`age'[`r',1] = `r'
			
			capture confirm variable home`age'_`r'
				if !_rc {
				* Randomisation variable
				qui regress home`age'_`r' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`r',2] = r[1,1]
				qui matrix `p'R_`age'[`r',3] = r[5,1]
				qui matrix `p'R_`age'[`r',4] = r[6,1]
				qui matrix `p'R_`age'[`r',5] = r[4,1]
				}
		}
			
	cd "$pile_working"

	svmat `p'R_`age', names(col)
	rename `p'R_`age'num row_`age'
	keep row_`age' `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
	keep if row_`age' != .
	save "`p'-pile-item-`age'", replace
	}
	
	cd "$pile_working"

	use ehscenter-pile-item-`age', clear

	foreach p of global programs {
		merge 1:1 row_`age' using `p'-pile-item-`age', nogen nolabel
	}

	rename row_`age' row
	save item-pile-`age', replace
}

* --------*
* Questions

foreach age of numlist 1 3 {
	cd "$pile_working"
	use item-pile-`age', clear
	include "${code_path}/function/home_item_``age'_name'"
	save item-pile-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	cd "$pile_working"
	use item-pile-`age', clear
	include "${code_path}/function/significance"
	
	include "${code_path}/function/home_item_graph"

	cd "$pile_out"
	graph export "item_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out"
	graph export "item_pile_R_`age'.png", replace
	
	include "${code_path}/function/home_item_graph_sep"

	cd "$pile_out"
	graph export "item_pile_R_`age'_sep.pdf", replace
	
	cd "$pile_git_out"
	graph export "item_pile_R_`age'_sep.png", replace
}
