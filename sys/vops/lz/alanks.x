# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# ALANK -- Compute the logical AND of a vector and a constant (generic).
# The logical output value is returned as an int.

procedure alanks (a, b, c, npix)

short	a[ARB], b
int	c[ARB]

int	npix, i

begin
	do i = 1, npix
	    if (a[i] != 0 && b != 0)
		c[i] = YES
	    else
		c[i] = NO
end
