	subroutine integrate_1d_points (ierr, x, s, e, xout, sout, eout)
	use type_definitions
	use tools_parameters
    use I_Index	
	use I_maths, only : single_integrate_1d_points

!-----------------------------------------------------------------------------------------------------------------------------------
! Integration over a 1D point data set.
!
! The method is a simple trapezoidal rule, with the ordinates at the points being linearly interpolated between
! the values in the array s.
!
!-----------------------------------------------------------------------------------------------------------------------------------
! [Optional arguments are marked with * below]
!
! INPUT:
!	x(:)	real		Point x coordinates (run from 1 to NX)
!	s(:)	real		Signal (run from 1 to MX)
!	e(:)	real		Error bars on signal (run from 1 to NX)
!	xout(:)	real		Output integration range bin boundaries (run from 1 to NB+1)
!
! OUTPUT:
!	ierr	integer		Error flag: = OK all fine; =WARN if informational messages =ERR if a problem
!	sout(:)	real		Output signal (runs from 1 to NX)
!	eout(:)	real		Output error bars on signal (runs from 1 to NX)
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

	real(dp), intent(in) :: x(:), s(:), e(:)
	real(dp), intent(out) :: xout(:), sout(:), eout(:)
	integer(i4b), intent(out) :: ierr
	
	integer(i4b) nx, nb, ml, mu, ib

	sout = 0.0_dp
	eout = 0.0_dp
	ierr = OK

! Perform checks on input parameters:
! ---------------------------------------
	nx = size(s)
	if (size(x) /= nx) then
		call remark ('Sizes of x and signal arrays do not correspond (integrate_1d_points)')
		ierr = ERR
		return
	endif
	if (size(e) /= nx) then
		call remark ('Sizes of signal and error arrays do not correspond (integrate_1d_points)')
		ierr = ERR
		return
	endif
	if (nx <= 1) then
		call remark ('Must have at least two data points to perform integration (integrate_1d_points)')
		ierr = ERR
		return
	endif

	nb = size(xout)-1
	if (nb<1) then
		call remark ('Size of output integration limits array too small (integrate_1d_points)')
		ierr = ERR
		return
	endif

! Get integration ranges:
! --------------------------

    ! Check that there is an overlap between the integration range and the points
    if (x(nx)<=xout(1) .or. xout(nb+1)<=x(1)) then
        return
    endif

    ! Get to starting output bin and input data point
    if (xout(1)>=x(1)) then
        ml=lower_index(x,xout(1))       ! xout(1) <= x(ml)
        ib=1;
    else
        ml=1;
        ib=upper_index(xout,x(1))       ! xout(ib) <= x(1)
    endif

    ! At this point, we have xout(ib)<=x(ml) for the first output bin, index ib, that overlaps with input data range
    ! Now get mu s.t. x(mu)<=xout(ib+1)
    do 
        if (ib>nb) return
        mu=ml-1;    ! can have mu=ml-1 if there are no data points in the interval [xout(ib),xout(ib+1)]
        do
            if (mu>=nx) exit
            if (x(mu+1)>xout(ib+1)) exit    ! Can you believe it: the stupid Intel compiler evaluates BOTH in (mu>=nx .or. x(mu+1)>xout(ib+1)
            mu=mu+1;
        end do
        ! Gets here if (1) x(mu+1)>xout(ib+1), or (2) mu=nx in which case the last x point is in output bin index ib
        call single_integrate_1d_points(x,s,e,xout(ib),xout(ib+1),ml,mu,sout(ib),eout(ib));
        ! Update ml for next output bin
        if (mu==nx .or. ib==nb) then
            return  ! no more output bins in the range [x(1),x(end)], or completed last output bin
        endif
        ib=ib+1;
        if (x(mu)<xout(ib)) then
            ml=mu+1;
        else
            ml=mu;
        endif
    end do

    end
