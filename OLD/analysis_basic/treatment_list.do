* ----------------------- *
* List of treatment effects
* Author: Chanwool Kim
* ----------------------- *

clear all

* - *
* EHS

cd "$data_working"
use "ehs-merge.dta", clear

* Price for income effect
reg price_care26 R $covariates if !missing(D)

* Video
local ehs_video_type	intrusive negative detach engage attention negative_parent support

foreach t of local ehs_video_type {
	reg video_`t'36 R $covariates if !missing(D)
}

* KIDI
reg kidi_total24 R $covariates if !missing(D)

* Attention/Cooperation
reg bayley_engagement36 R $covariates if !missing(D)
reg bayley_emotion36 R $covariates if !missing(D)

* -- *
* IHDP

cd "$data_working"
use "ihdp-merge.dta", clear

* Price for income effect
reg price_care36 R $covariates if !missing(D)

* Video
local ihdp_video_type	support assist persist enthusiasm

foreach t of local ihdp_video_type {
	reg video_`t'36 R $covariates if !missing(D)
}

* KIDI
reg kidi_accuracy24 R $covariates if !missing(D)

* Attention test behavior
forvalues i = 11/23 {
	reg v`i'_f62 R $covariates if !missing(D)
}

* - *
* ABC

cd "$data_working"
use "abc-merge.dta", clear

* Video
local abc_video_type	mutual_play read mutual_read play_alone mother_toy_alone

foreach t of local abc_video_type {
	reg video_`t'36 R $covariates if !missing(D)
}

* Parent's interest in spending time with child
reg parent_disinterest96 R $covariates if !missing(D)
reg parent_irritable96 R $covariates if !missing(D)

* Kohn-Rosman
local abc_kr_type		confidence withdrawn attentive distractible

foreach t of local abc_kr_type {
	reg kr_`t'36 R $covariates if !missing(D)
}

* -- *
* CARE

cd "$data_working"
use "careboth-merge.dta", clear

* KIDI
reg kidi_accuracy30 R $covariates if !missing(D)

cd "$data_working"
use "carehome-merge.dta", clear

* KIDI
reg kidi_accuracy30 R $covariates if !missing(D)
