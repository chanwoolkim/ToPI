***************************************************************
******** SET UP STATA *****************************************
***************************************************************

*Basic Stata setup
clear all
set mem 500m
set more off
cap set trace off

*Set working directories
local drive="/Users/Chris/projects/head_start"
local dict="`drive'/site_heterogeneity/programs/dictionaries"
local raw="`drive'/data/raw_data"
local statafiles="`drive'/data/stata_files"

*Switches to choose which parts of program to run
local readraw=1
local setup=1
local standardize=1


********************************************************
****** MERGE ALL OF THE HSIS FILES I NEED TOGETHER
*********************************************************

*Outcome files
use "`statafiles'/testscoreswide.dta"

*Add noncog
merge 1:1 hsis_childid using "`statafiles'/noncogwide.dta"
drop _merge

*Add weights
sort hsis_childid
merge hsis_childid using "`statafiles'/child_weights.dta"
tab _merge
drop _merge

*Add baseline demos
sort hsis_childid
merge hsis_childid using "`statafiles'/baseline_demos.dta"
tab _merge
drop _merge

*Add parent-reported attendance to be used for 3-year-olds; code offer and attendance
sort hsis_childid
merge hsis_childid using "`statafiles'/parent_reported_enrollment.dta"
drop _merge
gen Z=childresultgroup==2
gen D_admin=(Z==1 & noshow==0) | (Z==0 & crossover==1)
gen D_03=D_admin
gen D_04=D_admin
replace D_04=1 if hs_enroll_04==1 & childcohort==3
gen D_05=D_04
gen D_06=D_05 if childcohort==3

*Add experiences variables
merge 1:1 hsis_childid using "`statafiles'/child_experiences_final.dta"
drop _merge





********************************************************
****** SAVE FINAL DATA SET *****************************
********************************************************
drop X_baseline_noncog* X_m_baseline_noncog*
gen X_baseline_noncog=Y_noncog_02
gen X_m_baseline_noncog=X_baseline_noncog==.
replace X_baseline_noncog=0 if X_baseline_noncog==.
save "`statafiles'/analysis_file.dta", replace


