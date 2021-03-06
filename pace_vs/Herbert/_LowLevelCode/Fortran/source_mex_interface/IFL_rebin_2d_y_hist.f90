	subroutine IFL_rebin_2d_y_hist (ierr, nx, ny, y, s, e, my, yout, sout, eout)
	use type_definitions
	use I_maths, only: rebin_2d_y_hist
!-----------------------------------------------------------------------------------------------------------------------------------
! Interface to Fortran 90 library routines
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	integer(i4b) ierr, nx, ny, my
	real(dp) y(ny), s(nx,ny-1), e(nx,ny-1), yout(my), sout(nx,my-1), eout(nx,my-1)

	call rebin_2d_y_hist (ierr, y, s, e, yout, sout, eout)

	return
	end
