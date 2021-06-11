* Participation Stats *
cd "$data_working"

* EHS *

use ehscenter-topi, clear
keep if program_type==1
tab center_ehs D, mi col row
*center_ehs has 102 missings, while D has 104
tab R D, mi //shows no departures on the controls
tab R center_ehs, mi //there are departures everywhere

*           |  BY PSI26:R/FC Eng in >min EHS
*           |               act.
*center_ehs |         0          1          . |     Total
*-----------+---------------------------------+----------
*         0 |       180         34      1,564 |     1,778 
*         1 |        29        171        118 |       318 
*         . |        36          9        836 |       881 
*-----------+---------------------------------+----------
*     Total |       245        214      2,518 |     2,977 

sum ehs_months if ehs_months>0 //24.8

* IHDP *
use ihdp-topi, clear
sum ihdp_months if ihdp_months>0 //22.3

* ABC *
use abc-topi, clear
sum abc_months if abc_months>0 //29



