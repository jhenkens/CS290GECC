//
//  ECC.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "ECC.h"
#import "BigPoint.h"
#import "BigJacobPoint.h"

@implementation ECC

@synthesize privateKey = __privateKey;
@synthesize publicKey = __publicKey;
@synthesize curve = __curve;
@synthesize sharedSecret = __sharedSecret;

- (id) init
{
    self = [self initWithCurve:[ECC getD121Curve]];
    return self;
}

- (id) initWithCurve:(PrimeCurve *)curve_
{
    if ( self = [super init])
    {
        [self setCurve:curve_];
        [self setPrivateKey:BN_new()];
        do{
            BN_rand([self privateKey], BN_num_bits([[self curve] n]), -1, 0);
        }
        while (BN_cmp([self privateKey], [[self curve] n]) >=0);
        [self setPublicKey:[[BigPoint alloc] init]];
        [[self curve] multiplyPointProjectively:[[self curve] g] byNumber:[self privateKey] result:[self publicKey]];
        
        [self setSharedSecret:[[BigPoint alloc] init]];
    }
    return self;
}

- (void) makeSharedSecretFromPublicPoint:(BigPoint *)point
{
    [[self curve] multiplyPointProjectively:point byNumber:[self privateKey] result:[self sharedSecret]];
}

/*
 
 For this curve, NIST says it is E: y^2 = x^3 - 3x + b (mod p)
 A typical Elliptic Curve is y^2 = X^3 +ax + b (mod p), thus a = -3.
 The values are:
 p - prime modulus
 n - order
 SEED - 160-bit input seed to the SHA-1 based algorithm (i.e, the domain partner seed)
 c - the output of the Sha-1 based algorithm
 b - The coefficient (satisfying b^2c = -27(modp))
 Gx, Gy - the base point
 */
+ (PrimeCurve*) getD121Curve
{
    PrimeCurve* result = [[PrimeCurve alloc]
        initWithHexStringP:@"fffffffffffffffffffffffffffffffeffffffffffffffff"
        n:@"ffffffffffffffffffffffff99def836146bc9b1b4d22831"
        SEED:@"3045ae6fc8422f64ed579528d38120eae12196d5"
        c:@"3099d2bbbfcb2538542dcd5fb078b6ef5f3d6fe2c745de65"
        b:@"64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1"
        a:@"-3"
        Gx:@"188da80eb03090f67cbf20eb43a18800f4ff0afd82ff1012"
        Gy:@"07192b95ffc8da78631011ed6b24cdd573f977a11e794811"];
    return result;
}

@end
