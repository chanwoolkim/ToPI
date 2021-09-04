* ---------------------------------------- *
* Graphs of treatment effects - longitudinal
* Author: Chanwool Kim
* ---------------------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local tests						home labor

* HOME Types
local ehs_home_types			ca $home_types
local ihdp_home_types			ca $home_types
local abc_home_types			ca $home_types
local care_home_types			ca $home_types

* Labor Types
local ehs_labor_types			ca hh_inc m_work m_workhour
local ihdp_labor_types			ca hh_inc m_work m_workhour f_work
local abc_labor_types			ca hh_inc hh_wage m_work f_work
local care_labor_types			ca hh_inc hh_wage m_work

* ---------------------- *
* Define macros for graphs

local region					graphregion(color(white))

local xtitle					xtitle(Chronological Age)
local ytitle					ytitle(``t'_name' ``t'_`s'_name')

local ehs_labor_xlabel			xlabel(0(12)120, labsize(small))
local ihdp_labor_xlabel			xlabel(0(12)96, labsize(small))
local abc_labor_xlabel			xlabel(0(24)252, labsize(small))
local care_labor_xlabel			xlabel(0(12)144, labsize(small))

local ehs_home_xlabel			xlabel(0(12)120, labsize(small)) /*AH nov18*/
local ihdp_home_xlabel			xlabel(0(12)120, labsize(small))  /*AH nov18*/
local abc_home_xlabel			xlabel(0(12)120, labsize(small))  /*AH nov18*/
local care_home_xlabel			xlabel(0(12)120, labsize(small))  /*AH nov18*/

local treatment					treat == 1
local t_mean					lcol(black) mcol(black)
local t_sd						lcol(black) lwidth(vthin) mcol(black) msize(vtiny) 

local control					treat == 0
local c_mean					lcol(gs5) lpattern(dash) mcol(gs5)
local c_sd						lcol(gs5) lwidth(vthin) mcol(gs5) msize(vtiny) 

local labor_name				"Labor - "
local labor_hh_inc_name			"Household Annual Income"
local labor_hh_wage_name		"Household Annual Wage"
local labor_m_work_name			"Mother Currently Employed"
local labor_m_workhour_name		"Mother Work Hour"
local labor_f_work_name			"Father Currently Employed"

local home_name					"HOME - "
local home_total_name			"Total"
local home_learning_name		"Learning Stimulation"
local home_develop_name			"Developmental Materials"
local home_variety_name			"Opportunities for Variety"
local home_hostility_name		"Lack of Hostility"
local home_warmth_name			"Warmth"

local legend					legend(order(1 2) label(1 Treatment) label(2 Control) position(7) region(color(white)))

* ------- *
* Execution

* Get data
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

	* Generate local to help reshape data wide -> long
	local vars_to_reshape

	foreach t of local tests {

		cd "$data_working"
		use "`p'-merge.dta", clear

		if "`t'" == "home" {
			drop home_*
			rename norm_home_* home_*
		}

		if "`t'" == "labor" {
			if "`p'" == "care" | "`p'" == "carehv" | "`p'" == "careboth" {
				drop *180 *252
			}
		}

		foreach s of local `p_main'_`t'_types {
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
		foreach s of local `p_main'_`t'_types {
			gen plus_`t'_`s' = `t'_`s' + 1.96 * (sd_`t'_`s'/sqrt(N_`t'_`s'))
			gen minus_`t'_`s' = `t'_`s' - 1.96 * (sd_`t'_`s'/sqrt(N_`t'_`s'))

			twoway (connected `t'_`s' `t'_ca 		if `treatment', `t_mean') 	///
				(connected `t'_`s' `t'_ca 		if `control', 	`c_mean') 	///
				(connected plus_`t'_`s' `t'_ca 	if `treatment', `t_sd') 	///
				(connected minus_`t'_`s' `t'_ca if `treatment', `t_sd') 	///
				(connected plus_`t'_`s' `t'_ca 	if `control', `c_sd') 		///
				(connected minus_`t'_`s' `t'_ca if `control', 	`c_sd' 		///
				`xtitle' `ytitle' `legend' `region' ``p_main'_`t'_xlabel'	///
				name(`p'_`t'_`s', replace))

			cd "${analysis_out}/`t'"
			graph export "`p'_`t'_`s'.pdf", replace

			cd "${analysis_git_out}/`t'"
			graph export "`p'_`t'_`s'.png", replace
		}
	}
}
