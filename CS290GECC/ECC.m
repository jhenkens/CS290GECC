//
//  ECC.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "ECC.h"

@implementation ECC

@synthesize primeCurve = __primeCurve;

- (void) initCurveToD121
{
    BIGNUM *temp = BN_new();
    BN_dec2bn(&temp,"6277101735386680763835789423207666416083908700390324961279");
    BN_copy([[self primeCurve] p],temp);
    BN_dec2bn(&temp,"6277101735386680763835789423176059013767194773182842284081");
    BN_copy([[self primeCurve] n],temp);
    BN_hex2bn(&temp,"3045ae6fc8422f64ed579528d38120eae12196d5");
    BN_copy([[self primeCurve] SEED],temp);
    BN_hex2bn(&temp,"3099d2bbbfcb2538542dcd5fb078b6ef5f3d6fe2c745de65");
    BN_copy([[self primeCurve] c],temp);
    BN_hex2bn(&temp,"64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1");
    BN_copy([[self primeCurve] b],temp);
    BN_hex2bn(&temp,"188da80eb03090f67cbf20eb43a18800f4ff0afd82ff1012");
    BN_copy([[self primeCurve] Gx],temp);
    BN_hex2bn(&temp,"07192b95ffc8da78631011ed6b24cdd573f977a11e794811");
    BN_copy([[self primeCurve] Gy],temp);
    return;
}

- (id) init
{
    if ( self = [super init])
    {
        [self setPrimeCurve:[[PrimeCurve alloc] init]];
        [self initCurveToD121];
    }
    return self;
}

+(void)testMain{
    ECC* prime = [[ECC alloc] init];
    BN_print_fp(stdout, [[prime primeCurve] b]);
}

@end
