* ---------------------------------- *
* Data for item pile treatment effects
* Author: Chanwool Kim
* Date Created: 27 Jun 2017
* Last Update: 12 Sep 2017
* ---------------------------------- *

clear all
set more off

global data_home "C:\Users\chanw\Dropbox\TOPI\treatment_effect\home"
global data_store "C:\Users\chanw\Dropbox\TOPI\treatment_effect\pile"

* --------------- *
* Merge data to use

cd "$data_home"

* EHS (by participation status)

use "ehs-home-item.dta", clear
keep id home36_*
rename home36_* home_i*

* Rearranging matching IHDP
rename home_i1 home_15
rename home_i2 home_17
rename home_i3 home_27
rename home_i4 home_28
rename home_i5 home_29
rename home_i6 home_30
rename home_i7 home_31
rename home_i8 home_32
rename home_i9 home_40
rename home_i10 home_48
rename home_i11 home_52
rename home_i12 home_53
rename home_i13 home_54
rename home_i14 home_36
rename home_i15 home_13
rename home_i16 home_33
rename home_i17 home_11
rename home_i18 home_3
rename home_i19 home_7
rename home_i20 home_21
rename home_i21 home_25
rename home_i22 home_24
rename home_i23 home_19
rename home_i24 home_22
rename home_i25 home_20
rename home_i26 home_23

tempfile tmpehs
save "`tmpehs'", replace

use "ehs-home-control"
merge 1:1 id using `tmpehs', nogen nolabel
merge 1:1 id using "ehs-home-participation", nogen nolabel
save ehs-home-item-merge, replace

/* for different participation types
use "ehs-home-control"
merge 1:1 id using `tmpehs', nogen nolabel
merge 1:1 id using "ehs-home-participation", nogen nolabel
save ehscenter-home-item-merge, replace

use "ehs-home-control"
merge 1:1 id using `tmpehs', nogen nolabel
merge 1:1 id using "ehshome-home-participation", nogen nolabel
save ehshome-home-item-merge, replace
*/

* IHDP (by birth weight group)

use "ihdp-home-item.dta", clear
keep id home36_*
rename home36_* home_*
merge 1:1 id using "ihdp-home-control", nogen nolabel
merge 1:1 id using "ihdp-home-participation", nogen nolabel
save ihdp-home-item-merge, replace

keep if bwg == 1
save ihdphigh-home-item-merge, replace
use ihdp-home-item-merge, clear
keep if bwg == 0
save ihdplow-home-item-merge, replace

* ABC

use "abc-home-item.dta", clear
keep id treat home42_*
rename home42_* home_i*

* Rearranging matching IHDP
rename home_i1 home_1
rename home_i3 home_2
rename home_i5 home_3
rename home_i7 home_4
rename home_i8 home_5
rename home_i10 home_6
rename home_i12 home_7
rename home_i13 home_8
rename home_i14 home_9
rename home_i15 home_10
rename home_i23 home_11
rename home_i9 home_12
rename home_i25 home_13
rename home_i32 home_14
rename home_i43 home_15
rename home_i55 home_16
rename home_i66 home_17
rename home_i76 home_18
rename home_i34 home_19
rename home_i35 home_20
rename home_i36 home_21
rename home_i38 home_22
rename home_i39 home_23
rename home_i40 home_24
rename home_i41 home_25
rename home_i56 home_26
rename home_i61 home_27
rename home_i62 home_28
rename home_i63 home_29
rename home_i65 home_30
rename home_i67 home_31
rename home_i68 home_32
rename home_i22 home_33
rename home_i24 home_34
rename home_i27 home_35
rename home_i28 home_36
rename home_i29 home_37
rename home_i33 home_38
rename home_i45 home_39
rename home_i60 home_40
rename home_i79 home_41
rename home_i80 home_42
rename home_i6 home_43
rename home_i16 home_44
rename home_i19 home_45
rename home_i20 home_46
rename home_i30 home_47
rename home_i42 home_48
rename home_i59 home_49
rename home_i70 home_50
rename home_i77 home_51
rename home_i46 home_52
rename home_i47 home_53
rename home_i48 home_54
rename home_i51 home_55

tempfile tmpabc
save "`tmpabc'", replace

use "abc-home-control"
merge 1:1 id using `tmpabc', nogen nolabel
merge 1:1 id using "abc-home-participation", nogen nolabel
keep if program == "abc"
save abc-home-item-merge, replace

* CARE (by home visit & both)

use "care-home-control"
merge 1:1 id using `tmpabc', nogen nolabel
merge 1:1 id using "carehv-home-participation", nogen nolabel
keep if program == "care"
save carehv-home-item-merge, replace

use "care-home-control"
merge 1:1 id using `tmpabc', nogen nolabel
merge 1:1 id using "careboth-home-participation", nogen nolabel
keep if program == "care"
save careboth-home-item-merge, replace
