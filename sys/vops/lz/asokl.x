# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <mach.h>

# ASOK -- Select the Kth smallest element from a vector.  The algorithm used
# is selection by tail recursion (Gonnet 1984).  In each iteration a pivot key
# is selected (somewhat arbitrarily) from the array.  The array is then split
# into two subarrays, those with key values less than or equal to the pivot key
# and those with values greater than the pivot.  The size of the two subarrays
# determines which contains the median value, and the process is repeated
# on that subarray, and so on until all of the elements of the subarray
# are equal, e.g., there is only one element left in the subarray.  For a
# randomly ordered array the expected running time is O(3.38N).  The selection
# is carried out in place, leaving the array in a partially ordered state.
#
# N.B.: Behaviour is O(N) if the input array is sorted.
# N.B.: The cases ksel=1 and ksel=npix, i.e., selection of the minimum and
# maximum values, are more efficiently handled by ALIM which is O(2N).
#
# Jul99 - The above algorithm was found to be pathologically slow in cases
# where many or all elements of the array are equal.  The version of the
# algorithm below, from Wirth, appears to avoid this problem.

long procedure asokl (a, npix, ksel)

long	a[ARB]			# input array
int	npix			# number of pixels
int	ksel			# element to be selected

int	lo, up, i, j, k, dummy
long	temp, wtemp

begin
	lo = 1
	up = npix
	k  = max (lo, min (up, ksel))

	# while (lo < up)
	do dummy = 1, MAX_INT {
	    if (! (lo < up))
		break

	    temp = a[k];  i = lo;  j = up

	    repeat {
		while (a[i] < temp)
		    i = i + 1
		while (temp < a[j])
		    j = j - 1
		if (i <= j) {
		    wtemp = a[i];  a[i] = a[j];  a[j] = wtemp
		    i = i + 1;  j = j - 1
		}
	    } until (i > j)

	    if (j < k)
		lo = i
	    if (k < i)
		up = j
	}

	return (a[k])
end
