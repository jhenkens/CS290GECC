//
//  PrimeCurve.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "PrimeCurve.h"

@implementation PrimeCurve

- (id) init
{
    if ((self = [super init]))
    {
        self.p = BN_new();
        self.n = BN_new();
        self.SEED = BN_new();
        self.c = BN_new();
        self.b = BN_new();
        self.a = BN_new();
        self.g = [BigPoint new];
    }
    return self;
}

- (id) initWithDecStringP:(NSString *)p
                        n:(NSString *)n
                     SEED:(NSString *)seed
                        c:(NSString *)c
                        b:(NSString *)b
                        a:(NSString *)a
                       Gx:(NSString *)gx
                       Gy:(NSString *)gy
{
    if ((self = [self init])){
        BIGNUM *temp = BN_new();
        
        BN_dec2bn(&temp,[p UTF8String]);
        BN_copy(self.p,temp);
        
        BN_dec2bn(&temp,[n UTF8String]);
        BN_copy(self.n,temp);
        
        BN_dec2bn(&temp,[seed UTF8String]);
        BN_copy(self.SEED,temp);
        
        BN_dec2bn(&temp,[c UTF8String]);
        BN_copy(self.c,temp);
        
        BN_dec2bn(&temp,[b UTF8String]);
        BN_copy(self.b,temp);
        
        BN_dec2bn(&temp,[a UTF8String]);
        BN_copy(self.a,temp);
        
        BN_dec2bn(&temp,[gx UTF8String]);
        BN_copy(self.g.x,temp);
        
        BN_dec2bn(&temp,[gy UTF8String]);
        BN_copy(self.g.y,temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initWithHexStringP:(NSString *)p
                        n:(NSString *)n
                     SEED:(NSString *)seed
                        c:(NSString *)c
                        b:(NSString *)b
                        a:(NSString *)a
                       Gx:(NSString *)gx
                       Gy:(NSString *)gy
{
    if ((self = [self init])){
        BIGNUM *temp = BN_new();
        
        BN_hex2bn(&temp,[p UTF8String]);
        BN_copy(self.p,temp);
        
        BN_hex2bn(&temp,[n UTF8String]);
        BN_copy(self.n,temp);
        
        BN_hex2bn(&temp,[seed UTF8String]);
        BN_copy(self.SEED,temp);
        
        BN_hex2bn(&temp,[c UTF8String]);
        BN_copy(self.c,temp);
        
        BN_hex2bn(&temp,[b UTF8String]);
        BN_copy(self.b,temp);
        
        BN_hex2bn(&temp,[a UTF8String]);
        BN_copy(self.a,temp);
        
        BN_hex2bn(&temp,[gx UTF8String]);
        BN_copy(self.g.x,temp);
        
        BN_hex2bn(&temp,[gy UTF8String]);
        BN_copy(self.g.y,temp);
        
        BN_free(temp);
    }
    return self;
}

- (void) addPoint:(BigPoint *)point
          toPoint:(BigPoint *)other
             into:(BigPoint *)result
{
    BN_CTX* context= BN_CTX_new();
    BN_CTX_start(context);
    
    BigJacobPoint *jacobPoint = [[BigJacobPoint alloc] initFromContext:context];
    BigJacobPoint *jacobOther = [[BigJacobPoint alloc] initFromContext:context];
    BigJacobPoint *jacobResult = [[BigJacobPoint alloc] initFromContext:context];
    
    [point convertToJacobianPoint:jacobPoint];
    [other convertToJacobianPoint:jacobOther];
    
    [self addJacobPoint:jacobPoint toPoint:jacobOther into:jacobResult withContext:context];

    [jacobResult convertToPoint:result usingModulo:self.p withContext:context];
    
    BN_CTX_end(context);
    BN_CTX_free(context);
}

- (void) addJacobPoint:(BigJacobPoint *)point
               toPoint:(BigJacobPoint *)other
                  into:(BigJacobPoint *)result
{
    BN_CTX* context= BN_CTX_new();
    [self addJacobPoint:point toPoint:other into:result withContext:context];
    BN_CTX_free(context);
}

- (void) addJacobPoint:(BigJacobPoint *)point
               toPoint:(BigJacobPoint *)other
                  into:(BigJacobPoint *)result
           withContext:(BN_CTX *) context
{
    if (point.inf){
        [result copyFromJacobPoint:other];
    }
    else if (other.inf){
        [result copyFromJacobPoint:point];
    }
    else if (BN_is_one(point.z)){
        [self addBasicJacobPoint:point toRealJacobPoint:other into:result withContext:context];
    }
    else if (BN_is_one(other.z)){
        //Swap p1 and p2 so that p1.z is 1.
        [self addBasicJacobPoint:other toRealJacobPoint:point into:result withContext:context];
    }
    else {
        [self addRealJacobPoint:point toRealJacobPoint:other into:result withContext:context];
    }
}

/*!
 @method        addRealJacobPoint:toRealJacobPoint:into:withContext
 @abstract      result = point + other.
 @param         point
 The first point.
 @param         other
 The other point. 
 @param         result
 The result of the addition is stored here
 @discussion    Use of this directly is strongly discouraged. This is a helper method for
 addJacobPoint:toPoint:into:withContext, and does not cover all cases.
 @TODO          Implement this
 */
- (void) addRealJacobPoint:(BigJacobPoint *)point
          toRealJacobPoint:(BigJacobPoint *)other
                      into:(BigJacobPoint *)result
               withContext:(BN_CTX *)context
{
    BN_CTX_start(context);
    //Normal method:
    BIGNUM *rx = BN_CTX_get(context);
    BIGNUM *ry = BN_CTX_get(context);
    BIGNUM *rz = BN_CTX_get(context);
    BIGNUM *temp1 = BN_CTX_get(context);
    BIGNUM *temp2 = BN_CTX_get(context);
    BIGNUM *temp3 = BN_CTX_get(context);
    
    //L1 : rx ; temp1:z2sqr
    BN_mod_sqr(temp1, other.z, self.p, context);
    BN_mod_mul(rx, temp1, point.x, self.p, context);
    
    //L2 : ry ; temp2:z1sqr
    BN_mod_sqr(temp2, point.z, self.p, context);
    BN_mod_mul(ry, temp2, other.x, self.p, context);
    
    //L3 : rz
    BN_mod_sub(rz, rx, ry, self.p, context);
    
    if (BN_is_zero(rz)){
        //If it is zero, we are either doubling, or setting to infinity.
        //We need to check lambda6 to know, so lets rush to do that.
        //We need to save z1sqr (temp2) in case it is a doubling,

        //L4: rx
        BN_mod_mul(ry, temp1, other.z, self.p, context);
        BN_mod_mul(rx, ry, point.y, self.p, context);
        
        //L5: ry
        BN_mod_mul(temp1, temp2, point.z, self.p, context);
        BN_mod_mul(ry, temp1, other.y, self.p, context);
        
        //L6
        BN_mod_sub(temp1, rx, ry, self.p, context);
        if (BN_is_zero(temp1)){
            BOOL fastStart = NO;
            //If it is zero, then we are doubling
            if (BN_is_negative(self.a)){
                BN_set_negative(self.a, 0);
                if (BN_is_word(self.a, 3)){
                    fastStart = YES;
                }
                BN_set_negative(self.a, 1);
            }
            
            //At this point, the only important variable is z1sqr, in temp2.
            // rx, ry, rz, temp1 are free.
            // result.x, result.y, result.z are not yet free.
            // z1sqr:temp1, 3:temp3
            BN_set_word(temp3, 3);
            
            // After start:
            // rx, ry, temp1, temp2, temp3 are free.
            // L1:rz
            if (fastStart){
                BN_mod_add(ry, point.x, temp2, self.p, context);
                BN_mod_sub(rz, point.x, temp2, self.p, context);
                BN_mod_mul(rx, ry, rz, self.p, context);
                BN_mod_mul(rz, rx, temp3, self.p, context);
            }
            else {
                BN_mod_sqr(ry, temp2, self.p, context);
                BN_mod_mul(temp1, ry, self.a, self.p, context);
                BN_mod_sqr(ry, point.x, self.p, context);
                BN_mod_mul(temp2, ry, temp3, self.p, context);
                BN_mod_add(rz, temp1, temp2, self.p, context);
            }
            
            // rx, ry, temp1, temp2, temp3 are free.
            // L1:rz
            BN_mod_mul(temp1, point.y, point.z, self.p, context);
            BN_mod_lshift1(result.z, temp1, self.p, context);
            
            // ry, temp1, temp2, temp3 are free.
            // L1:rz, y1sqr:rx
            BN_mod_sqr(rx, point.y, self.p, context);
            
            // temp1, temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry
            BN_mod_mul(temp1, rx, point.x, self.p, context);
            BN_mod_lshift(ry, temp1, 2, self.p, context);
            
            // temp1, temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry
            BN_mod_lshift1(temp1, ry, self.p, context);
            BN_mod_sqr(temp2, rz, self.p, context);
            BN_mod_sub(result.x, temp2, temp1, self.p, context);
            
            // temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry, L3:temp1
            BN_mod_sqr(temp2, rx, self.p, context);
            BN_mod_lshift(temp1, temp2, 3, self.p, context);
            
            // temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry, L3:temp1
            BN_mod_sub(temp2, ry, result.x, self.p, context);
            BN_mod_mul(temp3, temp2, rz, self.p, context);
            BN_mod_sub(result.y, temp3, temp1, self.p, context);
        }
        else {
            //If it is not zero, then P1 = -P2, Thus P1 + P2 = -P2 + P2 = INF
            [result setInf:YES];
        }
    }
    else {
        //Right now, L1:rx, L2:ry, L3:rz, z2sqr:temp1, z1sqr:temp2
        //After we make L7, L1 and L2 are no longer needed.
        //After we make L4 and L5, temp1 and temp2 are no longer needed.
        //L7:temp3
        BN_mod_add(temp3, rx, ry, self.p, context);
        
        //L4:temp1   (Y1 Z2cube)
        BN_mod_mul(rx, temp1, other.z, self.p, context);
        BN_mod_mul(temp1, rx, point.y, self.p, context);
        
        //L5:temp2  (Y2 Z1cube)
        BN_mod_mul(rx, temp2, point.z, self.p, context);
        BN_mod_mul(temp2, rx, other.y, self.p, context);
        //rx, ry are free.
        // L3:rz, L4:temp1, L5:temp2, L7:temp3
        
        // Making Z1*Z2
        BN_mod_mul(rx, point.z, other.z, self.p, context);
        //We are now done with accessing the values in p1 and p2
        //This means we can write directly to r without worry about anything
        BN_mod_mul(result.z, rx, rz, self.p, context);
        
        //ry, result.y, result.x is free.
        // L3:rz, L4:temp1, L5:temp2, L7:temp3, L6: rx
        BN_mod_sub(rx, temp1, temp2, self.p, context);
        
        //result.y, result.x, temp1, temp2 is free.
        // L3:rz L7:temp3, L6: rx, L8:ry
        BN_mod_add(ry, temp1, temp2, self.p, context);
        
        // result.x, temp1, temp2 is free.
        // L3:rz L7:temp3, L6: rx, L8:ry, result.y:L6sqr
        BN_mod_sqr(result.y, rx, self.p, context);
        
        // result.x, temp2 is free.
        // L3:rz L7:temp3, L6: rx, L8:ry, L6sqr:result.y, L3sqr:temp1
        BN_mod_sqr(temp1, rz, self.p, context);
        
        // temp3 free
        // L3:rz L6:rx, L8:ry, L6sqr:result.y, L3sqr:temp1, L7L3sqr:temp2
        BN_mod_mul(temp2, temp3, temp1, self.p, context);
        
        // temp3, result.y free
        // L3:rz L6:rx, L8:ry, L3sqr:temp1, L7L3sqr:temp2
        BN_mod_sub(result.x, result.y, temp2, self.p, context);
        
        // result.y free
        // L3:rz L6:rx, L8:ry, L3sqr:temp1, L7L3sqr:temp2, 2result.x:temp3
        BN_mod_lshift1(temp3, result.x, self.p, context);
        
        // temp2, temp3 free
        // L3:rz L6:rx, L8:ry, L3sqr:temp1, L9:result.y
        BN_mod_sub(result.y, temp2, temp3, self.p, context);
        
        // temp3, result.y, rx free
        // L3:rz, L8:ry, L3sqr:temp1, L9L6:temp2
        BN_mod_mul(temp2, result.y, rx, self.p, context);
        
        // temp3, rx, rz, temp1 free
        // L8:ry, L9L6:temp2, L3cube:result.y
        BN_mod_mul(result.y, rz, temp1, self.p, context);
        
        // temp3, rx, rz, result.y temp1 free
        // L8L3cube:rx, L9L6:temp2
        BN_mod_mul(rx, ry, result.y, self.p, context);
        
        // temp3, rx, rz, result.y temp1 free
        // L8L3cube:rx, L9L6:temp2
        BN_mod_sub(temp1, temp2, rx, self.p, context);
        
        // temp3, rx, rz, result.y temp1 free
        // L8L3cube:rx, L9L6:temp2
        if (BN_is_odd(temp1)){
            BN_add(temp2, temp1, self.p);
            temp1 = temp2;
        }
        BN_rshift1(result.y, temp1);
    }
    BN_CTX_end(context);
}

/*!
 @method        addBasicJacobPoint:toRealJacobPoint:into:withContext
 @abstract      result = point + other.
 @param         point
 The first point. Z should be 1 for this point.
 @param         other
 The other point. Can be any jacobian point on the curve
 @param         result
 The result of the addition is stored here
 @discussion    Use of this directly is strongly discouraged. This is a helper method for
                addJacobPoint:toPoint:into:withContext when point has a value of z==1
 @TODO          Implement this
 */
- (void) addBasicJacobPoint:(BigJacobPoint *)point
           toRealJacobPoint:(BigJacobPoint *)other
                       into:(BigJacobPoint *)result
                withContext:(BN_CTX *)context
{
    BN_CTX_start(context);
    //Normal method:
    BIGNUM *rx = BN_CTX_get(context);
    BIGNUM *ry = BN_CTX_get(context);
    BIGNUM *rz = BN_CTX_get(context);
    BIGNUM *temp1 = BN_CTX_get(context);
    BIGNUM *temp2 = BN_CTX_get(context);
    BIGNUM *temp3 = BN_CTX_get(context);
    
    //L1 : rx ; temp1:z2sqr
    BN_mod_sqr(temp1, other.z, self.p, context);
    BN_mod_mul(rx, temp1, point.x, self.p, context);
    
    BN_mod_sub(rz, rx, other.x, self.p, context);
    
    if (BN_is_zero(rz)){
        //If it is zero, we are either doubling, or setting to infinity.
        //We need to check lambda6 to know, so lets rush to do that.
        //We need to save z1sqr (temp2) in case it is a doubling,
        
        //L4: rx
        BN_mod_mul(ry, temp1, other.z, self.p, context);
        BN_mod_mul(rx, ry, point.y, self.p, context);
       
        BN_mod_sub(temp1, rx, other.y, self.p, context);
        if (BN_is_zero(temp1)){

            //At this point, the only important variable is z1sqr, in temp2.
            // rx, ry, rz, temp1 are free.
            // result.x, result.y, result.z are not yet free.
            // z1sqr:temp1, 3:temp3
            BN_set_word(temp3, 3);
            
            // After start:
            // rx, ry, temp1, temp2, temp3 are free.
            // L1:rz
            
            BN_mod_sqr(ry, point.x, self.p, context);
            BN_mod_mul(temp2, ry, temp3, self.p, context);
            BN_mod_add(rz, temp2, self.a, self.p, context);
            
            
            // rx, ry, temp1, temp2, temp3 are free.
            // L1:rz
            BN_mod_lshift1(result.z, point.y, self.p, context);
            
            // ry, temp1, temp2, temp3 are free.
            // L1:rz, y1sqr:rx
            BN_mod_sqr(rx, point.y, self.p, context);
            
            // temp1, temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry
            BN_mod_mul(temp1, rx, point.x, self.p, context);
            BN_mod_lshift(ry, temp1, 2, self.p, context);
            
            // temp1, temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry
            BN_mod_lshift1(temp1, ry, self.p, context);
            BN_mod_sqr(temp2, rz, self.p, context);
            BN_mod_sub(result.x, temp2, temp1, self.p, context);
            
            // temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry, L3:temp1
            BN_mod_sqr(temp2, rx, self.p, context);
            BN_mod_lshift(temp1, temp2, 3, self.p, context);
            
            // temp2, temp3 are free.
            // L1:rz, y1sqr:rx, L2:ry, L3:temp1
            BN_mod_sub(temp2, ry, result.x, self.p, context);
            BN_mod_mul(temp3, temp2, rz, self.p, context);
            BN_mod_sub(result.y, temp3, temp1, self.p, context);
        }
        else {
            //If it is not zero, then P1 = -P2, Thus P1 + P2 = -P2 + P2 = INF
            [result setInf:YES];
        }
    }
    else {
        //Right now, L1:rx, L2:ry, L3:rz, z2sqr:temp1, z1sqr:temp2
        //After we make L7, L1 and L2 are no longer needed.
        //After we make L4 and L5, temp1 and temp2 are no longer needed.
        //L7:temp3
        BN_mod_add(temp3, rx, other.x, self.p, context);
        
        //L4:temp1   (Y1 Z2cube)
        BN_mod_mul(rx, temp1, other.z, self.p, context);
        BN_mod_mul(temp1, rx, point.y, self.p, context);
        
        // Making Z1*Z2
        //We are now done with accessing the values in p1 and p2
        //This means we can write directly to r without worry about anything
        BN_mod_mul(result.z, other.z, rz, self.p, context);
        
        //ry, result.y, result.x is free.
        // L3:rz, L4:temp1, L5:temp2, L7:temp3, L6: rx
        BN_mod_sub(rx, temp1, other.y, self.p, context);
        
        //result.y, result.x, temp1, temp2 is free.
        // L3:rz L7:temp3, L6: rx, L8:ry
        BN_mod_add(ry, temp1, other.y, self.p, context);
        
        // result.x, temp1, temp2 is free.
        // L3:rz L7:temp3, L6: rx, L8:ry, result.y:L6sqr
        BN_mod_sqr(result.y, rx, self.p, context);
        
        // result.x, temp2 is free.
        // L3:rz L7:temp3, L6: rx, L8:ry, L6sqr:result.y, L3sqr:temp1
        BN_mod_sqr(temp1, rz, self.p, context);
        
        // temp3 free
        // L3:rz L6:rx, L8:ry, L6sqr:result.y, L3sqr:temp1, L7L3sqr:temp2
        BN_mod_mul(temp2, temp3, temp1, self.p, context);
        
        // temp3, result.y free
        // L3:rz L6:rx, L8:ry, L3sqr:temp1, L7L3sqr:temp2
        BN_mod_sub(result.x, result.y, temp2, self.p, context);
        
        // result.y free
        // L3:rz L6:rx, L8:ry, L3sqr:temp1, L7L3sqr:temp2, 2result.x:temp3
        BN_mod_lshift1(temp3, result.x, self.p, context);
        
        // temp2, temp3 free
        // L3:rz L6:rx, L8:ry, L3sqr:temp1, L9:result.y
        BN_mod_sub(result.y, temp2, temp3, self.p, context);
        
        // temp3, result.y, rx free
        // L3:rz, L8:ry, L3sqr:temp1, L9L6:temp2
        BN_mod_mul(temp2, result.y, rx, self.p, context);
        
        // temp3, rx, rz, temp1 free
        // L8:ry, L9L6:temp2, L3cube:result.y
        BN_mod_mul(result.y, rz, temp1, self.p, context);
        
        // temp3, rx, rz, result.y temp1 free
        // L8L3cube:rx, L9L6:temp2
        BN_mod_mul(rx, ry, result.y, self.p, context);
        
        // temp3, rx, rz, result.y temp1 free
        // L8L3cube:rx, L9L6:temp2
        BN_mod_sub(temp1, temp2, rx, self.p, context);
        
        // temp3, rx, rz, result.y temp1 free
        // L8L3cube:rx, L9L6:temp2
        if (BN_is_odd(temp1)){
            BN_add(temp2, temp1, self.p);
            temp1 = temp2;
        }
        BN_rshift1(result.y, temp1);
    }
    BN_CTX_end(context);
}

- (void) multiplyPoint:(BigPoint *)point
              byNumber:(BIGNUM *)num
                  into:(BigPoint *)result
{
    BN_CTX* context = BN_CTX_new();
    BN_CTX_start(context);
    
    BigJacobPoint* temp = [[BigJacobPoint alloc] initFromContext:context];
    [point convertToJacobianPoint:temp];
    BigJacobPoint* res = [[BigJacobPoint alloc] initFromContext:context];
    
    int len = BN_num_bits(num);
    assert(len!=0);
    
    BOOL notFirst = NO;
    
    BOOL ci = NO;
    BOOL currBit = BN_is_bit_set(num, 0);
    BOOL nextBit;
    
    
    for (int i = 0; i<len+1; i++){
        nextBit = BN_is_bit_set(num, i+1);
        if (currBit ^ ci){
            if (nextBit){
                BN_set_negative(temp.y, 1);
                //Subtract current
            }
            if (notFirst){
                [self addJacobPoint:temp toPoint:res into:res withContext:context];
            }
            else {
                [res copyFromJacobPoint:temp];
                notFirst = YES;
            }
            if (nextBit){
                BN_set_negative(temp.y, 0);
            }
        }
        if ((ci + currBit + nextBit) >= 2){
            ci = YES;
        }
        else {
            ci = NO;
        }
        currBit = nextBit;
        [self addJacobPoint:temp toPoint:temp into:temp withContext:context];
    }
    [res convertToPoint:result usingModulo:self.p withContext:context];
    BN_CTX_end(context);
    BN_CTX_free(context);
}

- (void) dealloc
{
    BN_free(_p);
    BN_free(_n);
    BN_free(_SEED);
    BN_free(_c);
    BN_free(_b);
    BN_free(_a);
}

@end
