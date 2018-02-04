* ---------------------------------- *
* Preliminary data preparation - merge
* Author: Chanwool Kim
* Date Created: 12 Sep 2017
* Last Update: 3 Feb 2018
* ---------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_home"

foreach t of global ehs_type {
	use "ehs`t'-home-participation.dta", clear
	merge 1:1 id using ehs-home-agg, nogen nolabel keep(match)
	
	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global early_home_types {
		foreach m of numlist 14 24 {
		capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}

	foreach s of global later_home_types {
		foreach m of numlist 36 48 120 {
		capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}
	
	save ehs`t'-home-agg-participation, replace

	merge 1:1 id using ehs-home-control, nogen nolabel keep(match)
	save ehs`t'-home-agg-merge, replace
	
	use "ehs`t'-home-participation.dta", clear
	merge 1:1 id using ehs-home-item, nogen nolabel keep(match)
	merge 1:1 id using ehs-home-control, nogen nolabel keep(match)
	save ehs`t'-home-item-merge, replace
}

cd "$data_labor"

foreach t of global ehs_type {
	use "ehs`t'-labor-participation.dta", clear
	merge 1:1 id using ehs-labor-item, nogen nolabel keep(match)
	save ehs`t'-labor-item-participation, replace
	
	merge 1:1 id using ehs-labor-control, nogen nolabel keep(match)
	save ehs`t'-labor-item-merge, replace
}

cd "$data_parent"

foreach t of global ehs_type {
	use "ehs`t'-parent-participation.dta", clear
	merge 1:1 id using ehs-parent, nogen nolabel keep(match)
	
	* Normalise to have in-group sample mean 0 and variance 1
	foreach m of numlist 14 24 {
		capture egen norm_kidi_total`m' = std(kidi_total`m')
	}
	
	save ehs`t'-parent-participation, replace

	merge 1:1 id using ehs-parent-control, nogen nolabel keep(match)
	save ehs`t'-parent-merge, replace
}

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_home"

foreach t of global ihdp_type {
	use "ihdp`t'-home-participation.dta", clear
	merge 1:1 id using ihdp-home-agg, nogen nolabel keep(match)
	
	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global early_home_types {
		foreach m of numlist 12 {
		capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}

	foreach s of global later_home_types {
		foreach m of numlist 36 {
		capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}
	
	save ihdp`t'-home-agg-participation, replace

	merge 1:1 id using ihdp-home-control, nogen nolabel keep(match)
	save ihdp`t'-home-agg-merge, replace
	
	use "ihdp`t'-home-participation.dta", clear
	merge 1:1 id using ihdp-home-item, nogen nolabel keep(match)
	merge 1:1 id using ihdp-home-control, nogen nolabel keep(match)
	save ihdp`t'-home-item-merge, replace
}

cd "$data_labor"

foreach t of global ihdp_type {
	use "ihdp`t'-labor-participation.dta", clear
	merge 1:1 id using ihdp-labor-item, nogen nolabel keep(match)
	save ihdp`t'-labor-item-participation, replace
	
	merge 1:1 id using ihdp-labor-control, nogen nolabel keep(match)
	save ihdp`t'-labor-item-merge, replace
}

cd "$data_parent"

foreach t of global ihdp_type {
	use "ihdp`t'-parent-participation.dta", clear
	merge 1:1 id using ihdp-parent, nogen nolabel keep(match)
	
	* Normalise to have in-group sample mean 0 and variance 1
	foreach m of numlist 12 24 {
		foreach s in total accuracy attempted right {
			capture egen norm_kidi_`s'`m' = std(kidi_`s'`m')
		}
		forvalues i = 1/20 {
				capture egen norm_kidi`m'_`i' = std(kidi`m'_`i')
		}
	}
	
	save ihdp`t'-parent-participation, replace

	merge 1:1 id using ihdp-parent-control, nogen nolabel keep(match)
	save ihdp`t'-parent-merge, replace
}

* --------- *
* Abecedarian

cd "$data_home"

use "abc-home-participation.dta", clear
merge 1:1 id using abc-home-agg, nogen nolabel keep(match)

* Normalise to have in-group sample mean 0 and variance 1
foreach s of global early_home_types {
	foreach m of numlist 6 18 30 {
	capture egen norm_home_`s'`m' = std(home_`s'`m')
	}
}

foreach s of global later_home_types {
	foreach m of numlist 42 54 96 {
	capture egen norm_home_`s'`m' = std(home_`s'`m')
	}
}

save abc-home-agg-participation, replace

merge 1:1 id using abc-home-control, nogen nolabel keep(match)
save abc-home-agg-merge, replace

use "abc-home-participation.dta", clear
merge 1:1 id using abc-home-item, nogen nolabel keep(match)
merge 1:1 id using abc-home-control, nogen nolabel keep(match)
save abc-home-item-merge, replace

cd "$data_labor"

use "abc`t'-labor-participation.dta", clear
merge 1:1 id using abc-labor-item, nogen nolabel keep(match)
save abc-labor-item-participation, replace

merge 1:1 id using abc-labor-control, nogen nolabel keep(match)
save abc-labor-item-merge, replace

cd "$data_parent"

use "abc-parent-participation.dta", clear
merge 1:1 id using abc-parent, nogen nolabel keep(match)

* Normalise to have in-group sample mean 0 and variance 1
foreach m of numlist 6 18 {
	foreach s in dpnd scls noaggr isltd supsex maritl nohome rage verb egal comrde auth hostl demo {
	capture egen norm_pari_`s'`m' = std(pari_`s'`m')
	}
	forvalues i = 1/55 {
	capture egen norm_pari`m'_`i' = std(pari`m'_`i')
	}
}

foreach s in auth cnfv cntr do dtch indp obey pos prog sdv socv talk educ {
	foreach m of numlist 66 96 {
	capture egen norm_pase_`s'`m' = std(pase_`s'`m')
	}
}

save abc-parent-participation, replace

merge 1:1 id using abc-parent-control, nogen nolabel keep(match)
save abc-parent-merge, replace

* -- *
* CARE

cd "$data_home"

foreach t of global care_type {
	use "care`t'-home-participation.dta", clear
	merge 1:1 id using abc-home-agg, nogen nolabel keep(match)
	
	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global early_home_types {
		foreach m of numlist 6 18 30 {
		capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}

	foreach s of global later_home_types {
		foreach m of numlist 42 54 96 {
		capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}
	
	save care`t'-home-agg-participation, replace

	merge 1:1 id using abc-home-control, nogen nolabel keep(match)
	save care`t'-home-agg-merge, replace
	
	use "care`t'-home-participation.dta", clear
	merge 1:1 id using abc-home-item, nogen nolabel keep(match)
	merge 1:1 id using abc-home-control, nogen nolabel keep(match)
	save care`t'-home-item-merge, replace
}

cd "$data_labor"

foreach t of global care_type {
	use "care`t'-labor-participation.dta", clear
	merge 1:1 id using abc-labor-item, nogen nolabel keep(match)
	save care`t'-labor-item-participation, replace
	
	merge 1:1 id using abc-labor-control, nogen nolabel keep(match)
	save care`t'-labor-item-merge, replace
}

cd "$data_parent"

foreach t of global care_type {
	use "care`t'-parent-participation.dta", clear
	merge 1:1 id using abc-parent, nogen nolabel keep(match)
	
	* Normalise to have in-group sample mean 0 and variance 1
	foreach m of numlist 6 18 {
		foreach s in dpnd scls noaggr isltd supsex maritl nohome rage verb egal comrde auth hostl demo {
		capture egen norm_pari_`s'`m' = std(pari_`s'`m')
		}
		forvalues i = 1/55 {
		capture egen norm_pari`m'_`i' = std(pari`m'_`i')
		}
	}
	
	foreach s in auth cnfv cntr do dtch indp obey pos prog sdv socv talk educ {
		foreach m of numlist 66 96 {
		capture egen norm_pase_`s'`m' = std(pase_`s'`m')
		}
	}

	save care`t'-parent-participation, replace

	merge 1:1 id using abc-parent-control, nogen nolabel keep(match)
	save care`t'-parent-merge, replace
}
