# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <pkg/rg.h>
include	"icfit.h"
include	"names.h"

# IC_CLEAN -- Replace rejected points by the fitted values.

procedure ic_cleanr (ic, cv, x, y, w, npts)

pointer	ic				# ICFIT pointer
pointer	cv				# Curfit pointer
real	x[npts]				# Ordinates
real	y[npts]				# Abscissas
real	w[npts]				# Weights
int	npts				# Number of points

int	i, nclean, newreject
pointer	sp, xclean, yclean, wclean

real	rcveval()

begin
	if ((IC_LOW(ic) == 0.) && (IC_HIGH(ic) == 0.))
	    return

	# If there has been no subsampling and no sample averaging then the
	# IC_REJPTS(ic) array already contains the rejected points.

	if (npts == IC_NFIT(ic)) {
	    if (IC_NREJECT(ic) > 0) {
	        do i = 1, npts {
		    if (Memi[IC_REJPTS(ic)+i-1] == YES)
		        y[i] = rcveval (cv, x[i])
	        }
	    }

	# If there has been no sample averaging then the rejpts array already
	# contains indices into the subsampled array.

	} else if (abs(IC_NAVERAGE(ic)) < 2) {
	    if (IC_NREJECT(ic) > 0) {
	        do i = 1, npts {
		    if (Memi[IC_REJPTS(ic)+i-1] == YES)
			Memr[IC_YFIT(ic)+i-1] =
			    rcveval (cv, Memr[IC_XFIT(ic)+i-1])
		}
	    }
	    call rg_unpackr (IC_RG(ic), Memr[IC_YFIT(ic)], y)

	# Because ic_fit rejects points from the fitting data which
	# has been sample averaged the rejpts array refers to the wrong data.
	# Do the cleaning using ic_deviant to find the points to reject.

	} else if (RG_NPTS(IC_RG(ic)) == npts) {
	    call amovki (NO, Memi[IC_REJPTS(ic)], npts)
	    call ic_deviantr (cv, x, y, w, Memi[IC_REJPTS(ic)], npts,
		IC_LOW(ic), IC_HIGH(ic), IC_GROW(ic), NO, IC_NREJECT(ic),
		newreject)
	    if (IC_NREJECT(ic) > 0) {
	        do i = 1, npts {
		    if (Memi[IC_REJPTS(ic)+i-1] == YES)
			y[i] = rcveval (cv, x[i])
		}
	    }

	# If there is subsampling then allocate temporary arrays for the
	# subsample points.

	} else {
	    call smark (sp)
	    nclean = RG_NPTS(IC_RG(ic))
	    call salloc (xclean, nclean, TY_REAL)
	    call salloc (yclean, nclean, TY_REAL)
	    call salloc (wclean, nclean, TY_REAL)
	    call rg_packr (IC_RG(ic), x, Memr[xclean])
	    call rg_packr (IC_RG(ic), y, Memr[yclean])
	    call rg_packr (IC_RG(ic), w, Memr[wclean])
	    call amovki (NO, Memi[IC_REJPTS(ic)], npts)
	    call ic_deviantr (cv, Memr[xclean], Memr[yclean],
		Memr[wclean], Memi[IC_REJPTS(ic)], nclean, IC_LOW(ic),
		IC_HIGH(ic), IC_GROW(ic), NO, IC_NREJECT(ic), newreject)
	    if (IC_NREJECT(ic) > 0) {
	        do i = 1, npts {
		    if (Memi[IC_REJPTS(ic)+i-1] == YES)
			Memr[yclean+i-1] = rcveval (cv, Memr[xclean+i-1])
		}
	    }
	    call rg_unpackr (IC_RG(ic), Memr[yclean], y)
	    call sfree (sp)
	}
end
