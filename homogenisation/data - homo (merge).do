* ------------------------------- *
* Data - homogenisation (merge all)
* Author: Chanwool Kim
* Date Created: 14 Sep 2017
* Last Update: 4 Mar 2017
* ------------------------------- *

clear all

* -------------- *
* Early Head Start

foreach t of global ehs_type {
	cd "$homo_working"
	use "ehs-control-homo.dta", clear
	
	cd "$data_home"	
	merge 1:1 id using ehs`t'-home-agg-participation, nogen nolabel keep(match)
	rename norm_home_*14 norm_home_*1y
	rename norm_home_*36 norm_home_*3y

	merge 1:1 id using ehs-home-item, nogen nolabel keep(match)
	rename home14_* home1_i*
	rename home36_* home3_i*

	* Rearranging matching IHDP
	rename home1_i46 home1_1
	rename home1_i47 home1_2
	rename home1_i48 home1_3
	rename home1_i49 home1_4
	rename home1_i50 home1_5
	rename home1_i51 home1_6
	rename home1_i42 home1_7
	rename home1_i52 home1_8
	rename home1_i53 home1_9
	rename home1_i54 home1_10
	rename home1_i45 home1_11
	rename home1_i55 home1_12
	rename home1_i56 home1_13
	rename home1_i57 home1_14
	rename home1_i58 home1_16
	rename home1_i59 home1_17
	rename home1_i7 home1_18
	rename home1_i43 home1_19
	rename home1_i71 home1_20
	rename home1_i65 home1_21
	rename home1_i13 home1_22
	rename home1_i25 home1_24
	rename home1_i60 home1_25
	rename home1_i16 home1_26
	rename home1_i15 home1_27
	rename home1_i22 home1_28
	rename home1_i61 home1_29
	rename home1_i19 home1_30
	rename home1_i727374 home1_31
	rename home1_i18 home1_33
	rename home1_i21 home1_34
	rename home1_i62 home1_35
	rename home1_i44 home1_36
	rename home1_i1 home1_41
	rename home1_i11 home1_42
	rename home1_i64 home1_44
	rename home1_i20 home1_45
	
	rename home3_i5253 home3_1
	rename home3_i49 home3_3
	rename home3_i48 home3_7
	rename home3_i51 home3_13
	rename home3_i39 home3_15
	rename home3_i40 home3_17
	rename home3_i43 home3_18
	rename home3_i20 home3_19
	rename home3_i38 home3_20
	rename home3_i24 home3_22
	rename home3_i21 home3_23
	rename home3_i57 home3_24
	rename home3_i23 home3_25
	rename home3_i15 home3_28
	rename home3_i34 home3_29
	rename home3_i16 home3_30
	rename home3_i17 home3_31
	rename home3_i18 home3_32
	rename home3_i52 home3_33
	rename home3_i50 home3_36
	rename home3_i54 home3_40
	rename home3_i45 home3_44
	rename home3_i46 home3_46
	rename home3_i19 home3_48
	rename home3_i35 home3_52
	rename home3_i36 home3_53
	rename home3_i37 home3_54
	
	drop home1_i* home3_i*
	
	cd "$homo_working"
	save ehs`t'-home-homo-merge, replace
	
	use "ehs-control-homo.dta", clear
	
	cd "$data_labor"	
	merge 1:1 id using ehs`t'-labor-item-participation, nogen nolabel keep(match)
	
	cd "$homo_working"
	save ehs`t'-labor-homo-merge, replace
}

* ----------------------------------- *
* Infant Health and Development Program

cd "$homo_working"
use "ihdp-control-homo.dta", clear
	
cd "$data_home"
merge 1:1 id using ihdp-home-agg-participation, nogen nolabel keep(match)
rename norm_home_*12 norm_home_*1y
rename norm_home_*36 norm_home_*3y

merge 1:1 id using ihdp-home-item, nogen nolabel keep(match)
rename home12_* home1_*
rename home36_* home3_*

cd "$homo_working"
save ihdp-home-homo-merge, replace
	
use "ihdp-control-homo.dta", clear
	
cd "$data_labor"	
merge 1:1 id using ihdp-labor-item-participation, nogen nolabel keep(match)

cd "$homo_working"
save ihdp-labor-homo-merge, replace

* --------- *
* Abecedarian

cd "$homo_working"
use "abc-control-homo.dta", clear

cd "$data_home"
merge 1:1 id using abc-home-agg-participation, nogen nolabel keep(match)
rename norm_home_*18 norm_home_*1y
rename norm_home_*42 norm_home_*3y

merge 1:1 id using abc-home-item, nogen nolabel keep(match)
rename home18_* home1_*
rename home42_* home3_i*

* Rearranging matching IHDP
rename home3_i1 home3_1
rename home3_i3 home3_2
rename home3_i5 home3_3
rename home3_i7 home3_4
rename home3_i8 home3_5
rename home3_i10 home3_6
rename home3_i12 home3_7
rename home3_i13 home3_8
rename home3_i14 home3_9
rename home3_i15 home3_10
rename home3_i23 home3_11
rename home3_i9 home3_12
rename home3_i25 home3_13
rename home3_i32 home3_14
rename home3_i43 home3_15
rename home3_i55 home3_16
rename home3_i66 home3_17
rename home3_i76 home3_18
rename home3_i34 home3_19
rename home3_i35 home3_20
rename home3_i36 home3_21
rename home3_i38 home3_22
rename home3_i39 home3_23
rename home3_i40 home3_24
rename home3_i41 home3_25
rename home3_i56 home3_26
rename home3_i61 home3_27
rename home3_i62 home3_28
rename home3_i63 home3_29
rename home3_i65 home3_30
rename home3_i67 home3_31
rename home3_i68 home3_32
rename home3_i22 home3_33
rename home3_i24 home3_34
rename home3_i27 home3_35
rename home3_i28 home3_36
rename home3_i29 home3_37
rename home3_i33 home3_38
rename home3_i45 home3_39
rename home3_i60 home3_40
rename home3_i79 home3_41
rename home3_i80 home3_42
rename home3_i6 home3_43
rename home3_i16 home3_44
rename home3_i19 home3_45
rename home3_i20 home3_46
rename home3_i30 home3_47
rename home3_i42 home3_48
rename home3_i59 home3_49
rename home3_i70 home3_50
rename home3_i77 home3_51
rename home3_i46 home3_52
rename home3_i47 home3_53
rename home3_i48 home3_54
rename home3_i51 home3_55

drop home3_i*

cd "$homo_working"
save abc-home-homo-merge, replace

use "abc-control-homo.dta", clear
	
cd "$data_labor"	
merge 1:1 id using abc-labor-item-participation, nogen nolabel keep(match)
	
cd "$homo_working"
save abc-labor-homo-merge, replace
