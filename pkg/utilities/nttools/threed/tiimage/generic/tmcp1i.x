
#  TM_CP1  --  Fill pixel buffer and copy into table.
#
#
#
#
#  Revision history:
#  ----------------
#  30-Jan-97  -  Task created (I.Busko)


procedure tm_cp1i (im, tp, cp, row, lena, leni)

pointer	im		# imio pointer
pointer	tp		# table pointer
pointer	cp		# column pointer
int	row		# row where to begin insertion
int	lena		# array length
int	leni		# image length
#--
pointer	buf
double	undefd
real	undefr
int	undefi, i, len
short	undefs

pointer imgl1i()

begin
	# Read pixels into buffer.
	buf = imgl1i (im)

	# Choose the minimum between image and table array 
	# lengths as the array size to be written to table.
	len = min (lena, leni)

	# Write buffer into array cell element.
	call tbapti (tp, cp, row, Memi[buf], 1, len)

	# If image is smaller than array, set
	# remaining elements to INDEF.
	if (leni < lena) {
	    undefd = INDEFD
	    undefr = INDEFR
	    undefi = INDEFI
	    undefs = INDEFS
	    do i = len+1, lena
	        call tbapti (tp, cp, row, undefi, i, 1)
	}
end




