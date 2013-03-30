# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<config.h>
include	<syserr.h>

# SALLOC.X -- Stack management routines.  Stack storage is allocated in
# segments.  Space for each segment is dynamically allocated on the heap.
# Each segment contains a pointer to the previous segment to permit
# reclamation of the space (see "Mem.hlp" for additional details).
# This is a low level facility, hence any failure to allocate or deallocate
# stack storage is fatal.


# Segment header structure.  The header size parameter SZ_STKHDR is defined
# in <config.h> because it is potentially machine dependent.  SZ_STKHDR
# must be chosen such that the maximum alignment criteria is maintained.

define	SH_BASE		Memi[$1]	# char pointer to base of segment
define	SH_TOP		Memi[$1+1]	# char pointer to top of segment + 1
define	SH_OLDSEG	Memi[$1+2]	# struct pointer to header of prev.seg.


# SALLOC -- Allocate space on the stack.

procedure salloc (output_pointer, nelem, datatype)

pointer	output_pointer		# buffer pointer (output)
int	nelem			# number of elements of storage required
int	datatype		# datatype of the storage elements

int	nchars, dtype, sh_top
include	<szdtype.inc>
pointer	sp, cur_seg
common	/salcom/ sp, cur_seg

begin
	dtype = datatype
	if (dtype < 1 || dtype > MAX_DTYPE)
	    call sys_panic (500, "salloc: bad datatype code")

	# Align stack pointer for any data type.  Compute amount of
	# storage to be allocated.  Always add space for at least one
	# extra char for the EOS in case a string is stored in the buffer.

	sp = (sp + SZ_MEMALIGN-1) / SZ_MEMALIGN * SZ_MEMALIGN + 1
	if (dtype == TY_CHAR)
	    nchars = nelem + 1				# add space for EOS
	else
	    nchars = nelem * ty_size[dtype] + 1

	# Check for stack overflow, add new segment if out of room.
	# Since SMARK must be called before SALLOC, cur_seg cannot be
	# null, but we check anyhow.
	call zeq(sh_top,Memi[cur_seg+1])
	if (cur_seg == NULL || sp + nchars >= sh_top)
	    call stk_mkseg (cur_seg, sp, nchars)

	if (dtype == TY_CHAR)
	    output_pointer = sp
	else
	    output_pointer = (sp-1) / ty_size[dtype] + 1

	sp = sp + nchars			# bump stack pointer
#	call zzmsg("salloc - output_pointer", output_pointer)
#	call zzmsg("       - cur_seg", cur_seg)
#	call zzmsg("       - sp", sp)
end

# SMARK -- Mark the position of the stack pointer, so that stack space
# can be freed by a subsequent call to SFREE.  This routine also performs
# initialization of the stack, since it the very first routine called
# during task startup.

procedure smark (old_sp)

pointer	old_sp			# value of the stack pointer (output)
bool	first_time
pointer	sp, cur_seg
common	/salcom/ sp, cur_seg
data	first_time /true/

begin
	if (first_time) {
	    sp = NULL
	    cur_seg = NULL
	    call stk_mkseg (cur_seg, sp, SZ_STACK)
	    first_time = false
	}

	old_sp = sp
end


# SFREE -- Free space on the stack.  Return whole segments until segment
# containing the old stack pointer is reached.

procedure sfree (old_sp)

pointer	old_sp			# previous value of the stack pointer
pointer	old_seg
int sh_base, sh_top, sh_oldseg
pointer	sp, cur_seg
common	/salcom/ sp, cur_seg

begin
	# The following is needed to avoid recursion when SFREE is called
	# by the IRAF main during processing of SYS_MSSTKUNFL.

	if (cur_seg == NULL)
	    return
	    
	# If the stack underflows (probably because of an invalid pointer)
	# it is a fatal error.

        call zeq(sh_base,Memi[cur_seg])
	call zeq(sh_top,Memi[cur_seg+1])
	call zeq(sh_oldseg,Memi[cur_seg+2])

#	call zzmsg("sfree - old_sp", old_sp)
#	call zzmsg("      - cur_seg", cur_seg)
#	call zzmsg("      - sh_base", sh_base)
#	call zzmsg("      - sh_top", sh_top)
#	call zzmsg("      - sh_oldseg", sh_oldseg)

	while (old_sp < sh_base || old_sp > sh_top) {
	    if (sh_oldseg == NULL)
		call sys_panic (SYS_MSSTKUNFL, "Salloc underflow")

	    old_seg = sh_oldseg		# discard segment
	    call mfree (cur_seg, TY_STRUCT)
	    cur_seg = old_seg
	    call zeq(sh_base,Memi[cur_seg])
	    call zeq(sh_top,Memi[cur_seg+1])
	    call zeq(sh_oldseg,Memi[cur_seg+2])
	    call zzmsg("sfreel - old_sp", old_sp)
	    call zzmsg("      - cur_seg", cur_seg)
	    call zzmsg("      - sh_base", sh_base)
	    call zzmsg("      - sh_top", sh_top)
	    call zzmsg("      - sh_oldseg", sh_oldseg)
	}

	sp = old_sp					# pop stack
end


# STK_MKSEG -- Create and add a new stack segment (link at head of the
# segment list).  Called during initialization, and upon stack overflow.

procedure stk_mkseg (cur_seg, sp, segment_size)

pointer	cur_seg			# current segment
pointer	sp			# salloc stack pointer
int	segment_size		# size of new stack segment

int	nchars, new_seg
pointer	coerce() 
int	kmalloc()

begin
	# Compute size of new segment, allocate the buffer.
	nchars = max (SZ_STACK, segment_size) + SZ_STKHDR
	if (kmalloc (new_seg, nchars / SZ_STRUCT, TY_STRUCT) == ERR)
	    call sys_panic (SYS_MFULL, "Out of memory")

	# Output new stack pointer.
	sp = coerce (new_seg, TY_STRUCT, TY_CHAR) + SZ_STKHDR

	# Set up the segment descriptor.
	call zeq(SH_BASE(new_seg), sp)
	call zeq(SH_TOP(new_seg), sp - SZ_STKHDR + nchars)
	call zeq(SH_OLDSEG(new_seg), cur_seg)

#	call zzmsg("stk_mkseg - base", sp)
#	call zzmsg("	      - top", sp - SZ_STKHDR + nchars)
#	call zzmsg("          - cur_seg", cur_seg)
#	call zzmsg("          - new_seg", new_seg)

	# Make new segment the current segment.
	cur_seg = new_seg
end
