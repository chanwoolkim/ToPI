* -------------------------------------------------- *
* Treatment effects - population homogenisation (item)
* Author: Chanwool Kim
* -------------------------------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

/*
   Weights: benchmark is ABC

   Mother's age: 1 Adult 0 Teenage
   Mother's education: 1 Graduated high school or above 0 Some high school or below
   Poverty: 1 Over poverty line 0 Under poverty line
   Race: 1 White 0 Non-white
*/

cd "$data_analysis"
use distribution_homo_D, clear
mkmat abc

local abc_D_1 = abc[1,1]
local abc_D_2 = abc[2,1]
local abc_D_3 = abc[3,1]
local abc_D_4 = abc[4,1]
local abc_D_5 = abc[5,1]
local abc_D_6 = abc[6,1]
local abc_D_7 = abc[7,1]
local abc_D_8 = abc[8,1]
local abc_D_9 = abc[9,1]
local abc_D_10 = abc[10,1]
local abc_D_11 = abc[11,1]
local abc_D_12 = abc[12,1]
local abc_D_13 = abc[13,1]
local abc_D_14 = abc[14,1]
local abc_D_15 = abc[15,1]
local abc_D_16 = abc[16,1]

local cond_1 "m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 0"
local cond_2 "m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 1"
local cond_3 "m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 0"
local cond_4 "m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 1"
local cond_5 "m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 0"
local cond_6 "m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 1"
local cond_7 "m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 0"
local cond_8 "m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 1"
local cond_9 "m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 0"
local cond_10 "m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 1"
local cond_11 "m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 0"
local cond_12 "m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 1"
local cond_13 "m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 0"
local cond_14 "m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 1"
local cond_15 "m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 0"
local cond_16 "m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 1"

local cond_all "sibling != . & m_iq != . & sex != . & gestage != . & mf != . & !missing(D)"

* ------------ *
* Prepare matrix

local 1_nrow		45
local 3_nrow		55
local 1_name		early
local 3_name		later

foreach age of numlist 1 3 {
	foreach p of global programs {

		cd "$data_analysis"
		use "`p'-homo-merge.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_`age' = J(``age'_nrow', 5, .) // for randomisation variable

		qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval

		* Loop over rows to fill in values into the empty matrix.
		forvalues r = 1/``age'_nrow' {
			qui matrix `p'R_`age'[`r',1] = `r'

			* Create weights
			qui gen w_`age'_`r' = .

			capture confirm variable home`age'_`r'
			if !_rc {
				di "`p'_`r'"
				forvalues i = 1/16 {
					qui count if home`age'_`r' != . & `cond_`i'' & `cond_all'
					local num_count_`i' = r(N)
					qui replace w_`age'_`r' = `abc_D_`i''/`num_count_`i'' if home`age'_`r' != . & `cond_`i'' & `cond_all'
				}

				* Run regression
				qui regress home`age'_`r' R $covariates [pweight=w_`age'_`r']
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`r',2] = r[1,1]
				qui matrix `p'R_`age'[`r',3] = r[4,1]
			}
		}

		cd "$data_analysis"

		svmat `p'R_`age', names(col)
		rename `p'R_`age'num row_`age'
		keep row_`age' `p'R_`age'coeff `p'R_`age'pval
		keep if row_`age' != .
		save "`p'-homo-item-`age'", replace
	}

	cd "$data_analysis"

	use ehscenter-homo-item-`age', clear

	foreach p of global programs {
		merge 1:1 row_`age' using `p'-homo-item-`age', nogen nolabel
	}

	rename row_`age' row
	save item-homo-`age', replace
}

* --------*
* Questions

foreach age of numlist 1 3 {
	cd "$data_analysis"
	use item-homo-`age', clear
	include "${code_path}/function/home_item_``age'_name'"
	save item-homo-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	cd "$data_analysis"
	use item-homo-`age', clear
	include "${code_path}/function/significance"

	include "${code_path}/function/home_item_graph"

	cd "${homo_out}/home"
	graph export "item_homo_R_`age'.pdf", replace

	cd "${homo_git_out}/home"
	graph export "item_homo_R_`age'.png", replace

	include "${code_path}/function/home_item_graph_sep"

	cd "${homo_out}/home"
	graph export "item_homo_R_`age'_sep.pdf", replace

	cd "${homo_git_out}/home"
	graph export "item_homo_R_`age'_sep.png", replace
}
