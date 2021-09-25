**************
*** I. EHS ***
**************

global data_raw "${master_path}/Original datasets"
use "$data_raw/Harvard Dataverse Sensitive Original Data/parent_interview/00097_Early_Head_Start_B3P_ruf.dta", clear
gen caregiver_home=.
replace caregiver_home=1 if b3p33_03==3 //one or more aunts/uncles at home
replace caregiver_home=0 if b3p33_03==0
replace caregiver_home=1 if b3p33_04==4 //one or more grandparents
replace caregiver_home=0 if b3p33_04==0

*weekly childcare price
gen weekly_cc_pay=.
replace weekly_cc_pay=b3p424*40 		if b3p424p==1
replace weekly_cc_pay=b3p424*5 			if b3p424p==2
replace weekly_cc_pay=b3p424 			if b3p424p==3
replace weekly_cc_pay=b3p424/2 			if b3p424p==4
replace weekly_cc_pay=b3p424/4.2 		if b3p424p==5
replace weekly_cc_pay=b3p424/(4.2*11) 	if b3p424p==6
replace weekly_cc_pay=. 				if weekly_cc_pay>4000 //1 case
replace weekly_cc_pay=. if weekly_cc_pay<0

keep id caregiver_home weekly_cc_pay

merge 1:1 id using "$data_raw/Harvard Dataverse Sensitive Original Data/parent_interview/00097_Early_Head_Start_B2P_ruf.dta"

replace caregiver_home=1 if b2p33_03==3 & caregiver_home==.
replace caregiver_home=0 if b2p33_03==0 & caregiver_home==.
replace caregiver_home=1 if b2p33_04==4 & caregiver_home==.
replace caregiver_home=0 if b2p33_04==0 & caregiver_home==.

replace weekly_cc_pay=b2p424*40 		if b2p424p==1 & weekly_cc_pay==.
replace weekly_cc_pay=b2p424*5 			if b2p424p==2 & weekly_cc_pay==.
replace weekly_cc_pay=b2p424 			if b2p424p==3 & weekly_cc_pay==.
replace weekly_cc_pay=b2p424/2 			if b2p424p==4 & weekly_cc_pay==.
replace weekly_cc_pay=b2p424/4.2 		if b2p424p==5 & weekly_cc_pay==.
replace weekly_cc_pay=b2p424/(4.2*11) 	if b2p424p==6 & weekly_cc_pay==.
replace weekly_cc_pay=. 				if weekly_cc_pay>4000 //1 case
replace weekly_cc_pay=. if weekly_cc_pay<0

keep id caregiver_home weekly_cc_pay

merge 1:1 id using "$data_raw/Harvard Dataverse Sensitive Original Data/parent_interview/00097_Early_Head_Start_B1P_ruf.dta"
replace caregiver_home=1 if b1p33_03==3 & caregiver_home==.
replace caregiver_home=0 if b1p33_03==0 & caregiver_home==.
replace caregiver_home=1 if b1p33_04==4 & caregiver_home==.
replace caregiver_home=0 if b1p33_04==0 & caregiver_home==.

replace weekly_cc_pay=b1p424*40 		if b1p424p==1 & weekly_cc_pay==.
replace weekly_cc_pay=b1p424*5 			if b1p424p==2 & weekly_cc_pay==.
replace weekly_cc_pay=b1p424 			if b1p424p==3 & weekly_cc_pay==.
replace weekly_cc_pay=b1p424/2 			if b1p424p==4 & weekly_cc_pay==.
replace weekly_cc_pay=b1p424/4.2 		if b1p424p==5 & weekly_cc_pay==.
replace weekly_cc_pay=b1p424/(4.2*11) 	if b1p424p==6 & weekly_cc_pay==.
replace weekly_cc_pay=. 				if weekly_cc_pay>4000 //1 case
replace weekly_cc_pay=. if weekly_cc_pay<0

replace weekly_cc_pay=. if weekly_cc_pay==0

keep id caregiver_home weekly_cc_pay

cd "$data_working"
save ehs-instruments, replace

**************
** II. IHDP **
**************
cd "$data_raw"
use "base-ihdp.dta", clear
gen caregiver_home=.
foreach var of varlist v86a1_f52_3y-v86a15_f52_3y v45a1_f34_2y-v45a15_f34_2y v46a1_f18_1y-v46a15_f18_1y{
replace caregiver_home=0 if `var'!=. & caregiver_home==.
replace caregiver_home=1 if inlist(`var',5,6,7,8,9,10,11,13,14)
}
tab caregiver_home

gen weekly_cc_pay=care_payamt3y //mean 25, reasonable
rename ihdp id
keep id weekly_cc_pay caregiver_home
cd "$data_working"
save ihdp-instruments, replace

