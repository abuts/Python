	subroutine IFL_bin_boundaries_get_xarr (ierr, nb, xbounds, nx, x_in, mx, x_out)
	use type_definitions
	use I_maths, only: bin_boundaries_get_xarr
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nb, nx, mx
	real(dp) xbounds(nb), x_in(nx), x_out(mx)

	call bin_boundaries_get_xarr (ierr, xbounds, x_in=x_in, x_out=x_out)

	return
	end
