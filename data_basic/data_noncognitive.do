* ------------------------------------------ *
* Preliminary data preparation - non-cognitive
* Author: Chanwool Kim
* ------------------------------------------ *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

* CBCL
rename cbcl_agg5		cbcl_aggressive120
rename cbcl_att5		cbcl_attention120
rename cbcl_anx5		cbcl_anxious120
rename cbcl_ext5		cbcl_external120
rename cbcl_int5		cbcl_internal120
rename cbcl_rule5		cbcl_rule120
rename cbcl_som5		cbcl_somatic120
rename cbcl_soc5		cbcl_social120
rename cbcl_tho5		cbcl_thought120
rename cbcl_with5		cbcl_withdrawn120

* Bayley
rename bbrs_enga1		bayley_engagement14
rename bbrs_emot1		bayley_emotion14
rename bbrs_enga2		bayley_engagement24
rename bbrs_emot2		bayley_emotion24
rename bbrs_enga3		bayley_engagement36
rename bbrs_emot3		bayley_emotion36

/*
   keep id treat cbcl_*
   tempfile tmpehs
   save "`tmpehs'", replace

   cd "$data_ehs_harvard"
   use "00097_Early_Head_Start_B5P_ruf.dta", clear
*/

keep id treat cbcl_* bayley_*

cd "$data_working"
save ehs-noncog, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_raw"
use "merge-ihdp.dta", clear

rename ihdp			id

* CBCL
rename f326_b2601	 	cbcl60_1
rename f326_b2602 		cbcl60_2
rename f326_b2603 		cbcl60_3
rename f326_b2604 		cbcl60_4
rename f326_b2605 		cbcl60_5
rename f326_b2606 		cbcl60_6
rename f326_b2607 		cbcl60_7
rename f326_b2608 		cbcl60_8
rename f326_b2609 		cbcl60_9
rename f326_b2610 		cbcl60_10
rename f326_b2611 		cbcl60_11
rename f326_b2612 		cbcl60_12
rename f326_b2613 		cbcl60_13
rename f326_b2614 		cbcl60_14
rename f326_b2615 		cbcl60_15
rename f326_b2616 		cbcl60_16
rename f326_b2617 		cbcl60_17
rename f326_b2618 		cbcl60_18
rename f326_b2619 		cbcl60_19
rename f326_b2620 		cbcl60_20
rename f326_b2621 		cbcl60_21
rename f326_b2622 		cbcl60_22
rename f326_b2623 		cbcl60_23
rename f326_b2624 		cbcl60_24
rename f326_b2625 		cbcl60_25
rename f326_b2626 		cbcl60_26
rename f326_b2627 		cbcl60_27
rename f326_b2628 		cbcl60_28
rename f326_b2629 		cbcl60_29
rename f326_b2630 		cbcl60_30
rename f326_b2631 		cbcl60_31
rename f326_b2632 		cbcl60_32
rename f326_b2633 		cbcl60_33
rename f326_b2634 		cbcl60_34
rename f326_b2635 		cbcl60_35
rename f326_b2636 		cbcl60_36
rename f326_b2637 		cbcl60_37
rename f326_b2638 		cbcl60_38
rename f326_b2639 		cbcl60_39
rename f326_b2640 		cbcl60_40
rename f326_b2641 		cbcl60_41
rename f326_b2642 		cbcl60_42
rename f326_b2643 		cbcl60_43
rename f326_b2644 		cbcl60_44
rename f326_b2645 		cbcl60_45
rename f326_b2646 		cbcl60_46
rename f326_b2647 		cbcl60_47
rename f326_b2648 		cbcl60_48
rename f326_b2649 		cbcl60_49
rename f326_b2650 		cbcl60_50
rename f326_b2651 		cbcl60_51
rename f326_b2652 		cbcl60_52
rename f326_b2653 		cbcl60_53
rename f326_b2654 		cbcl60_54
rename f326_b2655 		cbcl60_55
rename f326_b2656a 		cbcl60_56a
rename f326_b2656b 		cbcl60_56b
rename f326_b2656c 		cbcl60_56c
rename f326_b2656d 		cbcl60_56d
rename f326_b2656e 		cbcl60_56e
rename f326_b2656f 		cbcl60_56f
rename f326_b2656g 		cbcl60_56g
rename f326_b2657 		cbcl60_57
rename f326_b2658 		cbcl60_58
rename f326_b2659 		cbcl60_59
rename f326_b2660 		cbcl60_60
rename f326_b2661 		cbcl60_61
rename f326_b2662		cbcl60_62
rename f326_b2663 		cbcl60_63
rename f326_b2664 		cbcl60_64
rename f326_b2665 		cbcl60_65
rename f326_b2666 		cbcl60_66
rename f326_b2667 		cbcl60_67
rename f326_b2668 		cbcl60_68
rename f326_b2669 		cbcl60_69
rename f326_b2670 		cbcl60_70
rename f326_b2671 		cbcl60_71
rename f326_b2672 		cbcl60_72
rename f326_b2673 		cbcl60_73
rename f326_b2674 		cbcl60_74
rename f326_b2675 		cbcl60_75
rename f326_b2676 		cbcl60_76
rename f326_b2677 		cbcl60_77
rename f326_b2678 		cbcl60_78
rename f326_b2679 		cbcl60_79
rename f326_b2680 		cbcl60_80
rename f326_b2681 		cbcl60_81
rename f326_b2682 		cbcl60_82
rename f326_b2683 		cbcl60_83
rename f326_b2684 		cbcl60_84
rename f326_b2685 		cbcl60_85
rename f326_b2686 		cbcl60_86
rename f326_b2687 		cbcl60_87
rename f326_b2688 		cbcl60_88
rename f326_b2689 		cbcl60_89
rename f326_b2690 		cbcl60_90
rename f326_b2691 		cbcl60_91
rename f326_b2692 		cbcl60_92
rename f326_b2693 		cbcl60_93
rename f326_b2694 		cbcl60_94
rename f326_b2695 		cbcl60_95
rename f326_b2696 		cbcl60_96
rename f326_b2697 		cbcl60_97
rename f326_b2698 		cbcl60_98
rename f326_b2699 		cbcl60_99
rename f326_b26100 		cbcl60_100
rename f326_b26101 		cbcl60_101
rename f326_b26102 		cbcl60_102
rename f326_b26103		cbcl60_103
rename f326_b26104 		cbcl60_104
rename f326_b26105 		cbcl60_105
rename f326_b26106 		cbcl60_106
rename f326_b26107 		cbcl60_107
rename f326_b26108 		cbcl60_108
rename f326_b26109 		cbcl60_109
rename f326_b26110 		cbcl60_110
rename f326_b26111 		cbcl60_111
rename f326_b26112 		cbcl60_112

rename f526_d2601		cbcl96_1
rename f526_d2602		cbcl96_2
rename f526_d2603		cbcl96_3
rename f526_d2604 		cbcl96_4
rename f526_d2605 		cbcl96_5
rename f526_d2606 		cbcl96_6
rename f526_d2607 		cbcl96_7
rename f526_d2608 		cbcl96_8
rename f526_d2609 		cbcl96_9
rename f526_d2610 		cbcl96_10
rename f526_d2611 		cbcl96_11
rename f526_d2612 		cbcl96_12
rename f526_d2613 		cbcl96_13
rename f526_d2614 		cbcl96_14
rename f526_d2615 		cbcl96_15
rename f526_d2616 		cbcl96_16
rename f526_d2617 		cbcl96_17
rename f526_d2618 		cbcl96_18
rename f526_d2619 		cbcl96_19
rename f526_d2620 		cbcl96_20
rename f526_d2621 		cbcl96_21
rename f526_d2622 		cbcl96_22
rename f526_d2623 		cbcl96_23
rename f526_d2624 		cbcl96_24
rename f526_d2625 		cbcl96_25
rename f526_d2626 		cbcl96_26
rename f526_d2627 		cbcl96_27
rename f526_d2628 		cbcl96_28
rename f526_d2629 		cbcl96_29
rename f526_d2630 		cbcl96_30
rename f526_d2631 		cbcl96_31
rename f526_d2632 		cbcl96_32
rename f526_d2633 		cbcl96_33
rename f526_d2634 		cbcl96_34
rename f526_d2635 		cbcl96_35
rename f526_d2636 		cbcl96_36
rename f526_d2637 		cbcl96_37
rename f526_d2638 		cbcl96_38
rename f526_d2639 		cbcl96_39
rename f526_d2640 		cbcl96_40
rename f526_d2641 		cbcl96_41
rename f526_d2642 		cbcl96_42
rename f526_d2643 		cbcl96_43
rename f526_d2644 		cbcl96_44
rename f526_d2645 		cbcl96_45
rename f526_d2646 		cbcl96_46
rename f526_d2647 		cbcl96_47
rename f526_d2648 		cbcl96_48
rename f526_d2649 		cbcl96_49
rename f526_d2650 		cbcl96_50
rename f526_d2651 		cbcl96_51
rename f526_d2652 		cbcl96_52
rename f526_d2653 		cbcl96_53
rename f526_d2654 		cbcl96_54
rename f526_d2655 		cbcl96_55
rename f526_d2656a 		cbcl96_56a
rename f526_d2656b 		cbcl96_56b
rename f526_d2656c 		cbcl96_56c
rename f526_d2656d 		cbcl96_56d
rename f526_d2656e 		cbcl96_56e
rename f526_d2656f 		cbcl96_56f
rename f526_d2656g 		cbcl96_56g
rename f526_d2657 		cbcl96_57
rename f526_d2658 		cbcl96_58
rename f526_d2659 		cbcl96_59
rename f526_d2660 		cbcl96_60
rename f526_d2661 		cbcl96_61
rename f526_d2662 		cbcl96_62
rename f526_d2663 		cbcl96_63
rename f526_d2664 		cbcl96_64
rename f526_d2665 		cbcl96_65
rename f526_d2666 		cbcl96_66
rename f526_d2667 		cbcl96_67
rename f526_d2668 		cbcl96_68
rename f526_d2669 		cbcl96_69
rename f526_d2670 		cbcl96_70
rename f526_d2671 		cbcl96_71
rename f526_d2672 		cbcl96_72
rename f526_d2673 		cbcl96_73
rename f526_d2674 		cbcl96_74
rename f526_d2675 		cbcl96_75
rename f526_d2676 		cbcl96_76
rename f526_d2677 		cbcl96_77
rename f526_d2678 		cbcl96_78
rename f526_d2679 		cbcl96_79
rename f526_d2680 		cbcl96_80
rename f526_d2681 		cbcl96_81
rename f526_d2682 		cbcl96_82
rename f526_d2683 		cbcl96_83
rename f526_d2684 		cbcl96_84
rename f526_d2685 		cbcl96_85
rename f526_d2686 		cbcl96_86
rename f526_d2687 		cbcl96_87
rename f526_d2688 		cbcl96_88
rename f526_d2689 		cbcl96_89
rename f526_d2690 		cbcl96_90
rename f526_d2691 		cbcl96_91
rename f526_d2692 		cbcl96_92
rename f526_d2693 		cbcl96_93
rename f526_d2694 		cbcl96_94
rename f526_d2695 		cbcl96_95
rename f526_d2696 		cbcl96_96
rename f526_d2697 		cbcl96_97
rename f526_d2698 		cbcl96_98
rename f526_d2699 		cbcl96_99
rename f526_d26100	 	cbcl96_100
rename f526_d26101 		cbcl96_101
rename f526_d26102 		cbcl96_102
rename f526_d26103 		cbcl96_103
rename f526_d26104 		cbcl96_104
rename f526_d26105 		cbcl96_105
rename f526_d26106 		cbcl96_106
rename f526_d26107 		cbcl96_107
rename f526_d26108 		cbcl96_108
rename f526_d26109 		cbcl96_109
rename f526_d26110 		cbcl96_110
rename f526_d26111 		cbcl96_111
rename f526_d26112 		cbcl96_112

* Bayley
rename v11a_f41			bayley24_11a
rename v11b_f41			bayley24_11b
rename v12a_f41			bayley24_12a
rename v12b_f41			bayley24_12b
rename v13a_f41			bayley24_13a
rename v13b_f41			bayley24_13b

foreach var in 11a 11b 12a 12b 13a 13b {
	recode bayley24_`var' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (5 = 0)
	replace bayley24_`var' = bayley24_`var'/4
}

rename v16a_f41			bayley24_16a
rename v16b_f41			bayley24_16b
replace bayley24_16a = bayley24_16a/4
replace bayley24_16b = bayley24_16b/4
rename v18a_f41			bayley24_18a
rename v18b_f41			bayley24_18b
replace bayley24_18a = bayley24_18a/4
replace bayley24_18b = bayley24_18b/4
gen bayley24_19a = v19a_f41 == 3 | v19a_f41 == 4
gen bayley24_19b = v19b_f41 == 3 | v19b_f41 == 4
rename v24a_f41			bayley24_24a
rename v24b_f41			bayley24_24b
replace bayley24_24a = bayley24_24a/4
replace bayley24_24b = bayley24_24b/4

rename v17a_f41			bayley24_17a
rename v17b_f41			bayley24_17b
replace bayley24_17a = bayley24_17a/4
replace bayley24_17b = bayley24_17b/4
gen bayley24_21a = v21a_f41 == 3 | v21a_f41 == 4
gen bayley24_21b = v21b_f41 == 3 | v21b_f41 == 4
gen bayley24_22a = v22a_f41 == 3 | v22a_f41 == 4
gen bayley24_22b = v22b_f41 == 3 | v22b_f41 == 4
gen bayley24_23a = v23a_f41 == 2 | v23a_f41 == 3 | v23a_f41 == 4
gen bayley24_23b = v23b_f41 == 2 | v23b_f41 == 3 | v23b_f41 == 4

gen bayley24_20a = v20a_f41 == 3 | v20a_f41 == 4
gen bayley24_20b = v20b_f41 == 3 | v20b_f41 == 4

keep id cbcl60_* cbcl96_* bayley24_* ///
	 v11_f62 v12_f62 v13_f62 v14_f62 v15_f62 v16_f62 v17_f62 v18_f62 v19_f62 v20_f62 v21_f62 v22_f62 v23_f62

* Data has a problem of string-coded missing
foreach var of varlist _all {
	capture confirm string var `var'
	if !_rc {
		qui replace `var' = ".n" if `var' == "N"
		qui replace `var' = ".d" if `var' == "D"
		qui replace `var' = ".r" if `var' == "R"
		qui replace `var' = ".d" if `var' == "d"
		qui replace `var' = ".r" if `var' == "r"
		qui replace `var' = ".d" if `var' == "DK"
		qui replace `var' = ".q" if `var' == "?"
		capture destring `var', replace
	}
}

egen cbcl60_56 = rowmean(cbcl60_56a cbcl60_56b cbcl60_56c cbcl60_56d cbcl60_56e cbcl60_56f cbcl60_56g)
egen cbcl96_56 = rowmean(cbcl96_56a cbcl96_56b cbcl96_56c cbcl96_56d cbcl96_56e cbcl96_56f cbcl96_56g)

* It seems like "b" has lots of missings: using "a" which corresponds to session 1
egen bayley_attention24 = rowmean(bayley24_11a bayley24_12a bayley24_13a bayley24_16a bayley24_18a bayley24_19a bayley24_24a)
egen bayley_emotion24 = rowmean(bayley24_17a bayley24_21a bayley24_22a bayley24_23a)
egen bayley_engagement24 = rowmean(bayley24_20a)

cd "$data_working"
save ihdp-noncog, replace

* ------ *
* ABC/CARE

cd "$data_raw"
use "append-abccare.dta", clear

* CBCL
rename achp8y_i*		cbcl96_*
egen cbcl96_56 = rowmean(cbcl96_56a cbcl96_56b cbcl96_56c cbcl96_56d cbcl96_56e cbcl96_56f cbcl96_56g)

* Kohn & Rosman (will treat as Bayley)
rename kr_confs3y		kr_confidence36
rename kr_withds3y		kr_withdrawn36
rename kr_atts3y		kr_attentive36
rename kr_dsts3y		kr_distractible36
rename kr72k*			kr72i*

foreach age of numlist 24 30 36 42 48 60 72 78 96 {
	rename kr`age'i*	bayley`age'_*
	egen bayley_attention`age' = rowmean(bayley`age'_2 bayley`age'_4 bayley`age'_6 bayley`age'_9 bayley`age'_11 bayley`age'_16 bayley`age'_20)
	egen bayley_emotion`age' = rowmean(bayley`age'_3 bayley`age'_7 bayley`age'_10 bayley`age'_15 bayley`age'_17 bayley`age'_19 bayley`age'_21 bayley`age'_23 bayley`age'_24)
	egen bayley_engagement`age' = rowmean(bayley`age'_1 bayley`age'_5 bayley`age'_8 bayley`age'_12 bayley`age'_14 bayley`age'_18 bayley`age'_22 bayley`age'_25 bayley`age'_26)
}

keep id treat program kr_* cbcl96_* bayley_* bayley*_*

cd "$data_working"
save abc-noncog, replace
