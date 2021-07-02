
* KEEP *
clear all
cd "$data_working"

* EHS (by participation status)
use "ehscenter-topi.dta", clear
keep id R D home1_* home3_* norm_home_* video* ppvt* $covariates bw poverty program_type ///
norm_kidi_* norm_bayley_* norm_cbcl_*  black ///
hours_worked m_work1 m_work2 program_type ///
hs H twin ww home3y_original

*Participation
merge 1:1 id using "ehs-preschools.dta"
rename center_ehs center_ehscenter
rename ehs_months ehscenter_months
di "DONE"
drop _merge

*SITEnum
merge 1:1 id using "${master_path}/Original datasets/Harvard Dataverse Sensitive Original Data/baseline/00097_Early_Head_Start_ehs_sites.dta"
keep if program_type==1

*Instruments
merge 1:1 using ehs-instruments
drop _merge
save ehscenter-topi, replace
keep 

outsheet using ehscenter-topi.csv, comma nolabel replace

**Adding Mixed
use "ehsmixed-topi.dta", clear
keep id R D home1_* home3_* norm_home_* video* ppvt* $covariates bw poverty program_type ///
norm_kidi_* norm_bayley_* norm_cbcl_*  black ///
hours_worked m_work1 m_work2 program_type ///
hs H twin /*ww*/ home3y_original

merge 1:1 id using "ehs-preschools.dta"
rename center_ehs center_ehsmixed
rename ehs_months ehsmixed_months
di "DONE"
drop _merge

*SITEnum
merge 1:1 id using "${master_path}/Original datasets/Harvard Dataverse Sensitive Original Data/baseline/00097_Early_Head_Start_ehs_sites.dta"
keep if program_type==3
save ehsmixed-topi, replace




* IHDP
use "ihdp-topi.dta", clear

keep id R D home1_* home3_* norm_home_* ppvt* video* sb* $covariates bw bwg  ///
norm_kidi_* kidi* norm_sameroff* norm_bayley_* cbcl*  poverty black twin pag ///
m_work3y ///
hs H twin ww home3y_original home_jbg_learning

merge 1:1 id using "ihdp-preshools.dta"

save ihdp-topi, replace
outsheet using ihdp-topi.csv, comma nolabel replace

* ABC
use "abc-topi.dta", clear

keep id R D home1_* home3_* norm_home_* video* sb* $covariates ///
bw  norm_pari* norm_pase* norm_bayley_* cbcl*  poverty black ///
hs H twin ww /*home3y6m_original*/ home_jbg_learning

merge 1:1 id using "abc-preschools.dta"

save abc-topi, replace
outsheet using abc-topi.csv, comma nolabel replace

* CARE (by home visit & both)
*foreach t of global care_type {
*use "care`t'-topi.dta", clear

*keep id R D home1_* home3_* norm_home_* sb* $covariates bw  ///
*norm_bayley_* cbcl*  poverty black kidi_* ///
*hs H twin ww

*save care`t'-topi, replace
*}
