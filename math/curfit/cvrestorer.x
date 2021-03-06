# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <math/curfit.h>

include "curfitdef.h"

# CVRESTORE -- Procedure to restore fit parameters saved by CVSAVE 
# for use by CVEVAL and CVVECTOR. The parameters are assumed to
# be stored in fit in the following order, curve_type, order, xmin,
# xmax, followed by the coefficients.

procedure cvrestore (cv, fit)

pointer	cv		# curve descriptor
real	fit[ARB]	# array containing fit parameters

int	curve_type, order

errchk malloc

begin
	# allocate space for curve descriptor
	call malloc (cv, LEN_CVSTRUCT, TY_STRUCT)

	order = nint (CV_SAVEORDER(fit))
	if (order < 1)
	    call error (0, "CVRESTORE: Illegal order.")

	if (CV_SAVEXMAX(fit) <= CV_SAVEXMIN(fit))
	    call  error (0, "CVRESTORE: xmax <= xmin.")

	# set curve_type dependent curve descriptor parameters
	curve_type = nint (CV_SAVETYPE(fit))
	switch (curve_type) {
	case CHEBYSHEV, LEGENDRE:
	    CV_ORDER(cv) = order
	    CV_NCOEFF(cv) = order
	    CV_RANGE(cv) = 2. / (CV_SAVEXMAX(fit) - CV_SAVEXMIN(fit))
	    CV_MAXMIN(cv) = - (CV_SAVEXMAX(fit) + CV_SAVEXMIN(fit)) / 2.
	    CV_USERFNC(cv) = NULL
	case SPLINE3:
	    CV_ORDER(cv) = SPLINE3_ORDER
	    CV_NCOEFF(cv) = order + SPLINE3_ORDER - 1
	    CV_NPIECES(cv) = order - 1
	    CV_SPACING(cv) = order / (CV_SAVEXMAX(fit) - CV_SAVEXMIN(fit))
	    CV_USERFNC(cv) = NULL
	case SPLINE1:
	    CV_ORDER(cv) = SPLINE1_ORDER
	    CV_NCOEFF(cv) = order + SPLINE1_ORDER - 1
	    CV_NPIECES(cv) = order - 1
	    CV_SPACING(cv) = order / (CV_SAVEXMAX(fit) - CV_SAVEXMIN(fit))
	    CV_USERFNC(cv) = NULL
	case USERFNC:
	    CV_ORDER(cv) = order
	    CV_NCOEFF(cv) = order
	    CV_RANGE(cv) = 2. / (CV_SAVEXMAX(fit) - CV_SAVEXMIN(fit))
	    CV_MAXMIN(cv) = - (CV_SAVEXMAX(fit) + CV_SAVEXMIN(fit)) / 2.
	    CV_USERFNCR(cv) = CV_SAVEFNC(fit)	# avoids type conversion
	default:
	    call error (0, "CVRESTORE: Unknown curve type.")
	}

	# set remaining curve parameters
	CV_TYPE(cv) = curve_type
	CV_XMIN(cv) = CV_SAVEXMIN(fit)
	CV_XMAX(cv) = CV_SAVEXMAX(fit)

	# allocate space for xbasis and coefficient arrays, set remaining
	# pointers to NULL

	call calloc (CV_XBASIS(cv), CV_ORDER(cv), TY_REAL)
	call calloc (CV_COEFF(cv), CV_NCOEFF(cv), TY_REAL)

	CV_MATRIX(cv) = NULL
	CV_CHOFAC(cv) = NULL
	CV_VECTOR(cv) = NULL
	CV_BASIS(cv) = NULL
	CV_LEFT(cv) = NULL
	CV_WY(cv) = NULL

	# restore coefficients
	if (CV_TYPE(cv) == USERFNC)
	    call amovr (fit[CV_SAVECOEFF+1], COEFF(CV_COEFF(cv)),
	        CV_NCOEFF(cv))
	else
	    call amovr (fit[CV_SAVECOEFF], COEFF(CV_COEFF(cv)),
	        CV_NCOEFF(cv))
end
