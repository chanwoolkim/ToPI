* ----------------------------------------------------------- *
* Data for aggregate pile treatment effects (EHS documentation)
* Author: Chanwool Kim
* Date Created: 27 Jun 2017
* Last Update: 27 Jun 2017
* ----------------------------------------------------------- *

clear all
set more off

global data_home "C:\Users\chanw\Dropbox\TOPI\treatment_effect\home"
global data_store "C:\Users\chanw\Dropbox\TOPI\treatment_effect\pile"

* --------------- *
* Merge data to use

cd "$data_home"

* EHS (by program type)

use "ehs-home-agg.dta", clear
drop home_*
rename norm_home_* home_*
keep id home_*14 home_*36
rename home_*14 home_*1
rename home_*36 home_*3
merge 1:1 id using "ehs-home-control", nogen nolabel
merge 1:1 id using "ehs-home-participation-patch", nogen nolabel

gen D1 = .
replace D1 = 0 if minimum == 0 | center == 0
replace D1 = 1 if minimum == 1 | center == 1
gen D2 = minimum
gen D3 = minimum
rename minimum D

save ehs-home-ehs-merge, replace

drop D
rename D1 D
keep if program_type == 1
save ehscenter-home-ehs-merge, replace

use ehs-home-ehs-merge, clear
drop D
rename D2 D
keep if program_type == 2
save ehshome-home-ehs-merge, replace

use ehs-home-ehs-merge, clear
drop D
rename D3 D
keep if program_type == 3
save ehsmixed-home-ehs-merge, replace

* IHDP (by birth weight group)

use "ihdp-home-ehs.dta", clear
drop home_*
rename norm_home_* home_*
keep id home_*12 home_*36
rename home_*12 home_*1
rename home_*36 home_*3
merge 1:1 id using "ihdp-home-control", nogen nolabel
merge 1:1 id using "ihdp-home-participation", nogen nolabel
save ihdp-home-ehs-merge, replace

keep if bwg == 1
save ihdphigh-home-ehs-merge, replace
use ihdp-home-ehs-merge, clear
keep if bwg == 0
save ihdplow-home-ehs-merge, replace

* ABC

use "abc-home-ehs.dta", clear
drop home_*
rename norm_home_* home_*
keep id home_*18 home_*42
rename home_*18 home_*1
rename home_*42 home_*3
tempfile tmpabc
save "`tmpabc'", replace

use "abc-home-control"
merge 1:1 id using `tmpabc', nogen nolabel
merge 1:1 id using "abc-home-participation", nogen nolabel
keep if program == "abc"
save abc-home-ehs-merge, replace

* CARE (by home visit & both)

use "care-home-control"
merge 1:1 id using `tmpabc', nogen nolabel
merge 1:1 id using "carehv-home-participation", nogen nolabel
keep if program == "care"
save carehv-home-ehs-merge, replace

use "care-home-control"
merge 1:1 id using `tmpabc', nogen nolabel
merge 1:1 id using "careboth-home-participation", nogen nolabel
keep if program == "care"
save careboth-home-ehs-merge, replace
