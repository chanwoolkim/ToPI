* ---------------------------------- *
* Preliminary data preparation - video
* Author: Chanwool Kim
* ---------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

rename pbehav_sup3	video_parent_support_3bag36
rename B3V3PDET		video_parent_detach_3bag36
rename B3VPCENG		video_child_engagement_puzzle36
rename B3VPPQ_A		video_parent_assistance_puzzle36
rename B3VPPSUP		video_parent_support_puzzle36
rename B3VPPDET		video_parent_detach_puzzle36
rename B3V3CENG		video_child_engagement_3bag36 //measures interaction

rename pbehav_neg3	video_parent_negative_3bag36 //not ivestment
rename c_attent3	video_child_attention_3bag36 //not investment: child-only
rename c_pers3_neg	video_child_negative_3bag36 //not investment: child-only
rename pbehav_int3	video_parent_intrusive_3bag36 //does not indiicate less investment 
rename B3VPPINT		video_parent_intrusive_puzzle36 //does not indiicate less investment 
rename B3VPCPER		video_child_persistence_puzzle36 //not investment: child-only
rename B3VPCFRU		video_child_frustration_puzzle36 //not investment: child-only

factor video_parent_support_3bag36 video_parent_detach_3bag36 ///
video_child_engagement_puzzle36 video_parent_assistance_puzzle36 ///
video_parent_support_puzzle36 video_parent_detach_puzzle36 ///
video_child_engagement_3bag36
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
use "nspi7.dta", clear
rename ihdp			id
rename f73v1a video_support36 //Box Rake
rename f73v1b video_assist36 //Box Rake
rename f74v1a video_persist36 //Child
rename f74v2a video_enthusiasm36 //Child
rename f74v7a video_mutuality36 // Dyad
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
*rename mread36d	video_mother_reads_alone36
rename mutrd36d		video_mutual_read36
*rename cplya36d		video_play_alone36
*rename mtoya36d		video_mother_toy_alone36

factor video_mutual_play36 video_mutual_read36
predict video_factor3y
keep id treat program video_*

cd "$data_working"
save abc-video, replace
