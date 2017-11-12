* ---------------- *
* Mediation analysis
* Author: Chanwool Kim
* Date Created: 20 Apr 2017
* Last Update: 5 Nov 2017
* ---------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local programs_m		ehscenter ehshome ehsmixed ihdplow ihdphigh

* EHS
local ehscenter_home_types	total lang /*warm host verb nonpun harsh learn inenviro exenviro*/
local ehscenter_cogs		ppvt
local ehshome_home_types	total lang /*warm host verb nonpun harsh learn inenviro exenviro*/
local ehshome_cogs			ppvt
local ehsmixed_home_types	total lang /*warm host verb nonpun harsh learn inenviro exenviro*/
local ehsmixed_cogs			ppvt

* IHDP
local ihdplow_home_types	total learn acad /*emot accept org pm inv var lang exenviro warm mod*/
local ihdplow_cogs			ppvt sb
local ihdphigh_home_types	total learn acad /*emot accept org pm inv var lang exenviro warm mod*/
local ihdphigh_cogs			ppvt sb

/* ABC/CARE
local abc_tests 			home
local abc_home_types		total nonpun toys var devstm emotin exper indep lang masc inv warm absrst inenviro exenviro mature
(no significant treatment effect observed)*/

* ------- *
* Execution

foreach p of global programs_m {
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
