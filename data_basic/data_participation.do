* ------------------------------------------ *
* Preliminary data preparation - participation
* Author: Chanwool Kim
* ------------------------------------------ *

clear all

/*
	   * Variables on program participation
	   *		Binary	Binary			Center_		Program_
	   *		Center	Program			months		months
	   *		Care	Participation	Care		Participation

	   * EHS	center	D				YES			Need Questionnaire
	   * ABC	P		D				Q YES?		YES?
*/

* -------------- *
* Early Head Start

/*
	   Notes on EHS participation:
	   - Ever center care age 3 ok
	   - Months of center care up to age 3 one can build
	   - Ever EHS age 3 ok, but we do not have the original variables
	   - Months of EHS up to age 3 we cannot build without the questionnaire (Parent Services Interview) in Mathematica
*/

* 1. CENTER CARE in EHS *

* HARVARD DATA, FAITHFUL TO QUESTIONNAIRE
* Parental interview, age 3
cd "${data_raw}/Harvard Dataverse Sensitive Original Data/parent_interview"
use "00097_Early_Head_Start_B3P_ruf.dta", clear

* Which arrangements are centers?
gen center_PI=0
replace center_PI=1 if b3p405a1==6 // main provider
replace center_PI=1 if b3p405a2==6 // second provider
replace center_PI=1 if b3p405a3==6 // third provider
tab center_PI // 35% yes, 2110 observations

* Months of age at the time of the interview
gen dob=date(cdob,"YMD")
format dob %td
gen intervew_date=date(b3p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob
gen age_months=age_days/30
tab age_months // almost all children are 36-39 months

* Dummies for each arrangement being centers
gen a1_center=(b3p405a1==6) // arrangement 1
gen a2_center=(b3p405a2==6) // arrangement 2
gen a3_center=(b3p405a3==6) // arrangement 3

* Months using each arrangement
foreach r in 1 2 3 {
	replace b3p407_`r'=. if b3p407_`r'<0
	gen mo`r'=age_months-b3p407_`r' // how many months has the child been using the arrangement
	replace mo`r'=0 if mo`r'<0
	replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

*Months center ages 0-3
gen mo_center=0
replace mo_center=mo1 if a1_center==1
replace mo_center=mo2 if a2_center==1 & mo_center==.
replace mo_center=mo3 if a3_center==1 & mo_center==.

keep id center_PI mo_center
tempfile ehs_PI3
save `ehs_PI3'

use "00097_Early_Head_Start_B2P_ruf.dta", clear
merge 1:1 id using `ehs_PI3', nogen nolabel

* Which arrangements are centers
gen center_extra=0
replace center_extra=1 if b2p405a1==6
replace center_extra=1 if b2p405a2==6
replace center_extra=1 if b2p405a3==6
tab center_extra // 23% yes, 2433 observations

* Adding information to our previous variables
replace center_PI=1 if center_PI==0 & center_extra==1
tab center_PI // 40% yes, 2110 obs

* Months of age at time of the interview
gen dob = date(cdob,"YMD")
format dob %td
gen intervew_date = date(b2p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob
gen age_months=age_days/30
tab age_months

* Dummies for each arrangement being centers
gen a1_center=(b2p405a1==6)
gen a2_center=(b2p405a2==6)
gen a3_center=(b2p405a3==6)

*How old was child when started using that arrangement
foreach r in 1 2 3 {
	replace b2p407_`r'=. if b2p407_`r'<0
	gen mo`r'=age_months-b2p407_`r'
	replace mo`r'=0 if mo`r'<0
	replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

gen mo_center_02=0
replace mo_center_02=mo1 if a1_center==1
replace mo_center_02=mo2 if a2_center==1 & mo_center_02==.
replace mo_center_02=mo3 if a3_center==1 & mo_center_02==.

gen mo_center_23=12 if mo_center>12 & mo_center!=.
replace mo_center_23=mo_center if mo_center<12

gen mo_center_total=mo_center_23+mo_center_02
compare mo_center mo_center_total
replace mo_center=max(mo_center_total,mo_center)

keep id center_PI mo_center
tempfile ehs_PI2
save `ehs_PI2'

use "00097_Early_Head_Start_B1P_ruf.dta", clear
merge 1:1 id using `ehs_PI2', nogen nolabel

gen center_extra=0
replace center_extra=1 if b1p405a1==6
replace center_extra=1 if b1p405a2==6
replace center_extra=1 if b1p405a3==6
tab center_extra // 20% yes, 2636 obs

replace center_PI=1 if center_PI==0 & center_extra==1
tab center_PI // 44% yes

gen dob = date(cdob,"YMD")
format dob %td
gen intervew_date = date(b1p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob

gen age_months=age_days/30
tab age_months
gen a1_center=(b1p405a1==6)
gen a2_center=(b1p405a2==6)
gen a3_center=(b1p405a3==6)

foreach r in 1 2 3 {
	replace b1p407_`r'=. if b1p407_`r'<0
	gen mo`r'=age_months-b1p407_`r'
	replace mo`r'=0 if mo`r'<0
	replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

gen mo_center_01=0
replace mo_center_01=mo1 if a1_center==1
replace mo_center_01=mo2 if a2_center==1
replace mo_center_01=mo3 if a3_center==1

gen mo_center_13=24 if mo_center>24 & mo_center!=.
replace mo_center_13=mo_center if mo_center<24

gen mo_center_total=mo_center_13+mo_center_01
compare mo_center mo_center_total
replace mo_center=max(mo_center_total,mo_center)

replace mo_center=mo_center_01 if mo_center<mo_center_01 & mo_center_01!=.

* Participates more than one month is roughly consistent with participation
count if mo_center==0 // 1211
count if center_PI==0 // 1179
count if mo_center>0 & mo_center !=. // 885
count if center_PI==1 // 931

sum center_PI // 44%, 2110 obs

keep id center_PI mo_center
tempfile ehs_PI_participation
save `ehs_PI_participation'

* ALL OTHER VARIABLES
cd "$data_raw"
use "std-ehs.dta", clear

merge 1:1 id using `ehs_PI_participation', nogen nolabel

rename center_used6m center_care6m
label values center_care6m dummy
rename P2V_CB14 center_care14m
label values center_care14m dummy
rename center_used15m center_care15m
label values center_care15m dummy
rename P2V_CB24 center_care24m
label values center_care24m dummy
rename center_used26m center_care26m
label values center_care26m dummy
rename P2V_CB36 center_care30m
label values center_care30m dummy
rename center_care3 center_care36m
label values center_care36m dummy

* See the analysis of these and other variables in the appendix
* This creation of the variable gains 300 obs, while keeping average and treatment effects
egen center_total=rowtotal(center_PI center_care6m center_care14m center_care15m ///
	center_care24m center_care26m center_care30m center_care36m), missing
gen center=(center_total>=1) if center_total!=.
sum center // 2354 obs .50 BIG GAIN IN OBS
reg center treat if program_type==1 // .27, DECENT

* 2. EHS PARTICIPATION *

/*
	   Notes:
	   * ehs1		Tracking: Care provider is EHS center
	   * P2V_EH14	PSIs: IN EHS CARE AT 14 MONTHS OLD
	   * ehs2		Tracking: Care provider is EHS center
	   * P2V_EH24	PSIs: IN EHS CARE AT 24 MONTHS OLD
	   * ehs3		Tracking: Care provider is EHS center
	   * P2V_EH36	PSIs: IN EHS CARE AT 36 MONTHS OLD
	   * ehs_care3	In EHS care at age 3
*/

* gen has_ehs_hrs14m=ehs_hrs14m>0 & ehs_hrs14m!=.
* gen has_ehs_hrs2=ehs_hrs2>0 & ehs_hrs2!=.
* gen has_ehs_hrs3=ehs_hrs3>0 & ehs_hrs3!=.

* replace any_ehs1=1 if has_ehs_hrs14m==1
* replace any_ehs1=1 if has_ehs_hrs2==1
* replace any_ehs1=1 if has_ehs_hrs3==1

egen ehs_total=rowtotal(ehs1 P2V_EH14 ehs2 P2V_EH24 ehs3 P2V_EH36 ehs_care3), mi
gen any_ehs=(ehs_total>=1) if ehs_total!=.

gen mo_center1 =mo_center>=1  & mo_center!=.
gen mo_center12=mo_center>=12 & mo_center!=.
label var ehs1 "Tracking: EHS center 14m"
label var ehs2 "Tracking: EHS center 24m"
label var ehs3 "Tracking: EHS center 36m"
label var P2V_EH14 "PSIs: IN EHS CARE 14m"
label var P2V_EH24 "PSIs: IN EHS CARE 24m"
label var P2V_EH36 "PSIs: IN EHS CARE 36m"
label var any_ehs "Indicator: any of the above"
label var P2V_ENG2 "PSI: Eng min EHS act"

matrix M=J(9,7,.)
matrix rownames M=ehs1 P2V_EH14 ehs2 P2V_EH24 ehs3 P2V_EH36 ehs_care3 any_ehs P2V_ENG2 
matrix colnames M=N avg_t avg_c center1_t center1_c center12_t center12_c
local r=1

foreach var in ehs1 P2V_EH14 ehs2 P2V_EH24 ehs3 P2V_EH36 ehs_care3 any_ehs P2V_ENG2{
	gen D_`var'_1=`var'*mo_center1
	gen D_`var'_12=`var'*mo_center12
	count if `var'!=.
	matrix M[`r',1]=r(N)

	sum `var' if treat==1
	matrix M[`r',2]=r(mean)
	sum `var' if treat==0
	matrix M[`r',3]=r(mean)

	sum D_`var'_1 if treat==1
	matrix M[`r',4]=r(mean)
	sum D_`var'_1 if treat==0
	matrix M[`r',5]=r(mean)

	sum D_`var'_12 if treat==1
	matrix M[`r',6]=r(mean)
	sum D_`var'_12 if treat==0
	matrix M[`r',7]=r(mean)

	local r=`r'+1
}

matrix list M

* Comparing two ways of construucting the EHS participation variables
* With and without the minimal engagement variable

gen any_ehs1=(ehs_total>=1) if ehs_total!=.
tab any_ehs1 // 15%
tab any_ehs1 if program_type==1 | program_type==3 // 27%

gen any_ehs2=any_ehs1
replace any_ehs2=1 if P2V_ENG2==1
tab any_ehs2 // 47%
tab any_ehs2 if program_type==1 | program_type==3 // 48%

reg any_ehs1 treat if program_type==1 // .58 effect, nice!
reg any_ehs2 treat if program_type==1 // .72 effect, huge!

gen center_ehs1=.
replace center_ehs1=1 if any_ehs1==1 & center==1
replace center_ehs1=0 if any_ehs1==0 & center!=.
replace center_ehs1=0 if any_ehs1!=. & center==0
tab center_ehs1 // 15%

gen center_ehs2=.
replace center_ehs2=1 if any_ehs2==1 & center==1
replace center_ehs2=0 if any_ehs2==0 & center!=.
replace center_ehs2=0 if any_ehs2!=. & center==0
tab center_ehs2 // 29%

reg center_ehs1 treat if program_type==1 // .58, very nice
reg center_ehs2 treat if program_type==1 // .67, very nice

* 3. MONTHS IN EHS PARTICIPATION *

gen ehs_months1=.
replace ehs_months1=0 if center==0
replace ehs_months1=0 if center==1 & center_ehs1==0
replace ehs_months1=mo_center if center==1 & center_ehs1==1 // (redundant, just for organization)

gen alt_months1=.
replace alt_months1=0 if center==0
replace alt_months1=0 if center==1 & center_ehs1==1
replace alt_months1=mo_center if center==1 & center_ehs1==0

sum ehs_months1
sum ehs_months1 if ehs_months1>0
sum alt_months1
sum alt_months1 if alt_months1>0

* tab ehs treat
gen alt1=.
replace alt1=0 if center!=. 
replace alt1=1 if center==1 & any_ehs1==0
gen alt2=.
replace alt2=0 if center!=.
replace alt2=1 if center==1 & any_ehs2==0

/*
	   * Compare alt_months and ehs_months
	   * Treated and control groups
	   cumul mo_center if treat==1, gen(v_t) equal
	   cumul mo_center if treat==0, gen(v_c) equal
       line v_t v_c mo_center, sort ylabel(0(0.1)1) legend(order (1 "Treatment" 2 "Control")) 		

	   * Months of EHS and non-EHS centers
       cumul alt_months if ehs_months==0, gen(v_alt) equal
	   cumul ehs_months if alt_months==0, gen(v_ehs) equal
	   line v_alt v_ehs mo_center, sort ylabel(0(0.1)1) legend(order (1 "Alternative" 2 "EHS")) 		
*/

foreach m in 1 6 12 18{
	gen P_`m'=.
	replace P_`m'=1 if alt_months1>=`m' & alt_months1!=.
	replace P_`m'=0 if alt_months1<`m'

	gen D_`m'=.
	replace D_`m'=1 if ehs_months1>=`m' & ehs_months1!=.
	replace D_`m'=0 if ehs_months1<`m'
}

gen P=.
replace P=1 if alt_months1>=1 & alt_months1!=.
replace P=0 if alt_months1<1

/*
	   * Silenced because it is redundant with D_1
	   * and later gets replaced by the old construction of the variable
	   gen D=.
	   replace D=1 if ehs_months1>=1 & ehs_months1!=.
	   replace D=0 if ehs_months1<1
	   tab ehs D, mi
*/

rename treat R
rename P2V_ENG2 D

tab D, mi
replace D = 1 if (D > 0 & D != .) // 0 changes
sum D
tab D R, col

gen alt=.
replace alt=0 if center!=.
replace alt=1 if center==1 & D==0 // D==0 is equivalent to doing center_ehs==0

keep id center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months ///
	R D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18 alt alt1 alt2 program_type
cd "$data_working"
save "ehs-participation.dta", replace

* --------- *
* Abecedarian

cd "$data_raw"
use "append-abccare.dta", clear

// See daycare.do for the creation of the variables

drop if id==74 	// died at 3 months
drop if id==85 	// withdrawn at 3 months, does not have SB
drop if id==108 // moved at 6 months, does not have SB
* 900 no-show
* 912 no-show
* 922 no-show
* 78 crossover
* 82 crossover [need]
* 119 crossover [need]

keep if program == "abc"
drop P D // no (1,1)
gen abc_months=dc_fpg1+dc_fpg2+dc_fpg3
gen alt_months=dc_alt1+dc_alt2+dc_alt3

foreach m in 1 6 12 18{
	gen P_`m'=.
	replace P_`m'=0 if alt_months<`m'
	replace P_`m'=1 if alt_months>=`m' & alt_months!=.

	gen D_`m'=.
	replace D_`m'=0 if abc_months<`m'
	replace D_`m'=1 if abc_months>=`m' & abc_months!=.
}

gen P=.
replace P=1 if alt_months>=1 & alt_months!=.
replace P=0 if alt_months<1
*replace P=0 if alt_months==0 // 11 changes!

gen D=.
replace D=1 if abc_months>=1 & abc_months!=.
replace D=0 if abc_months<1

/*
	   gen part=.
	   replace part=1 if D==1
	   replace part=2 if D==0 & P==1
	   replace part=3 if D==0 & P==0
	   tab part, mi
*/

* drop alt_months
tabstat abc_months alt_months, by(R)
* rename P center
* rename D center_abc

tab dc_alt1 if R==0 // 80% had none
tab dc_alt2 if R==0 // 70% had none
tab dc_alt3 if R==0 // 44% had none

gen mo_center=abc_months+alt_months

/*
	   * Treated and control groups
	   cumul mo_center if R==1, gen(v__t) equal
	   cumul mo_center if R==0, gen(v__c) equal
	   line v__t v__c mo_center, sort ylabel(0(0.1)1) legend(order(1 "Treatment" 2 "Control"))

	   * Months of ABC and non-ABC centers
       cumul alt_months if abc_months==0, gen(v_alt) equal
	   cumul abc_months if alt_months==0, gen(v_abc) equal
	   line v_alt v_abc mo_center, sort ylabel(0(0.1)1) legend(order(1 "Alternative" 2 "ABC"))

	   cumul abc_months if R==1, gen(v__t) equal
	   cumul abc_months if R==0, gen(v__c) equal
	   line v__t v__c abc_months, sort ylabel(0(0.1)1) legend(order(1 "Treatment" 2 "Control"))
*/

keep id center abc_months alt_months R D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18 
cd "$data_working"
save "abc-participation.dta", replace
