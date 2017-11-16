* ---------------------------------------- *
* Graphs of treatment effects - longitudinal
* Author: Chanwool Kim
* Date Created: 1 Mar 2017
* Last Update: 15 Nov 2017
* ---------------------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

* EHS
local ehscenter_tests 		home labor
local ehscenter_home_types	ca total warmth verbal hostility learning activity develop reading exterior interior
local ehscenter_labor_types	ca hh_inc m_work m_workhour
local ehshome_tests 		home labor
local ehshome_home_types	ca total warmth verbal hostility learning activity develop reading exterior interior
local ehshome_labor_types	ca hh_inc m_work m_workhour
local ehsmixed_tests 		home labor
local ehsmixed_home_types	ca total warmth verbal hostility learning activity develop reading exterior interior
local ehsmixed_labor_types	ca hh_inc m_work m_workhour

* IHDP
local ihdplow_tests 		home labor
local ihdplow_home_types	ca total warmth verbal hostility learning activity develop reading exterior interior
local ihdplow_labor_types	ca hh_inc m_work m_workhour f_work
local ihdphigh_tests 		home labor
local ihdphigh_home_types	ca total warmth verbal hostility learning activity develop reading exterior interior
local ihdphigh_labor_types	ca hh_inc m_work m_workhour f_work

* ABC
local abc_tests 			home labor
local abc_home_types		ca total warmth verbal hostility learning activity develop reading exterior interior
local abc_labor_types		ca hh_inc hh_wage m_work f_work

* CARE
local carehv_tests 			home labor
local carehv_home_types		ca total warmth verbal hostility learning activity develop reading exterior interior
local carehv_labor_types	ca hh_inc hh_wage m_work
local careboth_tests 		home labor
local careboth_home_types	ca total warmth verbal hostility learning activity develop reading exterior interior
local careboth_labor_types	ca hh_inc hh_wage m_work

* ---------------------- *
* Define macros for graphs

local region				graphregion(color(white))

local xtitle				xtitle(Chronological Age)
local ytitle				ytitle(``s'_name')

local ehscenter_labor_xlabel	xlabel(0(12)120, labsize(small))
local ehshome_labor_xlabel		xlabel(0(12)120, labsize(small))
local ehsmixed_labor_xlabel		xlabel(0(12)120, labsize(small))
local ihdplow_labor_xlabel		xlabel(0(12)96, labsize(small))
local ihdphigh_labor_xlabel		xlabel(0(12)96, labsize(small))
local abc_labor_xlabel			xlabel(0(24)252, labsize(small))
local carehv_labor_xlabel		xlabel(0(12)144, labsize(small))
local careboth_labor_xlabel		xlabel(0(12)144, labsize(small))

local ehscenter_home_xlabel		xlabel(0(12)120, labsize(small))
local ehshome_home_xlabel		xlabel(0(12)120, labsize(small))
local ehsmixed_home_xlabel		xlabel(0(12)120, labsize(small))
local ihdplow_home_xlabel		xlabel(0(6)42, labsize(small))
local ihdphigh_home_xlabel		xlabel(0(6)42, labsize(small))
local abc_home_xlabel			xlabel(0(12)96, labsize(small))
local carehv_home_xlabel		xlabel(0(12)96, labsize(small))
local careboth_home_xlabel		xlabel(0(12)96, labsize(small))

local treatment				treat == 1
local t_mean				lcol(black) mcol(black)
local t_sd					lcol(black) lwidth(vthin) mcol(black) msize(vtiny) 

local control				treat == 0
local c_mean				lcol(gs5) lpattern(dash) mcol(gs5)
local c_sd					lcol(gs5) lwidth(vthin) mcol(gs5) msize(vtiny) 

local labor_hh_inc_name		Household Annual Income
local labor_hh_wage_name	Household Annual Wage
local labor_m_work_name		Mother Currently Employed
local labor_m_workhour_name	Mother Work Hour
local labor_f_work_name		Father Currently Employed

local home_warmth_name		Parental Warmth
local home_verbal_name		Parental Verbal Skills
local home_hostility_name	Parental Lack of Hostility
local home_learning_name	Learning and Literacy
local home_activity_name	Activities and Outings
local home_develop_name		Developmental Advance
local home_reading_name		Access to Reading
local home_exterior_name	Home Exterior
local home_interior_name	Home Interior

local legend				legend(order(1 2) label(1 Treatment) label(2 Control) position(7) region(color(white)))

* ------- *
* Execution

* Get data
foreach p of global programs {

	* Generate local to help reshape data wide -> long
	local vars_to_reshape

	foreach t of local `p'_tests {
		if "`t'" == "home" {
			cd "${data_`t'}"
			use "`p'-`t'-agg-merge.dta", clear
			drop home_*
			rename norm_home_* home_*
		}
		
		if "`t'" == "labor" {
			cd "${data_`t'}"
			use "`p'-`t'-item-merge.dta", clear
						
			if "`p'" == "carehv" | "`p'" == "careboth" {
				drop *180 *252
			}
		}
		
		drop treat
		rename R treat
	
		foreach s of local `p'_`t'_types {
			local vars_to_reshape	`vars_to_reshape'	`t'_`s'
		}
		
		* Reshape the data 
		reshape long `vars_to_reshape', i(id) j(test_age)
		keep id treat test_age `vars_to_reshape' 

		* Calculate mean and sd of each test at each age by treatment and control
		preserve

		collapse (mean) `vars_to_reshape', by(treat test_age)
		gen N = _n
		tempfile mean
		save `mean'

		restore
		preserve

		collapse (sd) `vars_to_reshape', by(treat test_age)
		foreach v of varlist _all {
			rename `v' sd_`v'
		}
		gen N = _n

		merge 1:1 N using `mean', nogen
		tempfile sd
		save `sd'

		restore

		collapse (count) `vars_to_reshape', by(treat test_age)
		foreach v of varlist _all {
			rename `v' N_`v'
		}
		gen N = _n

		merge 1:1 N using `sd', nogen

		* Graph
		replace `t'_ca = test_age if `t'_ca == .
		foreach s of local `p'_`t'_types {
			gen plus_`t'_`s' = `t'_`s' + 1.96 * (sd_`t'_`s'/sqrt(N_`t'_`s'))
			gen minus_`t'_`s' = `t'_`s' - 1.96 * (sd_`t'_`s'/sqrt(N_`t'_`s'))

			twoway (connected `t'_`s' `t'_ca 		if `treatment', `t_mean') 	///
					(connected `t'_`s' `t'_ca 		if `control', 	`c_mean') 	///
					(connected plus_`t'_`s' `t'_ca 	if `treatment', `t_sd') 	///
					(connected minus_`t'_`s' `t'_ca if `treatment', `t_sd') 	///
					(connected plus_`t'_`s' `t'_ca 	if `control', `c_sd') 		///
					(connected minus_`t'_`s' `t'_ca if `control', 	`c_sd' 		///
								`xtitle' ytitle(``t'_name' ``t'_`s'_name') 	///
								`legend' `region' ``p'_`t'_xlabel'	///
								``p'_`t'_`s'_text' name(`p'_`t'_`s', replace))
		
			cd "${analysis_out}/`t'"
			graph export "`p'_`t'_`s'.pdf", replace
		}
	}
}
