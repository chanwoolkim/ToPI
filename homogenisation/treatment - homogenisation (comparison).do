* -------------------------------------------------------- *
* Treatment effects - population homogenisation (comparison)
* Author: Chanwool Kim
* Date Created: 26 Sep 2017
* Last Update: 2 Nov 2017
* -------------------------------------------------------- *

clear all

* ---------------------------- *
* Execution - Summary of Results

* By program
foreach age of numlist 1 3 {
	cd "${homo_path}/working"
	use agg-homo-`age', clear
	
	qui matrix by_program_`age' = J(4, 16, .)

	local col = 1
	
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
	}

	cd "${homo_path}/out/home"
	frmttable using by_program_`age', statmat(by_program_`age') sdec(0) fragment tex replace nocenter
}

* By scale
cd "${homo_path}/working"

use agg-homo-1, clear
keep *coeff
xpose, clear
rename v1 total_coeff
rename v2 warmth_coeff
rename v3 verbal_coeff
rename v4 hostility_coeff
rename v5 learning_coeff
rename v6 activity_coeff
rename v7 develop_coeff
gen row = _n
tempfile coeff_1
save "`coeff_1'", replace

use agg-homo-1, clear
keep *pval
xpose, clear
rename v1 total_pval
rename v2 warmth_pval
rename v3 verbal_pval
rename v4 hostility_pval
rename v5 learning_pval
rename v6 activity_pval
rename v7 develop_pval
gen row = _n
merge 1:1 row using "`coeff_1'", nogen nolabel
	
qui matrix by_scale_1 = J(4, 28, .)

local col = 1
	
foreach t of global early_home_types {
	qui count if `t'_coeff >= 0 & `t'_pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_1[1,`col'] = `num_count_insig'
		
	qui count if `t'_coeff >= 0 & `t'_pval <= 0.1 & `t'_pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_1[2,`col'] = `num_count_0_1'

	qui count if `t'_coeff >= 0 & `t'_pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_1[3,`col'] = `num_count_0_05'
	
	qui matrix by_scale_1[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
	
	local col = `col' + 1
	
	qui matrix by_scale_1[1,`col'] = 0
	qui matrix by_scale_1[2,`col'] = 0
	qui matrix by_scale_1[3,`col'] = 0
	qui matrix by_scale_1[4,`col'] = 0
	
	local col = `col' + 1
	
	qui count if `t'_coeff < 0 & `t'_pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_1[1,`col'] = `num_count_insig'
	
	qui count if `t'_coeff < 0 & `t'_pval <= 0.1 & `t'_pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_1[2,`col'] = `num_count_0_1'
	
	qui count if `t'_coeff < 0 & `t'_pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_1[3,`col'] = `num_count_0_05'
	
	qui matrix by_scale_1[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
	
	local col = `col' + 1
	
	qui matrix by_scale_1[1,`col'] = 0
	qui matrix by_scale_1[2,`col'] = 0
	qui matrix by_scale_1[3,`col'] = 0
	qui matrix by_scale_1[4,`col'] = 0
	
	local col = `col' + 1
}

cd "${homo_path}/working"
use item-homo-1, clear

foreach p of global programs {
	qui matrix by_scale_`p'_1 = J(4, 28, .)
	
	qui matrix by_scale_`p'_1[1,1] = 0
	qui matrix by_scale_`p'_1[2,1] = 0
	qui matrix by_scale_`p'_1[3,1] = 0
	qui matrix by_scale_`p'_1[4,1] = 0
	
	qui count if `p'R_1coeff >= 0 & `p'R_1pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_`p'_1[1,2] = `num_count_insig'
		
	qui count if `p'R_1coeff >= 0 & `p'R_1pval <= 0.1 & `p'R_1pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_`p'_1[2,2] = `num_count_0_1'

	qui count if `p'R_1coeff >= 0 & `p'R_1pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_`p'_1[3,2] = `num_count_0_05'
				
	qui matrix by_scale_`p'_1[4,2] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

	qui matrix by_scale_`p'_1[1,3] = 0
	qui matrix by_scale_`p'_1[2,3] = 0
	qui matrix by_scale_`p'_1[3,3] = 0
	qui matrix by_scale_`p'_1[4,3] = 0
	
	qui count if `p'R_1coeff < 0 & `p'R_1pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_`p'_1[1,4] = `num_count_insig'
			
	qui count if `p'R_1coeff < 0 & `p'R_1pval <= 0.1 & `p'R_1pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_`p'_1[2,4] = `num_count_0_1'

	qui count if `p'R_1coeff < 0 & `p'R_1pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_`p'_1[3,4] = `num_count_0_05'
			
	qui matrix by_scale_`p'_1[4,4] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

	forvalues col = 2/7 {
		qui matrix by_scale_`p'_1[1,4*`col'-3] = 0
		qui matrix by_scale_`p'_1[2,4*`col'-3] = 0
		qui matrix by_scale_`p'_1[3,4*`col'-3] = 0
		qui matrix by_scale_`p'_1[4,4*`col'-3] = 0
	
		qui count if `p'R_1coeff >= 0 & `p'R_1pval > 0.1 & scale_row == `col'
		local num_count_insig = r(N)
		qui matrix by_scale_`p'_1[1,4*`col'-2] = `num_count_insig'
			
		qui count if `p'R_1coeff >= 0 & `p'R_1pval <= 0.1 & `p'R_1pval > 0.05 & scale_row == `col'
		local num_count_0_1 = r(N)
		qui matrix by_scale_`p'_1[2,4*`col'-2] = `num_count_0_1'

		qui count if `p'R_1coeff >= 0 & `p'R_1pval <= 0.05 & scale_row == `col'
		local num_count_0_05 = r(N)
		qui matrix by_scale_`p'_1[3,4*`col'-2] = `num_count_0_05'
				
		qui matrix by_scale_`p'_1[4,4*`col'-2] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'

		qui matrix by_scale_`p'_1[1,4*`col'-1] = 0
		qui matrix by_scale_`p'_1[2,4*`col'-1] = 0
		qui matrix by_scale_`p'_1[3,4*`col'-1] = 0
		qui matrix by_scale_`p'_1[4,4*`col'-1] = 0
		
		qui count if `p'R_1coeff < 0 & `p'R_1pval > 0.1 & scale_row == `col'
		local num_count_insig = r(N)
		qui matrix by_scale_`p'_1[1,4*`col'] = `num_count_insig'
				
		qui count if `p'R_1coeff < 0 & `p'R_1pval <= 0.1 & `p'R_1pval > 0.05 & scale_row == `col'
		local num_count_0_1 = r(N)
		qui matrix by_scale_`p'_1[2,4*`col'] = `num_count_0_1'

		qui count if `p'R_1coeff < 0 & `p'R_1pval <= 0.05 & scale_row == `col'
		local num_count_0_05 = r(N)
		qui matrix by_scale_`p'_1[3,4*`col'] = `num_count_0_05'
			
		qui matrix by_scale_`p'_1[4,4*`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
	}
}

matrix by_scale_merge_1 = by_scale_1 ///
						+ by_scale_ehscenter_1 + by_scale_ehshome_1 + by_scale_ehsmixed_1 ///
						+ by_scale_ihdplow_1 + by_scale_ihdphigh_1 ///
						+ by_scale_abc_1 ///
						+ by_scale_carehv_1 + by_scale_careboth_1

cd "${homo_path}/out/home"
frmttable using by_scale_1, statmat(by_scale_merge_1) substat(1) sdec(0) fragment tex replace nocenter

cd "${homo_path}/working"

use agg-homo-3, clear
keep *coeff
xpose, clear
rename v1 total_coeff
rename v2 learning_coeff
rename v3 reading_coeff
rename v4 verbal_coeff
rename v5 warmth_coeff
rename v6 exterior_coeff
rename v7 interior_coeff
rename v8 activity_coeff
rename v9 hostility_coeff
gen row = _n
tempfile coeff_3
save "`coeff_3'", replace

use agg-homo-3, clear
keep *pval
xpose, clear
rename v1 total_pval
rename v2 learning_pval
rename v3 reading_pval
rename v4 verbal_pval
rename v5 warmth_pval
rename v6 exterior_pval
rename v7 interior_pval
rename v8 activity_pval
rename v9 hostility_pval
gen row = _n
merge 1:1 row using "`coeff_3'", nogen nolabel

qui matrix by_scale_3 = J(4, 36, .)

local col = 1
	
foreach t of global later_home_types {
	qui count if `t'_coeff >= 0 & `t'_pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_3[1,`col'] = `num_count_insig'
		
	qui count if `t'_coeff >= 0 & `t'_pval <= 0.1 & `t'_pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_3[2,`col'] = `num_count_0_1'

	qui count if `t'_coeff >= 0 & `t'_pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_3[3,`col'] = `num_count_0_05'
	
	qui matrix by_scale_3[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
	
	local col = `col' + 1
	
	qui matrix by_scale_3[1,`col'] = 0
	qui matrix by_scale_3[2,`col'] = 0
	qui matrix by_scale_3[3,`col'] = 0
	qui matrix by_scale_3[4,`col'] = 0
	
	local col = `col' + 1
	
	qui count if `t'_coeff < 0 & `t'_pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_3[1,`col'] = `num_count_insig'
	
	qui count if `t'_coeff < 0 & `t'_pval <= 0.1 & `t'_pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_3[2,`col'] = `num_count_0_1'
	
	qui count if `t'_coeff < 0 & `t'_pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_3[3,`col'] = `num_count_0_05'
	
	qui matrix by_scale_3[4,`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
	
	local col = `col' + 1
	
	qui matrix by_scale_3[1,`col'] = 0
	qui matrix by_scale_3[2,`col'] = 0
	qui matrix by_scale_3[3,`col'] = 0
	qui matrix by_scale_3[4,`col'] = 0
	
	local col = `col' + 1
}

cd "${homo_path}/working"
use item-homo-3, clear

foreach p of global programs {
	qui matrix by_scale_`p'_3 = J(4, 36, .)
	
	qui matrix by_scale_`p'_3[1,1] = 0
	qui matrix by_scale_`p'_3[2,1] = 0
	qui matrix by_scale_`p'_3[3,1] = 0
	qui matrix by_scale_`p'_3[4,1] = 0

	qui count if `p'R_3coeff >= 0 & `p'R_3pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_`p'_3[1,2] = `num_count_insig'
		
	qui count if `p'R_3coeff >= 0 & `p'R_3pval <= 0.1 & `p'R_3pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_`p'_3[2,2] = `num_count_0_1'

	qui count if `p'R_3coeff >= 0 & `p'R_3pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_`p'_3[3,2] = `num_count_0_05'
				
	qui matrix by_scale_`p'_3[4,2] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
	
	qui matrix by_scale_`p'_3[1,3] = 0
	qui matrix by_scale_`p'_3[2,3] = 0
	qui matrix by_scale_`p'_3[3,3] = 0
	qui matrix by_scale_`p'_3[4,3] = 0
	
	qui count if `p'R_3coeff < 0 & `p'R_3pval > 0.1
	local num_count_insig = r(N)
	qui matrix by_scale_`p'_3[1,4] = `num_count_insig'
			
	qui count if `p'R_3coeff < 0 & `p'R_3pval <= 0.1 & `p'R_3pval > 0.05
	local num_count_0_1 = r(N)
	qui matrix by_scale_`p'_3[2,4] = `num_count_0_1'

	qui count if `p'R_3coeff < 0 & `p'R_3pval <= 0.05
	local num_count_0_05 = r(N)
	qui matrix by_scale_`p'_3[3,4] = `num_count_0_05'
			
	qui matrix by_scale_`p'_3[4,4] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
			
	forvalues col = 2/9 {
		qui matrix by_scale_`p'_3[1,4*`col'-3] = 0
		qui matrix by_scale_`p'_3[2,4*`col'-3] = 0
		qui matrix by_scale_`p'_3[3,4*`col'-3] = 0
		qui matrix by_scale_`p'_3[4,4*`col'-3] = 0
		
		qui count if `p'R_3coeff >= 0 & `p'R_3pval > 0.1 & scale_row == `col'
		local num_count_insig = r(N)
		qui matrix by_scale_`p'_3[1,4*`col'-2] = `num_count_insig'
			
		qui count if `p'R_3coeff >= 0 & `p'R_3pval <= 0.1 & `p'R_3pval > 0.05 & scale_row == `col'
		local num_count_0_1 = r(N)
		qui matrix by_scale_`p'_3[2,4*`col'-2] = `num_count_0_1'

		qui count if `p'R_3coeff >= 0 & `p'R_3pval <= 0.05 & scale_row == `col'
		local num_count_0_05 = r(N)
		qui matrix by_scale_`p'_3[3,4*`col'-2] = `num_count_0_05'
				
		qui matrix by_scale_`p'_3[4,4*`col'-2] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
		
		qui matrix by_scale_`p'_3[1,4*`col'-1] = 0
		qui matrix by_scale_`p'_3[2,4*`col'-1] = 0
		qui matrix by_scale_`p'_3[3,4*`col'-1] = 0
		qui matrix by_scale_`p'_3[4,4*`col'-1] = 0
		
		qui count if `p'R_3coeff < 0 & `p'R_3pval > 0.1 & scale_row == `col'
		local num_count_insig = r(N)
		qui matrix by_scale_`p'_3[1,4*`col'] = `num_count_insig'
				
		qui count if `p'R_3coeff < 0 & `p'R_3pval <= 0.1 & `p'R_3pval > 0.05 & scale_row == `col'
		local num_count_0_1 = r(N)
		qui matrix by_scale_`p'_3[2,4*`col'] = `num_count_0_1'

		qui count if `p'R_3coeff < 0 & `p'R_3pval <= 0.05 & scale_row == `col'
		local num_count_0_05 = r(N)
		qui matrix by_scale_`p'_3[3,4*`col'] = `num_count_0_05'
			
		qui matrix by_scale_`p'_3[4,4*`col'] = `num_count_insig' + `num_count_0_1' + `num_count_0_05'
	}
}

matrix by_scale_merge_3 = by_scale_3 ///
						+ by_scale_ehscenter_3 + by_scale_ehshome_3 + by_scale_ehsmixed_3 ///
						+ by_scale_ihdplow_3 + by_scale_ihdphigh_3 ///
						+ by_scale_abc_3 ///
						+ by_scale_carehv_3 + by_scale_careboth_3

cd "${homo_path}/out/home"
frmttable using by_scale_3, statmat(by_scale_merge_3) substat(1) sdec(0) fragment tex replace nocenter
