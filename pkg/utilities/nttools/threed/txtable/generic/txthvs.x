#
# TXTHV  --  Write scalar value into header.
#
#
#
#
#  Revision history:
#  ----------------
#
#  22-Nov-96  -  Task created (I.Busko)

procedure txthvs (otp, col, buf)

pointer	otp		# i: table descriptor
int	col		# i: column number in input table
short	buf
#--
pointer	keyword

begin
	# Use original column number to build keyword name.
	call malloc (keyword, SZ_LINE, TY_CHAR)
	call sprintf (Memc[keyword], SZ_LINE, "TCV_%03d")
	    call pargi (col)

	call tbhadi (otp, Memc[keyword], int(buf))

	call mfree (keyword, TY_CHAR)
end

