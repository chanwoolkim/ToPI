* ---------------------------------- *
* Preliminary data preparation - merge
* Author: Chanwool Kim
* ---------------------------------- *

clear all

* -------------- *
* Early Head Start

foreach t of global ehs_type {
	cd "$data_working"
	use "ehs-outcome.dta", clear

	merge 1:1 id using ehs`t'-participation, nogen nolabel keep(match)
	merge 1:1 id using ehs-control, nogen nolabel keep(match)
	merge 1:1 id using ehs-home-agg, nogen nolabel keep(match)
	merge 1:1 id using ehs-video, 	 nogen nolabel keep(match)

	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global home_types {
		foreach m of numlist 14 24 36 48 120 {
			capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}

	merge 1:1 id using ehs-home-item, nogen nolabel keep(match)
	merge 1:1 id using ehs-labor, nogen nolabel keep(match)
	merge 1:1 id using ehs-parent, nogen nolabel keep(match)

	* Normalise to have in-group sample mean 0 and variance 1
	foreach m of numlist 14 24 {
		capture egen norm_kidi_total`m' = std(kidi_total`m')
	}

	merge 1:1 id using ehs-noncog, nogen nolabel keep(match)

	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global bayley_types {
		foreach m of numlist 14 24 36 {
			capture egen norm_bayley_`s'`m' = std(bayley_`s'`m')
		}
	}

	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global cbcl_types {
		foreach m of numlist 120 {
			capture egen norm_cbcl_`s'`m' = std(cbcl_`s'`m')
		}
	}
	

	save ehs`t'-merge, replace
}

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_working"
use "ihdp-outcome.dta", clear

merge 1:1 id using ihdp-participation, nogen nolabel keep(match)
merge 1:1 id using ihdp-control, nogen nolabel keep(match)
merge 1:1 id using ihdp-home-agg, nogen nolabel keep(match)

* Normalise to have in-group sample mean 0 and variance 1
/* AH added 60 78 96 */
foreach s of global home_types {
	foreach m of numlist 12 36 60 78 96{
		capture egen norm_home_`s'`m' = std(home_`s'`m')
	}
}

merge 1:1 id using ihdp-home-item, nogen nolabel keep(match)
merge 1:1 id using ihdp-labor, nogen nolabel keep(match)
merge 1:1 id using ihdp-parent, nogen nolabel keep(match)

* Normalise to have in-group sample mean 0 and variance 1
foreach m of numlist 12 24 {
	foreach s in total accuracy attempted right {
		capture egen norm_kidi_`s'`m' = std(kidi_`s'`m')
	}
}

foreach m of numlist 12 36 {
	foreach s in total cat prsp {
		capture egen norm_sameroff_`s'`m' = std(sameroff_`s'`m')
	}
	forvalues i = 1/20 {
		capture egen norm_sameroff`m'_`i' = std(sameroff`m'_`i')
	}
}

merge 1:1 id using ihdp-noncog, nogen nolabel keep(match)

* Normalise to have in-group sample mean 0 and variance 1
foreach s of global bayley_types {
	foreach m of numlist 24 {
		capture egen norm_bayley_`s'`m' = std(bayley_`s'`m')
	}
}

merge 1:1 id using ihdp-video, nogen nolabel keep(match)

save ihdp-merge, replace

keep if bwg == 0
save ihdplow-merge, replace
use ihdp-merge, clear
keep if bwg == 1
save ihdphigh-merge, replace

* --------- *
* Abecedarian

cd "$data_working"
use "abc-outcome.dta", clear

merge 1:1 id using abc-participation, nogen nolabel keep(match)
merge 1:1 id using abc-control, nogen nolabel keep(match)
merge 1:1 id using abc-home-agg, nogen nolabel keep(match)

* Normalise to have in-group sample mean 0 and variance 1
foreach s of global home_types {
	foreach m of numlist 6 18 30 42 54 96 {
		capture egen norm_home_`s'`m' = std(home_`s'`m')
	}
}

merge 1:1 id using abc-home-item, nogen nolabel keep(match)
merge 1:1 id using abc-labor, nogen nolabel keep(match)
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

merge 1:1 id using abc-noncog, nogen nolabel keep(match)

* Normalise to have in-group sample mean 0 and variance 1
foreach s of global bayley_types {
	foreach m of numlist 24 30 36 42 48 60 72 78 96 {
		capture egen norm_bayley_`s'`m' = std(bayley_`s'`m')
	}
}

merge 1:1 id using abc-video, nogen nolabel keep(match)

save abc-merge, replace

* -- *
* CARE

foreach t of global care_type {
	cd "$data_working"
	use "abc-outcome.dta", clear

	merge 1:1 id using care`t'-participation, nogen nolabel keep(match)
	merge 1:1 id using care-control, nogen nolabel keep(match)
	merge 1:1 id using abc-home-agg, nogen nolabel keep(match)

	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global home_types {
		foreach m of numlist 6 18 30 42 54 96 {
			capture egen norm_home_`s'`m' = std(home_`s'`m')
		}
	}

	merge 1:1 id using abc-home-item, nogen nolabel keep(match)
	merge 1:1 id using abc-labor, nogen nolabel keep(match)
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

	merge 1:1 id using abc-noncog, nogen nolabel keep(match)

	* Normalise to have in-group sample mean 0 and variance 1
	foreach s of global bayley_types {
		foreach m of numlist 24 30 36 42 48 60 72 78 96 {
			capture egen norm_bayley_`s'`m' = std(bayley_`s'`m')
		}
	}

	drop treat
	gen treat = R

	save care`t'-merge, replace
}
