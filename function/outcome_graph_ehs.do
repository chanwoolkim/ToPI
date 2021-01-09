graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
		  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
		  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05, ///
marker(1,msize(large) msymbol(S) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(S) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(S) mlc(navy) mfc(navy) mlw(thick)) ///
marker(4,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
marker(7,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) marker(8,msize(large) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(9,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
over(scale, label(labsize(large)) sort(scale_row)) ///
legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed") size(medsmall)) yline(0) ylabel(#7, labsize(medsmall)) ///
ylabel($outcome_axis_range2) ysize(1) xsize(2) ///
graphregion(fcolor(white)) bgcolor(white)

