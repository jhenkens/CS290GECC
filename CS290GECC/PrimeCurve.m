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
            result: (BigPoint*) r
{
    BN_CTX* context= BN_CTX_new();
    [self addPoints:p1 point2:p2 result:r context:context];
    BN_CTX_free(context);
}

- (void) addPoints: (BigPoint*) p1
            point2: (BigPoint*) p2
            result: (BigPoint*) r
           context: (BN_CTX*) context
{
    BN_CTX_start(context);
    BIGNUM* temp = BN_CTX_get(context);
    BN_copy(temp,[p1 y]);
    BN_set_negative(temp, !BN_is_negative(temp));
    
    if( [p1 inf])
    {
        [r copyPoint:p2];
    }
    else if([p2 inf])
    {
        [r copyPoint:p1];
    }
    else if((BN_cmp([p1 x],[p2 x])==0) && (BN_cmp([p2 y],temp) == 0))
    {
        [r setInf:YES];
    }
    else
    {
        BIGNUM* slope = BN_CTX_get(context);
        BIGNUM* temp2 = BN_CTX_get(context);
        BIGNUM* rTemp = BN_CTX_get(context);
        //If [p1 x] == [p2 x], we know that [p1 y] == [p2 y] due to the curve, thus we need to double.
        if(BN_cmp([p1 x],[p2 x]) != 0)
        {
            //Do normal addition
            BN_mod_sub(temp2, [p2 y], [p1 y], [self p], context);
            BN_mod_sub(temp,[p2 x],[p1 x], [self p], context);
            BN_mod_inverse(temp, temp, [self p], context);
            BN_mod_mul(slope, temp, temp2, [self p], context);
        }
        else
        {
            //Do doubling
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
    }
    BN_CTX_end(context);
}

- (void) multGByD:(BIGNUM*)d result:(BigPoint *)r
{
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
    
    
    for (int i = 0; i<len+1; i++)
    {
        nextBit = BN_is_bit_set(d, i+1);
        if(currBit ^ ci)
        {
            if(nextBit)
            {
                BN_set_negative([temp y], 1);
                //Subtract current
            }
            if(notFirst)
            {
                [self addPoints:temp point2:r result:r context:context];
            }
            else
            {
                [r copyPoint:temp];
                notFirst = YES;
            }
            if(nextBit)
            {
                BN_set_negative([temp y], 0);
            }
        }
        if((ci + currBit + nextBit) >= 2)
        {
            ci = YES;
        }
        else
        {
            ci = NO;
        }
        currBit = nextBit;
        [self addPoints:temp point2:temp result:temp context:context];

    }
}

- (void) addJacobPoints:(BigJacobPoint *)p1
                 point2:(BigJacobPoint *)p2
                 result:(BigJacobPoint *)r
{
    BN_CTX* context= BN_CTX_new();
    [self addJacobPoints:p1 point2:p2 result:r context:context];
    BN_CTX_free(context);
}

- (void) addJacobPoints:(BigJacobPoint *)p1
                 point2:(BigJacobPoint *)p2
                 result:(BigJacobPoint *)r
                context:(BN_CTX*) context
{
    /*if( [p1 inf])
    {
        [r copyJacobPoint:p2];
    }
    else if([p2 inf])
    {
        [r copyJacobPoint:p1];
    }
    else */if(BN_is_one([p1 z]))
    {
        [self addJacobPointsMixed:p1 point2:p2 result:r context:context];
    }
    else if(BN_is_one([p2 z]))
    {
        //Swap p1 and p2 so that p1.z is 1.
        [self addJacobPointsMixed:p2 point2:p1 result:r context:context];
    }
    else
    {
        BN_CTX_start(context);
        //Normal method:
        BIGNUM* rx = BN_CTX_get(context);
        BIGNUM* ry = BN_CTX_get(context);
        BIGNUM* rz = BN_CTX_get(context);
        BIGNUM* temp1 = BN_CTX_get(context);
        BIGNUM* temp2 = BN_CTX_get(context);
        BIGNUM* temp3 = BN_CTX_get(context);
        
        //L1 : rx ; temp1:z2sqr
        BN_mod_sqr(temp1, [p2 z], [self p], context);
        BN_mod_mul(rx, temp1, [p1 x], [self p], context);
        
        //L2 : ry ; temp2:z1sqr
        BN_mod_sqr(temp2, [p1 z], [self p], context);
        BN_mod_mul(ry, temp2, [p2 x], [self p], context);
        
        //L3 : rz
        BN_mod_sub(rz, rx, ry, [self p], context);
        
        if(BN_is_zero(rz))
        {
            //If it is zero, we are either doubling, or setting to infinity.
            //We need to check lambda6 to know, so lets rush to do that.
            //We need to save z1sqr (temp1) in case it is a doubling,
            
            //L5: ry
            BN_mod_mul(rx, temp2, [p1 z], [self p], context);
            BN_mod_mul(ry, rx, [p2 y], [self p], context);

            //L4: rx
            BN_mod_mul(temp2, temp1, [p2 z], [self p], context);
            BN_mod_mul(rx, temp2, [p1 y], [self p], context);
            
            //L6
            BN_mod_sub(temp2, rx, ry, [self p], context);
            if(BN_is_zero(temp2))
            {
                BOOL fastStart = NO;
                //If it is zero, then we are doubling
                if(BN_is_negative([self a]))
                {
                    BN_set_negative([self a], 0);
                    if(BN_is_word([self a], 3))
                    {
                        fastStart = YES;
                    }
                    BN_set_negative([self a], 1);
                }
                
                //At this point, the only important variable is z1sqr, in temp1.
                // rx, ry, rz, temp2 are free.
                // [r x], [r y], [r z] are not yet free.
                // z1sqr:temp1, 3:temp3
                BN_set_word(temp3, 3);
                
                // After start:
                // rx, ry, temp1, temp2, temp3 are free.
                // L1:rz
                if(fastStart)
                {
                    BN_mod_add(ry, [p1 x], temp1, [self p], context);
                    BN_mod_sub(rz, [p1 x], temp1, [self p], context);
                    BN_mod_mul(rx, ry, rz, [self p], context);
                    BN_mod_mul(rz, rx, temp3, [self p], context);
                }
                else
                {
                    BN_mod_sqr(ry, temp1, [self p], context);
                    BN_mod_mul(temp1, ry, [self a], [self p], context);
                    BN_mod_sqr(ry, [p1 x], [self p], context);
                    BN_mod_mul(temp2, ry, temp3, [self p], context);
                    BN_mod_add(rz, temp1, temp2, [self p], context);
                }
                
                // rx, ry, temp1, temp2, temp3 are free.
                // L1:rz
                BN_mod_mul(temp1, [p1 y], [p1 z], [self p], context);
                BN_mod_lshift1([r z], temp1, [self p], context);
                
                // ry, temp1, temp2, temp3 are free.
                // L1:rz, y1sqr:rx
                BN_mod_sqr(rx, [p1 y], [self p], context);

                // temp1, temp2, temp3 are free.
                // L1:rz, y1sqr:rx, L2:ry
                BN_mod_mul(temp1, rx, [p1 x], [self p], context);
                BN_mod_lshift(ry, temp1, 2, [self p], context);
                
                // temp1, temp2, temp3 are free.
                // L1:rz, y1sqr:rx, L2:ry
                BN_mod_lshift1(temp1, ry, [self p], context);
                BN_mod_sqr(temp2, rz, [self p], context);
                BN_mod_sub([r x], temp2, temp1, [self p], context);

                // temp2, temp3 are free.
                // L1:rz, y1sqr:rx, L2:ry, L3:temp1
                BN_mod_sqr(temp2, rx, [self p], context);
                BN_mod_lshift(temp1, temp2, 3, [self p], context);

                // temp2, temp3 are free.
                // L1:rz, y1sqr:rx, L2:ry, L3:temp1
                BN_mod_sub(temp2, ry, [r x], [self p], context);
                BN_mod_mul(temp3, temp2, rz, [self p], context);
                BN_mod_sub([r y], temp3, temp1, [self p], context);
            }
            else
                //If it is not zero, then P1 = -P2, Thus P1 + P2 = -P2 + P2 = INF
            {
                [r setInf:YES];
            }
        }
        else
        {
            //Right now, L1:rx, L2:ry, L3:rz, z2sqr:temp1, z1sqr:temp2
            //After we make L7, L1 and L2 are no longer needed.
            //After we make L4 and L5, temp1 and temp2 are no longer needed.
            //L7:temp3
            BN_mod_add(temp3, rx, ry, [self p], context);
            
            //L4:temp1   (Y1 Z2cube)
            BN_mod_mul(rx, temp1, [p2 z], [self p], context);
            BN_mod_mul(temp1, rx, [p1 y], [self p], context);
            
            //L5:temp2  (Y2 Z1cube)
            BN_mod_mul(rx, temp2, [p1 z], [self p], context);
            BN_mod_mul(temp2, rx, [p2 y], [self p], context);
            //rx, ry are free.
            // L3:rz, L4:temp1, L5:temp2, L7:temp3
            
            // Making Z1*Z2
            BN_mod_mul(rx,[p1 z], [p2 z], [self p], context);
            //We are now done with accessing the values in p1 and p2
            //This means we can write directly to r without worry about anything
            BN_mod_mul([r z], rx, rz, [self p], context);
            
            //ry, [r y], [r x] is free.
            // L3:rz, L4:temp1, L5:temp2, L7:temp3, L6: rx
            BN_mod_sub(rx, temp1, temp2, [self p], context);

            //[r y], [r x], temp1, temp2 is free.
            // L3:rz L7:temp3, L6: rx, L8:ry
            BN_mod_add(ry, temp1, temp2, [self p], context);
            
            // [r x], temp1, temp2 is free.
            // L3:rz L7:temp3, L6: rx, L8:ry, [r y]:L6sqr
            BN_mod_sqr([r y], rx, [self p], context);
            
            // [r x], temp2 is free.
            // L3:rz L7:temp3, L6: rx, L8:ry, L6sqr:[r y], L3sqr:temp1
            BN_mod_sqr(temp1, rz, [self p], context);
            
            // temp3 free
            // L3:rz L6:rx, L8:ry, L6sqr:[r y], L3sqr:temp1, L7L3sqr:temp2
            BN_mod_mul(temp2, temp3, temp1, [self p], context);
            
            // temp3, [r y] free
            // L3:rz L6:rx, L8:ry, L3sqr:temp1, L7L3sqr:temp2
            BN_mod_sub([r x], [r y], temp2, [self p], context);
            
            // [r y] free
            // L3:rz L6:rx, L8:ry, L3sqr:temp1, L7L3sqr:temp2, 2[r x]:temp3
            BN_mod_lshift1(temp3, [r x], [self p], context);
            
            // temp2, temp3 free
            // L3:rz L6:rx, L8:ry, L3sqr:temp1, L9:[r y]
            BN_mod_sub([r y], temp2, temp3, [self p], context);
            
            // temp3, [r y], rx free
            // L3:rz, L8:ry, L3sqr:temp1, L9L6:temp2
            BN_mod_mul(temp2, [r y], rx, [self p], context);
            
            // temp3, rx, rz, temp1 free
            // L8:ry, L9L6:temp2, L3cube:[r y]
            BN_mod_mul([r y], rz, temp1, [self p], context);
            
            // temp3, rx, rz, [r y] temp1 free
            // L8L3cube:rx, L9L6:temp2
            BN_mod_mul(rx, ry, [r y], [self p], context);
            
            // temp3, rx, rz, [r y] temp1 free
            // L8L3cube:rx, L9L6:temp2
            BN_rshift1([r y], rx);
        }
        BN_CTX_end(context);        
    }

}

- (void) addJacobPointsMixed:(BigJacobPoint *)p1
                      point2:(BigJacobPoint *)p2
                      result:(BigJacobPoint *)r
                     context:(BN_CTX*) context
{
    
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
