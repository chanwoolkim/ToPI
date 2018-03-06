* ---------------------------------- *
* Data for item pile treatment effects
* Author: Chanwool Kim
* Date Created: 27 Jun 2017
* Last Update: 4 Mar 2017
* ---------------------------------- *

clear all

* EHS (by participation status)

foreach t of global ehs_type {
	cd "$data_home"
	use "ehs`t'-home-item-merge.dta", clear
	
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
	
	cd "$pile_working"
	save ehs`t'-home-item-pile, replace
}

* IHDP

cd "$data_home"
use "ihdp-home-item-merge.dta", clear
	
rename home12_* home1_*
rename home36_* home3_*
	
cd "$pile_working"
save ihdp-home-item-pile, replace

* ABC

cd "$data_home"
use "abc-home-item-merge.dta", clear

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

cd "$pile_working"
save abc-home-item-pile, replace

* CARE (by home visit & both)

foreach t of global care_type {
	cd "$data_home"
	use "care`t'-home-item-merge.dta", clear
	
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
	
	cd "$pile_working"
	save care`t'-home-item-pile, replace
}
