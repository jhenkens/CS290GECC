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


//+(void)testMain
//{
//    PrimeCurve* prime = [ECC getD121Curve];
//    BigJacobPoint* jp1 = [[BigJacobPoint alloc] init];
//    BigPoint* p1 = [[BigPoint alloc] init];
//    BIGNUM* temp = BN_new();
//
//    // (27,91) -> Jacob (3,3,3) : (27/(3^3) , 91/(3^3), 3)
////    BN_set_word([jp1 x],3);
////    BN_set_word([jp1 y],3);
//    BN_dec2bn(&temp, "4707826301540010572876842067405749812062931525292743720960");
//    BN_copy([jp1 x],temp);
//    BN_dec2bn(&temp, "2353913150770005286438421033702874906031465762646371860480");
//    BN_copy([jp1 y],temp);
//    BN_set_word([jp1 z],1);
//    [jp1 toPoint:p1 modulo:[prime p]];
//    NSLog(@"%@",jp1);
//    NSLog(@"%@",p1);
//    
//    BN_set_word(temp, 3);
//    BN_set_negative(temp, 0);
//    printf("%d\n",BN_is_word(temp, 3));
//    
//}

+(void)testMain2
{
    PrimeCurve* prime = [ECC getD121Curve];
    BigPoint* p1 = [[BigPoint alloc] init];
    BigPoint* p2 = [[BigPoint alloc] init];
    BigPoint* r = [[BigPoint alloc] init];
    BigPoint* r2 = [[BigPoint alloc] init];
    BigJacobPoint* pj1 = [[BigJacobPoint alloc] init];
    BigJacobPoint* pj2 = [[BigJacobPoint alloc] init];
    BigJacobPoint* rj1 = [[BigJacobPoint alloc] init];
    BigJacobPoint* rj2 = [[BigJacobPoint alloc] init];
    BIGNUM* temp = BN_new();
    
    BN_dec2bn(&temp, "2154360660537946610207436656056507518107437989975993284250");
    BN_copy([p1 x],temp);
    BN_dec2bn(&temp, "2602884946809268339044418193606682176060144637205295389227");
    BN_copy([p1 y],temp);
    BN_dec2bn(&temp, "2835104286271553758739026755942804066882570039948637940091");
    BN_copy([p2 x],temp);
    BN_dec2bn(&temp, "1254825656320893673375849154742964262411653302661321552964");
    BN_copy([p2 y],temp);
    [prime addPoints:p1 point2:p2 result:r];
//    NSLog(@"%@\n",r);
    
    [p1 toJacobianPont:pj1];
    [p2 toJacobianPont:pj2];
//    NSLog(@"%@",pj2);
    [prime addJacobPoints:pj1 point2:pj2 result:rj1];
    [rj1 toPoint:r2 modulo:[prime p]];
//    NSLog(@"%@\n",r2);
//
//    BN_set_negative([p1 y],1);
//    [prime addPoints:r point2:p1 result:r2];
//    NSLog(@"%@ \n %@",r2, p2);
//    
//    [r toJacobianPont:rj1];
//    [p1 toJacobianPont:pj1];
//    [prime addJacobPoints:rj1 point2:pj1 result:rj2];
//    [rj2 toPoint:r2 modulo:[prime p]];
//    NSLog(@"%@ \n %@",r2, p2);
//    
//    PrimeCurve* test2 = [[PrimeCurve alloc] initWithDecStringP:@"23" n:@"2" SEED:@"3" c:@"4" b:@"1" a:@"1" Gx:@"1" Gy:@"1"];
//    BN_set_word([p1 x], 3);
//    BN_set_word([p1 y],10);
//    BN_set_word([p2 x],3);
//    BN_set_word([p2 y],10);
//    BN_set_word(temp,4);
//    BN_clear_bit(temp, 2);
////    printf("#######%s\n",BN_bn2dec(temp));
//    [test2 addPoints:p1 point2:p2 result:r];

//    NSLog(@"G: %@",[prime g]);
    
    BN_set_word(temp,1879234123);
    [prime multGByD:temp result:r];
    NSLog(@"%@",r);
    [prime multGByJacobianD:temp result:r2];
    NSLog(@"%@",r2);
//
    BN_free(temp);
}

+(void)testMain
{
//    PrimeCurve* prime = [ECC getD121Curve];
//    BIGNUM* temp = BN_new();
//    BIGNUM* temp2 = BN_new();
//    BIGNUM* temp3 = BN_new();
//    BIGNUM* res = BN_new();
//    BN_CTX* context = BN_CTX_new();
//    BN_CTX_start(context);
//    
//    BN_dec2bn(&temp, "2154360660537946610207436656056507518107437989975993284250");
//    
//    BN_set_word(temp2, 2);
//    BN_mod_inverse(temp3, temp2, [prime p], context);
//    BN_mod_mul(res,temp,temp3,[prime p], context);
//    BN_rshift1(temp2, temp);
//    
//    NSLog(@"%s\n",BN_bn2dec(res));
//    NSLog(@"%s\n",BN_bn2dec(temp2));
    [self testMain2];
}

+ (void) HW2Driver
{
    PrimeCurve* curve = [self getD121Curve];
    
    BIGNUM* rand192 = BN_new();
    BIGNUM* rand144 = BN_new();
    BIGNUM* rand96 = BN_new();
    BigPoint* resAff = [[BigPoint alloc] init];
    BigPoint* resJab = [[BigPoint alloc] init];
    
    BN_rand(rand192, 192, 0, false);
    while(BN_cmp(rand192,[curve n]) >= 0)
    {
        BN_rand(rand192, 192, 0, false);
    }
    BN_rand(rand144, 144, 0, false);
    BN_rand(rand96, 96, 0, false);
    NSLog(@"N192: %s",BN_bn2dec(rand192));
    NSLog(@"N144: %s",BN_bn2dec(rand144));
    NSLog(@"N96: %s",BN_bn2dec(rand96));
    
    [curve multGByD:rand192 result:resAff];
    [curve multGByJacobianD:rand192 result:resJab];
    NSLog(@"Testing equality with 192 bit...");
    assert([resAff isEqual:resJab]);
    
    [curve multGByD:rand144 result:resAff];
    [curve multGByJacobianD:rand144 result:resJab];
    NSLog(@"Testing equality with 144 bit...");
    assert([resAff isEqual:resJab]);
    
    [curve multGByD:rand96 result:resAff];
    [curve multGByJacobianD:rand96 result:resJab];
    NSLog(@"Testing equality with 96 bit...");
    assert([resAff isEqual:resJab]);
    NSLog(@"Testing done! Beginning performance timings...");
    
    BIGNUM* curr;
    for(int i = 0; i <3; i++){
        int iterations = 0;
        int bits = 0;
        NSTimeInterval start, duration;
        switch(i){
            case 0:
                curr = rand192;
                bits = 192;
                iterations = 2000;
                break;
            case 1:
                curr = rand144;
                bits = 144;
                iterations = 3500;
                break;
            case 2:
                curr = rand96;
                bits = 96;
                iterations = 4500;
                break;
            default:
                exit(1);
        }
        
        start = [NSDate timeIntervalSinceReferenceDate];
        for(int i = 0; i < iterations;i++){
            [curve multGByD:curr result:resAff];
        }
        duration = [NSDate timeIntervalSinceReferenceDate] - start;
        NSLog(@"Finished affine testing for %d bits with %d iterations. Duration: %f, Average: %f",bits,iterations,duration,duration/iterations);
        
        start = [NSDate timeIntervalSinceReferenceDate];
        for(int i = 0; i < iterations;i++){
            [curve multGByJacobianD:curr result:resAff];
        }
        duration = [NSDate timeIntervalSinceReferenceDate] - start;
        NSLog(@"Finished projective testing for %d bits with %d iterations. Duration: %f, Average: %f",bits,iterations,duration,duration/iterations);
        
    }
    NSLog(@"Done with performance testing!");
}

@end
