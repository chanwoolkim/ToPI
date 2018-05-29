* -------------------------------------------- *
* Graphs of treatment effects - parent item pile
* Author: Chanwool Kim
* -------------------------------------------- *

clear all

* ------------ *
* Prepare matrix

* IHDP - KIDI
local 1_row = 19
local 2_row = 17

foreach age of numlist 1 2 {

	cd "$data_analysis"
	use "ihdp-parent-pile.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix ihdpR_`age' = J(``age'_row', 5, .) // for randomisation variable

	qui matrix colnames ihdpR_`age' = ihdpR_`age'num ihdpR_`age'coeff ihdpR_`age'lower ihdpR_`age'upper ihdpR_`age'pval

	local row_`age' = 1

	* Loop over rows to fill in values into the empty matrix.

	forvalues r = 1/``age'_row' {
		qui matrix ihdpR_`age'[`row_`age'',1] = `row_`age''

		capture confirm variable kidi`age'y_`r'
		if !_rc {
			* Randomisation variable
			qui regress kidi`age'y_`r' R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix ihdpR_`age'[`row_`age'',2] = r[1,1]
			qui matrix ihdpR_`age'[`row_`age'',3] = r[5,1]
			qui matrix ihdpR_`age'[`row_`age'',4] = r[6,1]
			qui matrix ihdpR_`age'[`row_`age'',5] = r[4,1]

			local row_`age' = `row_`age'' + 1
		}

		else {
			local row_`age' = `row_`age'' + 1
		}
	}

	svmat ihdpR_`age', names(col)
	rename ihdpR_`age'num row_`age'
	keep row_`age' ihdpR_`age'coeff ihdpR_`age'lower ihdpR_`age'upper ihdpR_`age'pval
	keep if row_`age' != .
	save "ihdp-pile-kidi-`age'", replace
}

cd "$data_analysis"

use ihdp-pile-kidi-1, clear
rename row_1 row
save ihdp-kidi-pile-1, replace

use ihdp-pile-kidi-2, clear
rename row_2 row
save ihdp-kidi-pile-2, replace

* IHDP - Sameroff
local 1_row = 20
local 3_row = 20

foreach age of numlist 1 3 {

	cd "$data_analysis"
	use "ihdp-parent-pile.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix ihdpR_`age' = J(``age'_row', 5, .) // for randomisation variable

	qui matrix colnames ihdpR_`age' = ihdpR_`age'num ihdpR_`age'coeff ihdpR_`age'lower ihdpR_`age'upper ihdpR_`age'pval

	local row_`age' = 1

	* Loop over rows to fill in values into the empty matrix.

	forvalues r = 1/``age'_row' {
		qui matrix ihdpR_`age'[`row_`age'',1] = `row_`age''

		capture confirm variable norm_sameroff`age'y_`r'
		if !_rc {
			* Randomisation variable
			qui regress norm_sameroff`age'y_`r' R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix ihdpR_`age'[`row_`age'',2] = r[1,1]
			qui matrix ihdpR_`age'[`row_`age'',3] = r[5,1]
			qui matrix ihdpR_`age'[`row_`age'',4] = r[6,1]
			qui matrix ihdpR_`age'[`row_`age'',5] = r[4,1]

			local row_`age' = `row_`age'' + 1
		}

		else {
			local row_`age' = `row_`age'' + 1
		}
	}

	svmat ihdpR_`age', names(col)
	rename ihdpR_`age'num row_`age'
	keep row_`age' ihdpR_`age'coeff ihdpR_`age'lower ihdpR_`age'upper ihdpR_`age'pval
	keep if row_`age' != .
	save "ihdp-pile-sameroff-`age'", replace
}

cd "$data_analysis"

* Randomisation

use ihdp-pile-sameroff-1, clear

foreach t of global ihdp_type {
	merge 1:1 row_1 using ihdp-pile-sameroff-1, nogen nolabel
}

rename row_1 row
save ihdp-sameroff-pile-1, replace

use ihdp-pile-sameroff-3, clear

foreach t of global ihdp_type {
	merge 1:1 row_3 using ihdp-pile-sameroff-3, nogen nolabel
}

rename row_3 row
save ihdp-sameroff-pile-3, replace

* ABC/CARE - PARI
local 1_row = 55
local 2_row = 55

foreach p in abc {
	foreach age of numlist 1 2 {

		cd "$data_analysis"
		use "`p'-parent-pile.dta", clear

		* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
		qui matrix `p'R_`age' = J(``age'_row', 5, .) // for randomisation variable

		qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval

		local row_`age' = 1

		* Loop over rows to fill in values into the empty matrix.

		forvalues r = 1/``age'_row' {
			qui matrix `p'R_`age'[`row_`age'',1] = `row_`age''

			capture confirm variable norm_pari`age'y_`r'
			if !_rc {
				* Randomisation variable
				qui regress norm_pari`age'y_`r' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'R_`age'[`row_`age'',2] = r[1,1]
				qui matrix `p'R_`age'[`row_`age'',3] = r[5,1]
				qui matrix `p'R_`age'[`row_`age'',4] = r[6,1]
				qui matrix `p'R_`age'[`row_`age'',5] = r[4,1]					

				local row_`age' = `row_`age'' + 1
			}

			else {
				local row_`age' = `row_`age'' + 1
			}
		}

		svmat `p'R_`age', names(col)
		rename `p'R_`age'num row_`age'
		keep row_`age' `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
		keep if row_`age' != .
		save "`p'-pile-pari-`age'", replace
	}
}

cd "$data_analysis"

* Randomisation

use abc-pile-pari-1, clear

rename row_1 row
save abc-pari-pile-1, replace

use abc-pile-pari-2, clear

rename row_2 row
save abc-pari-pile-2, replace

* --------*
* Questions

cd "$data_analysis"

use ihdp-kidi-pile-1, clear

tostring row, gen(scale_num)

replace scale = "Babies with colic can cry for 20, 30 minutes, no matter what is done" if scale_num == "1"
replace scale = "If baby is fed evaporated milk, baby needs extra vitamins/iron" if scale_num == "2"
replace scale = "All infants need the same amount of sleep" if scale_num == "3"
replace scale = "Taking careof baby can leave parent tired, frustrated, overwhelmed" if scale_num == "4"
replace scale = "One year old knows right from wrong" if scale_num == "5"
replace scale = "Infants stop paying atttention to surroundings if too much going on" if scale_num == "6"
replace scale = "Some normal babies do not enjoy being cuddled" if scale_num == "7"
replace scale = "Comforting/holding crying baby is spoiling the baby" if scale_num == "8"
replace scale = "Frequent cause of accidents is chidl pulling somevthing on self" if scale_num == "9"
replace scale = "Good way to teach child not to hit is to hit back" if scale_num == "10"
replace scale = "6mo baby responds differently to people depending on person's mood" if scale_num == "11"
replace scale = "Infants are usually walking by 12mo" if scale_num == "12"
replace scale = "Most infants are ready to be toilet trained by 1yo" if scale_num == "13"
replace scale = "An infant will begin to respond to his her name at 10mo" if scale_num == "14"
replace scale = "5mo know what 'no' means" if scale_num == "15"
replace scale = "1yo children will cooperate and share when they play together" if scale_num == "16"
replace scale = "Baby is 7mo before he/she can reach for and grab vthings" if scale_num == "17"
replace scale = "Babies usually say first word at 6mo." if scale_num == "18"
replace scale = "Most appropriate game for 1yo: rolling a ball back and forth with an adult" if scale_num == "19"

save ihdp-kidi-pile-1, replace

use ihdp-kidi-pile-2, clear

tostring row, gen(scale_num)

replace scale = "Way infant is brought up will have little effect on intelligence" if scale_num == "1"
replace scale = "Baby can leave the parent feeling tired, frustrated, overwhelmed" if scale_num == "2"
replace scale = "Younger sibling may start wetting bed/sucking thumb when new baby arrives" if scale_num == "3"
replace scale = "Two year old's sense of time is different from an adults" if scale_num == "4"
replace scale = "The baby's personality is set by 6mo" if scale_num == "5"
replace scale = "Child  uses rules of speech even if saying vthings incorrectly" if scale_num == "6"
replace scale = "Child learns all language through copying what they hear people say" if scale_num == "7"
replace scale = "Frequent cause of accidents for 1yo is pulling vthings down onto themselves" if scale_num == "8"
replace scale = "Good way to teach child not to hit is to hit back" if scale_num == "9"
replace scale = "Most 2yo can tell fiction on TV from truth" if scale_num == "10"
replace scale = "Infants are usually walking by 12mo" if scale_num == "11"
replace scale = "2yo can reason logically, much as an adult would" if scale_num == "12"
replace scale = "1yo knows right from wrong" if scale_num == "13"
replace scale = "Most infants are ready to be toilet trained by 1yo" if scale_num == "14"
replace scale = "1yo children will cooperate and share when they play together" if scale_num == "15"
replace scale = "Infants of 12mo can remember toys they have watched being hidden" if scale_num == "16"
replace scale = "Babies usually say first word at 6mo." if scale_num == "17"

save ihdp-kidi-pile-2, replace

foreach age of numlist 1 3 {
	use ihdp-sameroff-pile-`age', clear

	tostring row, gen(scale_num)

	replace scale = "Children have to be treated differently as they grow older" if scale_num == "1"
	replace scale = "Parents must keep to their standards and rules no matter what their child is like" if scale_num == "2"
	replace scale = "It is not easy to define a good home because a good home is made up of many different things" if scale_num == "3"
	replace scale = "Fathers cannot raise their children as well as mothers" if scale_num == "4"
	replace scale = "The mischief that 2-year-olds get into is part of a passing stage they'll grow out of" if scale_num == "5"
	replace scale = "A child who isn't toilet trained by 3 years of age must have something wrong with him " if scale_num == "6"
	replace scale = "Parents need to be sensitive to the needs of their children" if scale_num == "7"
	replace scale = "Girls tend to be easier babies to take care of than are boys" if scale_num == "8"
	replace scale = "Difficult babies will grow out of it" if scale_num == "9"
	replace scale = "There's not much anyone can do to help emotionally disturbed children" if scale_num == "10"
	replace scale = "Children's problems seldom have a single cause" if scale_num == "11"
	replace scale = "Father's role is to provide discipline mother's role is to give love and attention to the children" if scale_num == "12"
	replace scale = "Parents can be turned off by a fussy child so that they are unable to be as nice as they would like" if scale_num == "13"
	replace scale = "Child's school success depends on how much his mother taught him at home" if scale_num == "14"
	replace scale = "There is no one right way to raise children" if scale_num == "15"
	replace scale = "Boy babies are less affectionate than girl babies" if scale_num == "16"
	replace scale = "Firstborn children are usually treated differently than are later-born children" if scale_num == "17"
	replace scale = "An easy baby will grow up to be a good child" if scale_num == "18"
	replace scale = "Parents change in response to their children" if scale_num == "19"
	replace scale = "Babies have to be taught to behave themselves or they will be bad later on" if scale_num == "20"

	save ihdp-sameroff-pile-`age', replace
}

foreach age of numlist 1 2 {
	use abc-pari-pile-`age', clear

	tostring row, gen(scale_num)

	replace scale = "A good mother should shelter her child from life's little difficulties" if scale_num == "1"
	replace scale = "Children should be taught about sex as soon as possible" if scale_num == "2"
	replace scale = "People who vthink they can get along in marriage without arguments just don't know the facts" if scale_num == "3"
	replace scale = "Parents should not have to earn the respect of their children by the way they act" if scale_num == "4"
	replace scale = "The women who want lots of parties seldom make good mothers" if scale_num == "5"
	replace scale = "Most mothers are content to be with children all the time" if scale_num == "6"
	replace scale = "A child has a right to his own point of view and ought to be allowed to express it" if scale_num == "7"
	replace scale = "If a parent is wrong he should admit it to his child" if scale_num == "8"
	replace scale = "A child should be taught to avoid fighting no matter what happens" if scale_num == "9"
	replace scale = "Most mothers can spend all day with the children and remain calm and even-tempered" if scale_num == "10"
	replace scale = "Parents who are interested in hearing about their children's parties, dates, and fun help them grow up right" if scale_num == "11"
	replace scale = "A child should learn that he has to be disappointed sometimes" if scale_num == "12"
	replace scale = "It is very important that young boys and girls not be allowed to see each other completely undressed" if scale_num == "13"
	replace scale = "If a couple really loves each other there are very few arguments in their married life" if scale_num == "14"
	replace scale = "Parents should adjust to the children some rather than always expecting the children to adjust to the parents" if scale_num == "15"
	replace scale = "A good mother should develop interests outside the home" if scale_num == "16"
	replace scale = "One of the worst vthings about taking care of a home is a woman feels that she can't get out" if scale_num == "17"
	replace scale = "Children should not be allowed to disagree with their parents, even if they feel their own ideas are better" if scale_num == "18"
	replace scale = "It's best for the child if he never gets started wondering whether his mother's views are right" if scale_num == "19"
	replace scale = "A child should be taught to fight his own battles" if scale_num == "20"
	replace scale = "Children will get on any woman's nerves if she has to be with them all day" if scale_num == "21"
	replace scale = "Children would be happier and better behaved if parents would show less interest in their affairs" if scale_num == "22"
	replace scale = "A child should be protected from jobs which might be too tiring or hard for him" if scale_num == "23"
	replace scale = "Sex play is a normal vthing in children" if scale_num == "24"
	replace scale = "Sometimes it's necessary for a wife to tell off her husband in order to get her rights" if scale_num == "25"
	replace scale = "Children should learn to compromise and adjust to the demands of their parents" if scale_num == "26"
	replace scale = "Too many women forget that a mother's place is in the home" if scale_num == "27"
	replace scale = "Most young mothers don't mind spending most of their time at home" if scale_num == "28"
	replace scale = "A child's ideas should be seriously considered in making family decisions" if scale_num == "29"
	replace scale = "A child should be encouraged to look for answers to his questions from other people even if the answers contradict his parents" if scale_num == "30"
	replace scale = "Children should not be encouraged to bos or wrestle because it often leads to trouble or injury" if scale_num == "31"
	replace scale = "Raising children is an easy job" if scale_num == "32"
	replace scale = "If parents would have fun with their children, the children would be more apt to take their advice" if scale_num == "33"
	replace scale = "Children have to face difficult situations on their own" if scale_num == "34"
	replace scale = "Sex is one of the greatest problems to be contended with in children" if scale_num == "35"
	replace scale = "Almost any problem can be settled by quietly talking it over" if scale_num == "36"
	replace scale = "There is no reason parents should have their own way all the time, any more than the children should have their own way all the time" if scale_num == "37"
	replace scale = "A mother can keep a nice home and still have plenty of time left over to visit with neighbors and friends" if scale_num == "38"
	replace scale = "One of the bad vthings about raising children is that you aren't free enough of the time to do just as you like" if scale_num == "39"
	replace scale = "Children should be discouraged from telling their parents about it when they feel family rules are unreasonable" if scale_num == "40"
	replace scale = "The child should not question the vthinking of his parents" if scale_num == "41"
	replace scale = "It's quite natural for children to hit one another" if scale_num == "42"
	replace scale = "Mothers very often feel that they can't stand their children a moment longer" if scale_num == "43"
	replace scale = "Laughing at children's jokes and telling children jokes usually fail to make vthings go more smoothly" if scale_num == "44"
	replace scale = "Children should be kept away from all hard jobs which might be discouraging" if scale_num == "45"
	replace scale = "Children are normally curious about sex" if scale_num == "46"
	replace scale = "It's natural to have quarrels when two people who both have minds of their own get married" if scale_num == "47"
	replace scale = "It is rarely possible to treat a child as an equal" if scale_num == "48"
	replace scale = "A good mother will find enough social life wivthin the family" if scale_num == "49"
	replace scale = "Most young mothers are pretty content with home life" if scale_num == "50"
	replace scale = "When a child is in trouble he ought to know he won't be punished for talking about it with his parents" if scale_num == "51"
	replace scale = "A good mother can tolerate criticism of herself, even when the children are around" if scale_num == "52"
	replace scale = "Most parents prefer a quiet child to a scrappy one" if scale_num == "53"
	replace scale = "A mother should keep control of her temper even when children are demanding" if scale_num == "54"
	replace scale = "When you do vthings together, children feel close to you and can talk easier" if scale_num == "55"

	save abc-pari-pile-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 2 {

	* IHDP KIDI	
	cd "$data_analysis"
	use ihdp-kidi-pile-`age', clear

	if "`age'" == "2" {
		drop if inlist(row, 1, 5)
	}

	gen inv_ihdpRcoeff = ihdpR_`age'coeff * -1
	gen ihdpRinsig = .
	gen ihdpR0_1 = .
	gen ihdpR0_05 = .
	replace ihdpRinsig = ihdpR_`age'coeff if ihdpR_`age'pval > 0.1
	replace ihdpR0_1 = ihdpR_`age'coeff if ihdpR_`age'pval <= 0.1 & ihdpR_`age'pval > 0.05
	replace ihdpR0_05 = ihdpR_`age'coeff if ihdpR_`age'pval <= 0.05

	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05, ///
		marker(1,msize(medium) msymbol(O) mlc(green) mfc(green*0) mlw(vthin)) marker(2,msize(medium) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) marker(3,msize(medium) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
		over(scale, label(labsize(vsmall)) sort(scale_num)) ///
		legend (order (3 "IHDP") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		ylabel($item_axis_range) ///
		graphregion(fcolor(white))

	cd "$pile_out"
	graph export "ihdp_kidi_pile_R_`age'.pdf", replace

	cd "$pile_git_out"
	graph export "ihdp_kidi_pile_R_`age'.png", replace

	* ABC/CARE PARI
	cd "$data_analysis"
	use abc-pari-pile-`age', clear

	foreach p in abc {
		gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
		gen `p'Rinsig = .
		gen `p'R0_1 = .
		gen `p'R0_05 = .
		replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
		replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
	}

	graph dot abcRinsig abcR0_1 abcR0_05, ///
		marker(1,msize(small) msymbol(O) mlc(blue) mfc(blue*0) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) marker(3,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
		over(scale, label(labsize(tiny)) sort(scale_num)) ///
		legend (order (3 "ABC") size(vsmall)) yline(0) ylabel(#6, labsize(tiny)) ///
		ylabel($item_axis_range) ///
		graphregion(fcolor(white))

	cd "$pile_out"
	graph export "abccare_pari_pile_R_`age'.pdf", replace

	cd "$pile_git_out"
	graph export "abccare_pari_pile_R_`age'.png", replace
}

foreach age of numlist 1 3 {
	* IHDP Sameroff	
	cd "$data_analysis"
	use ihdp-sameroff-pile-`age', clear

	gen inv_ihdpRcoeff = ihdpR_`age'coeff * -1
	gen ihdpRinsig = .
	gen ihdpR0_1 = .
	gen ihdpR0_05 = .
	replace ihdpRinsig = ihdpR_`age'coeff if ihdpR_`age'pval > 0.1
	replace ihdpR0_1 = ihdpR_`age'coeff if ihdpR_`age'pval <= 0.1 & ihdpR_`age'pval > 0.05
	replace ihdpR0_05 = ihdpR_`age'coeff if ihdpR_`age'pval <= 0.05

	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05, ///
		marker(1,msize(medium) msymbol(O) mlc(green) mfc(green*0) mlw(vthin)) marker(2,msize(medium) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) marker(3,msize(medium) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
		over(scale, label(labsize(tiny)) sort(scale_num)) ///
		legend (order (3 "IHDP") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		ylabel($item_axis_range) ///
		graphregion(fcolor(white))

	cd "$pile_out"
	graph export "ihdp_sameroff_pile_R_`age'.pdf", replace

	cd "$pile_git_out"
	graph export "ihdp_sameroff_pile_R_`age'.png", replace
}

* IHDP Belief
cd "$data_analysis"
use ihdp-kidi-pile-2, clear
rename ihdpR_2coeff ihdpR_coeff
rename ihdpR_2pval ihdpR_pval
keep row scale ihdpR_coeff ihdpR_pval
keep if inlist(row, 1, 5)
tempfile tmp_kidi
save "`tmp_kidi'", replace

use ihdp-sameroff-pile-3, clear
rename ihdpR_3coeff ihdpR_coeff
rename ihdpR_3pval ihdpR_pval
keep row scale ihdpR_coeff ihdpR_pval
keep if inlist(row, 14)
append using "`tmp_kidi'"

replace scale = "Way infant is brought up will have little effect on intelligence" if row == 1
replace scale = "The baby's personality is set by 6mo" if row == 5
replace scale = "Child's school success depends on mother's teach at home" if row == 14

gen inv_ihdpRcoeff = ihdpR_coeff * -1
gen ihdpRinsig = .
gen ihdpR0_1 = .
gen ihdpR0_05 = .
replace ihdpRinsig = ihdpR_coeff if ihdpR_pval > 0.1
replace ihdpR0_1 = ihdpR_coeff if ihdpR_pval <= 0.1 & ihdpR_pval > 0.05
replace ihdpR0_05 = ihdpR_coeff if ihdpR_pval <= 0.05

graph dot ihdpRinsig ihdpR0_1 ihdpR0_05, ///
	marker(1,msize(vhuge) msymbol(O) mlc(green) mfc(green*0) mlw(thick)) marker(2,msize(vhuge) msymbol(O) mlc(green) mfc(green*0.5) mlw(thick)) marker(3,msize(vhuge) msymbol(O) mlc(green) mfc(green) mlw(thick)) ///
	over(scale, label(labsize(vlarge)) sort(scale_num)) ///
	legend (order (3 "IHDP") size(large)) yline(0) ylabel(#6, labsize(large)) ///
	ylabel($item_axis_range) ysize(1) xsize(2.5) ///
	graphregion(fcolor(white))

cd "$pile_out"
graph export "ihdp_belief_pile_R.pdf", replace

cd "$pile_git_out"
graph export "ihdp_belief_pile_R.png", replace
