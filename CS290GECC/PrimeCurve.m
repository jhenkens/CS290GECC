//
//  PrimeCurve.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "PrimeCurve.h"

@implementation PrimeCurve
@synthesize p = __p;
@synthesize n = __n;
@synthesize SEED = __SEED;
@synthesize c = __c;
@synthesize b = __b;
@synthesize a = __a;
@synthesize g = __g;

- (id) init
{
    if ( self = [super init])
    {
        [self setP:BN_new()];
        [self setN:BN_new()];
        [self setSEED:BN_new()];
        [self setC:BN_new()];
        [self setB:BN_new()];
        [self setA:BN_new()];
        [self setG:[[BigPoint alloc] init]];
    }
    return self;
}

- (id) initWithDecStringP:(NSString*) p_
                        n:(NSString*) n_
                     SEED:(NSString*) SEED_
                        c:(NSString*) c_
                        b:(NSString*) b_
                        a:(NSString*) a_
                       Gx:(NSString*) Gx_
                       Gy:(NSString*) Gy_
{
    if(self = [self init])
    {
        
        BIGNUM *temp = BN_new();
        
        BN_dec2bn(&temp,[p_ UTF8String]);
        BN_copy([self p],temp);
        
        BN_dec2bn(&temp,[n_ UTF8String]);
        BN_copy([self n],temp);
        
        BN_dec2bn(&temp,[SEED_ UTF8String]);
        BN_copy([self SEED],temp);
        
        BN_dec2bn(&temp,[c_ UTF8String]);
        BN_copy([self c],temp);
        
        BN_dec2bn(&temp,[b_ UTF8String]);
        BN_copy([self b],temp);
        
        BN_dec2bn(&temp,[a_ UTF8String]);
        BN_copy([self a],temp);
        
        BN_dec2bn(&temp,[Gx_ UTF8String]);
        BN_copy([[self g] x],temp);
        
        BN_dec2bn(&temp,[Gy_ UTF8String]);
        BN_copy([[self g] y],temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initWithHexStringP:(NSString*) p_
                        n:(NSString*) n_
                     SEED:(NSString*) SEED_
                        c:(NSString*) c_
                        b:(NSString*) b_
                        a:(NSString*) a_
                       Gx:(NSString*) Gx_
                       Gy:(NSString*) Gy_
{
    if(self = [self init])
    {
        
        BIGNUM *temp = BN_new();
        
        BN_hex2bn(&temp,[p_ UTF8String]);
        BN_copy([self p],temp);
        
        BN_hex2bn(&temp,[n_ UTF8String]);
        BN_copy([self n],temp);
        
        BN_hex2bn(&temp,[SEED_ UTF8String]);
        BN_copy([self SEED],temp);
        
        BN_hex2bn(&temp,[c_ UTF8String]);
        BN_copy([self c],temp);
        
        BN_hex2bn(&temp,[b_ UTF8String]);
        BN_copy([self b],temp);
        
        BN_hex2bn(&temp,[a_ UTF8String]);
        BN_copy([self a],temp);
        
        BN_hex2bn(&temp,[Gx_ UTF8String]);
        BN_copy([[self g] x],temp);
        
        BN_hex2bn(&temp,[Gy_ UTF8String]);
        BN_copy([[self g] y],temp);
        
        BN_free(temp);
    }
    return self;
}

/*
 Infinity/O is current represented by nil for both the x and y of a point.
 TODO: Make this method not suck cryptographically for sidechannel analysis.
 AKA, get rid of if elses, make runtime similar regardless of inputs.
 Assumes [r x] and [r y] are initialized when passed in. Deletes them if it returns infinity.
 */


- (void) addPoints: (BigPoint*) p1
            point2: (BigPoint*) p2
            result: (BigPoint*) r{
    BN_CTX* context= BN_CTX_new();
    [self addPoints:p1 point2:p2 result:r context:context];
    BN_CTX_free(context);
}

- (void) addPoints: (BigPoint*) p1
            point2: (BigPoint*) p2
            result: (BigPoint*) r
           context: (BN_CTX*) context{

    BN_CTX_start(context);
    BIGNUM* temp = BN_CTX_get(context);
    BN_copy(temp,[p1 y]);
    BN_set_negative(temp, !BN_is_negative(temp));
    
    if( [p1 x] == nil && [p1 y] == nil){
        [r copyPoint:p2];
        return;
    } else if([p2 x]==nil && [p2 y] == nil){
        [r copyPoint:p1];
        return;
    } else if((BN_cmp([p1 x],[p2 x])==0) && (BN_cmp([p2 y],temp) == 0)){
        [r setInf:YES];
        return;
    }
    
    BIGNUM* slope = BN_CTX_get(context);
    BIGNUM* temp2 = BN_CTX_get(context);
    BIGNUM* rTemp = BN_CTX_get(context);
    //If [p1 x] != [p2 x], this will be -1 or 1, both of which should go through.
    if(BN_cmp([p1 x],[p2 x]) != 0){
        BN_mod_sub(temp2, [p2 y], [p1 y], [self p], context);
        BN_mod_sub(temp,[p2 x],[p1 x], [self p], context);
        BN_mod_inverse(temp, temp, [self p], context);
        BN_mod_mul(slope, temp, temp2, [self p], context);
    } else{
        BN_mod_sqr(temp2, [p1 x], [self p], context);
        BN_mul_word(temp2, 3);
        BN_mod(temp, temp2, [self p], context);
        BN_mod_add(temp2,temp,[self a],[self p],context);
        BN_mod_lshift1(temp, [p1 y], [self p], context);
        BN_mod_inverse(temp, temp, [self p], context);
        BN_mod_mul(slope, temp, temp2, [self p], context);
    }
    
    BN_mod_sqr(temp, slope, [self p], context);
    BN_mod_sub(temp2,temp,[p1 x],[self p],context);
    BN_mod_sub(rTemp,temp2,[p2 x],[self p],context); //Here, rTemp = [r x]
    //We use rTemp so we can do addPoint (a, a, a);
    
    
    BN_mod_sub(temp,[p1 x],rTemp,[self p],context);
    BN_mod_mul(temp2, temp, slope,[self p], context);
    BN_copy([r x], rTemp);
    BN_mod_sub(rTemp,temp2,[p1 y],[self p],context);
    BN_copy([r y], rTemp);
    
    BN_CTX_end(context);
}

- (void) multGByD:(BIGNUM*)d result:(BigPoint *)r{
    BN_CTX* context = BN_CTX_new();
    BN_CTX_start(context);
    
    BigPoint* temp = [[BigPoint alloc] initFromBigNumX:BN_CTX_get(context) y:BN_CTX_get(context)];
    [temp copyPoint:[self g]];
    
    int len = BN_num_bits(d);
    assert(len!=0);

    BOOL notFirst = NO;
    
    BOOL ci = NO;
    BOOL currBit = BN_is_bit_set(d, 0);
    BOOL nextBit;
    
    
    for (int i = 0; i<len+1; i++){
        nextBit = BN_is_bit_set(d, i+1);
        if(currBit ^ ci){

            if(nextBit){
                BN_set_negative([temp y], 1);
                //Subtract current
            }
            if(notFirst){
                [self addPoints:temp point2:r result:r context:context];
            } else{
                [r copyPoint:temp];
                notFirst = YES;
            }
            if(nextBit){
                BN_set_negative([temp y], 0);
                //Subtract current
            }
        }
        if((ci + currBit + nextBit) >= 2){
            ci = YES;
        } else{
            ci = NO;
        }
        currBit = nextBit;
        [self addPoints:temp point2:temp result:temp context:context];

    }
}

- (void) dealloc
{
    BN_free([self p]);
    BN_free([self n]);
    BN_free([self SEED]);
    BN_free([self c]);
    BN_free([self b]);
    BN_free([self a]);
}

- (void) finalize
{
    BN_free([self p]);
    BN_free([self n]);
    BN_free([self SEED]);
    BN_free([self c]);
    BN_free([self b]);
    BN_free([self a]);
    [super finalize];
}

@end
