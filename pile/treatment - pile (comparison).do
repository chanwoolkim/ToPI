* ----------------------------------- *
* Treatment effects - pile (comparison)
* Author: Chanwool Kim
* ----------------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local p_row_names	""Insig" "Moderate" "Statistical" "Total""
local nrow : list sizeof local(p_row_names)
local ncol_program : list sizeof global(programs)
local ncol_scale : list sizeof global(early_home_types)

* ---------------------------- *
* Execution - Summary of Results

* By program
foreach age of numlist 1 3 {
	cd "$data_analysis"
	use agg-pile-`age', clear

	qui matrix by_program_`age' = J(`nrow', 4*`ncol_program', .)

	local col = 1
	local col_item = 1

	foreach p of global programs {
		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_program_`age'[1,`col'] = `num_count_insig'

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_program_`age'[2,`col'] = `num_count_0_1'

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_program_`age'[3,`col'] = `num_count_0_05'

		qui matrix by_program_`age'[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		local col = `col' + 1

		qui matrix by_program_`age'[1,`col'] = 0
		qui matrix by_program_`age'[2,`col'] = 0
		qui matrix by_program_`age'[3,`col'] = 0
		qui matrix by_program_`age'[4,`col'] = 0

		local col = `col' + 1

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_program_`age'[1,`col'] = `num_count_insig'

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_program_`age'[2,`col'] = `num_count_0_1'

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_program_`age'[3,`col'] = `num_count_0_05'

		qui matrix by_program_`age'[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		local col = `col' + 1

		qui matrix by_program_`age'[1,`col'] = 0
		qui matrix by_program_`age'[2,`col'] = 0
		qui matrix by_program_`age'[3,`col'] = 0
		qui matrix by_program_`age'[4,`col'] = 0

		local col = `col' + 1
	}

	cd "$data_analysis"
	use item-pile-`age', clear

	qui matrix by_program_item_`age' = J(`nrow', 4*`ncol_program', .)

	foreach p of global programs {

		qui matrix by_program_item_`age'[1,`col_item'] = 0
		qui matrix by_program_item_`age'[2,`col_item'] = 0
		qui matrix by_program_item_`age'[3,`col_item'] = 0
		qui matrix by_program_item_`age'[4,`col_item'] = 0

		local col_item = `col_item' + 1

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_program_item_`age'[1,`col_item'] = `num_count_insig'

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_program_item_`age'[2,`col_item'] = `num_count_0_1'

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_program_item_`age'[3,`col_item'] = `num_count_0_05'

		qui matrix by_program_item_`age'[4,`col_item'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		local col_item = `col_item' + 1

		qui matrix by_program_item_`age'[1,`col_item'] = 0
		qui matrix by_program_item_`age'[2,`col_item'] = 0
		qui matrix by_program_item_`age'[3,`col_item'] = 0
		qui matrix by_program_item_`age'[4,`col_item'] = 0

		local col_item = `col_item' + 1

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_program_item_`age'[1,`col_item'] = `num_count_insig'

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_program_item_`age'[2,`col_item'] = `num_count_0_1'

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_program_item_`age'[3,`col_item'] = `num_count_0_05'

		qui matrix by_program_item_`age'[4,`col_item'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		local col_item = `col_item' + 1
	}

	matrix by_program_merge_`age' = by_program_`age' + by_program_item_`age'

	qui matrix rownames by_program_merge_`age' = `p_row_names'

	cd "$pile_out"
	frmttable using by_program_`age', statmat(by_program_merge_`age') substat(1) sdec(0) fragment tex replace nocenter

	cd "$pile_git_out"
	frmttable using by_program_`age', statmat(by_program_merge_`age') substat(1) sdec(0) fragment tex replace nocenter
}

* By scale
cd "$data_analysis"

foreach age of numlist 1 3 {
	use agg-pile-`age', clear
	sort scale_row
	keep *coeff
	xpose, clear
	rename v1 total_coeff
	rename v2 learning_coeff
	rename v3 develop_coeff
	rename v4 variety_coeff
	rename v5 hostility_coeff
	rename v6 warmth_coeff
	gen row = _n
	tempfile coeff_`age'
	save "`coeff_`age''", replace

	use agg-pile-`age', clear
	sort scale_row
	keep *pval
	xpose, clear
	rename v1 total_pval
	rename v2 learning_pval
	rename v3 develop_pval
	rename v4 variety_pval
	rename v5 hostility_pval
	rename v6 warmth_pval
	gen row = _n
	merge 1:1 row using "`coeff_`age''", nogen nolabel

	save count-agg-pile-`age', replace
}

foreach age of numlist 1 3 {
	cd "$data_analysis"
	use count-agg-pile-`age', clear

	qui matrix by_scale_`age' = J(`nrow', 4*`ncol_scale', .)

	local col = 1

	foreach t of global home_types {
		qui count if `t'_coeff >= 0 & `t'_pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_scale_`age'[1,`col'] = `num_count_insig'

		qui count if `t'_coeff >= 0 & `t'_pval <= 0.1 & `t'_pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_scale_`age'[2,`col'] = `num_count_0_1'

		qui count if `t'_coeff >= 0 & `t'_pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_scale_`age'[3,`col'] = `num_count_0_05'

		qui matrix by_scale_`age'[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		local col = `col' + 1

		qui matrix by_scale_`age'[1,`col'] = 0
		qui matrix by_scale_`age'[2,`col'] = 0
		qui matrix by_scale_`age'[3,`col'] = 0
		qui matrix by_scale_`age'[4,`col'] = 0

		local col = `col' + 1

		qui count if `t'_coeff < 0 & `t'_pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_scale_`age'[1,`col'] = `num_count_insig'

		qui count if `t'_coeff < 0 & `t'_pval <= 0.1 & `t'_pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_scale_`age'[2,`col'] = `num_count_0_1'

		qui count if `t'_coeff < 0 & `t'_pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_scale_`age'[3,`col'] = `num_count_0_05'

		qui matrix by_scale_`age'[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		local col = `col' + 1

		qui matrix by_scale_`age'[1,`col'] = 0
		qui matrix by_scale_`age'[2,`col'] = 0
		qui matrix by_scale_`age'[3,`col'] = 0
		qui matrix by_scale_`age'[4,`col'] = 0

		local col = `col' + 1
	}

	cd "$data_analysis"
	use item-pile-`age', clear

	foreach p of global programs {
		qui matrix by_scale_`p'_`age' = J(`nrow', 4*`ncol_scale', .)

		qui matrix by_scale_`p'_`age'[1,1] = 0
		qui matrix by_scale_`p'_`age'[2,1] = 0
		qui matrix by_scale_`p'_`age'[3,1] = 0
		qui matrix by_scale_`p'_`age'[4,1] = 0

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_scale_`p'_`age'[1,2] = `num_count_insig'

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_scale_`p'_`age'[2,2] = `num_count_0_1'

		qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_scale_`p'_`age'[3,2] = `num_count_0_05'

		qui matrix by_scale_`p'_`age'[4,2] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		qui matrix by_scale_`p'_`age'[1,3] = 0
		qui matrix by_scale_`p'_`age'[2,3] = 0
		qui matrix by_scale_`p'_`age'[3,3] = 0
		qui matrix by_scale_`p'_`age'[4,3] = 0

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval > 0.1
		local num_count_insig = r(N)
		qui matrix by_scale_`p'_`age'[1,4] = `num_count_insig'

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		local num_count_0_1 = r(N)
		qui matrix by_scale_`p'_`age'[2,4] = `num_count_0_1'

		qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.05
		local num_count_0_05 = r(N)
		qui matrix by_scale_`p'_`age'[3,4] = `num_count_0_05'

		qui matrix by_scale_`p'_`age'[4,4] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		forvalues col = 2/`ncol_scale' {
			qui matrix by_scale_`p'_`age'[1,4*`col'-3] = 0
			qui matrix by_scale_`p'_`age'[2,4*`col'-3] = 0
			qui matrix by_scale_`p'_`age'[3,4*`col'-3] = 0
			qui matrix by_scale_`p'_`age'[4,4*`col'-3] = 0

			qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval > 0.1 & scale_row == `col'
			local num_count_insig = r(N)
			qui matrix by_scale_`p'_`age'[1,4*`col'-2] = `num_count_insig'

			qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05 & scale_row == `col'
			local num_count_0_1 = r(N)
			qui matrix by_scale_`p'_`age'[2,4*`col'-2] = `num_count_0_1'

			qui count if `p'R_`age'coeff >= 0 & `p'R_`age'pval <= 0.05 & scale_row == `col'
			local num_count_0_05 = r(N)
			qui matrix by_scale_`p'_`age'[3,4*`col'-2] = `num_count_0_05'

			qui matrix by_scale_`p'_`age'[4,4*`col'-2] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

			qui matrix by_scale_`p'_`age'[1,4*`col'-1] = 0
			qui matrix by_scale_`p'_`age'[2,4*`col'-1] = 0
			qui matrix by_scale_`p'_`age'[3,4*`col'-1] = 0
			qui matrix by_scale_`p'_`age'[4,4*`col'-1] = 0

			qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval > 0.1 & scale_row == `col'
			local num_count_insig = r(N)
			qui matrix by_scale_`p'_`age'[1,4*`col'] = `num_count_insig'

			qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05 & scale_row == `col'
			local num_count_0_1 = r(N)
			qui matrix by_scale_`p'_`age'[2,4*`col'] = `num_count_0_1'

			qui count if `p'R_`age'coeff < 0 & `p'R_`age'pval <= 0.05 & scale_row == `col'
			local num_count_0_05 = r(N)
			qui matrix by_scale_`p'_`age'[3,4*`col'] = `num_count_0_05'

			qui matrix by_scale_`p'_`age'[4,4*`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
		}
	}

	matrix by_scale_merge_`age' = by_scale_`age' ///
		+ by_scale_ehscenter_`age' + by_scale_ehshome_`age' + by_scale_ehsmixed_`age' ///
		+ by_scale_ihdp_`age' ///
		+ by_scale_abc_`age'

	qui matrix rownames by_scale_merge_`age' = `p_row_names'

	cd "$pile_out"
	frmttable using by_scale_`age', statmat(by_scale_merge_`age') substat(1) sdec(0) fragment tex replace nocenter

	cd "$pile_git_out"
	frmttable using by_scale_`age', statmat(by_scale_merge_`age') substat(1) sdec(0) fragment tex replace nocenter
}
