* -------------------------------------------- *
* Preliminary data preparation - HOME aggregates
* Author: Chanwool Kim
* -------------------------------------------- *

* This aggregates items according to buying and doing (refer to treatment_effect/data/variable_match.xlsx.

clear all

* -------------- *
* Early Head Start

/*
* HOME total score (deprecated)
cd "$data_raw"
use "std-ehs.dta", clear

rename home_total14	home_total14
rename home_total2	home_total24
rename home_total3	home_total36
rename home_tot4	home_total48
rename home_tot5	home_total120

keep id treat home_total*
tempfile tmpehs
save "`tmpehs'", replace
*/

cd "$data_working"
use "ehs-home-item", clear

egen home_develop14 = rowmean(home14_7 home14_15 home14_16 home14_18 home14_19 home14_20 home14_21 home14_22 home14_23 home14_24 home14_43 home14_60 home14_727374)
egen home_family14 = rowmean(home14_49 home14_51)
gen home_housing14 = .
egen home_hostility14 = rowmean(home14_55 home14_56 home14_57 home14_58 home14_59)
egen home_learning14 = rowmean(home14_11 home14_46 home14_47 home14_48 home14_61)
egen home_variety14 = rowmean(home14_64 home14_65)
egen home_warmth14 = rowmean(home14_45 home14_52 home14_53 home14_54)
egen home_total14 = rowmean(home14_7 home14_15 home14_16 home14_18 home14_19 home14_20 home14_21 home14_22 home14_23 home14_24 home14_43 home14_60 home14_727374 ///
							home14_55 home14_56 home14_57 home14_58 home14_59 ///
							home14_11 home14_46 home14_47 home14_48 home14_61 ///
							home14_64 home14_65 ///
							home14_45 home14_52 home14_53 home14_54)
							
egen home_develop24 = rowmean(home24_7 home24_15 home24_16 home24_18 home24_19 home24_20 home24_21 home24_22 home24_23 home24_24 home24_43 home24_60)
egen home_family24 = rowmean(home24_49 home24_51)
gen home_housing24 = .
egen home_hostility24 = rowmean(home24_55 home24_56 home24_57 home24_58 home24_59)
egen home_learning24 = rowmean(home24_11 home24_46 home24_47 home24_48 home24_61)
egen home_variety24 = rowmean(home24_64 home24_65)
egen home_warmth24 = rowmean(home24_45 home24_52 home24_53 home24_54)
egen home_total24 = rowmean(home24_7 home24_15 home24_16 home24_18 home24_19 home24_20 home24_21 home24_22 home24_23 home24_24 home24_43 home24_60 ///
							home24_55 home24_56 home24_57 home24_58 home24_59 ///
							home24_11 home24_46 home24_47 home24_48 home24_61 ///
							home24_64 home24_65 ///
							home24_45 home24_52 home24_53 home24_54)

egen home_develop36 = rowmean(home36_48 home36_49)
egen home_family36 = rowmean(home36_5 home36_6 home36_19 home36_39)
egen home_housing36 = rowmean(home36_20 home36_21 home36_22 home36_23 home36_24 home36_38 home36_55 home36_56 home36_57)
egen home_hostility36 = rowmean(home36_4 home36_35 home36_36 home36_37)
egen home_learning36 = rowmean(home36_7 home36_8 home36_9 home36_10 home36_11 home36_12 home36_13 home36_14 home36_15 home36_34 home36_44 home36_50 home36_51 home36_5253 home36_54)
egen home_variety36 = rowmean(home36_2 home36_3 home36_43 home36_45 home36_46 home36_58 home36_59 home36_60)
egen home_warmth36 = rowmean(home36_16 home36_17 home36_18 home36_40 home36_61)
egen home_total36 = rowmean(home36_48 home36_49 ///
							home36_4 home36_35 home36_36 home36_37 ///
							home36_7 home36_8 home36_9 home36_10 home36_11 home36_12 home36_13 home36_14 home36_15 home36_34 home36_44 home36_50 home36_51 home36_5253 home36_54 ///
							home36_2 home36_3 home36_43 home36_45 home36_46 home36_58 home36_59 home36_60 ///
							home36_16 home36_17 home36_18 home36_40 home36_61)

#delimit ;
keep id
home_total*
home_develop*
home_family*
home_housing*
home_hostility*
home_learning*
home_variety*
home_warmth*
;
#delimit cr

save ehs-home-agg, replace

* ----------------------------------- *
* Infant Health and Development Program

/*
* HOME total score (deprecated)
cd "$data_raw"
use "base-ihdp.dta", clear

rename admin_treat	treat
rename ihdp			id

rename homto_12_sumscore	home_total12
rename homto_36_sumscore	home_total36

keep id treat home_total*
tempfile tmpihdp
save "`tmpihdp'", replace
*/

cd "$data_working"
use "ihdp-home-item", clear

egen home_develop12 = rowmean(home12_18 home12_19 home12_24 home12_25 home12_26 home12_27 home12_28 home12_30 home12_31 home12_32 home12_33 home12_34 home12_45)
egen home_family12 = rowmean(home12_4 home12_5 home12_6)
gen home_housing12 = .
egen home_hostility12 = rowmean(home12_12 home12_13 home12_14 home12_15 home12_16 home12_17)
egen home_learning12 = rowmean(home12_1 home12_2 home12_3 home12_7 home12_29 home12_35 home12_36 home12_37 home12_38 home12_39 home12_42)
egen home_variety12 = rowmean(home12_21 home12_22 home12_23 home12_41 home12_43 home12_44)
egen home_warmth12 = rowmean(home12_8 home12_9 home12_10 home12_11)
egen home_total12 = rowmean(home12_18 home12_19 home12_24 home12_25 home12_26 home12_27 home12_28 home12_30 home12_31 home12_32 home12_33 home12_34 home12_45 ///
							home12_12 home12_13 home12_14 home12_15 home12_16 home12_17 ///
							home12_1 home12_2 home12_3 home12_7 home12_29 home12_35 home12_36 home12_37 home12_38 home12_39 home12_42 ///
							home12_21 home12_22 home12_23 home12_41 home12_43 home12_44 ///
							home12_8 home12_9 home12_10 home12_11)

egen home_develop36 = rowmean(home36_1 home36_2 home36_3 home36_4 home36_5 home36_6 home36_7 home36_12 home36_43)
egen home_family36 = rowmean(home36_8 home36_9 home36_10 home36_15 home36_48)
egen home_housing36 = rowmean(home36_19 home36_20 home36_21 home36_22 home36_23 home36_24 home36_25)
egen home_hostility36 = rowmean(home36_41 home36_42 home36_52 home36_53 home36_54 home36_55)
egen home_learning36 = rowmean(home36_11 home36_13 home36_14 home36_16 home36_27 home36_28 home36_29 home36_33 home36_34 home36_35 home36_36 home36_37 home36_38 home36_39 home36_40 home36_47 home36_49)
egen home_variety36 = rowmean(home36_18 home36_44 home36_45 home36_46 home36_50 home36_51)
egen home_warmth36 = rowmean(home36_17 home36_26 home36_30 home36_31 home36_32)
egen home_total36 = rowmean(home36_1 home36_2 home36_3 home36_4 home36_5 home36_6 home36_7 home36_12 home36_43 ///
							home36_41 home36_42 home36_52 home36_53 home36_54 home36_55 ///
							home36_11 home36_13 home36_14 home36_16 home36_27 home36_28 home36_29 home36_33 home36_34 home36_35 home36_36 home36_37 home36_38 home36_39 home36_40 home36_47 home36_49 ///
							home36_18 home36_44 home36_45 home36_46 home36_50 home36_51 ///
							home36_17 home36_26 home36_30 home36_31 home36_32)

#delimit ;
keep id
home_total*
home_develop*
home_family*
home_housing*
home_hostility*
home_learning*
home_variety*
home_warmth*
;
#delimit cr

save ihdp-home-agg, replace

* ------ *
* ABC/CARE

/*
* HOME total score (deprecated)
cd "$data_raw"
use "append-abccare.dta", clear

rename home0y6m	home_total6
rename home1y6m	home_total18
rename home2y6m	home_total30
rename home3y6m	home_total42
rename home4y6m	home_total54
rename home8y	home_total96

keep id treat program home_total*
tempfile tmpabc
save "`tmpabc'", replace
*/

cd "$data_working"
use "abc-home-item", clear

egen home_develop6 = rowmean(home6_18 home6_19 home6_24 home6_25 home6_26 home6_27 home6_28 home6_30 home6_31 home6_32 home6_33 home6_34 home6_45)
egen home_family6 = rowmean(home6_4 home6_5 home6_6)
gen home_housing6 = .
egen home_hostility6 = rowmean(home6_12 home6_13 home6_14 home6_15 home6_16 home6_17)
egen home_learning6 = rowmean(home6_1 home6_2 home6_3 home6_7 home6_29 home6_35 home6_36 home6_37 home6_38 home6_39 home6_42)
egen home_variety6 = rowmean(home6_21 home6_22 home6_23 home6_41 home6_43 home6_44)
egen home_warmth6 = rowmean(home6_8 home6_9 home6_10 home6_11)
egen home_total6 = rowmean(home6_18 home6_19 home6_24 home6_25 home6_26 home6_27 home6_28 home6_30 home6_31 home6_32 home6_33 home6_34 home6_45 ///
						   home6_12 home6_13 home6_14 home6_15 home6_16 home6_17 ///
						   home6_1 home6_2 home6_3 home6_7 home6_29 home6_35 home6_36 home6_37 home6_38 home6_39 home6_42 ///
						   home6_21 home6_22 home6_23 home6_41 home6_43 home6_44 ///
						   home6_8 home6_9 home6_10 home6_11)

egen home_develop18 = rowmean(home18_18 home18_19 home18_24 home18_25 home18_26 home18_27 home18_28 home18_30 home18_31 home18_32 home18_33 home18_34 home18_45)
egen home_family18 = rowmean(home18_4 home18_5 home18_6)
gen home_housing18 = .
egen home_hostility18 = rowmean(home18_12 home18_13 home18_14 home18_15 home18_16 home18_17)
egen home_learning18 = rowmean(home18_1 home18_2 home18_3 home18_7 home18_29 home18_35 home18_36 home18_37 home18_38 home18_39 home18_42)
egen home_variety18 = rowmean(home18_21 home18_22 home18_23 home18_41 home18_43 home18_44)
egen home_warmth18 = rowmean(home18_8 home18_9 home18_10 home18_11)
egen home_total18 = rowmean(home18_18 home18_19 home18_24 home18_25 home18_26 home18_27 home18_28 home18_30 home18_31 home18_32 home18_33 home18_34 home18_45 ///
							home18_12 home18_13 home18_14 home18_15 home18_16 home18_17 ///
							home18_1 home18_2 home18_3 home18_7 home18_29 home18_35 home18_36 home18_37 home18_38 home18_39 home18_42 ///
							home18_21 home18_22 home18_23 home18_41 home18_43 home18_44 ///
							home18_8 home18_9 home18_10 home18_11)

egen home_develop30 = rowmean(home30_18 home30_19 home30_24 home30_25 home30_26 home30_27 home30_28 home30_30 home30_31 home30_32 home30_33 home30_34 home30_45)
egen home_family30 = rowmean(home30_4 home30_5 home30_6)
gen home_housing30 = .
egen home_hostility30 = rowmean(home30_12 home30_13 home30_14 home30_15 home30_16 home30_17)
egen home_learning30 = rowmean(home30_1 home30_2 home30_3 home30_7 home30_29 home30_35 home30_36 home30_37 home30_38 home30_39 home30_42)
egen home_variety30 = rowmean(home30_21 home30_22 home30_23 home30_41 home30_43 home30_44)
egen home_warmth30 = rowmean(home30_8 home30_9 home30_10 home30_11)
egen home_total30 = rowmean(home30_18 home30_19 home30_24 home30_25 home30_26 home30_27 home30_28 home30_30 home30_31 home30_32 home30_33 home30_34 home30_45 ///
							home30_12 home30_13 home30_14 home30_15 home30_16 home30_17 ///
							home30_1 home30_2 home30_3 home30_7 home30_29 home30_35 home30_36 home30_37 home30_38 home30_39 home30_42 ///
							home30_21 home30_22 home30_23 home30_41 home30_43 home30_44 ///
							home30_8 home30_9 home30_10 home30_11)

egen home_develop42 = rowmean(home42_1 home42_2 home42_3 home42_4 home42_5 home42_6 home42_7 home42_8 home42_9 home42_10 home42_11 home42_12 home42_58 home42_71 home42_72 home42_73)
egen home_family42 = rowmean(home42_13 home42_14 home42_15 home42_42 home42_43 home42_44)
egen home_housing42 = rowmean(home42_34 home42_35 home42_36 home42_37 home42_38 home42_39 home42_40 home42_41)
egen home_hostility42 = rowmean(home42_46 home42_47 home42_48 home42_49 home42_50 home42_51 home42_52 home42_79 home42_80)
egen home_learning42 = rowmean(home42_22 home42_23 home42_24 home42_25 home42_26 home42_27 home42_28 home42_29 home42_30 home42_31 home42_32 home42_33 home42_45 home42_53 home42_54 home42_55 home42_57 home42_59 home42_60 home42_61 home42_62 home42_63 home42_64 home54_74)
egen home_variety42 = rowmean(home42_16 home42_18 home42_19 home42_20 home42_21 home42_69 home42_70 home42_75 home42_76 home42_77 home42_78)
egen home_warmth42 = rowmean(home42_56 home42_65 home42_66 home42_67 home42_68)
egen home_total42 = rowmean(home42_1 home42_2 home42_3 home42_4 home42_5 home42_6 home42_7 home42_8 home42_9 home42_10 home42_11 home42_12 home42_58 home42_71 home42_72 home42_73 ///
							home42_46 home42_47 home42_48 home42_49 home42_50 home42_51 home42_52 home42_79 home42_80 ///
							home42_22 home42_23 home42_24 home42_25 home42_26 home42_27 home42_28 home42_29 home42_30 home42_31 home42_32 home42_33 home42_45 home42_53 home42_54 home42_55 home42_57 home42_59 home42_60 home42_61 home42_62 home42_63 home42_64 home54_74 ///
							home42_16 home42_18 home42_19 home42_20 home42_21 home42_69 home42_70 home42_75 home42_76 home42_77 home42_78 ///
							home42_56 home42_65 home42_66 home42_67 home42_68)

egen home_develop54 = rowmean(home54_1 home54_2 home54_3 home54_4 home54_5 home54_6 home54_7 home54_8 home54_9 home54_10 home54_11 home54_12 home54_58 home54_71 home54_72 home54_73)
egen home_family54 = rowmean(home54_13 home54_14 home54_15 home54_42 home54_43 home54_44)
egen home_housing54 = rowmean(home54_34 home54_35 home54_36 home54_37 home54_38 home54_39 home54_40 home54_41)
egen home_hostility54 = rowmean(home54_46 home54_47 home54_48 home54_49 home54_50 home54_51 home54_52 home54_79 home54_80)
egen home_learning54 = rowmean(home54_22 home54_23 home54_24 home54_25 home54_26 home54_27 home54_28 home54_29 home54_30 home54_31 home54_32 home54_33 home54_45 home54_53 home54_54 home54_55 home54_57 home54_59 home54_60 home54_61 home54_62 home54_63 home54_64 home54_74)
egen home_variety54 = rowmean(home54_16 home54_18 home54_19 home54_20 home54_21 home54_69 home54_70 home54_75 home54_76 home54_77 home54_78)
egen home_warmth54 = rowmean(home54_56 home54_65 home54_66 home54_67 home54_68)
egen home_total54 = rowmean(home54_1 home54_2 home54_3 home54_4 home54_5 home54_6 home54_7 home54_8 home54_9 home54_10 home54_11 home54_12 home54_58 home54_71 home54_72 home54_73 ///
							home54_46 home54_47 home54_48 home54_49 home54_50 home54_51 home54_52 home54_79 home54_80 ///
							home54_22 home54_23 home54_24 home54_25 home54_26 home54_27 home54_28 home54_29 home54_30 home54_31 home54_32 home54_33 home54_45 home54_53 home54_54 home54_55 home54_57 home54_59 home54_60 home54_61 home54_62 home54_63 home54_64 home54_74 ///
							home54_16 home54_18 home54_19 home54_20 home54_21 home54_69 home54_70 home54_75 home54_76 home54_77 home54_78 ///
							home54_56 home54_65 home54_66 home54_67 home54_68)

#delimit ;
keep id
home_total*
home_develop*
home_family*
home_housing*
home_hostility*
home_learning*
home_variety*
home_warmth*
;
#delimit cr

save abc-home-agg, replace
