* -------------------------------------- *
* Tables of treatment effects - aggregates
* Author: Chanwool Kim
* Date Created: 20 Apr 2017
* Last Update: 14 May 2017
* -------------------------------------- *

clear all
set more off
ssc install outreg2, replace
adoupdate outreg2

global data_ehs		: env data_ehs
global data_ihdp	: env data_ihdp
global data_abc		: env data_abc
global data_careboth	: env data_care
global data_carehv	: env data_care
global data_store	: env klmshare
global klmshare		: env klmshare

* --------------------------- *
* Define macros for abstraction

global covariates			m_age m_edu sibling m_iq race sex gestage mf

local programs				ehs ihdp abc careboth carehv

* EHS
local ehs_tests 			home
local ehs_home_types		total warm host verb nonpun harsh learn inenviro exenviro lang emot

* IHDP
local ihdp_tests 			home
local ihdp_home_types		total emot accept org pm inv var learn lang exenviro warm acad mod

* ABC
local abc_tests 			home
local abc_home_types		total nonpun toys var devstm exper indep lang masc inv warm absrst inenviro exenviro mature

* CARE
local careboth_tests 		home
local careboth_home_types	total nonpun toys var devstm exper indep lang masc inv warm absrst inenviro exenviro mature
local carehv_tests 			home
local carehv_home_types		total nonpun toys var devstm exper indep lang masc inv warm absrst inenviro exenviro mature

* ---------------------- *
* Define macros for tables

local ehs_ages				14 24 36 48 120
local ihdp_ages				12 36 60 78 96
local abc_ages				6 18 30 42 54 96
local careboth_ages			6 18 30 42 54 96
local carehv_ages			6 18 30 42 54 96

local treatment				treat == 1

local control				treat == 0

local home_total_name		Total Score
local home_warm_name		Warmth Score
local home_host_name		Hostility Score
local home_verb_name		Parental Verbal Skills Score
local home_exenviro_name	External Environment Score
local home_lang_name		Language and Cognitive Stimulation Score
local home_accept_name		Acceptance Score
local home_nonpun_name		Nonpunitive Score
local home_masc_name		Masculine Score
local home_harsh_name		Harshness Score
local home_pm_name			Play Material
local home_org_name			Organization Score
local home_devstm_name		Development Stimulation Score
local home_emot_name		Emotional Score
local home_absrst_name		Avoidance of Restriction
local home_mature_name		Mature Score
local home_emotin_name		Emotional Score
local home_exper_name		Breadth of Experience Score
local home_mod_name			Modeling Score
local home_learn_name		Learning Score
local home_acad_name		Academic Stimulation Score
local home_toys_name		Appropriate Toys Score
local home_var_name			Variety Score
local home_indep_name		Fostering Independence Score
local home_inv_name			Maternal Involvement Score
local home_inenviro_name	Internal Environment Score

* ------- *
* Execution

* Get data
foreach p of local programs {
cd "${data_`p'}"
use "`p'-home-agg.dta", clear

drop home_*
rename norm_home_* home_*

merge 1:1 id using "`p'-home-control", nogen nolabel
merge 1:1 id using "`p'-home-participation", nogen nolabel

cd "${data_store}\table\main"

foreach t of local `p'_tests {
	foreach s of local `p'_`t'_types {
		foreach age of local `p'_ages {
			capture confirm variable `t'_`s'`age'
			if !_rc {
			qui regress `t'_`s'`age' R $covariates if !missing(D)
			outreg2 using `p'_`t'_`s', keep(R) nocon append ctitle(`age'm) tex(land)
			}
		}
	}
}

* Participation variable (program specific)
* We only want to do IV regression only if there is significant variability (> 10%)
foreach t of local `p'_tests {
	foreach s of local `p'_`t'_types {
		foreach age of local `p'_ages {
			capture confirm variable `t'_`s'`age'
			if !_rc {
			qui count if `t'_`s'`age' != .
			local nobs = r(N)
			qui count if R != D & `t'_`s'`age' != .
			local ndiff = r(N)
			local nprop = `ndiff'/`nobs'
		
			if `nprop' < 0.01 {
			di "Not much variability - `t'`s'_`age'"
			qui regress `t'_`s'`age' R $covariates if !missing(D)
			outreg2 using `p'_`t'_`s'_D, keep(R) nocon append ctitle(`age'm) tex(land)
			}
			
			else {
			qui ivregress 2sls `t'_`s'`age' (D = R) $covariates if !missing(D)
			outreg2 using `p'_`t'_`s'_D, keep(D) nocon append ctitle(`age'm) tex(land)
			}
			}
		}
	}
}
}
