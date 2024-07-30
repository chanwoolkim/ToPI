* ---------------------------------- *
* Preliminary data preparation - merge
* Author: Chanwool Kim
* ---------------------------------- *

clear all

* -------------- *
* Early Head Start
* -------------- *
* Early Head Start
cd "$data_working"
use "ehs-participation.dta", clear
keep id program_type ehs_months

merge 1:1 id using ehs-participation2, nogen nolabel
merge 1:1 id using ehs-control, nogen nolabel
merge 1:1 id using ehs-labor, nogen nolabel
merge 1:1 id using ehs-instruments, nogen nolabel
merge 1:1 id using ehs-outcome, nogen nolabel

*Create minimal datasets
keep id R D D_1 D_6 D_12 D_18 E P P_1 P_6 P_12 P_18 program_type sitenum ///
$covariates poverty bw twin ///
caregiver_ever cc_payments_site income_site cc_price_relative ///
ppvt3y iq_orig hs H ///
ehs_months

order id R D D_1 D_6 D_12 D_18 E P P_1 P_6 P_12 P_18  program_type sitenum ///
$covariates poverty bw twin ///
caregiver_ever cc_payments_site income_site cc_price_relative ppvt3y iq_orig hs H

preserve
keep if program_type==1
gen ehscenter_months=ehs_months
drop ehs_months
outsheet using ehscenter-topi-new.csv, comma nolabel replace
save ehscenter-topi-new, replace
restore

preserve
keep if program_type==3
gen ehsmixed_months=ehs_months
drop ehs_months
outsheet using ehsmixed-topi-new.csv, comma nolabel replace
save ehsmixed-topi-new, replace
restore

preserve
keep if program_type==1 | program_type==3
gen ehsmixed_center_months=ehs_months
drop ehs_months
outsheet using ehsmixed_center-topi-new.csv, comma nolabel replace
save ehs_mixed_center-topi-new, replace
restore

outsheet using ehs-full-topi-new.csv, comma nolabel replace
save ehs-full-topi-new, replace

* --------- *
* Abecedarian

cd "$data_working"
use "abc-participation.dta", clear

merge 1:1 id using abc-control, nogen nolabel
merge 1:1 id using abc-labor, nogen nolabel
merge 1:1 id using abc-outcome, nogen nolabel

keep id R sb* iq_orig $covariates bw poverty ///
D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18

save abc-topi-new, replace
outsheet using abc-topi-new.csv, comma nolabel replace
