* -------------------------------------------- *
* Preliminary data preparation - HOME aggregates
* Author: Chanwool Kim
* Date Created: 11 Sep 2017
* Last Update: 3 Mar 2017
* -------------------------------------------- *

* This aggregates items according to Jeanne Brooks-Gunn's conceptually meaningful scales.

clear all

* -------------- *
* Early Head Start

cd "$data_ehs"
use "std-ehs.dta", clear

* HOME total score
rename home_total14	home_total14
rename home_total2	home_total24
rename home_total3	home_total36
rename home_tot4	home_total48
rename home_tot5	home_total120

keep id treat home_total*
tempfile tmpehs
save "`tmpehs'", replace

cd "$data_home"
use "ehs-home-item", clear

egen home_develop14 = rowtotal(home14_7 home14_15 home14_16 home14_18 home14_19 home14_20 home14_21 home14_22 home14_23 home14_24 home14_43 home14_60 home14_727374), mi
egen home_family14 = rowtotal(home14_49 home14_51), mi
gen home_housing14 = .
egen home_hostility14 = rowtotal(home14_55 home14_56 home14_57 home14_58 home14_59), mi
egen home_learning14 = rowtotal(home14_11 home14_46 home14_47 home14_48 home14_61), mi
egen home_variety14 = rowtotal(home14_64 home14_65), mi
egen home_warmth14 = rowtotal(home14_45 home14_52 home14_53 home14_54), mi

egen home_develop24 = rowtotal(home24_7 home24_15 home24_16 home24_18 home24_19 home24_20 home24_21 home24_22 home24_23 home24_24 home24_43 home24_60), mi
egen home_family24 = rowtotal(home24_49 home24_51), mi
gen home_housing24 = .
egen home_hostility24 = rowtotal(home24_55 home24_56 home24_57 home24_58 home24_59), mi
egen home_learning24 = rowtotal(home24_11 home24_46 home24_47 home24_48 home24_61), mi
egen home_variety24 = rowtotal(home24_64 home24_65), mi
egen home_warmth24 = rowtotal(home24_45 home24_52 home24_53 home24_54), mi

egen home_develop36 = rowtotal(home36_48 home36_49), mi
egen home_family36 = rowtotal(home36_19 home36_39), mi
egen home_housing36 = rowtotal(home36_20 home36_21 home36_23 home36_24 home36_38 home36_57), mi
egen home_hostility36 = rowtotal(home36_35 home36_36 home36_37), mi
egen home_learning36 = rowtotal(home36_15 home36_34 home36_50 home36_51 home36_5253 home36_54), mi
egen home_variety36 = rowtotal(home36_43 home36_45 home36_46 home36_58 home36_59), mi
egen home_warmth36 = rowtotal(home36_16 home36_17 home36_18 home36_40), mi

#delimit ;
keep id
home_develop*
home_family*
home_housing*
home_hostility*
home_learning*
home_variety*
home_warmth*
;
#delimit cr

merge 1:1 id using `tmpehs', nogen nolabel

cd "$data_home"
save ehs-home-agg, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
use "base-ihdp.dta", clear

rename admin_treat	treat
rename ihdp			id

* HOME total score
rename homto_12_sumscore	home_total12
rename homto_36_sumscore	home_total36

keep id treat home_total*
tempfile tmpihdp
save "`tmpihdp'", replace

cd "$data_home"
use "ihdp-home-item", clear

egen home_develop12 = rowtotal(home12_18 home12_19 home12_24 home12_25 home12_26 home12_27 home12_28 home12_30 home12_31 home12_32 home12_33 home12_34 home12_45), mi
egen home_family12 = rowtotal(home12_4 home12_5 home12_6), mi
gen home_housing12 = .
egen home_hostility12 = rowtotal(home12_12 home12_13 home12_14 home12_15 home12_16 home12_17), mi
egen home_learning12 = rowtotal(home12_1 home12_2 home12_3 home12_7 home12_29 home12_35 home12_36 home12_37 home12_38 home12_39 home12_42), mi
egen home_variety12 = rowtotal(home12_21 home12_22 home12_23 home12_41 home12_43 home12_44), mi
egen home_warmth12 = rowtotal(home12_8 home12_9 home12_10 home12_11), mi

egen home_develop36 = rowtotal(home36_1 home36_2 home36_3 home36_4 home36_5 home36_6 home36_7 home36_12 home36_43), mi
egen home_family36 = rowtotal(home36_8 home36_9 home36_10 home36_15 home36_48), mi
egen home_housing36 = rowtotal(home36_19 home36_20 home36_21 home36_22 home36_23 home36_24 home36_25), mi
egen home_hostility36 = rowtotal(home36_41 home36_42 home36_52 home36_53 home36_54 home36_55), mi
egen home_learning36 = rowtotal(home36_11 home36_13 home36_14 home36_16 home36_27 home36_28 home36_29 home36_33 home36_34 home36_35 home36_36 home36_37 home36_38 home36_39 home36_40 home36_47 home36_49), mi
egen home_variety36 = rowtotal(home36_18 home36_44 home36_45 home36_46 home36_50 home36_51), mi
egen home_warmth36 = rowtotal(home36_17 home36_26 home36_30 home36_31 home36_32), mi

#delimit ;
keep id
home_develop*
home_family*
home_housing*
home_hostility*
home_learning*
home_variety*
home_warmth*
;
#delimit cr

merge 1:1 id using `tmpihdp', nogen nolabel

cd "$data_home"
save ihdp-home-agg, replace

* ------ *
* ABC/CARE

cd "$data_abc"
use "append-abccare.dta", clear

* HOME total score
rename home0y6m	home_total6
rename home1y6m	home_total18
rename home2y6m	home_total30
rename home3y6m	home_total42
rename home4y6m	home_total54
rename home8y	home_total96

keep id treat program home_total*
tempfile tmpabc
save "`tmpabc'", replace

cd "$data_home"
use "abc-home-item", clear

egen home_develop6 = rowtotal(home6_18 home6_19 home6_24 home6_25 home6_26 home6_27 home6_28 home6_30 home6_31 home6_32 home6_33 home6_34 home6_45), mi
egen home_family6 = rowtotal(home6_4 home6_5 home6_6), mi
gen home_housing6 = .
egen home_hostility6 = rowtotal(home6_12 home6_13 home6_14 home6_15 home6_16 home6_17), mi
egen home_learning6 = rowtotal(home6_1 home6_2 home6_3 home6_7 home6_29 home6_35 home6_36 home6_37 home6_38 home6_39 home6_42), mi
egen home_variety6 = rowtotal(home6_21 home6_22 home6_23 home6_41 home6_43 home6_44), mi
egen home_warmth6 = rowtotal(home6_8 home6_9 home6_10 home6_11), mi

egen home_develop18 = rowtotal(home18_18 home18_19 home18_24 home18_25 home18_26 home18_27 home18_28 home18_30 home18_31 home18_32 home18_33 home18_34 home18_45), mi
egen home_family18 = rowtotal(home18_4 home18_5 home18_6), mi
gen home_housing18 = .
egen home_hostility18 = rowtotal(home18_12 home18_13 home18_14 home18_15 home18_16 home18_17), mi
egen home_learning18 = rowtotal(home18_1 home18_2 home18_3 home18_7 home18_29 home18_35 home18_36 home18_37 home18_38 home18_39 home18_42), mi
egen home_variety18 = rowtotal(home18_21 home18_22 home18_23 home18_41 home18_43 home18_44), mi
egen home_warmth18 = rowtotal(home18_8 home18_9 home18_10 home18_11), mi

egen home_develop30 = rowtotal(home30_18 home30_19 home30_24 home30_25 home30_26 home30_27 home30_28 home30_30 home30_31 home30_32 home30_33 home30_34 home30_45), mi
egen home_family30 = rowtotal(home30_4 home30_5 home30_6), mi
gen home_housing30 = .
egen home_hostility30 = rowtotal(home30_12 home30_13 home30_14 home30_15 home30_16 home30_17), mi
egen home_learning30 = rowtotal(home30_1 home30_2 home30_3 home30_7 home30_29 home30_35 home30_36 home30_37 home30_38 home30_39 home30_42), mi
egen home_variety30 = rowtotal(home30_21 home30_22 home30_23 home30_41 home30_43 home30_44), mi
egen home_warmth30 = rowtotal(home30_8 home30_9 home30_10 home30_11), mi

egen home_develop42 = rowtotal(home42_1 home42_3 home42_5 home42_6 home42_7 home42_8 home42_9 home42_10 home42_12 home42_58 home42_71 home42_72 home42_73), mi
egen home_family42 = rowtotal(home42_13 home42_14 home42_15 home42_42 home42_43 home42_44), mi
egen home_housing42 = rowtotal(home42_34 home42_35 home42_36 home42_37 home42_38 home42_39 home42_40 home42_41), mi
egen home_hostility42 = rowtotal(home42_46 home42_47 home42_48 home42_49 home42_50 home42_51 home42_52 home42_79 home42_80), mi
egen home_learning42 = rowtotal(home42_22 home42_23 home42_24 home42_25 home42_26 home42_27 home42_28 home42_29 home42_30 home42_31 home42_32 home42_33 home42_45 home42_53 home42_54 home42_55 home42_57 home42_59 home42_60 home42_61 home42_62 home42_63 home42_64 home54_74), mi
egen home_variety42 = rowtotal(home42_16 home42_19 home42_20 home42_69 home42_70 home42_75 home42_76 home42_77 home42_78), mi
egen home_warmth42 = rowtotal(home42_56 home42_65 home42_66 home42_67 home42_68), mi

egen home_develop54 = rowtotal(home54_1 home54_3 home54_5 home54_6 home54_7 home54_8 home54_9 home54_10 home54_12 home54_58 home54_71 home54_72 home54_73), mi
egen home_family54 = rowtotal(home54_13 home54_14 home54_15 home54_42 home54_43 home54_44), mi
egen home_housing54 = rowtotal(home54_34 home54_35 home54_36 home54_37 home54_38 home54_39 home54_40 home54_41), mi
egen home_hostility54 = rowtotal(home54_46 home54_47 home54_48 home54_49 home54_50 home54_51 home54_52 home54_79 home54_80), mi
egen home_learning54 = rowtotal(home54_22 home54_23 home54_24 home54_25 home54_26 home54_27 home54_28 home54_29 home54_30 home54_31 home54_32 home54_33 home54_45 home54_53 home54_54 home54_55 home54_57 home54_59 home54_60 home54_61 home54_62 home54_63 home54_64 home54_74), mi
egen home_variety54 = rowtotal(home54_16 home54_19 home54_20 home54_69 home54_70 home54_75 home54_76 home54_77 home54_78), mi
egen home_warmth54 = rowtotal(home54_56 home54_65 home54_66 home54_67 home54_68), mi

#delimit ;
keep id
home_develop*
home_family*
home_housing*
home_hostility*
home_learning*
home_variety*
home_warmth*
;
#delimit cr

merge 1:1 id using `tmpabc', nogen nolabel

cd "$data_home"
save abc-home-agg, replace
