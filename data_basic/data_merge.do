* ---------------------------------- *
* Preliminary data preparation - merge
* Author: Chanwool Kim
* ---------------------------------- *

clear all

* -------------- *
* Early Head Start
cd "$data_working"
use "ehs-participation.dta", clear

merge 1:1 id using ehs-control, nogen nolabel
merge 1:1 id using ehs-labor, nogen nolabel
merge 1:1 id using ehs-instruments, nogen nolabel
merge 1:1 id using ehs-outcome, nogen nolabel

*Create minimal datasets
keep id R D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18 alt program_type sitenum ///
$covariates poverty bw twin ///
caregiver_ever cc_payments_site income_site cc_price_relative ///
ppvt3y iq_orig alt_months hs H ///
any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months alt1 alt2 alt center

order id R D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18  alt program_type sitenum ///
$covariates poverty bw twin ///
caregiver_ever cc_payments_site income_site cc_price_relative ppvt3y iq_orig hs H alt_months

preserve
keep if program_type==1
gen ehscenter_months=ehs_months
drop ehs_months
outsheet using ehscenter-topi.csv, comma nolabel replace
save ehscenter-topi, replace
restore

preserve
keep if program_type==3
gen ehsmixed_months=ehs_months
drop ehs_months
outsheet using ehsmixed-topi.csv, comma nolabel replace
save ehsmixed-topi, replace
restore

preserve
keep if program_type==1 | program_type==3
gen ehsmixed_center_months=ehs_months
drop ehs_months
outsheet using ehsmixed_center-topi.csv, comma nolabel replace
save ehs_mixed_center-topi, replace
restore

outsheet using ehs-full-topi.csv, comma nolabel replace
save ehs-full-topi, replace

* --------- *
* Abecedarian

cd "$data_working"
use "abc-participation.dta", clear

merge 1:1 id using abc-control, nogen nolabel
merge 1:1 id using abc-labor, nogen nolabel
merge 1:1 id using abc-outcome, nogen nolabel

keep id R sb* iq_orig $covariates bw poverty ///
D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18

save abc-topi, replace
outsheet using abc-topi.csv, comma nolabel replace
