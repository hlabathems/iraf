      SUBROUTINE slPRNU (EPOCH, DATE, RMATPN)
*+
*     - - - - - - -
*      P R N U
*     - - - - - - -
*
*  Form the matrix of precession and nutation (IAU1976/FK5)
*  (double precision)
*
*  Given:
*     EPOCH   dp         Julian Epoch for mean coordinates
*     DATE    dp         Modified Julian Date (JD-2400000.5)
*                        for true coordinates
*
*  Returned:
*     RMATPN  dp(3,3)    combined precession/nutation matrix
*
*  Called:  slPREC, slEPJ, slNUT, slDMXM
*
*  Notes:
*
*  1)  The epoch and date are TDB (loosely ET).
*
*  2)  The matrix is in the sense   V(true)  =  RMATPN * V(mean)
*
*  P.T.Wallace   Starlink   April 1987
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*  Copyright (C) 1995 Association of Universities for Research in Astronomy Inc.
*-

      IMPLICIT NONE

      DOUBLE PRECISION EPOCH,DATE,RMATPN(3,3)

      DOUBLE PRECISION RMATP(3,3),RMATN(3,3),slEPJ



*  Precession
      CALL slPREC(EPOCH,slEPJ(DATE),RMATP)

*  Nutation
      CALL slNUT(DATE,RMATN)

*  Combine the matrices:  PN = N x P
      CALL slDMXM(RMATN,RMATP,RMATPN)

      END
