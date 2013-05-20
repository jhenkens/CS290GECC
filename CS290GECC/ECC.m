//
//  ECC.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "ECC.h"
#import "BigPoint.h"

@implementation ECC


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
        n:@"fffffffffffffffffffffff99def836146bc9b1b4d22831"
        SEED:@"3045ae6fc8422f64ed579528d38120eae12196d5"
        c:@"3099d2bbbfcb2538542dcd5fb078b6ef5f3d6fe2c745de65"
        b:@"64210519e59c80e70fa7e9ab72243049feb8deecc146b9b1"
        a:@"-3"
        Gx:@"188da80eb03090f67cbf20eb43a18800f4ff0afd82ff1012"
        Gy:@"07192b95ffc8da78631011ed6b24cdd573f977a11e794811"];
    return result;
}

+(void)testMain{
    PrimeCurve* prime = [ECC getD121Curve];
    BigPoint* p1 = [[BigPoint alloc] init];
    BigPoint* p2 = [[BigPoint alloc] init];
    BigPoint* r = [[BigPoint alloc] init];
    BIGNUM* temp = BN_new();
    
    BN_dec2bn(&temp, "2154360660537946610207436656056507518107437989975993284250");
    BN_copy([p1 x],temp);
    BN_dec2bn(&temp, "2602884946809268339044418193606682176060144637205295389227");
    BN_copy([p1 y],temp);
    [p2 copyPoint:p1];
//    BN_dec2bn(&x2, "2835104286271553758739026755942804066882570039948637940091");
//    BN_dec2bn(&y2, "1254825656320893673375849154742964262411653302661321552964");
    [prime addPoints:p1 point2:p2 result:r];
//    NSLog(@"%@",r);
    [prime addPoints:p1 point2:p1 result:r];
//    NSLog(@"%@",r);
    
    PrimeCurve* test2 = [[PrimeCurve alloc] initWithDecStringP:@"23" n:@"2" SEED:@"3" c:@"4" b:@"1" a:@"1" Gx:@"1" Gy:@"1"];
    BN_set_word([p1 x], 3);
    BN_set_word([p1 y],10);
    BN_set_word([p2 x],3);
    BN_set_word([p2 y],10);
//    [test2 addPoints:p1 point2:p2 result:r];

    
    BN_set_word(temp,253);
    [prime multGByD:temp result:r];
    NSLog(@"%@",r);
    
    BN_free(temp);
}

@end
