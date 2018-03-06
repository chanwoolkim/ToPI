graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
		  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
		  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05 ///
		  ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		  abcRinsig abcR0_1 abcR0_05 ///
		  carebothRinsig carebothR0_1 carebothR0_05 ///
		  carehomeRinsig carehomeR0_1 carehomeR0_05, ///
marker(1,msize(vlarge) msymbol(S) mlc(red) mfc(red*0) mlw(thin)) marker(2,msize(vlarge) msymbol(S) mlc(red) mfc(red*0.5) mlw(thin)) marker(3,msize(vlarge) msymbol(S) mlc(red) mfc(red) mlw(thin)) ///
marker(4,msize(vlarge) msymbol(T) mlc(red) mfc(red*0) mlw(thin)) marker(5,msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(thin)) marker(6,msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(thin)) ///
marker(7,msize(vlarge) msymbol(D) mlc(red) mfc(red*0) mlw(thin)) marker(8,msize(vlarge) msymbol(D) mlc(red) mfc(red*0.5) mlw(thin)) marker(9,msize(vlarge) msymbol(D) mlc(red) mfc(red) mlw(thin)) ///
marker(10,msize(vlarge) msymbol(D) mlc(green) mfc(green*0) mlw(thin)) marker(11,msize(vlarge) msymbol(D) mlc(green) mfc(green*0.5) mlw(thin)) marker(12,msize(vlarge) msymbol(D) mlc(green) mfc(green) mlw(thin)) ///
marker(13,msize(vlarge) msymbol(S) mlc(blue) mfc(blue*0) mlw(thin)) marker(14,msize(vlarge) msymbol(S) mlc(blue) mfc(blue*0.5) mlw(thin)) marker(15,msize(vlarge) msymbol(S) mlc(blue) mfc(blue) mlw(thin)) ///
marker(16,msize(vlarge) msymbol(D) mlc(purple) mfc(purple*0) mlw(thin)) marker(17,msize(vlarge) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(18,msize(vlarge) msymbol(D) mlc(purple) mfc(purple) mlw(thin)) ///
marker(19,msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0) mlw(thin)) marker(20,msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(21,msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(thin)) ///
over(scale, label(labsize(medsmall)) sort(scale_row)) ///
legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed" 12 "IHDP" 15 "ABC" 18 "CARE-Both" 21 "CARE-Home") size(medsmall)) yline(0) ylabel(#6, labsize(medsmall)) ///
ylabel($outcome_axis_range) ysize(1) xsize(2) ///
graphregion(fcolor(white))
