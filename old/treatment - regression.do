* --------------------------------------- *
* Graphs of treatment effects - regressions
* Author: Chanwool Kim
* Date Created: 11 Mar 2017
* Last Update: 14 May 2017
* --------------------------------------- *

clear all
set more off

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
local ehs_home_types		total /*warm verb exenviro lang*/

* IHDP
local ihdp_tests 			home
local ihdp_home_types		total /*accept
							pet trip museum (after age 60m, has only "Yes")*/

* ABC
local abc_tests 			home
local abc_home_types		total /*nonpun toys var indep inv warm inenviro exenviro
							vresp sdist init stoys mtoys vtoys eat /*relative*/ book pet grocery ///
							praise pos kiss respos annoy spank nopun scold */
							
* CARE
local careboth_tests 		home
local careboth_home_types	total /*nonpun toys var indep inv warm inenviro exenviro
							vresp sdist init stoys mtoys vtoys eat /*relative*/ book pet grocery ///
							praise pos kiss respos annoy spank nopun scold */
							
local carehv_tests 			home
local carehv_home_types		total /*nonpun toys var indep inv warm inenviro exenviro
							vresp sdist init stoys mtoys vtoys eat /*relative*/ book pet grocery ///
							praise pos kiss respos annoy spank nopun scold */

local ehs_ages				14 24 36 48 120
local ihdp_ages				12 36
local abc_ages				6 18 30 42 54 96
local careboth_ages			6 18 30 42 54 96
local carehv_ages			6 18 30 42 54 96

local ehs_end				36
local ihdp_end				36
local abc_end				60
local careboth_end			60
local carehv_end			60

local ehs_n					= 5
local ihdp_n				= 5
local abc_n					= 6
local careboth_n			= 6
local carehv_n				= 6

* ---------------------- *
* Define macros for graphs

local region				graphregion(color(white))

local xtitle				xtitle(Chronological Age)
local ytitle				ytitle(Regression Coefficient: ``t'_name' ``t'_`s'_name')

local ehs_xlabel			xlabel(12(12)130, labsize(small))
local ihdp_xlabel			xlabel(0(12)40, labsize(small))
local abc_xlabel			xlabel(0(12)100, labsize(small))
local care_xlabel			xlabel(0(12)100, labsize(small))

local home_name 			HOME

local home_total_name		Total Score
local home_warm_name		Warmth Score
local home_verb_name		Parental Verbal Skills Score
local home_exenviro_name	External Environment Score
local home_lang_name		Language and Cognitive Stimulation Score
local home_accept_name		Acceptance Score
local home_nonpun_name		Nonpunitive Score
local home_toys_name		Appropriate Toys Score
local home_var_name			Variety Score
local home_indep_name		Fostering Independence Score
local home_inv_name			Maternal Involvement Score
local home_inenviro_name	Internal Environment Score

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

* ------- *
* Execution

foreach p of local programs {
cd "${data_`p'}"
use "`p'-home-agg.dta", clear

drop home_*
rename norm_home_* home_*

* merge 1:1 id using "`p'-home", nogen nolabel
merge 1:1 id using "`p'-home-control", nogen nolabel
merge 1:1 id using "`p'-home-participation", nogen nolabel

save `p'-home-merge, replace

	foreach t of local `p'_tests {
		foreach s of local `p'_`t'_types {
		* Create an empty matrix that stores ages, coefficients, lower CIs and upper CIs.
		qui matrix A`t'`s' = J(``p'_n', 4, .) // for randomisation variable
		qui matrix B`t'`s' = J(``p'_n', 4, .) // for participation variable (program specific)
		* matrix C`t'`s' = J(``p'_n', 4, .) // for participation variable (any care) (NOT included)
		local row = 1
		qui matrix colnames A`t'`s' = Aage_`t'_`s' Acoeff_`t'_`s' Alci_`t'_`s' Auci_`t'_`s'
		qui matrix colnames B`t'`s' = Bage_`t'_`s' Bcoeff_`t'_`s' Blci_`t'_`s' Buci_`t'_`s'
		* matrix colnames C`t'`s' = Cage_`t'_`s' Ccoeff_`t'_`s' Clci_`t'_`s' Cuci_`t'_`s'
	
		* Loop over rows to fill in values into the empty matrix.
		foreach age of local `p'_ages {
			qui matrix A`t'`s'[`row',1] = `age'
			qui matrix B`t'`s'[`row',1] = `age'
			* matrix C`t'`s'[`row',1] = `age'

			capture confirm variable `t'_`s'`age'
			if !_rc {
			* Randomisation variable
			qui regress `t'_`s'`age' R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)
		
			qui matrix A`t'`s'[`row',2] = r[1,1]
			qui matrix A`t'`s'[`row',3] = r[5,1]
			qui matrix A`t'`s'[`row',4] = r[6,1]
			
			* Participation variable (program specific)
			* We only want to do IV regression only if there is significant variability (> 1%)
			qui count if `t'_`s'`age' != .
			local nobs = r(N)
			qui count if R != D & `t'_`s'`age' != .
			local ndiff = r(N)
			local nprop = `ndiff'/`nobs'
			
			if `nprop' < 0.01 {
			di "Not much variability - `t'`s'_`age'"
			qui regress `t'_`s'`age' R $covariates if !missing(D)
			}
			
			else {
			qui ivregress 2sls `t'_`s'`age' (D = R) $covariates if !missing(D)
			}
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)
		
			qui matrix B`t'`s'[`row',2] = r[1,1]
			qui matrix B`t'`s'[`row',3] = r[5,1]
			qui matrix B`t'`s'[`row',4] = r[6,1]

			/* Participation variable (any care) (NOT included)
			ivregress 2sls `t'_`s'`age' (P = R) $covariates
			* r(table) stores values from regression (ex. coeff, var, CI).
			matrix list r(table)
			matrix r = r(table)
		
			matrix C`t'`s'[`row',2] = r[1,1]
			matrix C`t'`s'[`row',3] = r[5,1]
			matrix C`t'`s'[`row',4] = r[6,1]
			*/
			
			local row = `row' + 1
			}	
			else {
			local row = `row' + 1
			}
		}

		* Randomisation variable
		qui matrix list A`t'`s', format(%12.2f)
		svmat A`t'`s', names(col)
		twoway (connected Acoeff_`t'_`s' Aage_`t'_`s', ``p'_xlabel' `region' `xtitle' ///
				`ytitle' lcolor(black) dfcolor(black) legend(off) yline(0) xline(``p'_end')) ///
				(line Alci_`t'_`s' Aage_`t'_`s', lpattern(dash) lcolor(black)) ///
				(line Auci_`t'_`s' Aage_`t'_`s', lpattern(dash) lcolor(black))	
		
		cd "$data_store\fig"
		graph export "`p'_`t'_`s'_coef.eps", replace
		
		* Participation variable (program-specific)
		qui matrix list B`t'`s', format(%12.2f)
		svmat B`t'`s', names(col)
		twoway (connected Bcoeff_`t'_`s' Bage_`t'_`s', ``p'_xlabel' `region' `xtitle' ///
				`ytitle' lcolor(black) dfcolor(black) legend(off) yline(0) xline(``p'_end')) ///
				(line Blci_`t'_`s' Bage_`t'_`s', lpattern(dash) lcolor(black)) ///
				(line Buci_`t'_`s' Bage_`t'_`s', lpattern(dash) lcolor(black))	
		
		graph export "`p'_`t'_`s'_coef_D.eps", replace
		
		/* Participation variable (any care) (NOT included)
		matrix list C`t'`s', format(%12.2f)
		svmat C`t'`s', names(col)
		twoway (connected Ccoeff_`t'_`s' Cage_`t'_`s', ``p'_xlabel' `region' `xtitle' ///
				`ytitle' lcolor(black) dfcolor(black) legend(off) yline(0) xline(``p'_end')) ///
				(line Clci_`t'_`s' Cage_`t'_`s', lpattern(dash) lcolor(black)) ///
				(line Cuci_`t'_`s' Cage_`t'_`s', lpattern(dash) lcolor(black))	
		
		graph export "`p'_`t'_`s'_coef_P.eps", replace
		*/
		}
	}
}
