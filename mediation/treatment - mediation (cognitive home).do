* ---------------------------- *
* Mediation analysis (IQ - HOME)
* Author: Chanwool Kim
* Date Created: 20 Apr 2017
* Last Update: 1 Mar 2018
* ---------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local programs_m			ehscenter ihdplow ihdphigh

* EHS
local ehscenter_home_types	total learning
local ehscenter_cogs		ppvt

* IHDP
local ihdplow_home_types	total learning
local ihdplow_cogs			ppvt sb
local ihdphigh_home_types	total learning
local ihdphigh_cogs			ppvt sb

* ---------------------------- *
* Execution - Mediation Analysis

foreach p of local programs_m {
cd "$data_home"
use "`p'-home-agg-merge.dta", clear

drop home_*
rename norm_home_* home_*

	foreach c of local `p'_cogs {
		foreach s of local `p'_home_types {
				sgmediation `c'36 if !missing(D), mv(home_`s'36) iv(R) cv($covariates)
				bootstrap r(ind_eff) r(dir_eff), reps(1000): sgmediation `c'36 if !missing(D), mv(home_`s'36) iv(R) cv($covariates)
			}
	}
}

* --------------------------- *
* Define macros for abstraction

* IHDP
local ehs_cogs		ppvt
local ihdp_cogs		ppvt sb
local abc_cogs		sb
local matrix_type	random parenting interaction

* ------- *
* Execution

foreach p of global programs_merge {
	foreach t of global `p'_type {
		foreach c of local `p'_cogs {
		cd "$data_home"
		use "`p'`t'-home-agg-merge.dta", clear
		
		if "`p'" == "abc" {
			rename norm_home_*42 norm_home_*36
		}
		
		foreach s of local matrix_type {
			qui matrix `p'`t'_`c'`s'_3 = J(9, 4, .)
			qui matrix colnames `p'`t'_`c'`s'_3 = `p'`t'_`c'`s'_3num `p'`t'_`c'`s'_3coeff `p'`t'_`c'`s'_3se `p'`t'_`c'`s'_3pval
		}
		
		local row_`c'3 = 1
		
		* Loop over rows to fill in values into the empty matrix.
		foreach r of global later_home_types {
			qui matrix `p'`t'_`c'random_3[`row_`c'3',1] = `row_`c'3'
			qui matrix `p'`t'_`c'parenting_3[`row_`c'3',1] = `row_`c'3'
			qui matrix `p'`t'_`c'interaction_3[`row_`c'3',1] = `row_`c'3'
					
			capture confirm variable norm_home_`r'36
				if !_rc {
				* Randomisation variable
				qui xi: regress `c'36 i.R*norm_home_`r'36 if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'`t'_`c'random_3[`row_`c'3',2] = r[1,1]
				qui matrix `p'`t'_`c'random_3[`row_`c'3',3] = r[2,1]
				qui matrix `p'`t'_`c'random_3[`row_`c'3',4] = r[4,1]
				
				qui matrix `p'`t'_`c'parenting_3[`row_`c'3',2] = r[1,2]
				qui matrix `p'`t'_`c'parenting_3[`row_`c'3',3] = r[2,2]
				qui matrix `p'`t'_`c'parenting_3[`row_`c'3',4] = r[4,2]
				
				qui matrix `p'`t'_`c'interaction_3[`row_`c'3',2] = r[1,3]
				qui matrix `p'`t'_`c'interaction_3[`row_`c'3',3] = r[2,3]
				qui matrix `p'`t'_`c'interaction_3[`row_`c'3',4] = r[4,3]

				local row_`c'3 = `row_`c'3' + 1
				}
						
				else {
				local row_`c'3 = `row_`c'3' + 1				
				}
			}
		
		cd "$mediation_working"
		
		foreach s of local matrix_type {
			clear
			svmat `p'`t'_`c'`s'_3, names(col)
			rename `p'`t'_`c'`s'_3num row_3
			keep row_3 `p'`t'_`c'`s'_3coeff `p'`t'_`c'`s'_3se `p'`t'_`c'`s'_3pval
			keep if row_3 != .
			save "`p'`t'-`c'`s'-agg-mediation-3", replace
		}
		}
	}
}

* --------*
* Questions

* Randomisation

foreach p of global programs_merge {
	cd "$mediation_working"
	foreach c of local `p'_cogs {

		use `p'-`c'random-agg-mediation-3, clear

		foreach t of global `p'_type {
			foreach s of local matrix_type {
				merge 1:1 row_3 using `p'`t'-`c'`s'-agg-mediation-3, nogen nolabel
			}
		}

		rename row_3 row
		
		tostring row, gen(scale_num)

		replace scale = "Total Score" if scale_num == "1"
		replace scale = "Development Materials" if scale_num == "2"
		replace scale = "Family Culture" if scale_num == "3"
		replace scale = "Housing" if scale_num == "4"
		replace scale = "Lack of Hostility" if scale_num == "5"
		replace scale = "Learning Stimulation" if scale_num == "6"
		replace scale = "Opportunities for Variety" if scale_num == "7"
		replace scale = "Warmth" if scale_num == "8"

		save `p'-`c'-agg-mediation-3, replace
	}
}

* ----------------- *
* Execution - P-value

foreach c of local ehs_cogs {
	cd "$mediation_working"
	
	use ehs-`c'-agg-mediation-3, clear
	
	foreach p in ehs ehscenter ehshome ehsmixed {
		gen `p'_`c'random_3dup = 1
		gen `p'_`c'parenting_3dup = 1
		gen `p'_`c'interaction_3dup = 1
	}
	
	mkmat ehs_`c'random_3coeff ehs_`c'random_3se ehs_`c'parenting_3coeff ehs_`c'parenting_3se ehs_`c'interaction_3coeff ehs_`c'interaction_3se ///
		  ehscenter_`c'random_3coeff ehscenter_`c'random_3se ehscenter_`c'parenting_3coeff ehscenter_`c'parenting_3se ehscenter_`c'interaction_3coeff ehscenter_`c'interaction_3se ///
		  ehshome_`c'random_3coeff ehshome_`c'random_3se ehshome_`c'parenting_3coeff ehshome_`c'parenting_3se ehshome_`c'interaction_3coeff ehshome_`c'interaction_3se ///
		  ehsmixed_`c'random_3coeff ehsmixed_`c'random_3se ehsmixed_`c'parenting_3coeff ehsmixed_`c'parenting_3se ehsmixed_`c'interaction_3coeff ehsmixed_`c'interaction_3se, ///
		  matrix(main_`c') rownames(scale_num)
		  
	mkmat ehs_`c'random_3pval ehs_`c'random_3dup ehs_`c'parenting_3pval ehs_`c'parenting_3dup ehs_`c'interaction_3pval ehs_`c'interaction_3dup ///
		  ehscenter_`c'random_3pval ehscenter_`c'random_3dup ehscenter_`c'parenting_3pval ehscenter_`c'parenting_3dup ehscenter_`c'interaction_3pval ehscenter_`c'interaction_3dup ///
		  ehshome_`c'random_3pval ehshome_`c'random_3dup ehshome_`c'parenting_3pval ehshome_`c'parenting_3dup ehshome_`c'interaction_3pval ehshome_`c'interaction_3dup ///
		  ehsmixed_`c'random_3pval ehsmixed_`c'random_3dup ehsmixed_`c'parenting_3pval ehsmixed_`c'parenting_3dup ehsmixed_`c'interaction_3pval ehsmixed_`c'interaction_3dup, ///
		  matrix(pval_`c') rownames(scale_num)
		  
	local nrow_`c' = rowsof(pval_`c')
	local ncol_`c' = colsof(pval_`c')
	
	qui matrix stars_`c' = J(`nrow_`c'', `ncol_`c'', 0)

	forvalues k = 1/`nrow_`c'' {
		forvalues l = 1/`ncol_`c'' {
			qui matrix stars_`c'[`k',`l'] = (pval_`c'[`k',`l'] < 0.1) ///
											+ (pval_`c'[`k',`l'] < 0.05) ///
											+ (pval_`c'[`k',`l'] < 0.01)
		}
	}
	
	cd "${mediation_out}"
	frmttable using ehs-table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
					annotate(stars_`c') asymbol(*,**,***)

	cd "${mediation_git_out}"
	frmttable using ehs-table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
					annotate(stars_`c') asymbol(*,**,***)
}

foreach c of local ihdp_cogs {
	cd "$mediation_working"
	
	use ihdp-`c'-agg-mediation-3, clear
	
	foreach p in ihdp ihdphigh ihdplow {
		gen `p'_`c'random_3dup = 1
		gen `p'_`c'parenting_3dup = 1
		gen `p'_`c'interaction_3dup = 1
	}
	
	mkmat ihdp_`c'random_3coeff ihdp_`c'random_3se ihdp_`c'parenting_3coeff ihdp_`c'parenting_3se ihdp_`c'interaction_3coeff ihdp_`c'interaction_3se ///
		  ihdphigh_`c'random_3coeff ihdphigh_`c'random_3se ihdphigh_`c'parenting_3coeff ihdphigh_`c'parenting_3se ihdphigh_`c'interaction_3coeff ihdphigh_`c'interaction_3se ///
		  ihdplow_`c'random_3coeff ihdplow_`c'random_3se ihdplow_`c'parenting_3coeff ihdplow_`c'parenting_3se ihdplow_`c'interaction_3coeff ihdplow_`c'interaction_3se, ///
		  matrix(main_`c') rownames(scale_num)
		  
	mkmat ihdp_`c'random_3pval ihdp_`c'random_3dup ihdp_`c'parenting_3pval ihdp_`c'parenting_3dup ihdp_`c'interaction_3pval ihdp_`c'interaction_3dup ///
		  ihdphigh_`c'random_3pval ihdphigh_`c'random_3dup ihdphigh_`c'parenting_3pval ihdphigh_`c'parenting_3dup ihdphigh_`c'interaction_3pval ihdphigh_`c'interaction_3dup ///
		  ihdplow_`c'random_3pval ihdplow_`c'random_3dup ihdplow_`c'parenting_3pval ihdplow_`c'parenting_3dup ihdplow_`c'interaction_3pval ihdplow_`c'interaction_3dup, ///
		  matrix(pval_`c') rownames(scale_num)
		  
	local nrow_`c' = rowsof(pval_`c')
	local ncol_`c' = colsof(pval_`c')
	
	qui matrix stars_`c' = J(`nrow_`c'', `ncol_`c'', 0)

	forvalues k = 1/`nrow_`c'' {
		forvalues l = 1/`ncol_`c'' {
			qui matrix stars_`c'[`k',`l'] = (pval_`c'[`k',`l'] < 0.1) ///
											+ (pval_`c'[`k',`l'] < 0.05) ///
											+ (pval_`c'[`k',`l'] < 0.01)
		}
	}
	
	cd "${mediation_out}"
	frmttable using ihdp-table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
					annotate(stars_`c') asymbol(*,**,***)

	cd "${mediation_git_out}"
	frmttable using ihdp-table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
					annotate(stars_`c') asymbol(*,**,***)
}

foreach c of local abc_cogs {
	cd "$mediation_working"
	
	use abc-`c'-agg-mediation-3, clear

	gen abc_`c'random_3dup = 1
	gen abc_`c'parenting_3dup = 1
	gen abc_`c'interaction_3dup = 1

	
	mkmat abc_`c'random_3coeff abc_`c'random_3se abc_`c'parenting_3coeff abc_`c'parenting_3se abc_`c'interaction_3coeff abc_`c'interaction_3se, ///
		  matrix(main_`c') rownames(scale_num)
		  
	mkmat abc_`c'random_3pval abc_`c'random_3dup abc_`c'parenting_3pval abc_`c'parenting_3dup abc_`c'interaction_3pval abc_`c'interaction_3dup, ///
		  matrix(pval_`c') rownames(scale_num)
		  
	local nrow_`c' = rowsof(pval_`c')
	local ncol_`c' = colsof(pval_`c')
	
	qui matrix stars_`c' = J(`nrow_`c'', `ncol_`c'', 0)

	forvalues k = 1/`nrow_`c'' {
		forvalues l = 1/`ncol_`c'' {
			qui matrix stars_`c'[`k',`l'] = (pval_`c'[`k',`l'] < 0.1) ///
											+ (pval_`c'[`k',`l'] < 0.05) ///
											+ (pval_`c'[`k',`l'] < 0.01)
		}
	}
	
	cd "${mediation_out}"
	frmttable using abc-table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
					annotate(stars_`c') asymbol(*,**,***)

	cd "${mediation_git_out}"
	frmttable using abc-table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
					annotate(stars_`c') asymbol(*,**,***)
}
