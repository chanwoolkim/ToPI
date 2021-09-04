* ---------------------------------------- *
* Preliminary data preparation - parent info
* Author: Chanwool Kim
* ---------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

* KIDI
rename B1P_KDC2		kidi_total14
rename B2P_KDC2		kidi_total24

keep id treat kidi_*

cd "$data_working"
save ehs-parent, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_raw"
use "merge-ihdp.dta", clear

rename ihdp					id

* KIDI
rename kidac_12_sumscore	kidi_accuracy12
rename kidat_12_sumscore	kidi_attempted12
rename kidto_12_sumscore	kidi_total12

label var kidi_accuracy12	"KIDI: Accuracy Score"
label var kidi_attempted12	"KIDI: Attempted Score"
label var kidi_total12		"KIDI: total score, age 1"

rename kidat_24_sumscore	kidi_attempted24
rename kidac_24_sumscore	kidi_accuracy24
rename kidr_24_sumscore		kidi_right24
rename kidto_24_sumscore	kidi_total24

label var kidi_attempted24	"KIDI: Attempted Score"
label var kidi_accuracy24	"KIDI: Accuracy Score"
label var kidi_right24		"KIDI: Right Score"
label var kidi_total24		"KIDI: total score, age 2"

forvalues i = 21/38 {
	local j = `i'-20
	rename vb`i'_f22		kidi12_`j'
}

gen kidi12_19 = vb40_f22
recode kidi12_19 (1 2 4 8 = 0) (3 = 1)

label var kidi12_1 			"KIDI: babies with colic can cry for 20, 30 minutes, no matter what is done"
label var kidi12_2 			"KIDI: if baby is fed evaporated milk, baby needs extra vitamins/iron"
label var kidi12_3 			"KIDI: all infants need the same amount of sleep"
label var kidi12_4 			"KIDI: taking careof baby can leave parent tired, frustrated, overwhelmed"
label var kidi12_5 			"KIDI: one year old knows right from wrong"
label var kidi12_6 			"KIDI: infants stop paying atttention to surroundings if too much going on"
label var kidi12_7 			"KIDI: some normal babies do not enjoy being cuddled"
label var kidi12_8 			"KIDI: comforting/holding crying baby is spoiling the baby"
label var kidi12_9 			"KIDI: frequent cause of accidents is chidl pulling something on self"
label var kidi12_10 		"KIDI: good way to teach child not to hit is to hit back"
label var kidi12_11 		"KIDI: 6mo baby responds differently to people depending on person's mood"
label var kidi12_12 		"KIDI: Infants are usually walking by 12mo"
label var kidi12_13 		"KIDI: most infants are ready to be toilet trained by 1yo"
label var kidi12_14 		"KIDI: an infant will begin to respond to his her name at 10mo"
label var kidi12_15 		"KIDI: 5mo know what 'no' means"
label var kidi12_16 		"KIDI: 1yo children will cooperate and share when they play together"
label var kidi12_17 		"KIDI: baby is 7mo before he/she can reach for and grab things"
label var kidi12_18 		"KIDI: babies usually say first word at 6mo."
label var kidi12_19 		"KIDI: most appropriate game for 1yo: rolling a ball back and forth with an adult"

foreach i of numlist 1/2 4 6/7 9 11 14 {
	recode kidi12_`i'		(2 8 = 0)
}

foreach i of numlist 3 5 8 10 12/13 15/18 {
	recode kidi12_`i'		(1 8 = 0) (2 = 1)
}

forvalues i = 21/29 {
	local j = `i'-20
	rename v`i'_f38			kidi24_`j'
}
	
forvalues i = 30/37 {
	local j = `i'-20
	rename v`i'_f38			kidi24_`j'
}

label var kidi24_1			"KIDI: way infant is brought up will have little effect on intelligence"
label var kidi24_2 			"KIDI: baby can leave the parent feeling tired, frustrated, overwhelmed"
label var kidi24_3			"KIDI: younger sibling may start wetting bed/sucking thumb when new baby arrives"
label var kidi24_4 			"KIDI: two year old's sense of time is different from an adults"
label var kidi24_5 			"KIDI: The baby's personality is set by 6mo"
label var kidi24_6 			"KIDI: Child  uses rules of speech even if saying things incorrectly"
label var kidi24_7 			"KIDI: Child learns all language through copying what they hear people say"
label var kidi24_8 			"KIDI: frequent cause of accidents for 1yo is pulling things down onto themselves"
label var kidi24_9 			"KIDI: good way to teach child not to hit is to hit back"
label var kidi24_10 		"KIDI: Most 2yo can tell fiction on TV from truth"
label var kidi24_11 		"KIDI: Infants are usually walking by 12mo"
label var kidi24_12 		"KIDI: 2yo can reason logically, much as an adult would"
label var kidi24_13 		"KIDI: 1yo knows right from wrong"
label var kidi24_14 		"KIDI: most infants are ready to be toilet trained by 1yo"
label var kidi24_15 		"KIDI: 1yo children will cooperate and share when they play together"
label var kidi24_16 		"KIDI: infants of 12mo can remember toys they have watched being hidden"
label var kidi24_17 		"KIDI: babies usually say first word at 6mo."

foreach i of numlist 2/4 6 8 {
	recode kidi24_`i'		(2 8 = 0)
}

foreach i of numlist 1 5 7 9 {
	recode kidi24_`i'		(1 8 = 0) (2 = 1)
}

foreach i of numlist 10/15 17 {
	recode kidi24_`i'		(1 2 8 = 0) (3 = 1)
}

recode kidi24_16			(2 3 8 = 0)

* Sameroff
rename codqc_12_sumscore sameroff_cat12
rename codqc_36_sumscore sameroff_cat36
rename codqp_12_sumscore sameroff_prsp12
rename codqp_36_sumscore sameroff_prsp36
rename codqt_12_sumscore sameroff_total12
rename codqt_36_sumscore sameroff_total36

label var sameroff_cat12 "Sameroff Concepts of Development: Categorical Score"
label var sameroff_cat36 "Sameroff Concepts of Development: Categorical Score"
label var sameroff_prsp12 "Sameroff Concepts of Development: Perspectivistic Score"
label var sameroff_prsp36 "Sameroff Concepts of Development: Perspectivistic Score"
label var sameroff_total12 "Sameroff Concepts of Development: Total Score"
label var sameroff_total36 "Sameroff Concepts of Development: Total Score"

rename vb1_f22 sameroff12_1
rename vb2_f22 sameroff12_2
rename vb3_f22 sameroff12_3
rename vb4_f22 sameroff12_4
rename vb5_f22 sameroff12_5
rename vb6_f22 sameroff12_6
rename vb7_f22 sameroff12_7
rename vb8_f22 sameroff12_8
rename vb9_f22 sameroff12_9
rename vb10_f22 sameroff12_10
rename vb11_f22 sameroff12_11
rename vb12_f22 sameroff12_12
rename vb13_f22 sameroff12_13
rename vb14_f22 sameroff12_14
rename vb15_f22 sameroff12_15
rename vb16_f22 sameroff12_16
rename vb17_f22 sameroff12_17
rename vb18_f22 sameroff12_18
rename vb19_f22 sameroff12_19
rename vb20_f22 sameroff12_20

rename v57_f56 sameroff36_1
rename v58_f56 sameroff36_2
rename v59_f56 sameroff36_3
rename v60_f56 sameroff36_4
rename v61_f56 sameroff36_5
rename v62_f56 sameroff36_6
rename v63_f56 sameroff36_7
rename v64_f56 sameroff36_8
rename v65_f56 sameroff36_9
rename v66_f56 sameroff36_10
rename v67_f56 sameroff36_11
rename v68_f56 sameroff36_12
rename v69_f56 sameroff36_13
rename v70_f56 sameroff36_14
rename v71_f56 sameroff36_15
rename v72_f56 sameroff36_16
rename v73_f56 sameroff36_17
rename v74_f56 sameroff36_18
rename v75_f56 sameroff36_19
rename v76_f56 sameroff36_20

foreach m of numlist 12 36 {
	forvalues i = 1/20 {
		local label: var label sameroff`m'_`i'
		label var sameroff`m'_`i' "Sameroff: `label'"
	}
}

keep id kidi_* kidi12_* kidi24_* sameroff_* sameroff12_* sameroff36_*

cd "$data_working"
save ihdp-parent, replace

* ------ *
* ABC

cd "$data_raw"
use "append-abccare.dta", clear

* Parent's interest in spending time with child
rename eps8		parent_disinterest96
rename eiebs7	parent_irritable96

* KIDI
rename kidi_acc2y6m	kidi_accuracy30

* PARI
foreach q in dpnd scls noaggr isltd supsex maritl nohome rage verb egal comrde auth hostl demo {
	rename pari_`q'			pari_`q'6
	rename pari_`q'1y6m		pari_`q'18
	tab pari_`q'6, mi
	tab pari_`q'18, mi
}

forvalues i = 1/55 {
	rename pari6i`i'		pari6_`i'
	rename par18i`i'		pari18_`i'
}

* PASE

foreach q in auth cnfv cntr do dtch indp obey pos prog sdv socv talk {
	rename pase_`q'5y6m		pase_`q'66
	rename pase_`q'8y		pase_`q'96
}

rename pase_educ5y6m		pase_educ66

keep id treat program parent_* kidi_* pari_* pari6_* pari18_* pase_*

cd "$data_working"
save abc-parent, replace
