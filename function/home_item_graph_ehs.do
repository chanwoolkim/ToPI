graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
		  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
		  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05, ///
marker(1,msize(small) msymbol(S) mlc(navy) mfc(navy*0) mlw(vthin)) marker(2,msize(small) msymbol(S) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(3,msize(small) msymbol(S) mlc(navy) mfc(navy) mlw(vthin)) ///
marker(4,msize(small) msymbol(T) mlc(navy) mfc(navy*0) mlw(vthin)) marker(5,msize(small) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(navy) mfc(navy) mlw(vthin)) ///
marker(7,msize(small) msymbol(D) mlc(navy) mfc(navy*0) mlw(vthin)) marker(8,msize(small) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(9,msize(small) msymbol(D) mlc(navy) mfc(navy) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(scale_row)) ///
legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed") size(vsmall)) yline(0) ylabel(#7, labsize(vsmall)) ///
ylabel($item_axis_range) ///
ysize(11) xsize(8.5) graphregion(fcolor(white)) bgcolor(white)

