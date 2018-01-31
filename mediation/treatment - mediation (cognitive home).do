* ---------------------------- *
* Mediation analysis (IQ - HOME)
* Author: Chanwool Kim
* Date Created: 20 Apr 2017
* Last Update: 27 Jan 2018
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

* ------- *
* Execution

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
