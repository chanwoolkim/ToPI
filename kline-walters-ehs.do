clear all
use "C:\Users\jpanta\Dropbox\TOPI\working\juan_ehs.dta"

* Basic Data Clean-Up
keep id ppvt3y R sitenum m_edu m_iq m_age black bw sex ehs alt

drop if  ppvt3y == .
drop if       R == .
drop if   m_edu == .
drop if   m_age == .
drop if    m_iq == .
drop if     sex == .
drop if     ehs == .
drop if sitenum == .
drop if   black == .
drop if      bw == .
drop if     alt == .

drop if m_edu!=1 & m_edu!=2 & m_edu!=3

rename R       Z
rename ppvt3y  Y
rename id      hhid
gen     treat_choice = .
replace treat_choice = 1 if ehs==1
replace treat_choice = 2 if alt==1
replace treat_choice = 3 if alt==0 & ehs==0

gen site_06 = (sitenum==6)
gen site_09 = (sitenum==9)
gen site_11 = (sitenum==11)
gen site_14 = (sitenum==14)

drop ehs alt sitenum

*replace m_edu = 0 if m_edu==1|m_edu==2
*replace m_edu = 1 if m_edu==3

gen m_edu_lessHS = (m_edu == 1)
gen m_edu_HS     = (m_edu == 2)
gen m_edu_moreHS = (m_edu == 3)


local covariates "black m_edu_moreHS site_06 site_09 site_11"
 
*local covariates "                 black    site_09 site_11 site_14"
*local covariates "m_iq       m_age       bw                        "

* Norm the covariate vector X (see page 1830 KW(2016))

*  foreach x of local covariates{
*     egen mean_`x' = mean (`x')
*	  replace  `x' = `x' - mean_`x'
* }

* Recode treat_choice so that category are such that category 1 which will be assigned as baseline category is the "None" alternative (currently "None" is given code 3) Category 2 which  will be assigned as scale alternative is the "IHDP" alternative (currently IHDP is give code 2) and Category 3 which is the "Other" alternative (Currently "Other" is given code 2)

rename  treat_choice treat_choice_old
gen     treat_choice = treat_choice_old
replace treat_choice = 1 if treat_choice_old==3
replace treat_choice = 2 if treat_choice_old==1
replace treat_choice = 3 if treat_choice_old==2

label define lbltreatchoice 1 "None" 2 "EHS" 3 "Other"
label values treat_choice lbltreatchoice

keep hhid Y Z treat_choice `covariates'
sort hhid
save ehs_data.dta, replace

* Create Interactions of Instruments and Covariates.

*foreach x of local covariates {
*	gen Z_`x'   = Z*`x'
*}

gen Z_m_edu_moreHS   = Z*m_edu_moreHS

* Prepare Data for Multinomial Probit

expand 3
by hhid, sort: gen treat_options = _n
gen choice = (treat_options == treat_choice)
sort hhid treat_options

* Set up to zero the IHDP offer Z and its interactions with covariates Z*X in the utility equations for the non-IHDP choices.

replace Z           = 0 if treat_options == 1|treat_options == 3
*foreach x of local covariates {
*    replace Z_`x'   = 0 if treat_options == 1|treat_options == 3
*}
replace Z_m_edu_moreHS = 0 if treat_options == 1|treat_options == 3


* Set up the data as needed using "cmset" for multinomial probit command.

cmset hhid treat_options

* Set up pattern of standard deviations in Structural Var-Cov Matrix Omega so that the Variances of the two differenced utility errors associated with the two non-base alternatives in the Differenced Var-Cov Matrix Sigma is equal to 1, as in KW(2016, page 1827)

matrix stdpat = J(3, 1, sqrt(0.5))

* First Step Estimate multinomial probit model: using non-participation (j=1) as base alternative and IHDP (j=2) as scale alternative

cmmprobit choice Z Z_*, casevars(`covariates') basealternative(1) scalealternative(2) stddev(fixed stdpat)

predict psi_hat, xb
predict pr_hat, pr

* Structural Representation of Var-Cov "Omega"

estat covariance

* Differenced Representation of Var-Cov "Sigma"

matrix Omega = r(cov)
matrix M = (1,-1,0 \ 1,0,-1)
matrix Sigma = M*Omega*M'
matrix list Sigma
scalar rho = Sigma[2,1]

* Second Step: Construct the 6 Bivariate Mills Ratios

drop Z Z_* choice `covariates' Y treat_choice
reshape wide psi_hat pr_hat, i( hhid ) j( treat_options )
sort hhid
merge 1:1 hhid using ehs_data.dta
drop   psi_hat1
rename psi_hat2 psi_h
rename psi_hat3 psi_c
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
drop psi_c psi_h

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

* Generate D_c and D_h interactions with covariates X

* Norm the covariate vector X (see page 1830 KW(2016))

  foreach x of local covariates{
     su `x' 
	 replace  `x' = `x' - r(mean)
 }

 
foreach x of local covariates {
	gen D_c_`x'   = D_c * `x'
    gen D_h_`x'   = D_h * `x'
}

gen D_c_lambda_h_c = D_c * lambda_h_c
gen D_c_lambda_c_c = D_c * lambda_c_c

gen D_h_lambda_h_h = D_h * lambda_h_h
gen D_h_lambda_c_h = D_h * lambda_c_h

reg Y `covariates' lambda_h_D lambda_c_D D_c D_c_* D_h D_h_* , robust

reg Y `covariates' lambda_h_D lambda_c_D D_c D_c_lambda* D_h D_h_lambda* , robust


n --> -.2655901
h -->  .1389282
c -->  .8344734

* E[y(h)-y(n)] =  .1389282 - (-.2655901) =  .4045183
* E[y(c)-y(n)] =  .8344734 - (-.2655901) = 1.1000635






