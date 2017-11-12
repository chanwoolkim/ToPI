* ----------------------------------- *
* Tables of treatment effects - EHS doc
* Author: Chanwool Kim
* Date Created: 28 Apr 2017
* Last Update: 14 May 2017
* ----------------------------------- *

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

global covariates 			m_age m_edu sibling m_iq race sex gestage mf

local programs				ehs ihdp abc careboth carehv

* EHS
local ehs_tests 			home
local ehs_home_types		warm nonpun verb harsh /*inenviro exenviro (scale not consistent)*/ lang

* IHDP
local ihdp_tests 			home
local ihdp_home_types		warm nonpun verb harsh /*inenviro exenviro (scale not consistent)*/ lang

* ABC
local abc_tests 			home
local abc_home_types		warm nonpun verb harsh /*inenviro exenviro (scale not consistent)*/ lang

* CARE
local careboth_tests 		home
local careboth_home_types	warm nonpun verb /*harsh(no obs)*/ /*inenviro exenviro (scale not consistent)*/ lang
local carehv_tests 			home
local carehv_home_types		warm nonpun verb /*harsh(no obs)*/ /*inenviro exenviro (scale not consistent)*/ lang

* ---------------------- *
* Define macros for tables

local ehs_ages				14 24 36
local ihdp_ages				12 36
local abc_ages				6 18 30 42 54
local careboth_ages			6 18 30 42 54
local carehv_ages			6 18 30 42 54

local treatment				treat == 1

local control				treat == 0

local home_total_name		Total Score
local home_warm_name		Warmth Score
local home_verb_name		Parental Verbal Skills Score
/*local home_exenviro_name	External Environment Score
local home_inenviro_name	Internal Environment Score*/
local home_lang_name		Language and Cognitive Stimulation Score
local home_nonpun_name		Nonpunitive Score

* ------- *
* Execution

* Get data
foreach p of local programs {
cd "${data_`p'}"
use "`p'-home-ehs.dta", clear

drop home_*
rename norm_home_* home_*

merge 1:1 id using "`p'-home-control", nogen nolabel
merge 1:1 id using "`p'-home-participation", nogen nolabel

cd "${data_store}\table\ehs"

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
