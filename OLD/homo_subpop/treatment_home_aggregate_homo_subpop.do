* ------------------------------------------------------------------------- *
* Treatment effects - population homogenisation and subpopulation (aggregate)
* Author: Chanwool Kim
* ------------------------------------------------------------------------- *

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
use distribution_homo_subpop_D, clear
mkmat abc

local abc_D_1 = abc[1,1]
local abc_D_2 = abc[2,1]
local abc_D_3 = abc[3,1]
local abc_D_4 = abc[4,1]
local abc_D_5 = abc[5,1]
local abc_D_6 = abc[6,1]
local abc_D_7 = abc[7,1]
local abc_D_8 = abc[8,1]

local cond_1 "m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 0"
local cond_2 "m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 0"
local cond_3 "m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 0"
local cond_4 "m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 0"
local cond_5 "m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 0"
local cond_6 "m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 0"
local cond_7 "m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 0"
local cond_8 "m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 0"

local cond_all "sibling != . & m_iq != . & sex != . & gestage != . & mf != . & !missing(D)"

local nrow : list sizeof global(home_types)

* ------------ *
* Prepare matrix

foreach age of numlist 1 3 {
	foreach p of global programs {

		cd "$data_analysis"
		use "`p'-homo-merge.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_`age' = J(`nrow', 3, .) // for randomisation variable

		qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'pval

		local row_`age' = 1

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global home_types {
			qui matrix `p'R_`age'[`row_`age'',1] = `row_`age''

			* Create weights
			qui gen w_`age'_`row_`age'' = .

			capture confirm variable norm_home_`r'`age'y
			if !_rc {
				di "`p'_`r'"
				forvalues i = 1/8 {
					qui count if norm_home_`r'`age'y != . & `cond_`i'' & `cond_all'
					local num_count_`i' = r(N)
					qui replace w_`age'_`row_`age'' = `abc_D_`i''/`num_count_`i'' if norm_home_`r'`age'y != . & `cond_`i'' & `cond_all'
				}

				* Run regression
				qui regress norm_home_`r'`age'y R $covariates [pweight=w_`age'_`row_`age'']
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`row_`age'',2] = r[1,1]
				qui matrix `p'R_`age'[`row_`age'',3] = r[4,1]

				local row_`age' = `row_`age'' + 1
			}

			else {
				local row_`age' = `row_`age'' + 1
			}
		}

		svmat `p'R_`age', names(col)
		rename `p'R_`age'num row_`age'
		keep row_`age' `p'R_`age'coeff `p'R_`age'pval
		keep if row_`age' != .
		save "`p'-homo_subpop-agg-`age'", replace
	}

	use ehscenter-homo_subpop-agg-`age', clear

	foreach p of global programs {
		merge 1:1 row_`age' using `p'-homo_subpop-agg-`age', nogen nolabel
	}

	rename row_`age' row
	save agg-homo_subpop-`age', replace
}

* --------*
* Questions

foreach age of numlist 1 3 {
	cd "$data_analysis"
	use agg-homo_subpop-`age', clear
	include "${code_path}/function/home_agg"
	save agg-homo_subpop-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	cd "$data_analysis"
	use agg-homo_subpop-`age', clear
	include "${code_path}/function/significance"

	include "${code_path}/function/home_agg_graph"

	cd "$homo_subpop_out"
	graph export "agg_homo_subpop_R_`age'.pdf", replace

	cd "$homo_subpop_git_out"
	graph export "agg_homo_subpop_R_`age'.png", replace

	include "${code_path}/function/home_agg_graph_sep"

	cd "$homo_subpop_out"
	graph export "agg_homo_subpop_R_`age'_sep.pdf", replace

	cd "$homo_subpop_git_out"
	graph export "agg_homo_subpop_R_`age'_sep.png", replace
}
