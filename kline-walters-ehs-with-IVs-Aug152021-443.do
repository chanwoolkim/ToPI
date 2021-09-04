clear all
*use "C:\Users\jpanta\Dropbox\TOPI\working\juan_ehs.dta"
*use "C:\Users\jpanta\Dropbox\TOPI\working\juan_ehs_centermixed.dta"
*use "C:\Users\jpanta\Dropbox\TOPI\working\ehscenter-juan-with-IVs.dta"
 use "C:\Users\jpanta\Dropbox\TOPI\working\ehscenter-juan-with-IVs_mixed_center.dta"


 
* Basic Data Clean-Up
keep id ppvt3y R sitenum m_edu m_iq bw m_age black sex D alt caregiver_home cc_payments income_site cc_price_relative

drop if  ppvt3y == .
drop if       R == .
drop if   m_edu == .
drop if   m_age == .
drop if    m_iq == .
drop if     sex == .
drop if       D == .
drop if sitenum == .
drop if   black == .
drop if      bw == .
drop if     alt == .
drop if caregiver_home == . 
drop if    cc_payments == . 
drop if    income_site == . 
drop if  cc_price_relative == .

drop if m_edu!=1 & m_edu!=2 & m_edu!=3

rename R       Z_h
rename ppvt3y  Y
rename id      hhid
gen     treat_choice = .
replace treat_choice = 1 if D==1
replace treat_choice = 2 if alt==1
replace treat_choice = 3 if alt==0 & D==0

gen site_06 = (sitenum==6)
gen site_09 = (sitenum==9)
gen site_11 = (sitenum==11)
gen site_14 = (sitenum==14)

rename caregiver_home Z_n
rename cc_payments    Z_c

drop D alt sitenum

*replace m_edu = 0 if m_edu==1|m_edu==2
*replace m_edu = 1 if m_edu==3

gen m_edu_lessHS = (m_edu == 1)
gen m_edu_HS     = (m_edu == 2)
gen m_edu_moreHS = (m_edu == 3)


gen nonblack = 1-black


 
*local covariates " m_iq nonblack       m_edu_moreHS sex bw m_age                " NO
*local covariates " m_iq                                                         " NO
*local covariates "      black                                                   " 
 local covariates " m_iq black                                                   " 
*local covariates " m_iq black                    sex                            " NO
*local covariates " m_iq black       m_edu_moreHS sex                            " NO
*local covariates " m_iq black       m_edu_moreHS sex bw                         " NO 
*local covariates " m_iq black       m_edu_moreHS sex bw m_age                   " NO
*local covariates "      black                                                   " NO
*local covariates "      black       m_edu_moreHS                                " NO
*local covariates "      black                    sex                            " NO
*local covariates "      black       m_edu_moreHS                                " NO
                    

* Norm the covariate vector X (see page 1830 KW(2016))

*foreach x of local covariates { 
*     egen mean_`x' = mean (`x')
*	  replace  `x' = `x' - mean_`x'
*}

* Recode treat_choice so that category are such that category 1 which will be assigned as baseline category is the "None" alternative (currently "None" is given code 3) Category 2 which  will be assigned as scale alternative is the "IHDP" alternative (currently IHDP is give code 2) and Category 3 which is the "Other" alternative (Currently "Other" is given code 2)

rename  treat_choice treat_choice_old
gen     treat_choice = treat_choice_old
replace treat_choice = 1 if treat_choice_old==3
replace treat_choice = 2 if treat_choice_old==1
replace treat_choice = 3 if treat_choice_old==2

label define lbltreatchoice 1 "None" 2 "EHS" 3 "Other"
label values treat_choice lbltreatchoice

*keep hhid Y Z_h Z_c Z_n treat_choice `covariates'
*keep hhid Y Z_h Z_c     treat_choice `covariates'
 keep hhid Y Z_h Z_c Z_n treat_choice `covariates'

sort hhid
save ehs_data.dta, replace


reg Y Z_h              `covariates', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh

gen D =(treat_choice==2)
reg Y D              `covariates', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D

ivregress 2sls Y (D=Z_h) `covariates', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D

reg Y i.treat_choice `covariates', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_treat_choice


esttab EHS_ols_Zh EHS_ols_D EHS_2sls_D EHS_ols_treat_choice using topi_EHS_jp.tex, b(%5.4f) se(%5.4f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl)

* Create Interactions of Instruments and Covariates.

foreach x of local covariates {
	gen Z_h_`x'   = Z_h*`x'
    gen Z_c_`x'   = Z_c*`x'
    gen Z_n_`x'   = Z_n*`x'
}

* Prepare Data for Multinomial Probit

expand 3
by hhid, sort: gen treat_options = _n
gen choice = (treat_options == treat_choice)
sort hhid treat_options

* Set up to zero the ECE offer Z and its interactions with covariates Z*X in the utility equations for the non-ECE choices.

replace Z_h           = 0 if treat_options == 1|treat_options == 3
foreach x of local covariates {
    replace Z_h_`x'   = 0 if treat_options == 1|treat_options == 3
}

replace Z_c           = 0 if treat_options == 1|treat_options == 2
foreach x of local covariates {
    replace Z_c_`x'   = 0 if treat_options == 1|treat_options == 2
}

*replace Z_n           = 0 if treat_options == 2|treat_options == 3
*foreach x of local covariates {
*    replace Z_n_`x'   = 0 if treat_options == 2|treat_options == 3
*}

replace Z_n           = 0 if treat_options == 1
foreach x of local covariates {
    replace Z_n_`x'   = 0 if treat_options == 1
}


* Set up the data as needed using "cmset" for multinomial probit command.

cmset hhid treat_options

* Set up pattern of standard deviations in Structural Var-Cov Matrix Omega so that the Variances of the two differenced utility errors associated with the two non-base alternatives in the Differenced Var-Cov Matrix Sigma is equal to 1, as in KW(2016, page 1827)

matrix stdpat = J(3, 1, sqrt(0.5))

* First Step Estimate multinomial probit model: using non-participation (j=1) as base alternative and IHDP (j=2) as scale alternative

 cmmprobit choice Z_n* Z_h* Z_c*, casevars(`covariates') basealternative(1) scalealternative(2) stddev(fixed stdpat)
*cmmprobit choice      Z_h* Z_c*, casevars(`covariates') basealternative(1) scalealternative(2) stddev(fixed stdpat)
*cmmprobit choice Z_n* Z_h* , casevars(`covariates') basealternative(1) scalealternative(2) stddev(fixed stdpat)

predict pr_hat, pr
predict psi_hat, xb

gen psi_h_Zi       =  0
gen psi_h_Zi_Zhi_0 =  0
gen psi_h_Zi_Zhi_1 =  0

local Zs "Z_n Z_n_black Z_h Z_h_black Z_c Z_c_black"
local col = 1 

foreach var of local Zs {
	
	if "`var'" == "Z_h" | "`var'"=="Z_h_black" {
	
		if "`var'" == "Z_h" {
			replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * Z_h
			replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * 0
			replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * 1
		}
		
		if "`var'" == "Z_h_black" {			
			replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * Z_h_black
			replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * 0 * black
			replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * 1 * black
		}
	}
		
	else {
		replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * `var'
		replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * `var'
		replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * `var'
	}
	
	local col = `col' + 1
	di `col'	
}

replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * black + e(b)[1,`col'+ 1]
replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * black + e(b)[1,`col'+ 1]
replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * black + e(b)[1,`col'+ 1]

gen psi_hat_Zhi_0 = psi_h_Zi_Zhi_0
gen psi_hat_Zhi_1 = psi_h_Zi_Zhi_1

replace psi_hat_Zhi_0 = -999 if treat_options == 1 | treat_options == 3
replace psi_hat_Zhi_1 = -999 if treat_options == 1 | treat_options == 3

* Structural Representation of Var-Cov "Omega"

estat covariance

* Differenced Representation of Var-Cov "Sigma"

matrix Omega = r(cov)
matrix M = (1,-1,0 \ 1,0,-1)
matrix Sigma = M*Omega*M'
matrix list Sigma
scalar rho = Sigma[2,1]

* Second Step: Construct the 6 Bivariate Mills Ratios

  drop Z_n Z_n* Z_h Z_h* Z_c Z_c* choice `covariates' Y treat_choice psi_h_Zi psi_h_Zi_Zhi_0 psi_h_Zi_Zhi_1
* drop          Z_h Z_h* Z_c Z_c* choice `covariates' Y treat_choice
* drop Z_n Z_n* Z_h Z_h*          choice `covariates' Y treat_choice 
  
reshape wide psi_hat pr_hat psi_hat_Zhi_0 psi_hat_Zhi_1, i( hhid ) j( treat_options )

sort hhid
merge 1:1 hhid using ehs_data.dta
drop   psi_hat1
drop psi_hat_Zhi_01 psi_hat_Zhi_03
drop psi_hat_Zhi_11 psi_hat_Zhi_13
rename psi_hat2 psi_h
rename psi_hat3 psi_c
rename psi_hat_Zhi_02 psi_h_Zhi0
rename psi_hat_Zhi_12 psi_h_Zhi1
drop _merge


* lambda_h(.,.,h)
gen a = psi_h
gen b = (psi_h-psi_c) / sqrt(2*(1-rho))
scalar ksi = sqrt((1-rho)/2)
gen lambda_h_h = (-1)*(-1)*( ( normalden(a)*normal( (b-ksi*a) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal((a-ksi*b) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi))

* lambda_c(.,.,h)
drop a b 
scalar drop ksi
gen a = (psi_h-psi_c) / sqrt(2*(1-rho))
gen b = psi_h
scalar ksi = sqrt((1-rho)/2)
gen lambda_c_h = lambda_h_h + sqrt(2*(1-rho)) * (-1)*( ( normalden(a)*normal( (b-ksi*a) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*b) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_c(.,.,c)
drop a b 
scalar drop ksi
gen a = psi_c
gen b = (psi_c-psi_h) / sqrt(2*(1-rho))
scalar ksi = sqrt((1-rho)/2)
gen lambda_c_c = (-1)*(-1)*( ( normalden(a)*normal( (b-ksi*a) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*b) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_h(.,.,c)
drop a b 
scalar drop ksi
gen a = (psi_c-psi_h) / sqrt(2*(1-rho))
gen b = psi_c
scalar ksi = sqrt((1-rho)/2)
gen lambda_h_c = lambda_c_c + sqrt(2*(1-rho)) * (-1)*( ( normalden(a)*normal( (b-ksi*(a)) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*(b)) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_h(.,.,n)
drop a b 
scalar drop ksi
gen a = -psi_h
gen b = -psi_c
scalar ksi = rho
gen lambda_h_n= (-1)*( ( normalden(a)*normal( (b-ksi*(a)) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*(b)) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_c(.,.,n)
drop a b 
scalar drop ksi
gen a = -psi_c
gen b = -psi_h
scalar ksi = rho
gen lambda_c_n = (-1)*( ( normalden(a)*normal( (b-ksi*(a)) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*(b)) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

scalar drop ksi
drop a b 
drop psi_h

* Third Step: OLS controlling for bi-variate mills ratios.

gen D_n = (treat_choice==1)
gen D_h = (treat_choice==2)
gen D_c = (treat_choice==3)

gen      lambda_c_D = .
replace  lambda_c_D = lambda_c_n if D_n == 1
replace  lambda_c_D = lambda_c_h if D_h == 1
replace  lambda_c_D = lambda_c_c if D_c == 1

gen      lambda_h_D = .
replace  lambda_h_D = lambda_h_n if D_n == 1
replace  lambda_h_D = lambda_h_h if D_h == 1
replace  lambda_h_D = lambda_h_c if D_c == 1



* Norm the covariate vector X (see page 1830 KW(2016))

  foreach x of local covariates{
     su `x' 
	 replace  `x' = `x' - r(mean)
 }

* Generate D_c and D_h interactions with covariates X
 
foreach x of local covariates {
	gen D_c_`x'   = D_c * `x'
    gen D_h_`x'   = D_h * `x'
}

gen D_c_lambda_h_c = D_c * lambda_h_c
gen D_c_lambda_c_c = D_c * lambda_c_c

gen D_h_lambda_h_h = D_h * lambda_h_h
gen D_h_lambda_c_h = D_h * lambda_c_h

 reg Y `covariates' lambda_h_D lambda_c_D D_c D_c_*       D_h D_h_*       , robust

scalar gamma_nh_hat = _b[lambda_h_D]
scalar gamma_nc_hat = _b[lambda_c_D]
scalar gamma_hh_hat = _b[D_h_lambda_h_h] + gamma_nh_hat
scalar gamma_hc_hat = _b[D_h_lambda_c_h] + gamma_nc_hat


*reg Y `covariates' lambda_h_D lambda_c_D D_c D_c_lambda* D_h D_h_lambda* , robust
 
quietly{
noi di as text "Estimated theta_c0-theta_n0 = E[Yc-Yn]: = " _b[D_c]
noi di as text "Estimated theta_c0-theta_n0 = E[Yh-Yn]: = " _b[D_h]
}

scalar theta_c0_theta_n0_hat = _b[D_c]
scalar theta_h0_theta_n0_hat = _b[D_h]
scalar          theta_n0_hat = _b[_cons]
scalar          theta_h0_hat = theta_h0_theta_n0_hat + theta_n0_hat

* SubLATE E[Yh-Yn|n-to-h complier]
* ================================

gen X_theta_hx_hat = 0
gen X_theta_nx_hat = 0

foreach x of local covariates {
	scalar          theta_nx_hat_`x' = _b[`x']
	scalar theta_cx_theta_nx_hat_`x' = _b[D_c_`x']
	scalar theta_hx_theta_nx_hat_`x' = _b[D_h_`x']
	scalar          theta_hx_hat_`x' = theta_hx_theta_nx_hat_`x' - theta_nx_hat_`x'
	replace X_theta_hx_hat = X_theta_hx_hat + `x' * theta_hx_hat_`x'
    replace X_theta_nx_hat = X_theta_nx_hat + `x' * theta_nx_hat_`x'
}


gen a1 = -psi_h_Zhi0
gen b1 = -psi_c
gen a2 = -psi_h_Zhi1
gen b2 = -psi_c

gen   omega_nh_hat = binormal(a1,b1,rho) - binormal(a2,b2,rho)
total omega_nh_hat
scalar sum_omega_nh_hat = e(b)[1,1]
gen weight_nh = omega_nh_hat / sum_omega_nh_hat

drop a1 b1 a2 b2

* Lambda0_hh
gen a0 = -psi_h_Zhi1
gen a1 = -psi_h_Zhi0
gen b0 = -1000000
gen b1 = -psi_c
scalar ksi = rho

gen COMMON_DENOMINATOR = binormal(a1,b1,ksi) - binormal(a1,b0,rho) - binormal(a0,b1,ksi) + 2*binormal(a0,b0,ksi)
gen  FIRST_NUMERATOR   =     normalden(a0)*(normal((b1-ksi*a0) / sqrt(1-(ksi)^2) ) - normal( (1-ksi)*a0  / sqrt(1-(ksi)^2))) -     normalden(a1)*(normal( (b1-ksi*a1) / sqrt(1-(ksi)^2) ) - normal( (b0-ksi*a1) / sqrt(1-(ksi)^2) ) ) 
gen SECOND_NUMERATOR   = ksi*normalden(b0)*(normal((a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b0) / sqrt(1-(ksi)^2))) - ksi*normalden(b1)*(normal( (a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b1) / sqrt(1-(ksi)^2) ) )

gen Lambda0_hh_FIRST   =  FIRST_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_hh_SECOND  = SECOND_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_hh         = Lambda0_hh_FIRST + Lambda0_hh_SECOND

drop a0 a1 b0 b1 FIRST_NUMERATOR SECOND_NUMERATOR COMMON_DENOMINATOR
scalar drop ksi

* Lambda0_hc
gen a0 = -1000000
gen a1 = -psi_c
gen b0 = -psi_h_Zhi1
gen b1 = -psi_h_Zhi0
scalar ksi = rho

gen COMMON_DENOMINATOR = binormal(a1,b1,ksi) - binormal(a1,b0,rho) - binormal(a0,b1,ksi) + 2*binormal(a0,b0,ksi)
gen  FIRST_NUMERATOR   =     normalden(a0)*(normal((b1-ksi*a0) / sqrt(1-(ksi)^2) ) - normal( (1-ksi)*a0  / sqrt(1-(ksi)^2))) -     normalden(a1)*(normal( (b1-ksi*a1) / sqrt(1-(ksi)^2) ) - normal( (b0-ksi*a1) / sqrt(1-(ksi)^2) ) ) 
gen SECOND_NUMERATOR   = ksi*normalden(b0)*(normal((a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b0) / sqrt(1-(ksi)^2))) - ksi*normalden(b1)*(normal( (a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b1) / sqrt(1-(ksi)^2) ) )

gen Lambda0_hc_FIRST   = FIRST_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_hc_SECOND  = SECOND_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_hc = Lambda0_hc_FIRST + Lambda0_hc_SECOND

drop a0 a1 b0 b1 FIRST_NUMERATOR SECOND_NUMERATOR COMMON_DENOMINATOR
scalar drop ksi

* Lambda0_nh
gen Lambda0_nh = Lambda0_hh

* Lambda0_nc
gen Lambda0_nc = Lambda0_hc

gen mu_hat_nh_h_X = theta_h0_hat + X_theta_hx_hat + gamma_hh_hat * Lambda0_hh + gamma_hc_hat * Lambda0_hc
gen mu_hat_nh_n_X = theta_n0_hat + X_theta_nx_hat + gamma_nh_hat * Lambda0_nh + gamma_nc_hat * Lambda0_nc

gen mu_hat_nh_h_X_weight_nh = mu_hat_nh_h_X * weight_nh
total mu_hat_nh_h_X_weight_nh
scalar mu_hat_nh_h = e(b)[1,1]

gen mu_hat_nh_n_X_weight_nh = mu_hat_nh_n_X * weight_nh
total mu_hat_nh_n_X_weight_nh
scalar mu_hat_nh_n = e(b)[1,1]

scalar subLATE_nh = mu_hat_nh_h - mu_hat_nh_n

quietly{
noi di as text "Estimated E[Yh-Yn|n-to-h complier]: =" subLATE_nh
}

