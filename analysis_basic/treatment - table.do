* ------------------------- *
* Tables of treatment effects
* Author: Chanwool Kim
* Date Created: 30 Jun 2017
* Last Update: 5 Nov 2017
* ------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

* EHS
local ehscenter_tests 		home labor
local ehscenter_home_types	total reading develop exterior interior hostility learning activity verbal warmth
local ehscenter_home_type_name	""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local ehscenter_home_num	10
local ehscenter_labor_types	hh_inc m_work m_workhour
local ehscenter_labor_type_name	""Household Income" "Mother Employed" "Mother Work Hour""
local ehscenter_labor_num	3

local ehshome_tests 		home labor
local ehshome_home_types	total reading develop exterior interior hostility learning activity verbal warmth
local ehshome_home_type_name	""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local ehshome_home_num		10
local ehshome_labor_types	hh_inc m_work m_workhour
local ehshome_labor_type_name	""Household Income" "Mother Employed" "Mother Work Hour""
local ehshome_labor_num		3

local ehsmixed_tests 		home labor
local ehsmixed_home_types	total reading develop exterior interior hostility learning activity verbal warmth
local ehsmixed_home_type_name	""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local ehsmixed_home_num		10
local ehsmixed_labor_types	hh_inc m_work m_workhour
local ehsmixed_labor_type_name	""Household Income" "Mother Employed" "Mother Work Hour""
local ehsmixed_labor_num	3

* IHDP
local ihdplow_tests 		home labor
local ihdplow_home_types	total reading develop exterior interior hostility learning activity verbal warmth
local ihdplow_home_type_name	""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local ihdplow_home_num		10
local ihdplow_labor_types	hh_inc m_work m_workhour f_work
local ihdplow_labor_type_name	""Household Income" "Mother Employed" "Mother Work Hour" "Father Employed""
local ihdplow_labor_num		4

local ihdphigh_tests 		home labor
local ihdphigh_home_types	total reading develop exterior interior hostility learning activity verbal warmth
local ihdphigh_home_type_name	""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local ihdphigh_home_num		10
local ihdphigh_labor_types	hh_inc m_work m_workhour f_work
local ihdphigh_labor_type_name	""Household Income" "Mother Employed" "Mother Work Hour" "Father Employed""
local ihdphigh_labor_num	4

* ABC
local abc_tests 			home labor
local abc_home_types		total reading develop exterior interior hostility learning activity verbal warmth
local abc_home_type_name	""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local abc_home_num			10
local abc_labor_types		hh_inc hh_wage m_work
local abc_labor_type_name	""Household Income" "Household Wage" "Mother Employed""
local abc_labor_num			3

* CARE
local careboth_tests 		home labor
local careboth_home_types	total reading develop exterior interior hostility learning activity verbal warmth
local careboth_home_type_name ""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local careboth_home_num		10
local careboth_labor_types	hh_inc hh_wage m_work
local careboth_labor_type_name	""Household Income" "Household Wage" "Mother Employed""
local careboth_labor_num	3

local carehv_tests 			home labor
local carehv_home_types		total reading develop exterior interior hostility learning activity verbal warmth
local carehv_home_type_name	""Total" "Access to Reading" "Development" "Home Exterior" "Home Interior" "Lack of Hostility" "Learning Stimulation" "Outings/Activities" "Verbal Skills"  "Warmth""
local carehv_home_num		10
local carehv_labor_types	hh_inc hh_wage m_work
local carehv_labor_type_name	""Household Income" "Household Wage" "Mother Employed""
local carehv_labor_num		3

* ---------------------- *
* Define macros for tables

local ehscenter_home_ages	14 24 36 48 120
local ehshome_home_ages		14 24 36 48 120
local ehsmixed_home_ages	14 24 36 48 120
local ihdplow_home_ages		12 36
local ihdphigh_home_ages	12 36
local abc_home_ages			6 18 30 42 54 96
local careboth_home_ages	6 18 30 42 54 96
local carehv_home_ages		6 18 30 42 54 96

local ehscenter_home_ages_dup	14m 14 24m 24 36m 36 48m 48 120m 120
local ehshome_home_ages_dup		14m 14 24m 24 36m 36 48m 48 120m 120
local ehsmixed_home_ages_dup	14m 14 24m 24 36m 36 48m 48 120m 120
local ihdplow_home_ages_dup		12m 12 36m 36
local ihdphigh_home_ages_dup	12m 12 36m 36
local abc_home_ages_dup			6m 6 18m 18 30m 30 42m 42 54m 54 96m 96
local careboth_home_ages_dup	6m 6 18m 18 30m 30 42m 42 54m 54 96m 96
local carehv_home_ages_dup		6m 6 18m 18 30m 30 42m 42 54m 54 96m 96

local ehscenter_home_n		5
local ehshome_home_n		5
local ehsmixed_home_n		5
local ihdplow_home_n		2
local ihdphigh_home_n		2
local abc_home_n			6
local careboth_home_n		6
local carehv_home_n			6

local ehscenter_labor_ages	0 26 60 120
local ehshome_labor_ages	0 26 60 120
local ehsmixed_labor_ages	0 26 60 120
local ihdplow_labor_ages	0 4 8 12 18 24 30 36 48 60 78 96
local ihdphigh_labor_ages	0 4 8 12 18 24 30 36 48 60 78 96
local abc_labor_ages		0 18 30 42 54 60 96 144 180 252
local careboth_labor_ages	0 18 30 42 54 60 96 144
local carehv_labor_ages		0 18 30 42 54 60 96 144

local ehscenter_labor_ages_dup	0m 0 26m 26 60m 60 120m 120
local ehshome_labor_ages_dup	0m 0 26m 26 60m 60 120m 120
local ehsmixed_labor_ages_dup	0m 0 26m 26 60m 60 120m 120
local ihdplow_labor_ages_dup	0m 0 4m 4 8m 8 12m 12 18m 18 24m 24 30m 30 36m 36 48m 48 60m 60 78m 78 96m 96
local ihdphigh_labor_ages_dup	0m 0 4m 4 8m 8 12m 12 18m 18 24m 24 30m 30 36m 36 48m 48 60m 60 78m 78 96m 96
local abc_labor_ages_dup		0m 0 18m 18 30m 30 42m 42 54m 54 60m 60 96m 96 144m 144 180m 180 252m 252
local careboth_labor_ages_dup	0m 0 18m 18 30m 30 42m 42 54m 54 60m 60 96m 96 144m 144
local carehv_labor_ages_dup		0m 0 18m 18 30m 30 42m 42 54m 54 60m 60 96m 96 144m 144
local ehscenter_labor_n		4
local ehshome_labor_n		4
local ehsmixed_labor_n		4
local ihdplow_labor_n		12
local ihdphigh_labor_n		12
local abc_labor_n			10
local careboth_labor_n		8
local carehv_labor_n		8

* ------- *
* Execution

foreach p of global programs {

	foreach t of local `p'_tests {
		cd "${data_`t'}"
		
		if "`t'" == "home" {
			use `p'-home-agg-merge, clear
			drop home*
			rename norm_* *
		}
		
		if "`t'" == "labor" {
			use `p'-labor-item-merge, clear
			
			* Some additional cleaning
			if "`p'" == "abc" {
				drop labor_hh_inc0 labor_hh_inc96 labor_hh_wage60 labor_m_work60
			}
			
			if "`p'" == "carehv" | "`p'" == "careboth" {
				drop labor_hh_inc18 labor_hh_wage0 labor_hh_wage96 labor_hh_wage180 labor_hh_wage252 labor_m_work0 labor_m_work252 labor_f_work0 labor_f_work252
			}
		}
	
	* Create empty matrices: coefficients, SEs, and p-values (row is type, col is age)
	qui matrix R`t'_coeff_se = J(``p'_`t'_num', 2*``p'_`t'_n', .) // for randomisation (coefficient and SE)
	qui matrix R`t'_p = J(``p'_`t'_num', 2*``p'_`t'_n', .) // for randomisation (p-value)
	qui matrix D`t'_coeff_se = J(``p'_`t'_num', 2*``p'_`t'_n', .) // for participation (coefficient and SE)
	qui matrix D`t'_p = J(``p'_`t'_num', 2*``p'_`t'_n', .) // for participation (p-value)
	
	qui matrix colnames R`t'_coeff_se = ``p'_`t'_ages_dup'
	qui matrix colnames R`t'_p = ``p'_`t'_ages_dup'
	qui matrix colnames D`t'_coeff_se = ``p'_`t'_ages_dup'
	qui matrix colnames D`t'_p = ``p'_`t'_ages_dup'
	
	qui matrix rownames R`t'_coeff_se = ``p'_`t'_type_name'
	qui matrix rownames D`t'_coeff_se = ``p'_`t'_type_name'

	local row = 1

		foreach s of local `p'_`t'_types {
		local col = 1
			
		* Loop over rows to fill in values into the empty qui matrix.
		foreach age of local `p'_`t'_ages {
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
	
	qui matrix colnames R`t'_stars = ``p'_ages'
	qui matrix colnames D`t'_stars = ``p'_ages'
	
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
	
	cd "${basic_path}/out/`t'"
	frmttable using `p'R_`t', statmat(R`t'_coeff_se) substat(1) sdec(3) fragment tex replace nocenter ///
					rtitles(``p'_row') ///
					annotate(R`t'_stars) asymbol(*,**,***)
	
	frmttable using `p'D_`t', statmat(D`t'_coeff_se) substat(1) sdec(3) fragment tex replace nocenter ///
					rtitles(``p'_row') ///
					annotate(D`t'_stars) asymbol(*,**,***)
	}
}
