graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
		  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
		  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05 ///
		  ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		  abcRinsig abcR0_1 abcR0_05 ///
		  carebothRinsig carebothR0_1 carebothR0_05 ///
		  carehomeRinsig carehomeR0_1 carehomeR0_05, ///
marker(1,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thick)) marker(2,msize(large) msymbol(S) mlc(red) mfc(red*0.5) mlw(thick)) marker(3,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thick)) ///
marker(4,msize(large) msymbol(T) mlc(red) mfc(red*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(red) mfc(red*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(red) mfc(red) mlw(thick)) ///
marker(7,msize(large) msymbol(D) mlc(red) mfc(red*0) mlw(thick)) marker(8,msize(large) msymbol(D) mlc(red) mfc(red*0.5) mlw(thick)) marker(9,msize(large) msymbol(D) mlc(red) mfc(red) mlw(thick)) ///
marker(10,msize(large) msymbol(D) mlc(green) mfc(green*0) mlw(thick)) marker(11,msize(large) msymbol(D) mlc(green) mfc(green*0.5) mlw(thick)) marker(12,msize(large) msymbol(D) mlc(green) mfc(green) mlw(thick)) ///
marker(13,msize(large) msymbol(S) mlc(blue) mfc(blue*0) mlw(thick)) marker(14,msize(large) msymbol(S) mlc(blue) mfc(blue*0.5) mlw(thick)) marker(15,msize(large) msymbol(S) mlc(blue) mfc(blue) mlw(thick)) ///
marker(16,msize(large) msymbol(D) mlc(purple) mfc(purple*0) mlw(thick)) marker(17,msize(large) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(thick)) marker(18,msize(large) msymbol(D) mlc(purple) mfc(purple) mlw(thick)) ///
marker(19,msize(large) msymbol(T) mlc(purple) mfc(purple*0) mlw(thick)) marker(20,msize(large) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(thick)) marker(21,msize(large) msymbol(T) mlc(purple) mfc(purple) mlw(thick)) ///
over(scale, label(labsize(large)) sort(scale_row)) ///
legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed" 12 "IHDP" 15 "ABC" 18 "CARE-Both" 21 "CARE-Home") size(medsmall)) yline(0) ylabel(#6, labsize(medsmall)) ///
ylabel($outcome_axis_range) ysize(1) xsize(2) ///
graphregion(fcolor(white))
