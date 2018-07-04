* ---------------------------- *
* Mediation analysis (IQ - HOME)
* Author: Chanwool Kim
* ---------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local ehs_cogs		ppvt
local ihdp_cogs		ppvt sb
local abc_cogs		sb
local care_cogs		sb
local matrix_type	indirect direct total
local nrow : list sizeof global(home_types)

* ---------------------------- *
* Execution - Mediation Analysis

foreach p of global programs_merge {
	foreach t of global `p'_type {
		foreach c of local `p'_cogs {
			cd "$data_working"
			use "`p'`t'-merge.dta", clear

			if "`p'" == "abc" | "`p'" == "care" {
				rename norm_home_*42 norm_home_*36
			}

			foreach s of local matrix_type {
				qui matrix `p'`t'_`c'`s'_3 = J(`nrow', 4, .)
				qui matrix colnames `p'`t'_`c'`s'_3 = `p'`t'_`c'`s'_3num `p'`t'_`c'`s'_3coeff `p'`t'_`c'`s'_3se `p'`t'_`c'`s'_3pval
			}

			local row_`c'3 = 1

			foreach r of global home_types {
				qui matrix `p'`t'_`c'indirect_3[`row_`c'3',1] = `row_`c'3'
				qui matrix `p'`t'_`c'direct_3[`row_`c'3',1] = `row_`c'3'
				qui matrix `p'`t'_`c'total_3[`row_`c'3',1] = `row_`c'3'

				capture confirm variable norm_home_`r'36
				if !_rc {

					bootstrap r(ind_eff) r(dir_eff) r(tot_eff), reps(500): sgmediation `c'36 if !missing(D), mv(norm_home_`r'36) iv(R) cv($covariates)
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)

					qui matrix `p'`t'_`c'indirect_3[`row_`c'3',2] = r[1,1]
					qui matrix `p'`t'_`c'indirect_3[`row_`c'3',3] = r[2,1]
					qui matrix `p'`t'_`c'indirect_3[`row_`c'3',4] = r[4,1]

					qui matrix `p'`t'_`c'direct_3[`row_`c'3',2] = r[1,2]
					qui matrix `p'`t'_`c'direct_3[`row_`c'3',3] = r[2,2]
					qui matrix `p'`t'_`c'direct_3[`row_`c'3',4] = r[4,2]

					qui matrix `p'`t'_`c'total_3[`row_`c'3',2] = r[1,3]
					qui matrix `p'`t'_`c'total_3[`row_`c'3',3] = r[2,3]
					qui matrix `p'`t'_`c'total_3[`row_`c'3',4] = r[4,3]

					local row_`c'3 = `row_`c'3' + 1
				}

				else {
					local row_`c'3 = `row_`c'3' + 1				
				}
			}

			cd "$data_analysis"

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
	cd "$data_analysis"
	foreach c of local `p'_cogs {

		use `p'-`c'total-agg-mediation-3, clear

		foreach t of global `p'_type {
			foreach s of local matrix_type {
				merge 1:1 row_3 using `p'`t'-`c'`s'-agg-mediation-3, nogen nolabel
			}
		}

		rename row_3 row
		include "${code_path}/function/home_agg"
		save `p'-`c'-agg-mediation-3, replace
	}
}

* ----------------- *
* Execution - P-value

foreach c of local ehs_cogs {
	cd "$data_analysis"

	use ehs-`c'-agg-mediation-3, clear

	foreach p in ehs ehscenter ehshome ehsmixed {
		gen `p'_`c'indirect_3dup = 1
		gen `p'_`c'direct_3dup = 1
		gen `p'_`c'total_3dup = 1
	}

	mkmat ehs_`c'indirect_3coeff ehs_`c'indirect_3se ehs_`c'direct_3coeff ehs_`c'direct_3se ehs_`c'total_3coeff ehs_`c'total_3se ///
		ehscenter_`c'indirect_3coeff ehscenter_`c'indirect_3se ehscenter_`c'direct_3coeff ehscenter_`c'direct_3se ehscenter_`c'total_3coeff ehscenter_`c'total_3se ///
		ehshome_`c'indirect_3coeff ehshome_`c'indirect_3se ehshome_`c'direct_3coeff ehshome_`c'direct_3se ehshome_`c'total_3coeff ehshome_`c'total_3se ///
		ehsmixed_`c'indirect_3coeff ehsmixed_`c'indirect_3se ehsmixed_`c'direct_3coeff ehsmixed_`c'direct_3se ehsmixed_`c'total_3coeff ehsmixed_`c'total_3se, ///
		matrix(main_`c') rownames(scale)

	mkmat ehs_`c'indirect_3pval ehs_`c'indirect_3dup ehs_`c'direct_3pval ehs_`c'direct_3dup ehs_`c'total_3pval ehs_`c'total_3dup ///
		ehscenter_`c'indirect_3pval ehscenter_`c'indirect_3dup ehscenter_`c'direct_3pval ehscenter_`c'direct_3dup ehscenter_`c'total_3pval ehscenter_`c'total_3dup ///
		ehshome_`c'indirect_3pval ehshome_`c'indirect_3dup ehshome_`c'direct_3pval ehshome_`c'direct_3dup ehshome_`c'total_3pval ehshome_`c'total_3dup ///
		ehsmixed_`c'indirect_3pval ehsmixed_`c'indirect_3dup ehsmixed_`c'direct_3pval ehsmixed_`c'direct_3dup ehsmixed_`c'total_3pval ehsmixed_`c'total_3dup, ///
		matrix(pval_`c') rownames(scale)

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

	cd "$mediation_out"
	frmttable using ehs-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)

	cd "$mediation_git_out"
	frmttable using ehs-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)
}

foreach c of local ihdp_cogs {
	cd "$data_analysis"

	use ihdp-`c'-agg-mediation-3, clear

	foreach p in ihdp ihdphigh ihdplow {
		gen `p'_`c'indirect_3dup = 1
		gen `p'_`c'direct_3dup = 1
		gen `p'_`c'total_3dup = 1
	}

	mkmat ihdp_`c'indirect_3coeff ihdp_`c'indirect_3se ihdp_`c'direct_3coeff ihdp_`c'direct_3se ihdp_`c'total_3coeff ihdp_`c'total_3se ///
		ihdphigh_`c'indirect_3coeff ihdphigh_`c'indirect_3se ihdphigh_`c'direct_3coeff ihdphigh_`c'direct_3se ihdphigh_`c'total_3coeff ihdphigh_`c'total_3se ///
		ihdplow_`c'indirect_3coeff ihdplow_`c'indirect_3se ihdplow_`c'direct_3coeff ihdplow_`c'direct_3se ihdplow_`c'total_3coeff ihdplow_`c'total_3se, ///
		matrix(main_`c') rownames(scale)

	mkmat ihdp_`c'indirect_3pval ihdp_`c'indirect_3dup ihdp_`c'direct_3pval ihdp_`c'direct_3dup ihdp_`c'total_3pval ihdp_`c'total_3dup ///
		ihdphigh_`c'indirect_3pval ihdphigh_`c'indirect_3dup ihdphigh_`c'direct_3pval ihdphigh_`c'direct_3dup ihdphigh_`c'total_3pval ihdphigh_`c'total_3dup ///
		ihdplow_`c'indirect_3pval ihdplow_`c'indirect_3dup ihdplow_`c'direct_3pval ihdplow_`c'direct_3dup ihdplow_`c'total_3pval ihdplow_`c'total_3dup, ///
		matrix(pval_`c') rownames(scale)

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

	cd "$mediation_out"
	frmttable using ihdp-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)

	cd "$mediation_git_out"
	frmttable using ihdp-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)
}

foreach c of local abc_cogs {
	cd "$data_analysis"

	use abc-`c'-agg-mediation-3, clear

	gen abc_`c'indirect_3dup = 1
	gen abc_`c'direct_3dup = 1
	gen abc_`c'total_3dup = 1


	mkmat abc_`c'indirect_3coeff abc_`c'indirect_3se abc_`c'direct_3coeff abc_`c'direct_3se abc_`c'total_3coeff abc_`c'total_3se, ///
		matrix(main_`c') rownames(scale)

	mkmat abc_`c'indirect_3pval abc_`c'indirect_3dup abc_`c'direct_3pval abc_`c'direct_3dup abc_`c'total_3pval abc_`c'total_3dup, ///
		matrix(pval_`c') rownames(scale)

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

	cd "$mediation_out"
	frmttable using abc-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)

	cd "$mediation_git_out"
	frmttable using abc-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)
}

foreach c of local care_cogs {
	cd "$data_analysis"

	use care-`c'-agg-mediation-3, clear

	foreach p in care careboth carehome {
		gen `p'_`c'indirect_3dup = 1
		gen `p'_`c'direct_3dup = 1
		gen `p'_`c'total_3dup = 1
	}

	mkmat care_`c'indirect_3coeff care_`c'indirect_3se care_`c'direct_3coeff care_`c'direct_3se care_`c'total_3coeff care_`c'total_3se ///
		careboth_`c'indirect_3coeff careboth_`c'indirect_3se careboth_`c'direct_3coeff careboth_`c'direct_3se careboth_`c'total_3coeff careboth_`c'total_3se ///
		carehome_`c'indirect_3coeff carehome_`c'indirect_3se carehome_`c'direct_3coeff carehome_`c'direct_3se carehome_`c'total_3coeff carehome_`c'total_3se, ///
		matrix(main_`c') rownames(scale)

	mkmat care_`c'indirect_3pval care_`c'indirect_3dup care_`c'direct_3pval care_`c'direct_3dup care_`c'total_3pval care_`c'total_3dup ///
		careboth_`c'indirect_3pval careboth_`c'indirect_3dup careboth_`c'direct_3pval careboth_`c'direct_3dup careboth_`c'total_3pval careboth_`c'total_3dup ///
		carehome_`c'indirect_3pval carehome_`c'indirect_3dup carehome_`c'direct_3pval carehome_`c'direct_3dup carehome_`c'total_3pval carehome_`c'total_3dup, ///
		matrix(pval_`c') rownames(scale)

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

	cd "$mediation_out"
	frmttable using care-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)

	cd "$mediation_git_out"
	frmttable using care-mediation-`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)
}
