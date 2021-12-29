***********************************************
*** Expermenting with Instruments, Dec 2021 ***
***********************************************
*center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months ///
*D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18 alt1 alt2

global master_path			"/Users/andres/Dropbox/TOPI"
global data_working			"${master_path}/working"
cd $data_working

*****************************************
*** Data Experiments with Full Sample ***
*****************************************

use ehs-full-topi, clear

rename D oldD //this is minimal engagement
*reg D R //t=102
*reg alt R // -22 because it was based on the engagement variable
*How is alt created? YES THIS IS IT
drop alt
gen alt=.
replace alt=0 if center!=.
replace alt=1 if center==1 & oldD==0 //

gen P2=.
replace P2=0 if center!=.
replace P2=1 if center==1 & D_1==0 // D==0 is equivalent to doing center_ehs==0
reg P2 R 	//-1.78
reg P_1 R 	//-1.38

reg alt 	cc_price_relative 	//good
reg alt 	caregiver_ever 		//nothing
reg alt 	cc_payments_site 	//good		-2.68
reg alt1 	cc_price_relative 	//nothing
reg alt1 	caregiver_ever 		//nothing
reg alt1 	cc_payments_site 	//nothing
reg alt2 	cc_price_relative 	//-2
reg alt2 	caregiver_ever 		//nothing
reg alt2 	cc_payments_site 	//nothing
reg P2 		cc_price_relative 	//nothing
reg P2 		caregiver_ever 		//nothing
reg P2 		cc_payments_site 	//nothing
reg P_1 	cc_price_relative 	//nothing
reg P_1 	caregiver_ever 		//nothing
reg P_1 	cc_payments_site 	//nothing
reg P_6 	cc_price_relative 	//-2.21
reg P_6 	caregiver_ever 		//nothing
reg P_6 	cc_payments_site 	//nothing
reg P_12 	cc_price_relative 	// -4.17
reg P_12 	caregiver_ever 		//
reg P_12 	cc_payments_site 	// -2.78
reg P_18 	cc_price_relative 	// -4.79
reg P_18 	caregiver_ever 		//nothing
reg P_18 	cc_payments_site 	// -3.93

tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if oldD==1

tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if oldD==0 	//3% ehs children in control group
																							//they seem to be all in centers
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if alt==1
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if P_1==1
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if P_12==1
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if P_18==1

reg oldD R	//t=102
reg D_1 R	//t=14
reg D_6 R	//t=14
reg D_12 R	//t=14
reg D_18 R	//t=14

ivreg2 ppvt3 (D_6 P_6   = cc_price_relative R)	//CD=12 b=.07 g=-1
ivreg2 ppvt3 (D_12 P_12 = cc_price_relative R)	//CD=16 b=.11 g=-1
ivreg2 ppvt3 (D_18 P_18 = cc_price_relative R)	//CD=16 b=.12 g=-1.1

ivreg2 ppvt3 (D_6 P_6   = cc_price_relative R)	i.program_type //CD=7  b=.21 g=-.5
ivreg2 ppvt3 (D_12 P_12 = cc_price_relative R)	i.program_type //CD=10 b=.25 g=-.49
ivreg2 ppvt3 (D_18 P_18 = cc_price_relative R)	i.program_type //CD=12 b=.27 g=-0.55

*PAYMENTS SITE SEEM BAD
ivreg2 ppvt3 (D_6 P_6   = cc_payments_site R)	//CD=12 b=.26 g=-2
ivreg2 ppvt3 (D_12 P_12 = cc_payments_site R)	//CD=16 b=.16 g=-2
ivreg2 ppvt3 (D_18 P_18 = cc_payments_site R)	//CD=16 b=.14 g=-3

ivreg2 ppvt3 (D_6 P_6   = cc_payments_site R)	i.program_type //CD: BAD
ivreg2 ppvt3 (D_12 P_12 = cc_payments_site R)	i.program_type //CD: 6.6 b=-0.1 g=-2.5
ivreg2 ppvt3 (D_18 P_18 = cc_payments_site R)	i.program_type //CD: 8.6 b=-0.5 g=-2.5
*END PAYMENTS SITE

gen N_1=(D_1==0 & P_1==0) if D_1!=. & P_1!=.
reg N_1 cc_price_relative	//3.15
reg N_1 caregiver_ever 		//
reg N_1 cc_payments_site 	//3.4
gen N_6=(D_6==0 & P_6==0) if D_6!=. & P_6!=.
reg N_6 cc_price_relative	//5.2
reg N_6 caregiver_ever 		//
reg N_6 cc_payments_site 	//4.9
gen N_12=(D_12==0 & P_12==0) if D_12!=. & P_12!=.
reg N_12 cc_price_relative	//6
reg N_12 caregiver_ever 	//
reg N_12 cc_payments_site 	//6
gen N_18=(D_18==0 & P_18==0) if D_18!=. & P_18!=.
reg N_18 cc_price_relative	//7
reg N_18 caregiver_ever 	//
reg N_18 cc_payments_site 	//7

*Alternative Preschools Bad, Home or EHS indifferent
sum any_ehs1	//.15
sum any_ehs2	//.47

sum P_1			//.23
sum D_1			//.12
sum N_1			//.63

sum P_6			//.17
sum D_6			//.11
sum N_6			//.7

sum P_12		//.12
sum D_12		//.11
sum N_12		//.76


ivreg2 ppvt3 (P_6 N_6   = cc_price_relative R)					//CD=12 b=-1 g=-0.7
ivreg2 ppvt3 (P_12 N_12 = cc_price_relative R)					//CD=16 b=.11 g=-1
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)					//CD=16 b=-1.2 g=-.12

ivreg2 ppvt3 (P_6 N_6   = cc_price_relative R)	i.program_type 	//CD=7  b= -.74 -.21
ivreg2 ppvt3 (P_12 N_12 = cc_price_relative R)	i.program_type 	//CD=10 b= -.74 -.24
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)	i.program_type 	//CD=12 b= -.81 -.27

ivreg2 ppvt3 (D_18 N_18 = cc_price_relative R)														//CD=16 b=1  g=1   N=1366
ivreg2 ppvt3 (D_18 N_18 = cc_price_relative R)	i.program_type										//CD=12 b=.8 g=.54 N=1366
ivreg2 ppvt3 (D_18 N_18 = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=3.7 b=-1 g=-2 N=790 CRAP!

ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)										//CD=16 b=-1.2 g=-0.12 N=1366
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)	if program_type==1|program_type==3 	//CD=3.7 b=-1 g=-2 N=790 CRAP!

ivreg2 ppvt3 (P_6 N_6   = cc_price_relative R)	i.program_type										//CD=7   b=-.74 g=-.21
ivreg2 ppvt3 (P_6 N_6   = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=2.3 b=.24  g=-.57 CD TOO LOW
ivreg2 ppvt3 (P_12 N_12 = cc_price_relative R)	i.program_type										//CD=10	 b=-.74 g=-.25
ivreg2 ppvt3 (P_12 N_12 = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=3					CD TOO LOW
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)	i.program_type										//CD=12 b=-.81 g=-.27
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=5.3 b=.17 g=-.5 N=790

ivreg2 ppvt3 (D_18 = R) //.33
ivreg2 ppvt3 (D_18 = R) if program_type==1|program_type==3 //.32
ivreg2 ppvt3 (D_18 = R) if program_type==1 //.29
ivreg2 ppvt3 (D_18 = R) if program_type==3 //.62
ivreg2 ppvt3 (D_18 = R) if program_type==2
tab D_18 if program_type==2 & ppvt3!=.

ivreg2 ppvt3 (P_18 = cc_price_relative)  									//-1.1 CD is 26
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==1|program_type==3 	// 1.6 CD is 8
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==1 					//-4.5 CD is 8
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==3 					// 1.1 CD is 6
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==2 					//-1.7 CD is 17

*** Interactions Between Instruments ***
*Relative prices should be important when R=0
gen R0inter=(1-R)*cc_price_relative
gen R1inter=R*cc_price_relative
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R R0inter)	i.program_type						//CD=8.6/13  b=-.71 g=-.24 None significant
ivreg2 ppvt3 (P_18 N_18 = R R0inter)	i.program_type										//CD=8.4/7   b=-.57 g=-.32 None significant

ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R R1inter)	i.program_type						//CD=8.6/13  b=-.71 g=-.24 None significant
ivreg2 ppvt3 (P_18 N_18 = R R1inter)	i.program_type										//CD=3/7   b=-.57 g=-.32 None significant

*** Interactions Between Instruments and Program Type ***
ivreg2 ppvt3 (D_18 = R) if program_type==1
ivreg2 ppvt3 (D_18 = R) if program_type==2
ivreg2 ppvt3 (D_18 = R) if program_type==3

tab D_1 if program_type==2 & ppvt3!=. //1
tab P_1 if program_type==2 & ppvt3!=. //150
tab any_ehs1 if program_type==2 & ppvt3!=. //1
tab any_ehs2 if program_type==2 & ppvt3!=. //265
tab center_ehs2 if program_type==2 & ppvt3!=. //107
tab center if program_type==2 & ppvt3!=. //225
reg center R if program_type==2 & ppvt3!=. //Non-significant, they are going to other types of centers

gen R_inter_type2=R*(program_type==2)

ivreg2 ppvt3 ( P_18 N_18 = cc_price_relative R R_inter_type2) i.program_type, first

*** Interactions Between Instruments and Covariates ***
reg D_1  black R i.program_type //t=1.7
reg D_18 black R i.program_type //t=2.4
reg D_1  m_iq R i.program_type 	//t=4
reg D_18 m_iq R i.program_type 	//t=3.4
reg D_1  sex R i.program_type 	//t=0
reg D_18 sex R i.program_type 	//t=0
reg D_1  m_age R i.program_type //t=2
reg D_18 m_age R i.program_type //t=2.5
reg D_1  m_edu R i.program_type //t=4
reg D_18 m_edu R i.program_type //t=5

reg P_1  black R i.program_type //t=4.6
reg P_18 black R i.program_type //t=3.6
reg P_1  m_iq R i.program_type 	//t=
reg P_18 m_iq R i.program_type 	//t=
reg P_1  sex R i.program_type 	//t=0
reg P_18 sex R i.program_type 	//t=0
reg P_1  m_age R i.program_type //t=
reg P_18 m_age R i.program_type //t=
reg P_1  m_edu R i.program_type //t=3
reg P_18 m_edu R i.program_type //t=2

foreach var in black m_iq sex m_age m_edu{
gen R_inter_`var'=R*`var'
gen price_inter_`var'=cc_price_relative*`var'
}
reg P_12 R_inter_black 	black 	R i.program_type //
reg P_12 R_inter_m_iq 	m_iq 	R i.program_type //
reg P_12 R_inter_sex 	sex 	R i.program_type //
reg P_12 R_inter_m_age 	m_age 	R i.program_type //barely significant
reg P_12 R_inter_m_edu	m_edu 	R i.program_type //

reg P_12 price_inter_black 	black 	cc_price_relative	R i.program_type //
reg P_12 price_inter_m_iq 	m_iq 	cc_price_relative	R i.program_type //significant
reg P_12 price_inter_sex 	sex 	cc_price_relative	R i.program_type //
reg P_12 price_inter_m_age 	m_age 	cc_price_relative	R i.program_type //
reg P_12 price_inter_m_edu	m_edu 	cc_price_relative	R i.program_type //

gen R_inter_m_edu_lessHS=R*m_edu_lessHS
reg P_12 R_inter_m_edu_lessHS 	m_edu_lessHS 	R i.program_type

*** CHOPPIN' ***
gen m_edu_lessHS = (m_edu == 1)
gen m_edu_HS     = (m_edu == 2)
gen m_edu_moreHS = (m_edu == 3)
rename m_edu_moreHS medumoreHS 
rename m_edu_lessHS medulessHS 
global chop "black==1 & (m_edu_HS==1|medulessHS==1)"

ivreg2 ppvt3 (D_6 P_6   = cc_price_relative R) if $chop	//CD=2.3/7
ivreg2 ppvt3 (D_12 P_12 = cc_price_relative R) if $chop	//CD=3.8/7
ivreg2 ppvt3 (D_18 P_18 = cc_price_relative R) if $chop	//CD=0.8/7

*** HULL *** ??







