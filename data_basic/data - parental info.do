* ---------------------------------------- *
* Preliminary data preparation - parent info
* Author: Chanwool Kim
* Date Created: 26 Jan 2018
* Last Update: 29 Jan 2018
* ---------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_ehs"
use "std-ehs.dta", clear

* KIDI
rename B1P_KDC2		kidi_total14
rename B2P_KDC2		kidi_total24

keep id treat kidi_*

cd "$data_parent"
save ehs-parent, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
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
	rename vb`i'_f22		kidi12_`i'
	recode kidi12_`i'		(2 8 = 0)
}

rename vb39_f22				kidi12_39
rename vb40_f22				kidi12_40

recode kidi12_39			(8 = 0)
recode kidi12_40			(8 = 0)

label var kidi12_21 		"KIDI: babies with colic can cry for 20, 30 minutes, no matter what is done"
label var kidi12_22 		"KIDI: if baby is fed evaporated milk, baby needs extra vitamins/iron"
label var kidi12_23 		"KIDI: all infants need the same amount of sleep"
label var kidi12_24 		"KIDI: taking careof baby can leave parent tired, frustrated, overwhelmed"
label var kidi12_25 		"KIDI: one year old knows right from wrong"
label var kidi12_26 		"KIDI: infants stop paying atttention to surroundings if too much going on"
label var kidi12_27 		"KIDI: some normal babies do not enjoy being cuddled"
label var kidi12_28 		"KIDI: comforting/holding crying baby is spoiling the baby"
label var kidi12_29 		"KIDI: frequent cause of accidents is chidl pulling something on self"
label var kidi12_30 		"KIDI: good way to teach child not to hit is to hit back"
label var kidi12_31 		"KIDI: 6mo baby responds differently to people depending on person's mood"
label var kidi12_32 		"KIDI: Infants are usually walking by 12mo"
label var kidi12_33 		"KIDI: most infants are ready to be toilet trained by 1yo"
label var kidi12_34 		"KIDI: an infant will begin to respond to his her name at 10mo"
label var kidi12_35 		"KIDI: 5mo know what 'no' means"
label var kidi12_36 		"KIDI: 1yo children will cooperate and share when they play together"
label var kidi12_37 		"KIDI: baby is 7mo before he/she can reach for and grab things"
label var kidi12_38 		"KIDI: babies usually say first word at 6mo."
label var kidi12_39 		"KIDI: best way to deal with 1yo who keeps playing with breakable things"
label var kidi12_40 		"KIDI: most appropriate game for 1yo"

forvalues i = 21/29 {
	rename v`i'_f38			kidi24_`i'
	recode kidi24_`i'		(2 8 = 0)
}
	
forvalues i = 30/37 {
	rename v`i'_f38			kidi24_`i'
	recode kidi24_`i'		(8 = 0)
}

rename v38_f38				kidi24_38

recode kidi24_38			(8 = 0)

label var kidi24_21			"KIDI: way infant is brought up will have little effect on intelligence"
label var kidi24_22 		"KIDI: baby can leave the parent feeling tired, frustrated, overwhelmed"
label var kidi24_23			"KIDI: younger sibling may start wetting bed/sucking thumb when new baby arrives"
label var kidi24_24 		"KIDI: two year old's sense of time is different from an adults"
label var kidi24_25 		"KIDI: The baby's personality is set by 6mo"
label var kidi24_26 		"KIDI: Child  uses rules of speech even if saying things incorrectly"
label var kidi24_27 		"KIDI: Child learns all language through copying what they hear people say"
label var kidi24_28 		"KIDI: frequent cause of accidents for 1yo is pulling things down onto themselves"
label var kidi24_29 		"KIDI: good way to teach child not to hit is to hit back"
label var kidi24_30 		"KIDI: Most 2yo can tell fiction on TV from truth"
label var kidi24_31 		"KIDI: Infants are usually walking by 12mo"
label var kidi24_32 		"KIDI: 2yo can reason logically, much as an adult would"
label var kidi24_33 		"KIDI: 1yo knows right from wrong"
label var kidi24_34 		"KIDI: most infants are ready to be toilet trained by 1yo"
label var kidi24_35 		"KIDI: 1yo children will cooperate and share when they play together"
label var kidi24_36 		"KIDI: infants of 12mo can remember toys they have watched being hidden"
label var kidi24_37 		"KIDI: babies usually say first word at 6mo."
label var kidi24_38 		"KIDI: which is the best way to avoid future trantrums by 2yo?"

keep id kidi_* kidi12_* kidi24_*

cd "$data_parent"
save ihdp-parent, replace

* ------ *
* ABC/CARE

cd "$data_abc"
use "append-abccare.dta", clear

* PARI
foreach q in dpnd scls noaggr isltd supsex maritl nohome rage verb egal comrde auth hostl demo {
	rename pari_`q'			pari_`q'6
	rename pari_`q'1y6m		pari_`q'18
	tab pari_`q'6, mi
	tab pari_`q'18, mi
}

forvalues i = 1/55 {
	rename pari6i`i'		pari_6`i'
	rename par18i`i'		pari_18`i'
}

* PASE

foreach q in auth cnfv cntr do dtch indp obey pos prog sdv socv talk {
	rename pase_`q'5y6m		pase_`q'66
	rename pase_`q'8y		pase_`q'96
}

rename pase_educ5y6m		pase_educ66

keep id treat program pari_* pari_6* pari_18* pase_*

cd "$data_parent"
save abc-parent, replace
