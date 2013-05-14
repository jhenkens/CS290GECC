//
//  ECC.h
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bn.h>
#import "PrimeCurve.h"


/*
 Steps:
 1) Implement the computation of the EC point multiplication operating [d]P given the curve and its generating point P
 and the order n, for an integer d<n. This is the core operation for EC-DH, EC-DSA, and EC-IES.
 2) For the point multiplication operation, use the binary method and the signed-digit expansion of the exponent d, such that d'
 is expanded using the digit set {0,1,-1} and the canonical recording algorithm given in the report
 http://cs.ucsb.edu/~koc/ac/docs/w01/r01rsasw.pdf
 3) Multiplications can be performed using the multi-precision library you are using. For inversion, you can use
 Fermat's method (alpha)^(-1) = (alpha) ^ ( p - 2 ) % p
 4) Implement both the affine and projective coordinate systems. The affine formulas are in
 http://cs.ucsb.edu/~koc/ac/docs/w03/w10a-ecc.pdf while the projective formulas are in
 http://cs.ucsb.edu/~koc/ac/docs/w03/ecc-protocols.pdf .
 5) Give the timings of the computation [d]P for several different sizes of the d, which are 100%, 75%, and 50% size of the point
 order n. For example, if n is 192 bits, then select d as 192 bits, 144 bits, and 96 bits. Compare the timings of the affine
 versus projective coordinate systems for these 3 different sizes.
 
 Select a GF(p) NIST curve from http://cs.ucsb.edu/~koc/ac/docs/w03/fips_186-3.pdf (FIPS 186-3).
 In your report, clearly specifiy which curve you are using and give its parameters p (prime), a, b (curve parameters), P = (x,y)
 (the generating point), and n (the order of the generating point).
 
 */

@interface ECC : NSObject{
    PrimeCurve *__primeCurve;
}
+ (void) testMain;

@property (nonatomic, retain) PrimeCurve* primeCurve;
//- ;
//- phot
//
@end
