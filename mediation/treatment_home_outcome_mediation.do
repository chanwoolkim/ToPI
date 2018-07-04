* ---------------- *
* Mediation analysis
* Author: Chanwool Kim
* ---------------- *

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

cd "$data_working"
use "ihdp-merge.dta", clear

factor home36_1-home36_55
predict theta36, bartlett
gen theta36_R = theta36*R

factor home12_1-home12_45
predict theta12, bartlett
gen theta12_R = theta12*R

foreach v of global covariates {
	gen `v'_R = `v'*R
}

ivregress 2sls ppvt36 (theta36 theta36_R = theta12 theta12_R) R $covariates m_age_R m_edu_R sibling_R m_iq_R race_R sex_R gestage_R mf_R, vce(robust)

reg ppvt36 R $covariates, robust
ivregress 2sls ppvt36 (theta36 = theta12) R $covariates, vce(robust)
reg theta36 R $covariates, robust

qui matrix ihdp_ppvt = J(1000, 3, .)
qui matrix colnames ihdp_ppvt = ihdp_ppvt_all ihdp_ppvt_ind_outcome ihdp_ppvt_ind_mediator

forvalues b = 1/1000 {
	preserve
	bsample
	
	quietly {
	reg ppvt36 R $covariates, robust
	matrix list r(table)
	matrix r = r(table)
	matrix ihdp_ppvt[`b',1] = r[1,1]
	
	ivregress 2sls ppvt36 (theta36 = theta12) R $covariates, vce(robust)
	matrix list r(table)
	matrix r = r(table)
	matrix ihdp_ppvt[`b',2] = r[1,1]
	
	reg theta36 R $covariates, robust
	matrix list r(table)
	matrix r = r(table)
	matrix ihdp_ppvt[`b',3] = r[1,1]
	}
	
	restore
}

svmat ihdp_ppvt, names(col)
gen mediation_effect = ihdp_ppvt_ind_outcome * ihdp_ppvt_ind_mediator / ihdp_ppvt_all
keep mediation_effect ihdp_ppvt_all ihdp_ppvt_ind_outcome ihdp_ppvt_ind_mediator
keep if !missing(mediation_effect)
sort mediation_effect

ivregress 2sls sb36 (theta36 theta36_R = theta12 theta12_R) R $covariates m_age_R m_edu_R sibling_R m_iq_R race_R sex_R gestage_R mf_R, vce(robust)

reg sb36 R $covariates, robust
ivregress 2sls sb36 (theta36 = theta12) R $covariates, vce(robust)
reg theta36 R $covariates, robust


cd "$data_working"
use "abc-merge.dta", clear

factor home42_1-home42_80
predict theta42, bartlett
gen theta42_R = theta42*R

forvalues i = 1/45 {
	quietly {
	reg home30_`i' home18_`i' home6_`i'
	local df_r = e(df_r)
	predict home30_`i'_p, xb
	gen home30_`i'_r = home30_`i' - home30_`i'_p
	qui sum home30_`i'_r
	local var_r = r(Var)
	sum home30_`i'_p
	replace home30_`i'_p = r(mean) if missing(home30_`i'_p)
	replace home30_`i'_p = home30_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
	replace home30_`i' = home30_`i'_p if missing(home30_`i')
	
	reg home18_`i' home30_`i' home6_`i'
	local df_r = e(df_r)
	predict home18_`i'_p, xb
	gen home18_`i'_r = home18_`i' - home18_`i'_p
	qui sum home18_`i'_r
	local var_r = r(Var)
	sum home18_`i'_p
	replace home18_`i'_p = r(mean) if missing(home18_`i'_p)
	replace home18_`i'_p = home18_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
	replace home18_`i' = home18_`i'_p if missing(home18_`i')
	
	reg home6_`i' home30_`i' home18_`i'
	local df_r = e(df_r)
	predict home6_`i'_p, xb
	gen home6_`i'_r = home6_`i' - home6_`i'_p
	qui sum home6_`i'_r
	local var_r = r(Var)
	sum home6_`i'_p
	replace home6_`i'_p = r(mean) if missing(home6_`i'_p)
	replace home6_`i'_p = home6_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
	replace home6_`i' = home6_`i'_p if missing(home6_`i')
	}
	drop *_p *_r
}

factor home30_1-home30_45
predict theta30, bartlett
gen theta30_R = theta30*R

factor home18_1-home18_45
predict theta18, bartlett
gen theta18_R = theta18*R

factor home6_1-home6_45
predict theta6, bartlett
gen theta6_R = theta6*R

foreach v of global covariates {
	gen `v'_R = `v'*R
}

ivregress 2sls sb48 (theta42 theta42_R = theta30 theta30_R theta18 theta18_R theta6 theta6_R) R $covariates m_age_R m_edu_R sibling_R m_iq_R race_R sex_R gestage_R mf_R, vce(robust)

reg sb48 R $covariates, robust
ivregress 2sls sb48 (theta42 = theta30 theta18 theta6) R $covariates, vce(robust)
reg theta42 R $covariates, robust
