* --------------------- *
* By-site analysis (IHDP)
* Author: Chanwool Kim
* --------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

* IHDP
local cogs			ppvt sb
local matrix_type	random parenting interaction

local nrow : list sizeof global(home_types)

* ------- *
* Execution

foreach t of global ihdp_type {
	foreach c of local cogs {
		cd "$data_working"
		use "ihdp`t'-merge.dta", clear

		levelsof state, local(states)

		gen `c'_result = .

		foreach s of local states {
			qui regress `c'36 R $covariates if !missing(D) & state == "`s'"
			qui matrix list r(table)
			qui matrix r = r(table)
			local `c'_`s'_result = r[1,1]

			replace `c'_result = ``c'_`s'_result' if state == "`s'"
		}

		foreach s of local matrix_type {
			qui matrix ihdp`t'_`c'`s'_3 = J(`nrow', 4, .) // for randomisation variable
			qui matrix colnames ihdp`t'_`c'`s'_3 = ihdp`t'_`c'`s'_3num ihdp`t'_`c'`s'_3coeff ihdp`t'_`c'`s'_3se ihdp`t'_`c'`s'_3pval
		}

		local row_`c'3 = 1

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global home_types {
			qui matrix ihdp`t'_`c'random_3[`row_`c'3',1] = `row_`c'3'
			qui matrix ihdp`t'_`c'parenting_3[`row_`c'3',1] = `row_`c'3'
			qui matrix ihdp`t'_`c'interaction_3[`row_`c'3',1] = `row_`c'3'

			capture confirm variable norm_home_`r'36
			if !_rc {
				* Randomisation variable
				qui xi: regress norm_home_`r'36 i.R*`c'_result if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix ihdp`t'_`c'random_3[`row_`c'3',2] = r[1,1]
				qui matrix ihdp`t'_`c'random_3[`row_`c'3',3] = r[2,1]
				qui matrix ihdp`t'_`c'random_3[`row_`c'3',4] = r[4,1]

				qui matrix ihdp`t'_`c'parenting_3[`row_`c'3',2] = r[1,2]
				qui matrix ihdp`t'_`c'parenting_3[`row_`c'3',3] = r[2,2]
				qui matrix ihdp`t'_`c'parenting_3[`row_`c'3',4] = r[4,2]

				qui matrix ihdp`t'_`c'interaction_3[`row_`c'3',2] = r[1,3]
				qui matrix ihdp`t'_`c'interaction_3[`row_`c'3',3] = r[2,3]
				qui matrix ihdp`t'_`c'interaction_3[`row_`c'3',4] = r[4,3]

				local row_`c'3 = `row_`c'3' + 1
			}

			else {
				local row_`c'3 = `row_`c'3' + 1				
			}
		}

		cd "$data_analysis"

		foreach s of local matrix_type {
			clear
			svmat ihdp`t'_`c'`s'_3, names(col)
			rename ihdp`t'_`c'`s'_3num row_3
			keep row_3 ihdp`t'_`c'`s'_3coeff ihdp`t'_`c'`s'_3se ihdp`t'_`c'`s'_3pval
			keep if row_3 != .
			save "ihdp`t'-`c'`s'-by-site-3", replace
		}
	}
}

* --------*
* Questions

cd "$data_analysis"

* Randomisation

foreach c of local cogs {

	use ihdp-`c'random-by-site-3, clear

	foreach t of global ihdp_type {
		foreach s of local matrix_type {
			merge 1:1 row_3 using ihdp`t'-`c'`s'-by-site-3, nogen nolabel
		}
	}

	rename row_3 row
	include "${code_path}/function/home_agg"
	save ihdp-`c'-by-site-3, replace
}

* ----------------- *
* Execution - P-value

foreach c of local cogs {
	cd "$data_analysis"

	use ihdp-`c'-by-site-3, clear

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

	qui matrix stars_`c' = J(`nrow_`c'', `ncol_`c'', 0) // for randomisation (stars)

	forvalues k = 1/`nrow_`c'' {
		forvalues l = 1/`ncol_`c'' {
			qui matrix stars_`c'[`k',`l'] = (pval_`c'[`k',`l'] < 0.1) ///
				+ (pval_`c'[`k',`l'] < 0.05) ///
				+ (pval_`c'[`k',`l'] < 0.01)
		}
	}

	cd "$by_site_out"
	frmttable using table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)

	cd "$by_site_git_out"
	frmttable using table_`c', statmat(main_`c') substat(1) sdec(3) fragment tex replace nocenter ///
		annotate(stars_`c') asymbol(*,**,***)
}
