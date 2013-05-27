//
//  BigJacobPoint.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/20/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "BigJacobPoint.h"
#import "BigPoint.h"

@implementation BigJacobPoint

- (id) init
{
    if ((self = [super init])){
        self.x = BN_new();
        self.y = BN_new();
        self.z = BN_new();
        self.inf = NO;
        self.fromContext = NO;
    }
    return self;
}

- (id) initWithDecStringX:(NSString *)x
                        y:(NSString *)y
                        z:(NSString *)z
{
    if ((self = [self init])){
        BIGNUM *temp = BN_new();
        
        BN_dec2bn(&temp,[x UTF8String]);
        BN_copy(self.x,temp);
        
        BN_dec2bn(&temp,[y UTF8String]);
        BN_copy(self.y,temp);
        
        BN_dec2bn(&temp,[z UTF8String]);
        BN_copy(self.z,temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initWithHexStringX:(NSString *)x
                        y:(NSString *)y
                        z:(NSString *)z
{
    if ((self = [self init])){
        BIGNUM *temp = BN_new();
        
        BN_hex2bn(&temp,[x UTF8String]);
        BN_copy(self.x,temp);
        
        BN_hex2bn(&temp,[y UTF8String]);
        BN_copy(self.y,temp);
        
        BN_hex2bn(&temp,[z UTF8String]);
        BN_copy(self.z,temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initFromContext:(BN_CTX *)context
{
    if ((self = [super init])){
        self.x = BN_CTX_get(context);
        self.y = BN_CTX_get(context);
        self.z = BN_CTX_get(context);
        self.inf = NO;
        self.fromContext = YES;
    }
    return self;
}

- (void) convertToPoint:(BigPoint *)point
            usingModulo:(BIGNUM *)mod
{
    BN_CTX *context = BN_CTX_new();
    [self convertToPoint:point usingModulo:mod withContext:context];
    BN_CTX_free(context);
}

- (void) convertToPoint:(BigPoint *)point
            usingModulo:(BIGNUM *)mod
            withContext:(BN_CTX *)context
{
    BN_CTX_start(context);
    BIGNUM *inv = BN_CTX_get(context);
    BIGNUM *inv2 = BN_CTX_get(context);
    BIGNUM *inv3 = BN_CTX_get(context);
    
    BN_mod_inverse(inv, self.z, mod, context);
    
    BN_mod_sqr(inv2, inv, mod, context);
    BN_mod_mul(point.x, inv2, self.x, mod, context);
    
    BN_mod_mul(inv3, inv2, inv, mod, context);
    BN_mod_mul(point.y, inv3, self.y, mod, context);
    
    BN_CTX_end(context);
}

- (void) printAsAffinePointUsingModulo:(BIGNUM *)mod
{
    BigPoint *temp = [BigPoint new];
    [self convertToPoint:temp usingModulo:mod];
    NSLog(@"%@",temp);
}

- (NSString *) asDecimalString
{
    if (!self.inf){
        return [NSString stringWithFormat:@"(%s/Z^2,%s/Z^3,%s)",BN_bn2dec(self.x),BN_bn2dec(self.y),BN_bn2dec(self.z)];
    }
    else {
        return @"(inf,inf,1)";
    }
}

- (NSString *) asHexString;
{
    if (!self.inf){
        return [NSString stringWithFormat:@"(%s/Z^2,%s/Z^3,%s)",BN_bn2hex(self.x),BN_bn2hex(self.y),BN_bn2hex(self.z)];
    }
    else {
        return @"(inf,inf,1)";
    }
}

- (NSString*) description
{
    return [self asDecimalString];
}

- (void) copyFromJacobPoint:(BigJacobPoint *)point
{
    BN_copy(self.x,point.x);
    BN_copy(self.y,point.y);
    BN_copy(self.z,point.z);
    self.inf = point.inf;
}

- (void) dealloc
{
    if (!_fromContext){
        BN_free(_x);
        BN_free(_y);
        BN_free(_z);
    }
}
@end
