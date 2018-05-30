* -------------------------------------- *
* Treatment effects - subpopulation (item)
* Author: Chanwool Kim
* -------------------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local subpop_types	white black rich poor

local white_cond	"race_g == 1 & !missing(D)"
local black_cond	"race_g == 0 & !missing(D)"
local rich_cond		"poverty == 1 & !missing(D)"
local poor_cond		"poverty == 0 & !missing(D)"

/*
   Poverty: 1 Over poverty line 0 Under poverty line
   Race: 1 White 0 Black
*/

* ------------ *
* Prepare matrix

local 1_nrow		45
local 3_nrow		55
local 1_name		early
local 3_name		later

foreach age of numlist 1 3 {
	foreach p of global programs {

		cd "$data_analysis"

		foreach t of local subpop_types {
			use "`p'-subpop-merge.dta", clear

			* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
			qui matrix `p'R`t'_`age' = J(``age'_nrow', 3, .) // for randomisation variable

			qui matrix colnames `p'R`t'_`age' = `p'R`t'_`age'num `p'R`t'_`age'coeff `p'R`t'_`age'pval

			* Loop over rows to fill in values into the empty matrix.
			forvalues r = 1/``age'_nrow' {
				qui matrix `p'R`t'_`age'[`r',1] = `r'

				capture confirm variable home`age'_`r'
				if !_rc {

					qui count if ``t'_cond'
					local num = r(N)

					if `num' > 10 {
						* Run regression
						qui regress home`age'_`r' R $covariates if ``t'_cond'

						* r(table) stores values from regression (ex. coeff, var, CI).
						qui matrix list r(table)
						qui matrix r = r(table)

						qui matrix `p'R`t'_`age'[`r',2] = r[1,1]
						qui matrix `p'R`t'_`age'[`r',3] = r[4,1]
					}
				}
			}

			svmat `p'R`t'_`age', names(col)
			rename `p'R`t'_`age'num row_`age'
			keep row_`age' `p'R`t'_`age'coeff `p'R`t'_`age'pval
			keep if row_`age' != .
			save "`p'-`t'-subpop-item-`age'", replace
		}
	}

	foreach t of local subpop_types {

		use ehscenter-`t'-subpop-item-`age', clear

		foreach p of global programs {
			merge 1:1 row_`age' using `p'-`t'-subpop-item-`age', nogen nolabel
		}

		rename row_`age' row
		save item-`t'-subpop-`age', replace
	}
}

* --------*
* Questions

foreach age of numlist 1 3 {
	foreach t of local subpop_types {
		cd "$data_analysis"
		use item-`t'-subpop-`age', clear
		include "${code_path}/function/home_item_``age'_name'"
		save item-`t'-subpop-`age', replace
	}
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	foreach t of local subpop_types {
		cd "$data_analysis"
		use item-`t'-subpop-`age', clear

		* Make sure variable names follow the convention
		rename *`t'_* *_*

		include "${code_path}/function/significance"

		include "${code_path}/function/home_item_graph"

		cd "$subpop_out"
		graph export "item_subpop_R_`t'_`age'.pdf", replace

		cd "$subpop_git_out"
		graph export "item_subpop_R_`t'_`age'.png", replace

		include "${code_path}/function/home_item_graph_sep"

		cd "$subpop_out"
		graph export "item_subpop_R_`t'_`age'_sep.pdf", replace

		cd "$subpop_git_out"
		graph export "item_subpop_R_`t'_`age'_sep.png", replace
	}
}
