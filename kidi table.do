cd "$data_working"
use ehs-topi, clear
ivreg2 norm_kidi_total2y R $covariates 
eststo

use ihdp-topi, clear
ivreg2 kidi_accuracy24 R $covariates 
eststo

cd "$git_out"

esttab using kidi.tex, replace /// 
cells(`"b(fmt(a2) label(Beta))  p(fmt(2) par label(p-value))"' ) ///
title(Impacts on KIDI) nogaps  label modelwidth() style(tex) ///
mtitles("EHS CENTER" "IHDP")

