********
* KEEP *
********

clear all
cd "$data_working"

* EHS (by participation status)
use "ehs-renamed-items.dta", clear
tab poverty
tab m_ed
		gen hs=.
		replace hs=1 if m_ed==1|m_ed==2
		replace hs=2 if m_ed==3		
gen H=.
replace H = 4140/6000 if D==1
replace H=0 if D==0
*https://eclkc.ohs.acf.hhs.gov/programs/article/early-head-start-program-options
gen twin=0

*Participation
merge 1:1 id using "ehs-preschools.dta"
drop _merge

*SITEnum
merge 1:1 id using "${master_path}/Original datasets/Harvard Dataverse Sensitive Original Data/baseline/00097_Early_Head_Start_ehs_sites.dta"
drop _merge

*Instruments
merge 1:1 id using ehs-instruments
drop _merge

*Create instruments
egen cc_payments_site =mean(weekly_cc_pay),by(sitenum)
egen income_site =mean(labor_hh_inc60),by(sitenum)
gen cc_price_relative=cc_payments_site*4.2/(income_site/12)
*instruments: cc_price_relative cc_payments_site income_site caregiver_home
label var cc_payments_site 	"Z_p Mean Price of Alternative childcare"
label var cc_price_relative "Z_p Price of Alternative childcare Relative to Mean Income"
label var income_site		"Z_ph Mean income in area (proxy of wages)"
label var caregiver_ever 	"Z_n Potential Caregiver Available at Home"
label var caregiver_n 		"Z_n N Potential Caregivers Available "

*Many Participation Varaiables

gen alt=.
replace alt=0 if center!=.
replace alt=1 if center==1 & D==0 // D==0 is equivalent to doing center_ehs==0

*gen n=alt==0 & D==0

*Check the coding of Caregiver, which should definitely impact n and it is not impacting anything
*Check why alt is not affeced by price, wtf

*reg ever_center R caregiver_ever		cc_price_relative 	//very significant**
*reg main_center R caregiver_ever		cc_price_relative 	//very significant**
*reg center_ehs	R caregiver_ever		cc_price_relative	//R, price very significant
*reg center		R caregiver_ever		cc_price_relative	//R, price very significant
*reg D			R caregiver_ever		cc_price_relative	//R, price very significant
*reg alt		R caregiver_ever		cc_price_relative	//R, but not price
*reg n			R caregiver_ever		cc_price_relative	//R, price very significant

*Caregiver does not do anything, so we move to this-->
*reg center_ehs	R 	cc_price_relative	//R, price very significant
*reg center		R 	cc_price_relative	//R, price very significant
reg D			R 	cc_price_relative	//R, price very significant
reg alt			R 	cc_price_relative	//R, but not price
*reg n			R 	cc_price_relative	//R, price very significant


/*trying different specification of alt centers to see if it works
gen private_center=.
replace private_center=0 if ever_center!=. & D!=.
replace private_center=1 if ever_center==1 & D==0
reg private_center R caregiver_ever cc_price_relative //NOP
*/

/*trying different specification of EHS centers to see if it works
gen ehs_center=.
replace ehs_center=0 if ever_center!=. & D!=.
replace ehs_center=1 if ever_center==1 & D==1
reg ehs_center R caregiver_ever cc_price_relative //super influenced by the prices!!
*/

*Create Minimal Datasets
keep id R D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18 alt program_type sitenum ///
m_iq m_age sex poverty m_edu gestage bw black mf sibling twin ///
caregiver_ever cc_payments_site income_site cc_price_relative ///
ppvt3y /*center_ehs*/ ehs_months alt_months hs H ///
any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months alt1 alt2 alt center

order id R D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18  alt program_type sitenum ///
m_iq m_age sex poverty m_edu gestage bw black mf sibling twin ///
caregiver_ever cc_payments_site income_site cc_price_relative ppvt3y hs H alt_months



preserve
keep if program_type==1
drop /*center_ehs*/ ehs_months
outsheet using ehscenter-topi.csv, comma nolabel replace	//for Chanwool/Athey
save ehscenter-juan, replace								//for Juan: few variables
restore

preserve
keep if program_type==1
*gen center_ehscenter=center_ehs 							//to work on the pile code
gen ehscenter_months=ehs_months 							//to work on the pile code 
save ehscenter-topi, replace
restore

preserve
keep if program_type==3
drop /*center_ehs*/ ehs_months
outsheet using ehsmixed-topi.csv, comma nolabel replace		//for Chanwool/Athey
restore

preserve
count
keep if program_type==3|program_type==1
count
gen ehs_mixed_center_months=ehs_months
*gen center_ehsmmixed=center_ehs 							//to work on the pile code
*gen ehsmixed_months=ehs_months 								//to work on the pile code 
outsheet using ehsmixed_center-topi.csv, comma nolabel replace		//for Chanwool/Athey
save ehs_mixed_center-topi, replace
restore

save ehs-full-topi, replace






* IHDP
use "ihdp-renamed-items.dta", clear

tab poverty // 401 527 (poverty=1-->nonpoor)
tab m_ed     // 394 270 321
		gen hs=.
		replace hs=1 if m_ed==1|m_ed==2
		replace hs=2 if m_ed==3

gen H=.
replace H = 4212/6000 if D==1
replace H=0 if D==0
*http://www.welfareacademy.org/pubs/early_education/pdfs/Besharov_ECE%20assessments_IHDP.pdf assumes 9 hours/day				

*Preschools
merge 1:1 id using "ihdp-preschools.dta"
drop _merge

*Instruments
merge 1:1 id using ihdp-instruments
drop _merge
rename caregiver_three caregiver_home

*Create instruments
egen cc_payments_site =mean(weekly_cc_pay),by(site)

egen income_site =mean(hh_inc3y),by(site)
gen cc_price_relative=cc_payments_site*4.2/(income_site/12)


*instruments: cc_price_relative cc_payments_site income_site caregiver_home
label var cc_payments_site 	"Z_p Mean Price of Alternative childcare"
label var cc_price_relative "Z_p Price of Alternative childcare Relative to Mean Income"
label var income_site		"Z_ph Mean income in area (proxy of wages)"
label var caregiver_home	"Z_n Potential Caregiver Available at Home"

*Create Minimal Datasets
gen alt=.
replace alt=0 if center!=.
replace alt=1 if center==1 & D==0

keep id R D alt site pag ///
m_iq m_age sex poverty m_edu bw black mf gestage sibling twin  ///
caregiver_home cc_payments_site income_site cc_price_relative ppvt3y sb3y hs H center_ihdp ihdp_months

order id R D alt site pag ///
m_iq m_age sex poverty m_edu bw black mf gestage sibling twin  ///
caregiver_home cc_payments_site income_site cc_price_relative ppvt3y sb3y hs H center_ihdp ihdp_months

outsheet using ihdp-topi.csv, comma nolabel replace			//for Chanwool/Athey
save ihdp-juan, replace								//for Juan: few variables
save ihdp-topi, replace






* ABC
use "abc-renamed-items.dta", clear

keep id R home1_* home3_* norm_home_* video* sb* $covariates ///
bw  norm_pari* norm_pase* norm_bayley_* cbcl*  poverty black ///
/*hs0 H twin ww home3y6m_original*/ home_jbg_learning

merge 1:1 id using "abc-preschools.dta"

save abc-topi, replace
outsheet using abc-topi.csv, comma nolabel replace

*D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18







* CARE (by home visit & both)
*foreach t of global care_type {
*use "care`t'-topi.dta", clear

*keep id R D home1_* home3_* norm_home_* sb* $covariates bw  ///
*norm_bayley_* cbcl*  poverty black kidi_* ///
*hs H twin ww

*save care`t'-topi, replace
*}

/*OLD KEEP
EHS:
keep id R D home1_* home3_* norm_home_* video* ppvt* $covariates bw poverty  ///
norm_kidi_* norm_bayley_* norm_cbcl_*  black ///
hours_worked m_work1 m_work2 program_type ///
hs H twin /*ww*/ home3y_original ///
weekly_cc_pay caregiver_home labor_hh_inc60 sitenum ///
center center_ehs ehs_months alt_months

IHDP:
keep id R D alt home1_* home3_* norm_home_* ppvt* video* sb* $covariates bw bwg  ///
norm_kidi_* kidi* norm_sameroff* norm_bayley_* cbcl*  poverty black twin pag ///
m_work3y site hh_inc3y ///
hs H twin /*ww*/ home3y_original home_jbg_learning
*/
