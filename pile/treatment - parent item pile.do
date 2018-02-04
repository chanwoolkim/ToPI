* -------------------------------------------- *
* Graphs of treatment effects - parent item pile
* Author: Chanwool Kim
* Date Created: 3 Feb 2018
* Last Update: 3 Feb 2018
* -------------------------------------------- *

clear all

* ------------ *
* Prepare matrix

* IHDP - KIDI
local 1_row = 20
local 2_row = 18

foreach t of global ihdp_type {

cd "$pile_working"
use "ihdp`t'-parent-pile.dta", clear

cd "$pile_working"

foreach age of numlist 1 2 {
* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
qui matrix ihdp`t'R_`age' = J(``age'_row', 5, .) // for randomisation variable

qui matrix colnames ihdp`t'R_`age' = ihdp`t'R_`age'num ihdp`t'R_`age'coeff ihdp`t'R_`age'lower ihdp`t'R_`age'upper ihdp`t'R_`age'pval

local row_`age' = 1

* Loop over rows to fill in values into the empty matrix.

	forvalues r = 1/``age'_row' {
		qui matrix ihdp`t'R_`age'[`row_`age'',1] = `row_`age''
		
		capture confirm variable norm_kidi`age'y_`r'
			if !_rc {
			* Randomisation variable
			qui regress norm_kidi`age'y_`r' R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix ihdp`t'R_`age'[`row_`age'',2] = r[1,1]
			qui matrix ihdp`t'R_`age'[`row_`age'',3] = r[5,1]
			qui matrix ihdp`t'R_`age'[`row_`age'',4] = r[6,1]
			qui matrix ihdp`t'R_`age'[`row_`age'',5] = r[4,1]
				
			local row_`age' = `row_`age'' + 1
			}
			
			else {
			local row_`age' = `row_`age'' + 1
			}
	}

	svmat ihdp`t'R_`age', names(col)
	rename ihdp`t'R_`age'num row_`age'
	keep row_`age' ihdp`t'R_`age'coeff ihdp`t'R_`age'lower ihdp`t'R_`age'upper ihdp`t'R_`age'pval
	keep if row_`age' != .
	save "ihdp`t'-pile-kidi-`age'", replace
	}
}

cd "$pile_working"

* Randomisation

use ihdp-pile-kidi-1, clear

foreach t of global ihdp_type {
	merge 1:1 row_1 using ihdp`t'-pile-kidi-1, nogen nolabel
}

rename row_1 row
save ihdp-kidi-pile-1, replace

use ihdp-pile-kidi-2, clear

foreach t of global ihdp_type {
	merge 1:1 row_2 using ihdp`t'-pile-kidi-2, nogen nolabel
}

rename row_2 row
save ihdp-kidi-pile-2, replace

* ABC/CARE - PARI
local 1_row = 55
local 2_row = 55

foreach p in abc care {
	foreach t of global ``p'_type' {

	cd "$pile_working"
	use "`p'`t'-parent-pile.dta", clear

	cd "$pile_working"

	foreach age of numlist 1 2 {
	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix `p'`t'R_`age' = J(``age'_row', 5, .) // for randomisation variable

	qui matrix colnames `p'`t'R_`age' = `p'`t'R_`age'num `p'`t'R_`age'coeff `p'`t'R_`age'lower `p'`t'R_`age'upper `p'`t'R_`age'pval

	local row_`age' = 1

	* Loop over rows to fill in values into the empty matrix.

		forvalues r = 1/``age'_row' {
			qui matrix `p'`t'R_`age'[`row_`age'',1] = `row_`age''
			
			capture confirm variable norm_kidi`age'y_`r'
				if !_rc {
				* Randomisation variable
				qui regress norm_kidi`age'y_`r' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix `p'`t'R_`age'[`row_`age'',2] = r[1,1]
				qui matrix `p'`t'R_`age'[`row_`age'',3] = r[5,1]
				qui matrix `p'`t'R_`age'[`row_`age'',4] = r[6,1]
				qui matrix `p'`t'R_`age'[`row_`age'',5] = r[4,1]
					
				local row_`age' = `row_`age'' + 1
				}
				
				else {
				local row_`age' = `row_`age'' + 1
				}
		}

		svmat `p'`t'R_`age', names(col)
		rename `p'`t'R_`age'num row_`age'
		keep row_`age' `p'`t'R_`age'coeff `p'`t'R_`age'lower `p'`t'R_`age'upper `p'`t'R_`age'pval
		keep if row_`age' != .
		save "`p'`t'-pile-pari-`age'", replace
		}
	}
}

cd "$pile_working"

* Randomisation

use abc-pile-kidi-1, clear

foreach t of global care_type {
	merge 1:1 row_1 using care`t'-pile-pari-1, nogen nolabel
}

rename row_1 row
save abc-pari-pile-1, replace

use abc-pile-pari-2, clear

foreach t of global care_type {
	merge 1:1 row_2 using care`t'-pile-pari-2, nogen nolabel
}

rename row_2 row
save abc-pari-pile-2, replace

* --------*
* Questions

cd "$pile_working"

use ihdp-kidi-pile-1, clear

tostring row, gen(scale_num)

replace scale = "KIDI: babies with colic can cry for 20, 30 minutes, no matter what is done" if scale_num == "1"
replace scale = "KIDI: if baby is fed evaporated milk, baby needs extra vitamins/iron" if scale_num == "2"
replace scale = "KIDI: all infants need the same amount of sleep" if scale_num == "3"
replace scale = "KIDI: taking careof baby can leave parent tired, frustrated, overwhelmed" if scale_num == "4"
replace scale = "KIDI: one year old knows right from wrong" if scale_num == "5"
replace scale = "KIDI: infants stop paying atttention to surroundings if too much going on" if scale_num == "6"
replace scale = "KIDI: some normal babies do not enjoy being cuddled" if scale_num == "7"
replace scale = "KIDI: comforting/holding crying baby is spoiling the baby" if scale_num == "8"
replace scale = "KIDI: frequent cause of accidents is chidl pulling something on self" if scale_num == "9"
replace scale = "KIDI: good way to teach child not to hit is to hit back" if scale_num == "10"
replace scale = "KIDI: 6mo baby responds differently to people depending on person's mood" if scale_num == "11"
replace scale = "KIDI: Infants are usually walking by 12mo" if scale_num == "12"
replace scale = "KIDI: most infants are ready to be toilet trained by 1yo" if scale_num == "13"
replace scale = "KIDI: an infant will begin to respond to his her name at 10mo" if scale_num == "14"
replace scale = "KIDI: 5mo know what 'no' means" if scale_num == "15"
replace scale = "KIDI: 1yo children will cooperate and share when they play together" if scale_num == "16"
replace scale = "KIDI: baby is 7mo before he/she can reach for and grab things" if scale_num == "17"
replace scale = "KIDI: babies usually say first word at 6mo." if scale_num == "18"
replace scale = "KIDI: best way to deal with 1yo who keeps playing with breakable things" if scale_num == "19"
replace scale = "KIDI: most appropriate game for 1yo" if scale_num == "20"

save ihdp-kidi-pile-1, replace

use ihdp-kidi-pile-2, clear

tostring row, gen(scale_num)

replace scale = "KIDI: way infant is brought up will have little effect on intelligence" if scale_num == "1"
replace scale = "KIDI: baby can leave the parent feeling tired, frustrated, overwhelmed" if scale_num == "2"
replace scale = "KIDI: younger sibling may start wetting bed/sucking thumb when new baby arrives" if scale_num == "3"
replace scale = "KIDI: two year old's sense of time is different from an adults" if scale_num == "4"
replace scale = "KIDI: The baby's personality is set by 6mo" if scale_num == "5"
replace scale = "KIDI: Child  uses rules of speech even if saying things incorrectly" if scale_num == "6"
replace scale = "KIDI: Child learns all language through copying what they hear people say" if scale_num == "7"
replace scale = "KIDI: frequent cause of accidents for 1yo is pulling things down onto themselves" if scale_num == "8"
replace scale = "KIDI: good way to teach child not to hit is to hit back" if scale_num == "9"
replace scale = "KIDI: Most 2yo can tell fiction on TV from truth" if scale_num == "10"
replace scale = "KIDI: Infants are usually walking by 12mo" if scale_num == "11"
replace scale = "KIDI: 2yo can reason logically, much as an adult would" if scale_num == "12"
replace scale = "KIDI: 1yo knows right from wrong" if scale_num == "13"
replace scale = "KIDI: most infants are ready to be toilet trained by 1yo" if scale_num == "14"
replace scale = "KIDI: 1yo children will cooperate and share when they play together" if scale_num == "15"
replace scale = "KIDI: infants of 12mo can remember toys they have watched being hidden" if scale_num == "16"
replace scale = "KIDI: babies usually say first word at 6mo." if scale_num == "17"
replace scale = "KIDI: which is the best way to avoid future trantrums by 2yo?" if scale_num == "18"

save ihdp-kidi-pile-2, replace

foreach age of numlist 1 2 {
	use abc-pari-pile-`age', clear

	tostring row, gen(scale_num)

	replace scale = "PARI: A good mother should shelter her child from life's little difficulties" if scale_num == "1"
	replace scale = "PARI: Children should be taught about sex as soon as possible" if scale_num == "2"
	replace scale = "PARI: People who think they can get along in marriage without arguments just don't know the facts" if scale_num == "3"
	replace scale = "PARI: Parents should not have to earn the respect of their children by the way they act" if scale_num == "4"
	replace scale = "PARI: The women who want lots of parties seldom make good mothers" if scale_num == "5"
	replace scale = "PARI: Most mothers are content to be with children all the time" if scale_num == "6"
	replace scale = "PARI: A child has a right to his own point of view and ought to be allowed to express it" if scale_num == "7"
	replace scale = "PARI: If a parent is wrong he should admit it to his child" if scale_num == "8"
	replace scale = "PARI: A child should be taught to avoid fighting no matter what happens" if scale_num == "9"
	replace scale = "PARI: Most mothers can spend all day with the children and remain calm and even-tempered" if scale_num == "10"
	replace scale = "PARI: Parents who are interested in hearing about their children's parties, dates, and fun help them grow up right" if scale_num == "11"
	replace scale = "PARI: A child should learn that he has to be disappointed sometimes" if scale_num == "12"
	replace scale = "PARI: It is very important that young boys and girls not be allowed to see each other completely undressed" if scale_num == "13"
	replace scale = "PARI: If a couple really loves each other there are very few arguments in their married life" if scale_num == "14"
	replace scale = "PARI: Parents should adjust to the children some rather than always expecting the children to adjust to the parents" if scale_num == "15"
	replace scale = "PARI: A good mother should develop interests outside the home" if scale_num == "16"
	replace scale = "PARI: One of the worst things about taking care of a home is a woman feels that she can't get out" if scale_num == "17"
	replace scale = "PARI: Children should not be allowed to disagree with their parents, even if they feel their own ideas are better" if scale_num == "18"
	replace scale = "PARI: It's best for the child if he never gets started wondering whether his mother's views are right" if scale_num == "19"
	replace scale = "PARI: A child should be taught to fight his own battles" if scale_num == "20"
	replace scale = "PARI: Children will get on any woman's nerves if she has to be with them all day" if scale_num == "21"
	replace scale = "PARI: Children would be happier and better behaved if parents would show less interest in their affairs" if scale_num == "22"
	replace scale = "PARI: A child should be protected from jobs which might be too tiring or hard for him" if scale_num == "23"
	replace scale = "PARI: Sex play is a normal thing in children" if scale_num == "24"
	replace scale = "PARI: Sometimes it's necessary for a wife to tell off her husband in order to get her rights" if scale_num == "25"
	replace scale = "PARI: Children should learn to compromise and adjust to the demands of their parents" if scale_num == "26"
	replace scale = "PARI: Too many women forget that a mother's place is in the home" if scale_num == "27"
	replace scale = "PARI: Most young mothers don't mind spending most of their time at home" if scale_num == "28"
	replace scale = "PARI: A child's ideas should be seriously considered in making family decisions" if scale_num == "29"
	replace scale = "PARI: A child should be encouraged to look for answers to his questions from other people even if the answers contradict his parents" if scale_num == "30"
	replace scale = "PARI: Children should not be encouraged to bos or wrestle because it often leads to trouble or injury" if scale_num == "31"
	replace scale = "PARI: Raising children is an easy job" if scale_num == "32"
	replace scale = "PARI: If parents would have fun with their children, the children would be more apt to take their advice" if scale_num == "33"
	replace scale = "PARI: Children have to face difficult situations on their own" if scale_num == "34"
	replace scale = "PARI: Sex is one of the greatest problems to be contended with in children" if scale_num == "35"
	replace scale = "PARI: Almost any problem can be settled by quietly talking it over" if scale_num == "36"
	replace scale = "PARI: There is no reason parents should have their own way all the time, any more than the children should have their own way all the time" if scale_num == "37"
	replace scale = "PARI: A mother can keep a nice home and still have plenty of time left over to visit with neighbors and friends" if scale_num == "38"
	replace scale = "PARI: One of the bad things about raising children is that you aren't free enough of the time to do just as you like" if scale_num == "39"
	replace scale = "PARI: Children should be discouraged from telling their parents about it when they feel family rules are unreasonable" if scale_num == "40"
	replace scale = "PARI: The child should not question the thinking of his parents" if scale_num == "41"
	replace scale = "PARI: It's quite natural for children to hit one another" if scale_num == "42"
	replace scale = "PARI: Mothers very often feel that they can't stand their children a moment longer" if scale_num == "43"
	replace scale = "PARI: Laughing at children's jokes and telling children jokes usually fail to make things go more smoothly" if scale_num == "44"
	replace scale = "PARI: Children should be kept away from all hard jobs which might be discouraging" if scale_num == "45"
	replace scale = "PARI: Children are normally curious about sex" if scale_num == "46"
	replace scale = "PARI: It's natural to have quarrels when two people who both have minds of their own get married" if scale_num == "47"
	replace scale = "PARI: It is rarely possible to treat a child as an equal" if scale_num == "48"
	replace scale = "PARI: A good mother will find enough social life within the family" if scale_num == "49"
	replace scale = "PARI: Most young mothers are pretty content with home life" if scale_num == "50"
	replace scale = "PARI: When a child is in trouble he ought to know he won't be punished for talking about it with his parents" if scale_num == "51"
	replace scale = "PARI: A good mother can tolerate criticism of herself, even when the children are around" if scale_num == "52"
	replace scale = "PARI: Most parents prefer a quiet child to a scrappy one" if scale_num == "53"
	replace scale = "PARI: A mother should keep control of her temper even when children are demanding" if scale_num == "54"
	replace scale = "PARI: When you do things together, children feel close to you and can talk easier" if scale_num == "55"

	save abc-pari-pile-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 2 {
	* IHDP KIDI	
	cd "$pile_working"
	use ihdp-kidi-pile-`age', clear
	
	foreach t of global ihdp_type {
		gen inv_ihdp`t'Rcoeff = ihdp`t'R_`age'coeff * -1
		gen ihdp`t'Rinsig = .
		gen ihdp`t'R0_1 = .
		gen ihdp`t'R0_05 = .
		replace ihdp`t'Rinsig = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval > 0.1
		replace ihdp`t'R0_1 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.1 & ihdp`t'R_`age'pval > 0.05
		replace ihdp`t'R0_05 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.05
	}
	
	cd "$pile_out"

	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05 ///
			  ihdphighRinsig ihdphighR0_1 ihdphighR0_05 ///
			  ihdplowRinsig ihdplowR0_1 ihdplowR0_05, ///
	marker(1,msize(large) msymbol(D) mlc(green) mfc(green*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(green) mfc(green*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(green) mfc(green) mlw(thin)) ///
	marker(4,msize(large) msymbol(T) mlc(green) mfc(green*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(green) mfc(green*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(green) mfc(green) mlw(thin)) ///
	marker(7,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(8,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(9,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
	over(scale, label(labsize(vsmall)) sort(scale_num)) ///
	legend (order (3 "IHDP-All" 6 "IHDP-High" 9 "IHDP-Low") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ylabel($parent_axis_range) ///
	graphregion(fcolor(white))

	graph export "ihdp_kidi_pile_R_`age'.pdf", replace

	* ABC/CARE PARI
	cd "$pile_working"
	use abc-pari-pile-`age', clear
	
	foreach p in abc care careboth carehv {
		gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
		gen `p'Rinsig = .
		gen `p'R0_1 = .
		gen `p'R0_05 = .
		replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
		replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
	}
	
	cd "$pile_out"

	graph dot abcRinsig abcR0_1 abcR0_05 ///
			  careRinsig careR0_1 careR0_05 ///
			  carebothRinsig carebothR0_1 carebothR0_05 ///
			  carehvRinsig carehvR0_1 carehvR0_05, ///
	marker(1,msize(large) msymbol(D) mlc(blue) mfc(blue*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(blue) mfc(blue*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(blue) mfc(blue) mlw(thin)) ///
	marker(4,msize(large) msymbol(D) mlc(purple) mfc(purple*0) mlw(thin)) marker(5,msize(large) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(6,msize(large) msymbol(D) mlc(purple) mfc(purple) mlw(thin)) ///
	marker(7,msize(large) msymbol(O) mlc(purple) mfc(purple*0) mlw(thin)) marker(8,msize(large) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(9,msize(large) msymbol(O) mlc(purple) mfc(purple) mlw(thin)) ///
	marker(10,msize(large) msymbol(T) mlc(purple) mfc(purple*0) mlw(thin)) marker(11,msize(large) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(12,msize(large) msymbol(T) mlc(purple) mfc(purple) mlw(thin)) ///1
	over(scale, label(labsize(vsmall)) sort(scale_num)) ///
	legend (order (3 "IHDP-All" 6 "IHDP-High" 9 "IHDP-Low" 12 "") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ylabel($parent_axis_range) ///
	graphregion(fcolor(white))

	graph export "abccare_pari_pile_R_`age'.pdf", replace
}
