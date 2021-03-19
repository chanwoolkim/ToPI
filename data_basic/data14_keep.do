
* KEEP *
clear all
cd "$data_working"

* EHS (by participation status)
use "ehscenter-topi.dta", clear

keep id R D home1_* home3_* norm_home_* video* ppvt* $covariates bw poverty ///
norm_kidi_* norm_bayley_* norm_cbcl_*  black ///
hours_worked m_work1 m_work2 ///
hs H twin ww home3y_original

save ehscenter-topi, replace

* IHDP
use "ihdp-topi.dta", clear

keep id R D home1_* home3_* norm_home_* ppvt* video* sb* $covariates bw bwg  ///
norm_kidi_* kidi* norm_sameroff* norm_bayley_* cbcl*  poverty black twin pag ///
m_work3y ///
hs H twin ww home3y_original home_jbg_learning

save ihdp-topi, replace

* ABC
use "abc-topi.dta", clear

keep id R D home1_* home3_* norm_home_* video* sb* $covariates ///
bw  norm_pari* norm_pase* norm_bayley_* cbcl*  poverty black ///
hs H twin ww home3y6m_original home_jbg_learning

save abc-topi, replace

* CARE (by home visit & both)
*foreach t of global care_type {
*use "care`t'-topi.dta", clear

*keep id R D home1_* home3_* norm_home_* sb* $covariates bw  ///
*norm_bayley_* cbcl*  poverty black kidi_* ///
*hs H twin ww

*save care`t'-topi, replace
*}
