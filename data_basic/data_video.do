* ---------------------------------- *
* Preliminary data preparation - video
* Author: Chanwool Kim
* ---------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

rename pbehav_int3	video_intrusive36
rename pbehav_neg3	video_negative36
rename B3V3PDET		video_detach36
rename B3V3CENG		video_engage36
rename c_attent3	video_attention36
rename c_pers3_neg	video_negative_parent36
rename pbehav_sup3	video_support36

keep id treat video_*

cd "$data_working"
save ehs-video, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_raw"
use "base-ihdp.dta", clear

rename ihdp			id

rename f73v1a_post3_070320	video_support36
rename f73v1b_post3_070320	video_assist36
rename f74v1a_post3_070320	video_persist36
rename f74v2a_post3_070320	video_enthusiasm36

keep id video_*

cd "$data_working"
save ihdp-video, replace

* ------ *
* ABC/CARE

cd "$data_raw"
use "append-abccare.dta", clear

rename mutpy36d		video_mutual_play36
rename mread36d		video_read36
rename mutrd36d		video_mutual_read36
rename cplya36d		video_play_alone36
rename mtoya36d		video_mother_toy_alone36

keep id treat program video_*

cd "$data_working"
save abc-video, replace
