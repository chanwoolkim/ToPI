* --------------------------- *
* Abecedarian - Check subscores
* Author: Chanwool Kim
* Date Created: 14 Apr 2017
* Last Update: 5 Nov 2017
* --------------------------- *

clear all

cd "$data_abc"
use "append-abccare.dta", clear

/*
Summary:
Codebook says 1 is YES and 2 is NO.
However, we observe that there are cases with 0 as a value, and we do not know what it is.
We assume that if an individual started the questionnaire, one finishes it.
Then from exercises below, we conclude the following:

For ages 6m, 18m, 30m, 42m, 54m: ABC has 1 YES 2 NO, and CARE has 1 YES 0 NO
For age 96m, both ABC and CARE have 1 YES 2 NO

For ABC, 2 has been recoded to 0.
Now, ABC has cases with 3 and 0 as values. We treat both of these as NO and recode to 0.
*/

* -------- *
* Age 0 to 3

local age0to3	6 18 30

* Recode 2 to 0, 0 to .
foreach age of local age0to3 {
	foreach n of numlist 1/45 {
		qui replace hs`age'i`n' = . if hs`age'i`n' == 0 | hs`age'i`n' > 2
		qui replace hs`age'i`n' = 0 if hs`age'i`n' == 2
	}
}

* HOME Warmth Scale
foreach age of local age0to3 {
	qui egen home_affect`age' = rowtotal(hs`age'i1-hs`age'i10), mi
}

/*
// Verified that item 11 (praise) NOT included
tab home_affect0y6m, mi
tab home_affect6, mi // 1 different
tab home_affect1y6m, mi
tab home_affect18, mi // match!
tab home_affect2y6m, mi
tab home_affect30, mi // 3 different
*/

* HOME Nonpunitive Scale
foreach age of local age0to3 {
	qui egen home_abspun`age' = rowtotal(hs`age'i12-hs`age'i18), mi
}

/*
// Verified that item 19 (pet) NOT included
tab home_abspun0y6m, mi
tab home_abspun6, mi // match!
tab home_abspun1y6m, mi
tab home_abspun18, mi // match!
tab home_abspun2y6m, mi
tab home_abspun30, mi // 3 different
*/

* HOME Organization of Environment
foreach age of local age0to3 {
	qui egen home_orgenv`age' = rowtotal(hs`age'i20-hs`age'i25), mi
}

/*
tab home_orgenv0y6m, mi
tab home_orgenv6, mi // match!
tab home_orgenv1y6m, mi
tab home_orgenv18, mi // match!
tab home_orgenv2y6m, mi
tab home_orgenv30, mi // match!
*/

* HOME Appropriate Play Materials
foreach age of local age0to3 {
	qui egen home_toys`age' = rowtotal(hs`age'i26-hs`age'i34), mi
}

/*
tab home_toys0y6m, mi
tab home_toys6, mi // 2 different
tab home_toys1y6m, mi
tab home_toys18, mi // match!
tab home_toys2y6m, mi
tab home_toys30, mi // 1 different
*/

* HOME Maternal Involvement
foreach age of local age0to3 {
	qui egen home_minvol`age' = rowtotal(hs`age'i35-hs`age'i40), mi
}

/*
tab home_minvol0y6m, mi
tab home_minvol6, mi // 6 different
tab home_minvol1y6m, mi
tab home_minvol18, mi // 7 different
tab home_minvol2y6m, mi
tab home_minvol30, mi // 7 different
*/

* HOME Opportunities for Variety
foreach age of local age0to3 {
	qui egen home_oppvar`age' = rowtotal(hs`age'i41-hs`age'i45), mi
}

/*
tab home_oppvar0y6m, mi
tab home_oppvar6, mi // 1 different
tab home_oppvar1y6m, mi
tab home_oppvar18, mi // match!
tab home_oppvar2y6m, mi
tab home_oppvar30, mi // match!
*/

* -------- *
* Age 3 to 6

local age3to6	42 54

* Recode 2 to 0, 0 to .
foreach age of local age3to6 {
	foreach n of numlist 1/80 {
		qui replace hs`age'i`n' = . if hs`age'i`n' == 0 | hs`age'i`n' > 2
		qui replace hs`age'i`n' = 0 if hs`age'i`n' == 2
	}
}

* HOME Stimulation through Equipment, Toys, and Experiences
foreach age of local age3to6 {
	qui egen home_exper`age' = rowtotal(hs`age'i1-hs`age'i21), mi
}

/*
tab home_exper3y6m, mi
tab home_exper42, mi // match!
tab home_exper4y6m, mi
tab home_exper54, mi // match!
*/

* HOME Stimulation of Mature Behavior
foreach age of local age3to6 {
	qui egen home_mature`age' = rowtotal(hs`age'i22-hs`age'i33), mi
}

/*
tab home_mature3y6m, mi
tab home_mature42, mi // 1 different
tab home_mature4y6m, mi
tab home_mature54, mi // match!
*/

* HOME Physical and Language Environment
foreach age of local age3to6 {
	qui egen home_phyenv`age' = rowtotal(hs`age'i34-hs`age'i45), mi
}

/*
// Codebook says item 45 excluded, but it is actually included
tab home_phyenv3y6m, mi
tab home_phyenv42, mi // 1 different
tab home_phyenv4y6m, mi
tab home_phyenv54, mi // match!
*/

* HOME Avoidance of Restriction and Punishment
foreach age of local age3to6 {
	qui egen home_abspun`age' = rowtotal(hs`age'i46-hs`age'i52), mi
}

/*
// Codebook says item 51 and 52 excluded, but they are actually included
tab home_abspun3y6m, mi
tab home_abspun42, mi // match!
tab home_abspun4y6m, mi
tab home_abspun54, mi // match!
*/

* HOME Pride, Affection, and Thoughtfulness
foreach age of local age3to6 {
	qui egen home_affect`age' = rowtotal(hs`age'i53-hs`age'i68), mi
}

/*
// Codebook says item 53-59 excluded, but they are actually included
tab home_affect3y6m, mi
tab home_affect42, mi // 1 different
tab home_affect4y6m, mi
tab home_affect54, mi // match!
*/

* HOME Masculine Stimulation
foreach age of local age3to6 {
	qui egen home_masc`age' = rowtotal(hs`age'i69-hs`age'i73), mi
}

/*
tab home_masc3y6m, mi
tab home_masc42, mi // match!
tab home_masc4y6m, mi
tab home_masc54, mi // match!
*/

* HOME Independence from Parental Control
foreach age of local age3to6 {
	qui egen home_indep`age' = rowtotal(hs`age'i74-hs`age'i80), mi
}

/*
tab home_indep3y6m, mi
tab home_indep42, mi // 1 different
tab home_indep4y6m, mi
tab home_indep54, mi // match!
*/

* --- *
* Age 8

* Recode 2 to 0, 0 to .
foreach n of numlist 1/85 {
	qui replace hsepi`n' = . if hsepi`n' == 0 | hsepi`n' > 2
	qui replace hsepi`n' = 0 if hsepi`n' == 2
}

* HOME Organization of a Stable and Predictable Environment
qui egen home_orgenv96 = rowtotal(hsepi1-hsepi6), mi

/*
tab home_orgenv8y, mi
tab home_orgenv96, mi // match!
*/

* HOME Developmental Stimulation
qui egen home_devstm96 = rowtotal(hsepi7-hsepi20), mi

/*
tab home_devstm8y, mi
tab home_devstm96, mi // match!
*/

* HOME Quality of Language Environment
qui egen home_leng96 = rowtotal(hsepi21-hsepi30), mi

/*
tab home_leng8y, mi
tab home_leng96, mi // match!
*/

* HOME Need Gratification and Avoidance of Restriction
qui egen home_absrst96 = rowtotal(hsepi31-hsepi33), mi

/*
tab home_absrst8y, mi
tab home_absrst96, mi // match!
*/

* HOME Fostering Maturity and Independence
qui egen home_indep96 = rowtotal(hsepi34-hsepi48), mi

/*
tab home_indep8y, mi
tab home_indep96, mi // match!
*/

* HOME Emotional Climate
qui egen home_emotin96 = rowtotal(hsepi49-hsepi54), mi

/*
tab home_emotin8y, mi
tab home_emotin96, mi // match!
*/

* HOME Breadth of Experience
qui egen home_oppvar96 = rowtotal(hsepi55-hsepi64), mi

/*
tab home_oppvar8y, mi
tab home_oppvar96, mi // match!
*/

* HOME Aspects of Physical Environment
qui egen home_phyenv96 = rowtotal(hsepi65-hsepi80), mi

/*
tab home_phyenv8y, mi
tab home_phyenv96, mi // match!
*/

* HOME Play Materials
qui egen home_toys96 = rowtotal(hsepi81-hsepi85), mi

/*
tab home_toys8y, mi
tab home_toys96, mi // match!
*/
