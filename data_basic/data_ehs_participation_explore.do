* ------------------------------------------ *
* Preliminary data preparation - participation
* Author: Chanwool Kim
* ------------------------------------------ *

* EXPLORING PARTICIPATION IN EHS *
cd "$data_raw"
use "std-ehs.dta", clear

/*
	   * Variables that show participation in EHS:

	   P2V_EH14		PSI IN EHS CARE AT n MONTHS OLD (n=14,24,36)	1965 D=11% TE=.57
	   P2V_EH24		PSI IN EHS CARE AT n MONTHS OLD (n=14,24,36)	1787 D=10% TE=.52		
	   P2V_EH36		PSI IN EHS CARE AT n MONTHS OLD (n=14,24,36)	543  D=10% TE=.48
	   ehs_hrs14m   AGEHRSE4   	PSI Hours per week in EHS care, 14m
	   ehs_hrs2     AGEHRSE6   	PSI Hours per week in EHS care, 2
	   ehs_hrs3     AGEHRSE8   	PSI Hours per week in EHS care, 3
	   ehs1         B1CT_EHS   	Tracking: Care provider is EHS center	371	 D=63% TE=.62 [Probb conditions on being in care]
	   ehs2         B2CT_EHS   	Tracking: Care provider is EHS center	415  D=52% TE=.60 [Probb conditions on being in care]	
	   ehs3         B3CT_EHS   	Tracking: Care provider is EHS center	500  D=28% TE=.44 [Probb conditions on being in care]
	   P2V_ENG2		BY PSI26:R/FC Eng in >min EHS act.				2129 D=47% TE=.86 [Artificial]
	   ehs_care3 	P2B_E36		PSI IN EHS at 36 mo					858  D=16% TE=.48

	   NO: B5P33F01 – 33F08	   	Ever attended EHS
*/

tab ehs_hrs14m

foreach var in P2V_EH14 P2V_EH24 P2V_EH36 ehs1 ehs2 ehs3 P2V_ENG2 ehs_care3 {
	di  as text in red "`: var label `var''"
	sum `var'
	reg `var' treat if program_type==1
	reg `var' treat if program_type==3
	label values `var' dummy
}

corr P2V_EH14 P2V_EH24 P2V_EH36 ehs1 ehs2 ehs3 ehs_care3 //corrs are decent
egen analyze_ehs_miss=group(ehs1 P2V_EH14 ehs2 P2V_EH24 ehs3 P2V_EH36 ehs_care3), label missing
tab analyze_ehs_miss
// This is kind of a mess: we see both missings and contradictions

* EXPLORING PARTICIPATION VARIABLES *
/*
	   * Appendix: Exploring Variables that show participation in other programs: *

	   center_used6m   P26_CTR2   	Used child care center by 6m			1954
	   P2V_CB14   					PSIs: IN CENTER CARE AT 14 MONTHS OLD	1951
	   center_hrs14m   AGEHRSC4   	Hours per week in center care, 14m		1897
	   center_hrs15m   P215_CHR   	Hours per week in center care, 15m		1831
	   center_used15m  P215_CR2   	Used child care center by 15m			1987
	   center_hrs2     AGEHRSC6   	Hours per week in center care, 2		1647
	   P2V_CB24   					PSIs: IN CENTER CARE AT 24 MONTHS OLD	1699
	   center_used26m  P2V_CTR2   	Used child care center by 26m			1948
	   center_hrs26m   P2V_CHRS   	Hours per week in center care, 26m		1683
	   P2V_CB36   					PSIs: IN CENTER CARE AT 36 MONTHS OLD	522
	   center_care3    P2B_CB36   	IN CENTER CARE @36MO W/ PI DATA			983
	   HRSCB8	   					HRS/WK IN CENTER CARE @36MO W/ PI DATA
	   center_hrs3     AGEHRSC8   	Hours per week in center care, 3		512
*/

label define dummy 1 "1" 0 "0"

rename center_used6m center_care6m
sum center_care6m // 1954 obs
tab center_care6m // 77% no
reg center_care6m treat // 0.15 effect
reg center_care6m treat if program_type==1 // 0.38 effect
reg center_care6m treat if program_type==3 // 0.16 effect
label values center_care6m dummy

rename P2V_CB14 center_care14m
sum center_care14m // 1951 obs
tab center_care14m // 75% no
reg center_care14m treat // 0.17 effect
reg center_care14m treat if program_type==1 // 0.40 effect
reg center_care14m treat if program_type==3 // 0.18 effect
label values center_care14m dummy

tab center_hrs14m
gen center_care14m_from_hours=.
replace center_care14m_from_hours=1 if center_hrs14m>0 & center_hrs14m!=.
replace center_care14m_from_hours=0 if center_hrs14m==0
sum center_care14m_from_hours // 1897 obs
tab center_care14m_from_hours // 77% no
reg center_care14m_from_hours treat // 0.17 effect
reg center_care14m_from_hours treat if program_type==1 // .41 effect
reg center_care14m_from_hours treat if program_type==3 // .16 effect
label values center_care14m_from_hours dummy

tab center_hrs15m
gen center_care15m_from_hours=.
replace center_care15m_from_hours=1 if center_hrs15m>0 & center_hrs15m!=.
replace center_care15m_from_hours=0 if center_hrs15m==0
sum center_care15m_from_hours // 1831 obs
tab center_care15m_from_hours // 74% no
reg center_care15m_from_hours treat // 0.14 effect
reg center_care15m_from_hours treat if program_type==1 // .36 effect
reg center_care15m_from_hours treat if program_type==3 // .18 effect
label values center_care15m_from_hours dummy

rename center_used15m center_care15m
sum center_care15m // 1987 obs
tab center_care15m // 68% no
reg center_care15m treat // 0.16 effect
reg center_care15m treat if program_type==1 // 0.33 effect
reg center_care15m treat if program_type==3 // 0.21 effect
label values center_care15m dummy

tab center_hrs2
gen center_care24m_from_hours=.
replace center_care24m_from_hours=1 if center_hrs2>0 & center_hrs2!=.
replace center_care24m_from_hours=0 if center_hrs2==0
sum center_care24m_from_hours // 1647 obs
tab center_care24m_from_hours // 80% no
reg center_care24m_from_hours treat // 0.15 effect
reg center_care24m_from_hours treat if program_type==1 // .33 effect
reg center_care24m_from_hours treat if program_type==3 // .17 effect
label values center_care24m_from_hours dummy

rename P2V_CB24 center_care24m
sum center_care24m // 1699 obs
tab center_care24m // 77% no
reg center_care24m treat // 0.16 effect
reg center_care24m treat if program_type==1 // 0.32 effect
reg center_care24m treat if program_type==3 // 0.18 effect
label values center_care24m dummy

rename center_used26m center_care26m
sum center_care26m // 1948 obs
tab center_care26m // 58% no
reg center_care26m treat // 0.15 effect
reg center_care26m treat if program_type==1 // 0.28 effect
reg center_care26m treat if program_type==3 // 0.20 effect
label values center_care26m dummy

rename P2V_CB36 center_care30m
sum center_care30m // 522 obs THIS VAR IS A FAILURE
tab center_care30m // 75% WEIRD 
reg center_care30m treat // 0.16 effect
reg center_care30m treat if program_type==1 // 0.38 effect
reg center_care30m treat if program_type==3 // 0.05 effect
label values center_care30m dummy

rename center_care3 center_care36m
sum center_care36m // 983 obs TOO FEW!
tab center_care36m // 60% yes
reg center_care36m treat // 0.14 effect
reg center_care36m treat if program_type==1 // 0.25 effect
reg center_care36m treat if program_type==3 // 0.07 effect
label values center_care36m dummy

tab HRSCB8 
gen center_care36m_from_hours=.
replace center_care36m_from_hours=1 if HRSCB8>0 & HRSCB8!=.
replace center_care36m_from_hours=0 if HRSCB8==0
sum center_care36m_from_hours // 973 obs
tab center_care36m_from_hours // 59% yes
reg center_care36m_from_hours treat // 0.15 effect
reg center_care36m_from_hours treat if program_type==1 // .25 effect
reg center_care36m_from_hours treat if program_type==3 // .08 effect
label values center_care36m_from_hours dummy

tab center_hrs3 
gen center_care36m_from_hours2=.
replace center_care36m_from_hours2=1 if center_hrs3>0 & center_hrs3!=.
replace center_care36m_from_hours2=0 if center_hrs3==0
sum center_care36m_from_hours2 // 512 obs
tab center_care36m_from_hours2 // 23% yes, WEIRD
reg center_care36m_from_hours2 treat // 0.15 effect
reg center_care36m_from_hours2 treat if program_type==1 // .39 effect
reg center_care36m_from_hours2 treat if program_type==3 // .07 effect
label values center_care36m_from_hours2 dummy

egen analyze_center_miss=group(center_care6m center_care14m center_care15m ///
	center_care24m center_care26m center_care30m ///
	center_care36m center_care36m_from_hours center_care36m_from_hours2), label missing
tab analyze_center_miss

// center_care36m_from_hours2 has no additional information over center_care36m_from_hours
// center_care36m_from_hours has 7 observations with different values than center_care36m
// It does not have any additional obs, not worth it
// center_care30m has less info, no contribution

* Option 1: variables in the dataset, adding one by one
gen center_care=.
replace center_care=center_care36m if center_care==. // 983 changes
corr center_care center_care26m // 0.56
tab center_care center_care26m, mi // roughly similar 0/1 and 1/0 differences, no clear bias
replace center_care=center_care26m if center_care==. // 1030 changes

tab center_care // 42% attends at age 2/3
reg center_care treat // .15%
reg center_care treat if program_type==1 // .27*** DECENT
reg center_care treat if program_type==3 // .15***
reg center_care treat if program_type==2 // .09***

* Option 2: variables in dataset, considering Var=1 if ever in center care
egen center_total1=rowtotal(center_care6m center_care14m center_care15m ///
	center_care24m center_care26m center_care30m center_care36m), missing
gen center1=(center_total>=1) if center_total!=.
sum center1 // 2042 .48
reg center1 treat if program_type==1 // .24, DECENT

/*
	   * Option 3: variables in dataset, considering Var=1 if ever in center care,
	   * Adding the one created with Harvard data
	   egen center_total=rowtotal(center3 center_care6m center_care14m center_care15m ///
	   center_care24m center_care26m center_care30m center_care36m), missing
	   gen center=(center_total>=1) if center_total!=.
	   sum center // 2354 .47 BIG GAIN IN OBS
	   reg center treat if program_type==1 // .24, DECENT
*/

/*
	   * APPENDIX: EXPLORING VARIABLES THAT SHOW PARTICIPATION IN CHILD CARE: [NOT USED] *

	   P2V_CC14        P2V_CC14   PSIs: IN CHILD CARE AT 14 MONTHS OLD 	1913 D=.63 TE=.12
	   P2V_CC24        P2V_CC24   PSIs: IN CHILD CARE AT 24 MONTHS OLD 	1569
	   P2V_CC36        P2V_CC36   PSIs: IN CHILD CARE AT 36 MONTHS OLD 	493
	   ccare_used14m   B1P_NECC   14m ANY CHILD CARE					2341
	   ccare_used24m   B2P_NECC   24m ANY CHILD CARE					2162
	   child_care3     P2B_CC36   In child care at age 3				1323

	   ccare_hrs6m     P26_HRS    By 6th mo: Avg Weekly Hrs of Child Care	
	   center_hrs6m    P26_CHRS   By 6th mo: Avg Weekly Hrs of Center Care
	   ccare_hrs15m    P215_HRS   By 15th mo: Avg Weekly Hrs of Child Care
	   HRSB8           HRSB8      HRS/WEEK IN CHILD CARE @36MO W/ PI DATA
	   ccare_hrs14m    AGEHRS4    Hours per week in child care, 14m
	   ccare_hrs2      AGEHRS6    Hours per week in child care, 2
	   ccare_hrs26m    P2V_HRS    Hours per week in child care, 26m
	   ccare_hrs3      AGEHRS8    Hours per week in child care, 3
*/

corr P2V_CC14 P2V_CC24 P2V_CC36 ccare_used14m ccare_used24m child_care3

foreach var in P2V_CC14 P2V_CC24 P2V_CC36 ccare_used14m ccare_used24m child_care3{
	di  as text in red "`: var label `var''"
	sum `var'
	reg `var' treat if program_type==1
	reg `var' treat if program_type==3
}
