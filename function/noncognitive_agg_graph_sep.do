graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
		  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
		  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05, ///
marker(1,msize(large) msymbol(S) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(S) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(S) mlc(navy) mfc(navy) mlw(thick)) ///
marker(4,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
marker(7,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) marker(8,msize(large) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(9,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
over(scale, label(labsize(large)) sort(scale_row)) ///
legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed") size(medsmall)) yline(0) ylabel(#7, labsize(medsmall)) ///
ylabel($agg_axis_range) ///
graphregion(fcolor(white)) bgcolor(white)

cd "$pile_out"
graph export "noncognitive_pile_R_agg_`age'_ehs.pdf", replace

cd "$pile_git_out"
graph export "noncognitive_pile_R_agg_`age'_ehs.png", replace

graph dot ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		  abcRinsig abcR0_1 abcR0_05 ///
		  carebothRinsig carebothR0_1 carebothR0_05 ///
		  carehomeRinsig carehomeR0_1 carehomeR0_05, ///
marker(1,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(O) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
marker(4,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
marker(7,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) marker(8,msize(large) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(9,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
marker(10,msize(large) msymbol(S) mlc(navy) mfc(navy*0) mlw(thick)) marker(11,msize(large) msymbol(S) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(12,msize(large) msymbol(S) mlc(navy) mfc(navy) mlw(thick)) ///
over(scale, label(labsize(large)) sort(scale_row)) ///
legend (order (3 "IHDP" 6 "ABC" 9 "CARE-Both" 12 "CARE-Home") size(medsmall)) yline(0) ylabel(#7, labsize(medsmall)) ///
ylabel($agg_axis_range) ///
graphregion(fcolor(white)) bgcolor(white)
