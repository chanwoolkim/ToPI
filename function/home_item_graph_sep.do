graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
		  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
		  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05 ///
		  ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		  abcRinsig abcR0_1 abcR0_05 ///
		  carebothRinsig carebothR0_1 carebothR0_05 ///
		  carehomeRinsig carehomeR0_1 carehomeR0_05, ///
marker(1,msize(small) msymbol(S) mlc(red) mfc(red*0) mlw(vthin)) marker(2,msize(small) msymbol(S) mlc(red) mfc(red*0.5) mlw(vthin)) marker(3,msize(small) msymbol(S) mlc(red) mfc(red) mlw(vthin)) ///
marker(4,msize(small) msymbol(T) mlc(red) mfc(red*0) mlw(vthin)) marker(5,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(7,msize(small) msymbol(D) mlc(red) mfc(red*0) mlw(vthin)) marker(8,msize(small) msymbol(D) mlc(red) mfc(red*0.5) mlw(vthin)) marker(9,msize(small) msymbol(D) mlc(red) mfc(red) mlw(vthin)) ///
marker(10,msize(small) msymbol(D) mlc(green) mfc(green*0) mlw(vthin)) marker(11,msize(small) msymbol(D) mlc(green) mfc(green*0.5) mlw(vthin)) marker(12,msize(small) msymbol(D) mlc(green) mfc(green) mlw(vthin)) ///
marker(13,msize(small) msymbol(S) mlc(blue) mfc(blue*0) mlw(vthin)) marker(14,msize(small) msymbol(S) mlc(blue) mfc(blue*0.5) mlw(vthin)) marker(15,msize(small) msymbol(S) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(16,msize(small) msymbol(D) mlc(purple) mfc(purple*0) mlw(vthin)) marker(17,msize(small) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(vthin)) marker(18,msize(small) msymbol(D) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(19,msize(small) msymbol(T) mlc(purple) mfc(purple*0) mlw(vthin)) marker(20,msize(small) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) marker(21,msize(small) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(scale_row)) ///
legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed" 12 "IHDP" 15 "ABC" 18 "CARE-Both" 21 "CARE-Home") size(vsmall)) yline(0) ylabel(#7, labsize(vsmall)) ///
ylabel($item_axis_range) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))
