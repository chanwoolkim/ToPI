* ------------------------- *
* Tables of treatment effects
* Author: Chanwool Kim
* ------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local tests 					home labor

* EHS
local ehs_home_types			$home_types
local ehs_home_type_name		""Total" "Learning Stimulation" "Developmental Materials" "Opportunities for Variety" "Lack of Hostility" "Warmth""
local ehs_labor_types			hh_inc m_work m_workhour
local ehs_labor_type_name		""Household Income" "Mother Employed" "Mother Work Hour""

* IHDP
local ihdp_home_types			$home_types
local ihdp_home_type_name		""Total" "Learning Stimulation" "Developmental Materials" "Opportunities for Variety" "Lack of Hostility" "Warmth""
local ihdp_labor_types			hh_inc m_work m_workhour f_work
local ihdp_labor_type_name		""Household Income" "Mother Employed" "Mother Work Hour" "Father Employed""

* ABC
local abc_home_types			$home_types
local abc_home_type_name		""Total" "Learning Stimulation" "Developmental Materials" "Opportunities for Variety" "Lack of Hostility" "Warmth""
local abc_labor_types			hh_inc hh_wage m_work
local abc_labor_type_name		""Household Income" "Household Wage" "Mother Employed""

* CARE
local care_home_types			$home_types
local care_home_type_name 		""Total" "Learning Stimulation" "Developmental Materials" "Opportunities for Variety" "Lack of Hostility" "Warmth""
local care_labor_types			hh_inc hh_wage m_work
local care_labor_type_name		""Household Income" "Household Wage" "Mother Employed""

* ---------------------- *
* Define macros for tables

local home_digits				3
local labor_digits				0

local ehs_home_ages				14 24 36
local ihdp_home_ages			12 36
local abc_home_ages				6 18 30 42 54
local care_home_ages			6 18 30 42 54

local ehs_home_ages_dup	14m 	14 24m 24 36m 36
local ihdp_home_ages_dup		12m 12 36m 36
local abc_home_ages_dup			6m 6 18m 18 30m 30 42m 42 54m 54
local care_home_ages_dup		6m 6 18m 18 30m 30 42m 42 54m 54

local ehs_labor_ages			0 26 60 120
local ihdp_labor_ages			0 4 8 12 18 24 30 36 48 60 78 96
local abc_labor_ages			0 18 30 42 54 60 96 144 180 252
local care_labor_ages			0 18 30 42 54 60 96 144

local ehs_labor_ages_dup		0m 0 26m 26 60m 60 120m 120
local ihdp_labor_ages_dup		0m 0 4m 4 8m 8 12m 12 18m 18 24m 24 30m 30 36m 36 48m 48 60m 60 78m 78 96m 96
local abc_labor_ages_dup		0m 0 18m 18 30m 30 42m 42 54m 54 60m 60 96m 96 144m 144 180m 180 252m 252
local care_labor_ages_dup		0m 0 18m 18 30m 30 42m 42 54m 54 60m 60 96m 96 144m 144

* ------- *
* Execution

foreach p of global programs {

	* Set local name of main program
	if "`p'" == "ehs" | "`p'" == "ehscenter" | "`p'" == "ehshome" | "`p'" == "ehsmixed" {
		local p_main "ehs"
	}

	if "`p'" == "ihdp" {
		local p_main "ihdp"
	}

	if "`p'" == "abc" {
		local p_main "abc"
	}

	if "`p'" == "care" | "`p'" == "careboth" | "`p'" == "carehv" {
		local p_main "care"
	}

	foreach t of local tests {
		cd "$data_working"
		use `p'-merge, clear
		
		if "`t'" == "home" {
			drop home*
			rename norm_home* home*
		}
		
		if "`t'" == "labor" {
			* Some additional cleaning
			if "`p'" == "abc" {
				drop labor_hh_inc0 labor_hh_inc96 labor_hh_wage60 labor_m_work60
			}
			
			if "`p'" == "carehv" | "`p'" == "careboth" {
				drop labor_hh_inc18 labor_hh_wage0 labor_hh_wage96 labor_hh_wage180 labor_hh_wage252 labor_m_work0 labor_m_work252 labor_f_work0 labor_f_work252
			}
		}
	
	local p_t_num : list sizeof local(`p_main'_`t'_types)
	local p_t_n	  : list sizeof local(`p_main'_`t'_ages)
	
	* Create empty matrices: coefficients, SEs, and p-values (row is type, col is age)
	qui matrix R`t'_coeff_se = J(`p_t_num', 2*`p_t_n', .) // for randomisation (coefficient and SE)
	qui matrix R`t'_p = J(`p_t_num', 2*`p_t_n', .) // for randomisation (p-value)
	qui matrix D`t'_coeff_se = J(`p_t_num', 2*`p_t_n', .) // for participation (coefficient and SE)
	qui matrix D`t'_p = J(`p_t_num', 2*`p_t_n', .) // for participation (p-value)
	
	qui matrix colnames R`t'_coeff_se = ``p_main'_`t'_ages_dup'
	qui matrix colnames R`t'_p = ``p_main'_`t'_ages_dup'
	qui matrix colnames D`t'_coeff_se = ``p_main'_`t'_ages_dup'
	qui matrix colnames D`t'_p = ``p_main'_`t'_ages_dup'
	
	qui matrix rownames R`t'_coeff_se = ``p_main'_`t'_type_name'
	qui matrix rownames D`t'_coeff_se = ``p_main'_`t'_type_name'

	local row = 1

		foreach s of local `p_main'_`t'_types {
		local col = 1
			
		* Loop over rows to fill in values into the empty qui matrix.
		foreach age of local `p_main'_`t'_ages {
			capture confirm variable `t'_`s'`age'
			if !_rc {
			
			* Need to check there is enough variation
			* If all values are the same, put 0 for coefficient and SE
			by `t'_`s'`age', sort: gen nvals_`t'_`s'`age' = _n == 1 if `t'_`s'`age' != .
			count if nvals_`t'_`s'`age' == 1
			local nvals = r(N)
			
			if `nvals' < 2 {
			di "Not much variability - `t'`s'_`age'"
			
			qui matrix R`t'_coeff_se[`row',2*`col'-1] = 0
			qui matrix R`t'_coeff_se[`row',2*`col'] = 0
			qui matrix R`t'_p[`row',2*`col'-1] = 1
			
			qui matrix D`t'_coeff_se[`row',2*`col'-1] = 0
			qui matrix D`t'_coeff_se[`row',2*`col'] = 0
			qui matrix D`t'_p[`row',2*`col'-1] = 1
			}
			
			else {
			* Randomisation variable
			qui regress `t'_`s'`age' R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, SE, p-value).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix R`t'_coeff_se[`row',2*`col'-1] = r[1,1]
			qui matrix R`t'_coeff_se[`row',2*`col'] = r[2,1]
			qui matrix R`t'_p[`row',2*`col'-1] = r[4,1]
			
			* Participation variable (program specific)
			* We only want to do IV regression only if there is significant variability (> 1%)
			count if !missing(`t'_`s'`age') & !missing(D)
			local nobs = r(N)
			count if R != D & !missing(`t'_`s'`age') & !missing(D)
			local ndiff = r(N)
			local nprop = `ndiff'/`nobs'
			
			if `nprop' < 0.01 | `ndiff' < 2 {
			di "Not much variability - `t'`s'_`age'"
			qui regress `t'_`s'`age' R $covariates if !missing(D)
			}
			
			else {
			qui ivregress 2sls `t'_`s'`age' (D = R) $covariates if !missing(D)
			}
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)
		
			qui matrix D`t'_coeff_se[`row',2*`col'-1] = r[1,1]
			qui matrix D`t'_coeff_se[`row',2*`col'] = r[2,1]
			qui matrix D`t'_p[`row',2*`col'-1] = r[4,1]
			}
			
			local col = `col' + 1
			}
			
			else {
			local col = `col' + 1
			}
		}
		
		local row = `row' + 1
		}
	
	local R`t'nrow = rowsof(R`t'_p)
	local R`t'ncol = colsof(R`t'_p)
	local D`t'nrow = rowsof(D`t'_p)
	local D`t'ncol = colsof(D`t'_p)

	qui matrix R`t'_stars = J(`R`t'nrow', `R`t'ncol', 0) // for randomisation (stars)
	qui matrix D`t'_stars = J(`D`t'nrow', `D`t'ncol', 0) // for participation (stars)
	
	qui matrix colnames R`t'_stars = ``p_main'_ages'
	qui matrix colnames D`t'_stars = ``p_main'_ages'
	
	forvalues k = 1/`R`t'nrow' {
		forvalues l = 1/`R`t'ncol' {
			qui matrix R`t'_stars[`k',`l'] = (R`t'_p[`k',`l'] < 0.1) ///
										 + (R`t'_p[`k',`l'] < 0.05) ///
										 + (R`t'_p[`k',`l'] < 0.01)
		}
	}
	
	forvalues k = 1/`D`t'nrow' {
		forvalues l = 1/`D`t'ncol' {
			qui matrix D`t'_stars[`k',`l'] = (D`t'_p[`k',`l'] < 0.1) ///
										 + (D`t'_p[`k',`l'] < 0.05) ///
										 + (D`t'_p[`k',`l'] < 0.01)
		}
	}
	
	cd "${analysis_out}/`t'"
	frmttable using `p'R_`t', statmat(R`t'_coeff_se) substat(1) sdec(``t'_digits') fragment tex replace nocenter ///
					annotate(R`t'_stars) asymbol(*,**,***)
	
	frmttable using `p'D_`t', statmat(D`t'_coeff_se) substat(1) sdec(``t'_digits') fragment tex replace nocenter ///
					annotate(D`t'_stars) asymbol(*,**,***)
					
	cd "${analysis_git_out}/`t'"
	frmttable using `p'R_`t', statmat(R`t'_coeff_se) substat(1) sdec(``t'_digits') fragment tex replace nocenter ///
					annotate(R`t'_stars) asymbol(*,**,***)
	
	frmttable using `p'D_`t', statmat(D`t'_coeff_se) substat(1) sdec(``t'_digits') fragment tex replace nocenter ///
					annotate(D`t'_stars) asymbol(*,**,***)
	}
}
