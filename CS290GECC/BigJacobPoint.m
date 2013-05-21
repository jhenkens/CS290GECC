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

@synthesize x = __x;
@synthesize y = __y;
@synthesize z = __z;
@synthesize inf = __inf;

- (id) init
{
    if ( self = [super init])
    {
        [self setX:BN_new()];
        [self setY:BN_new()];
        [self setZ:BN_new()];
        [self setInf:NO];
        __fromCtx = NO;
    }
    return self;
}

- (id) initWithDecStringX:(NSString*) x_
                        y:(NSString*) y_
                        z:(NSString*) z_
{
    if(self = [self init])
    {
        
        BIGNUM *temp = BN_new();
        
        BN_dec2bn(&temp,[x_ UTF8String]);
        BN_copy([self x],temp);
        
        BN_dec2bn(&temp,[y_ UTF8String]);
        BN_copy([self y],temp);
        
        BN_dec2bn(&temp,[z_ UTF8String]);
        BN_copy([self z],temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initWithHexStringX:(NSString*) x_
                        y:(NSString*) y_
                        z:(NSString*) z_
{
    if(self = [self init])
    {
        
        BIGNUM *temp = BN_new();
        
        BN_hex2bn(&temp,[x_ UTF8String]);
        BN_copy([self x],temp);
        
        BN_hex2bn(&temp,[y_ UTF8String]);
        BN_copy([self y],temp);
        
        BN_hex2bn(&temp,[z_ UTF8String]);
        BN_copy([self z],temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initFromBigNumX:(BIGNUM *)x_
                     y:(BIGNUM *)y_
                     z:(BIGNUM *)z_
{
    if ( self = [super init])
    {
        [self setX:x_];
        [self setY:y_];
        [self setZ:z_];
        [self setInf:NO];
        __fromCtx = YES;
    }
    return self;
}

- (void) toPoint:(BigPoint *)p
          modulo:(BIGNUM*)m
{
    BN_CTX* context = BN_CTX_new();
    [self toPoint:p modulo:m context:context];
    BN_CTX_free(context);
}

- (void) toPoint:(BigPoint *)p
          modulo:(BIGNUM *)m
         context:(BN_CTX *)context
{
    BN_CTX_start(context);
    BIGNUM* inv = BN_CTX_get(context);
    BIGNUM* temp = BN_CTX_get(context);
    BIGNUM* temp2 = BN_CTX_get(context);
    BN_mod_inverse(inv, [self z], m, context);
    BN_mod_sqr(temp, inv, m, context);
    BN_mod_mul([p x], temp, [self x], m, context);
    BN_mod_mul(temp2, temp, inv, m, context);
    BN_mod_mul([p y], temp2, [self y], m, context);
    BN_CTX_end(context);
}

- (NSString*) toDecimalString
{
    if(![self inf])
    {
        return [NSString stringWithFormat:@"(%s/Z^2,%s/Z^3,%s)",BN_bn2dec([self x]),BN_bn2dec([self y]),BN_bn2dec([self z])];
    }
    else
    {
        return @"(inf,inf)";
    }
}

- (NSString*) toHexString
{
    if(![self inf])
    {
        return [NSString stringWithFormat:@"(%s/Z^2,%s/Z^3,%s)",BN_bn2hex([self x]),BN_bn2hex([self y]),BN_bn2hex([self z])];
    }
    else
    {
        return @"(inf,inf)";
    }
}

- (NSString*) description
{
    return [self toDecimalString];
}

- (void) copyJacobPoint:(BigJacobPoint*) p
{
    BN_copy([self x],[p x]);
    BN_copy([self y],[p y]);
    BN_copy([self y],[p z]);
    [self setInf:[p inf]];
}

- (void) dealloc
{
    if(!__fromCtx){
        BN_free([self x]);
        BN_free([self y]);
        BN_free([self z]);
    }
}

- (void) finalize
{
    if(!__fromCtx)
    {
        BN_free([self x]);
        BN_free([self y]);
        BN_free([self z]);
    }
    [super finalize];
}

@end
