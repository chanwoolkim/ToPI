* ------------------------------------- *
* Graphs of treatment effects - item pile
* Author: Chanwool Kim
* Date Created: 5 Jun 2017
* Last Update: 5 Nov 2017
* ------------------------------------- *

clear all

* ------------ *
* Prepare matrix

foreach p of global programs {

cd "$data_home"
use "`p'-home-item-pile.dta", clear

* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
qui matrix `p'R_1 = J(55, 5, .) // for randomisation variable
qui matrix `p'R_3 = J(55, 5, .) // for randomisation variable

qui matrix colnames `p'R_1 = `p'R_1num `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
qui matrix colnames `p'R_3 = `p'R_3num `p'R_3coeff `p'R_3lower `p'R_3upper `p'R_3pval

	* Loop over rows to fill in values into the empty matrix.
	forvalues r = 1/45 {
		qui matrix `p'R_1[`r',1] = `r'
		
		capture confirm variable home1_`r'
			if !_rc {
			* Randomisation variable
			qui regress home1_`r' R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix `p'R_1[`r',2] = r[1,1]
			qui matrix `p'R_1[`r',3] = r[5,1]
			qui matrix `p'R_1[`r',4] = r[6,1]
			qui matrix `p'R_1[`r',5] = r[4,1]
			}
	}

	* Loop over rows to fill in values into the empty matrix.
	forvalues r = 1/55 {
		qui matrix `p'R_3[`r',1] = `r'
		
		capture confirm variable home3_`r'
			if !_rc {
			* Randomisation variable
			qui regress home3_`r' R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix `p'R_3[`r',2] = r[1,1]
			qui matrix `p'R_3[`r',3] = r[5,1]
			qui matrix `p'R_3[`r',4] = r[6,1]
			qui matrix `p'R_3[`r',5] = r[4,1]
			}
	}
		
cd "${pile_path}/working"

svmat `p'R_1, names(col)
rename `p'R_1num row_1
keep row_1 `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
keep if row_1 != .
save "`p'-pile-item-1", replace

svmat `p'R_3, names(col)
rename `p'R_3num row_3
keep row_3 `p'R_3coeff `p'R_3lower `p'R_3upper `p'R_3pval
keep if row_3 != .
save "`p'-pile-item-3", replace
}

cd "${pile_path}/working"

use ehscenter-pile-item-1, clear

foreach p of global programs {
	merge 1:1 row_1 using `p'-pile-item-1, nogen nolabel
}

rename row_1 row
save item-pile-1, replace

use ehscenter-pile-item-3, clear

foreach p of global programs {
	merge 1:1 row_3 using `p'-pile-item-3, nogen nolabel
}

rename row_3 row
save item-pile-3, replace

* --------*
* Questions

cd "${pile_path}/working"

use item-pile-1, clear
tostring row, gen(question)
gen scale = question

replace scale = "Activities/Outings" if question == "21" | question == "22" |  question == "23"
replace scale = "Developmental Advance" if question == "37" | question == "38" |  question == "39" |  question == "40"
replace scale = "Learning/Literacy" if question == "18" | question == "26" |  question == "27" |  question == "29" |  question == "30" |  question == "31" |  question == "33" |  question == "34" |  question == "42" |  question == "45"
replace scale = "Parental Lack of Hostility" if question == "12" | question == "13" |  question == "14" |  question == "16" |  question == "17"
replace scale = "Parental Verbal Skills" if question == "4" | question == "5" |  question == "6"
replace scale = "Parental Warmth" if question == "1" | question == "2" |  question == "3" |  question == "8" |  question == "9" |  question == "10" |  question == "11"
replace scale = "N/S" if question == "7" | question == "15" |  question == "19" |  question == "20" |  question == "24" |  question == "25" |  question == "28" | question == "32" |  question == "35" |  question == "36" |  question == "41" |  question == "43" |  question == "44"

gen scale_row = .
replace scale_row = 2 if scale == "Parental Warmth"
replace scale_row = 3 if scale == "Parental Verbal Skills"
replace scale_row = 4 if scale == "Parental Lack of Hostility"
replace scale_row = 5 if scale == "Learning/Literacy"
replace scale_row = 6 if scale == "Activities/Outings"
replace scale_row = 7 if scale == "Developmental Advance"
replace scale_row = 8 if scale == "N/S"

replace question = "Parent spontaneously vocalized to child twice" if question == "1"
replace question = "Parent responds verbally to child's verbalization" if question == "2"
replace question = "Parent tells child name of object or person during visit" if question == "3"
replace question = "Parent's speech is distinct and audible" if question == "4"
replace question = "Parent initiates verbal exchanges with visitor" if question == "5"
replace question = "Parent converses freely and easily" if question == "6"
replace question = "Parent permits child to engage in messy play" if question == "7"
replace question = "Parent spontaneously praises child at least twice" if question == "8"
replace question = "Parent's voice conveys positive feelings towards child" if question == "9"
replace question = "Parent caresses or kisses child at least once" if question == "10"
replace question = "Parent responds positively to praise of child offered by visitor" if question == "11"
replace question = "Parent does not shout at child" if question == "12"
replace question = "Parent does not express annoyance with or hostility to child" if question == "13"
replace question = "Parent neither slaps nor spanks child during visit" if question == "14"
replace question = "No more than one instance of physical punishment during past week" if question == "15"
replace question = "Parent does not scold or criticize child during visit" if question == "16"
replace question = "Parent does not interfere or restrict child more than 3 times" if question == "17"
replace question = "At least ten books are present & visible" if question == "18"
replace question = "Family has a pet" if question == "19"
replace question = "Substitute care is provided by one of 3 regular substitutes" if question == "20"
replace question = "Child is taken to grocery store at least once/week" if question == "21"
replace question = "Child gets out of house at least 4 times/week" if question == "22"
replace question = "Child is taken regularly to doctor's office or clinic" if question == "23"
replace question = "Child has a special place for toys and treasures" if question == "24"
replace question = "Child's play environment is safe" if question == "25"
replace question = "Muscle activity toys or equipment" if question == "26"
replace question = "Push or pull toy" if question == "27"
replace question = "Stroller or walker, kiddie car, scooter, or tricycle" if question == "28"
replace question = "Parent provides toys for child during visit" if question == "29"
replace question = "Learning equipment appropriate to age - cuddly toys or role-playing toys" if question == "30"
replace question = "Learning facilitator - mobile, table and chairs, high chair, play pen" if question == "31"
replace question = "Simple eye-hand coordination toys" if question == "32"
replace question = "Complex eye-hand coordination toys (those permitting combination)" if question == "33"
replace question = "Toys for literature and music" if question == "34"
replace question = "Parent keeps child in visual range, looks at often" if question == "35"
replace question = "Parent talks to child while doing household work" if question == "36"
replace question = "Parent consciously encourages developmental advance" if question == "37"
replace question = "Parent invests maturing toys with value via personal attention" if question == "38"
replace question = "Parent structures child's play periods" if question == "39"
replace question = "Parent provides toys that challenge child to develop new skills" if question == "40"
replace question = "Father provides some care daily" if question == "41"
replace question = "Parent reads stories to child at least 3 times weekly" if question == "42"
replace question = "Child eats at least one meal per day with mother and father" if question == "43"
replace question = "Family visits relatives or receives visits once a months or so" if question == "44"
replace question = "Child has 3 or more books of his/her own" if question == "45"

save item-pile-1, replace

use item-pile-3, clear
tostring row, gen(question)
gen scale = question

replace scale = "Access to Reading" if question == "7" | question == "8" |  question == "9" |  question == "10" |  question == "13"
replace scale = "Home Exterior" if question == "19" | question == "20" |  question == "22"
replace scale = "Home Interior" if question == "21" |  question == "23" |  question == "24" |  question == "25"
replace scale = "Learning Stimulation" if question == "1" | question == "2" |  question == "3" |  question == "4" |  question == "5" |  question == "6" |  question == "11" | question == "12" |  question == "33" |  question == "34" |  question == "35" |  question == "36" |  question == "37"|  question == "43"
replace scale = "Outings/Activities" if question == "44" | question == "45" |  question == "46"
replace scale = "Parental Lack of Hostility" if question == "52" | question == "53" |  question == "54"
replace scale = "Parental Verbal Skills" if question == "15" | question == "48"
replace scale = "Parental Warmth" if question == "16" | question == "17" |  question == "26" |  question == "27" |  question == "28" |  question == "29" |  question == "30" | question == "31" |  question == "32"
replace scale = "N/S" if question == "14" | question == "18" |  question == "38" |  question == "39" |  question == "40" |  question == "41" |  question == "42" | question == "47" |  question == "49" |  question == "50" |  question == "51" |  question == "55"

gen scale_row = .
replace scale_row = 2 if scale == "Learning Stimulation"
replace scale_row = 3 if scale == "Access to Reading"
replace scale_row = 4 if scale == "Parental Verbal Skills"
replace scale_row = 5 if scale == "Parental Warmth"
replace scale_row = 6 if scale == "Home Exterior"
replace scale_row = 7 if scale == "Home Interior"
replace scale_row = 8 if scale == "Outings/Activities"
replace scale_row = 9 if scale == "Parental Lack of Hostility"
replace scale_row = 10 if scale == "N/S"

replace question = "Toys that teach color, size, shape" if question == "1"
replace question = "Three or more puzzles" if question == "2"
replace question = "Record player and >5 children's records" if question == "3"
replace question = "Child has toys permitting free expression" if question == "4"
replace question = "Child has toys or games requiring refined movements" if question == "5"
replace question = "Child has toys or games which help teach numbers" if question == "6"
replace question = "Child has at least 10 children's books" if question == "7"
replace question = "At least 10 books are visible in the apartment" if question == "8"
replace question = "Family buys and reads a daily newspaper" if question == "9"
replace question = "Family subscribes to at least one magazine" if question == "10"
replace question = "Child is encouraged to learn shapes" if question == "11"
replace question = "Child has toys that help teach the names of animals" if question == "12"
replace question = "Child is encouraged to learn the alphabet" if question == "13"
replace question = "Parent teaches child simple verbal manners" if question == "14"
replace question = "Mother uses correct grammar and pronunciation" if question == "15"
replace question = "Parent encourages child to talk and takes time to listen" if question == "16"
replace question = "Parent's voice conveys positive feelings to child" if question == "17"
replace question = "Child is permitted choice in breakfast or lunch menu" if question == "18"
replace question = "Building appears safe" if question == "19"
replace question = "Outside play environment appears safe" if question == "20"
replace question = "Interior of apartment not dark or perceptually monotonous" if question == "21"
replace question = "Neighborhood is aesthetically pleasing" if question == "22"
replace question = "House has 100 sq. ft. of living space per person" if question == "23"
replace question = "Rooms are not overcrowded with furniture" if question == "24"
replace question = "House is reasonably clean and minimally cluttered" if question == "25"
replace question = "Parent holds child close 10-15 minutes per day" if question == "26"
replace question = "Parent converses with child at least twice during visit" if question == "27"
replace question = "Parent answers child's questions or requests verbally" if question == "28"
replace question = "Parent usually responds to child's speech" if question == "29"
replace question = "Parent spontaneously praises child's qualities twice during visit" if question == "30"
replace question = "Parent caresses, kisses, or cuddles child during visit" if question == "31"
replace question = "Parent helps child demonstrate some achievement during visit" if question == "32"
replace question = "Child is encouraged to learn colors" if question == "33"
replace question = "Child is encouraged to learn patterned speech (songs, etc.)" if question == "34"
replace question = "Child is encouraged to learn spatial relationships" if question == "35"
replace question = "Child is encouraged to learn numbers" if question == "36"
replace question = "Child is encouraged to learn to read a few words" if question == "37"
replace question = "Some delay of food gratification is expected" if question == "38"
replace question = "TV is used judiciously" if question == "39"
replace question = "Parent introduces visitor to child" if question == "40"
replace question = "Child can express negative feelings without reprisal" if question == "41"
replace question = "Child can hit parent without harsh reprisal" if question == "42"
replace question = "Child has real or toy musical instrument" if question == "43"
replace question = "Child is taken on outing by family member at least every other week" if question == "44"
replace question = "Child has been on trip more than 50 miles during last year" if question == "45"
replace question = "Child has been taken to a museum during past year" if question == "46"
replace question = "Parent encourages child to put away toys without help" if question == "47"
replace question = "Parent uses complex sentences structure and vocabulary" if question == "48"
replace question = "Child's art work is displayed some place in house" if question == "49"
replace question = "Child eats at least one meal per day with mother and father" if question == "50"
replace question = "Parent lets child choose some foods or brands at grocery store" if question == "51"
replace question = "Parent does not scold or derogate child more than once" if question == "52"
replace question = "Parent does not physical restraint during visit" if question == "53"
replace question = "Parent neither slaps nor spanks child during visit" if question == "54"
replace question = "No more than once instance of physical punishment during past week" if question == "55"

save item-pile-3, replace

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	cd "${pile_path}/working"
	use item-pile-`age', clear
	
	foreach p of global programs {
		gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
		gen `p'Rinsig = .
		gen `p'R0_1 = .
		gen `p'R0_05 = .
		gen `p'R0_01 = .
		replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
		replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05 & `p'R_`age'pval > 0.01
		replace `p'R0_01 = `p'R_`age'coeff if `p'R_`age'pval <= 0.01
	}
	
	cd "${pile_path}/out"

	graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ehscenterR0_01 ///
			  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ehshomeR0_01 ///
			  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05 ehsmixedR0_01 ///
			  ihdphighRinsig ihdphighR0_1 ihdphighR0_05 ihdphighR0_01 ///
			  ihdplowRinsig ihdplowR0_1 ihdplowR0_05 ihdplowR0_01 ///
			  abcRinsig abcR0_1 abcR0_05 abcR0_01 ///
			  carebothRinsig carebothR0_1 carebothR0_05 carebothR0_01 ///
			  carehvRinsig carehvR0_1 carehvR0_05 carehvR0_01, ///
	marker(1,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
	marker(3,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
	marker(5,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
	marker(7,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
	marker(9,msize(small) msymbol(S) mlc(red) mfc(red*0.05) mlw(vthin)) marker(10,msize(small) msymbol(S) mlc(red) mfc(red*0.5) mlw(vthin)) ///
	marker(11,msize(small) msymbol(S) mlc(red) mfc(red*0.75) mlw(vthin)) marker(12,msize(small) msymbol(S) mlc(red) mfc(red) mlw(vthin)) ///
	marker(13,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
	marker(15,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
	marker(17,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
	marker(19,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
	marker(21,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
	marker(23,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
	marker(25,msize(small) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(26,msize(small) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
	marker(27,msize(small) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(28,msize(small) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
	marker(29,msize(small) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(30,msize(small) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
	marker(31,msize(small) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(32,msize(small) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
	over(question, label(labsize(tiny)) sort(scale_row)) ///
	legend (order (4 "EHS-Center" 8 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-High" 20 "IHDP-Low" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ysize(11) xsize(8.5) graphregion(fcolor(white))

	graph export "item_pile_R_`age'.pdf", replace
}
