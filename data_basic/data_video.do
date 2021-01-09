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

rename B3VPCENG		video_puzzle_engage36
rename B3VPPQ_A		video_puzzle_assistance36
rename B3VPPSUP		video_puzzle_support36
rename B3VPPDET		video_puzzle_detach36

factor video_support36 video_detach36 video_negative36 ///
video_puzzle_engage36 video_puzzle_assistance36 ///
video_puzzle_support36 video_puzzle_detach36
predict video_factor3y

*AH 2018*: get a few more variables, hard to construct them from Harvard dataset:
rename home_tot4	home_total4y
rename home_tot5	home_total10y
rename home_warm4	home_warm4y
rename B5HMWARM		home_warm10y
rename B5HMLCHO		home_host10y
rename B5HMVERB		home_verb10y
rename home_learn4	home_cog4y
rename home_inenviro5	home_inenviro10y
rename home_phys4	home_exenviro4y
rename home_enviro5	home_exenviro10y
rename *4y	*48
rename *10y	*120
local ehs_home_types	total cog exenviro harsh host inenviro nonpun verb warm
* Normalise to have in-group sample mean 0 and variance 1
foreach t of local ehs_home_types {
	foreach m of numlist 14 24 36 48 120 {
	capture egen norm_home_`t'`m' = std(home_`t'`m')
	}
}

keep id treat video_* ///
home_exenviro48 home_cog48										home_warm48					home_total48  ///
home_exenviro120 home_inenviro120  home_verb120 home_host120 	home_warm120 home_total120  home_total120 

cd "$data_working"
save ehs-video, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_raw"

*CHANGED FROM CHANWOOL'S TO THE ORIGINAL SOURCE W ALL DATA
*use "base-ihdp.dta", clear
*rename ihdp			id
*rename f73v1a_post3_070320	video_support36
*rename f73v1b_post3_070320	video_assist36
*rename f74v1a_post3_070320	video_persist36
*rename f74v2a_post3_070320	video_enthusiasm36
*keep id video_*

use "nspi7.dta", clear
rename ihdp			id
rename f73v1a video_support36
rename f73v1b video_assist36
rename f74v1a video_persist36
rename f74v2a video_enthusiasm36
rename f74v7a video_mutuality36
factor video_support36 video_assist36 video_mutuality36
predict video_factor3y
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

factor video_mutual_play36 video_mutual_read36 video_play_alone36
predict video_factor3y
keep id treat program video_*

cd "$data_working"
save abc-video, replace
