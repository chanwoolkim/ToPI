* --------------------------------- *
* Graphs of treatment effects - items
* Author: Chanwool Kim
* Date Created: 1 Mar 2017
* Last Update: 5 Mar 2017
* --------------------------------- *

clear all
set more off

global data_ehs		: env data_ehs
global data_ihdp	: env data_ihdp
global data_abc		: env data_abc
global data_store	: env klmshare
global klmshare		: env klmshare

* --------------------------- *
* Define macros for abstraction

local programs				/*ehs*/ ihdp abc

/* EHS
local ehs_tests 			home
local ehs_home_types		ca 
*/

* IHDP
local ihdp_tests 			home
local ihdp_home_types		ca pet trip museum

* ABC
local abc_tests 			home
local abc_home_types		ca vresp sdist init stoys mtoys vtoys eat relative book pet grocery ///
							praise pos kiss respos annoy spank nopun scold

* ---------------------- *
* Define macros for graphs

local region				graphregion(color(white))

local xtitle				xtitle(Chronological Age)
local ytitle				ytitle(``t'_name' ``s'_name')

local ehs_xlabel			xlabel(12(12)130, labsize(small))
local ihdp_xlabel			xlabel(6(12)96, labsize(small))
local abc_xlabel			xlabel(0(12)100, labsize(small))

local treatment				treat == 1
local t_mean				lcol(black) mcol(black)
local t_sd					lcol(black) lwidth(vthin) mcol(black) msize(vtiny) 

local control				treat == 0
local c_mean				lcol(gs5) lpattern(dash) mcol(gs5)
local c_sd					lcol(gs5) lwidth(vthin) mcol(gs5) msize(vtiny) 

local home_name 			HOME

local home_pet_name			Has Pet
local home_trip_name		50 Mile Trip
local home_museum_name		Visited Museum
local home_vresp_name		Respond Verbally
local home_sdist_name		Distinct Speech
local home_stoys_name		Place for Toys
local home_mtoys_name		Muscle Activity Toys
local home_vtoys_name		Toys for Visit
local home_eat_name			Eats with Parents
local home_relative_name	Visits Relatives
local home_book_name		At Least 10 Books
local home_grocery_name		Taken to Grocery
local home_praise_name		Praises Twice
local home_pos_name			Positive Feelings
local home_kiss_name		Kisses or Caresses
local home_respos_name		Responds Positively
local home_annoy_name		No Annoyance
local home_spank_name		No Spank or Slap
local home_nopun_name		No Physical Punish
local home_scold_name		No Scolding

local legend				legend(order(1 2) label(1 Treatment) label(2 Control) position(7) region(color(white)))

* ------- *
* Execution

* Get data
foreach p of local programs {
cd "${data_`p'}"
use "`p'-home.dta", clear

	* Generate local to help reshape data wide -> long
	local vars_to_reshape

	foreach t of local `p'_tests {
		foreach s of local `p'_`t'_types {
			local vars_to_reshape 	`vars_to_reshape' 	`t'_`s'
		}
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
	foreach t of local `p'_tests {
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
								`legend' `region' ``p'_xlabel'	///
								``p'_`t'_`s'_text' name(`p'_`t'_`s', replace))
		
			cd "$data_store\fig"
			graph export "`p'_`t'_`s'.eps", replace
		}
	}
}
