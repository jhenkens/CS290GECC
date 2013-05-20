//
//  BigPoint.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/19/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "BigPoint.h"

@implementation BigPoint

@synthesize x = __x;
@synthesize y = __y;
@synthesize inf = __inf;

- (id) init
{
    if ( self = [super init]){
        [self setX:BN_new()];
        [self setY:BN_new()];
        [self setInf:NO];
        __fromCtx = NO;
    }
    return self;
}

- (id) initWithDecStringX:(NSString*) x_
                        y:(NSString*) y_{
    if(self = [self init])
    {
        
        BIGNUM *temp = BN_new();
        
        BN_dec2bn(&temp,[x_ UTF8String]);
        BN_copy([self x],temp);
        
        BN_dec2bn(&temp,[y_ UTF8String]);
        BN_copy([self y],temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initWithHexStringX:(NSString*) x_
                        y:(NSString*) y_{
    if(self = [self init])
    {
        
        BIGNUM *temp = BN_new();
        
        BN_hex2bn(&temp,[x_ UTF8String]);
        BN_copy([self x],temp);
        
        BN_hex2bn(&temp,[y_ UTF8String]);
        BN_copy([self y],temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initFromBigNumX:(BIGNUM *)x_ y:(BIGNUM *)y_{
    if ( self = [super init]){
        [self setX:x_];
        [self setY:y_];
        [self setInf:NO];
        __fromCtx = YES;
    }
    return self;
}

- (NSString*) toDecimalString{
    return [NSString stringWithFormat:@"(%s,%s)",BN_bn2dec([self x]),BN_bn2dec([self y])];
}

- (NSString*) toHexString{
    return [NSString stringWithFormat:@"(%s,%s)",BN_bn2hex([self x]),BN_bn2hex([self y])];
}

- (NSString*) description{
    return [self toDecimalString];
}

- (void) copyPoint:(BigPoint*) p{
    BN_copy([self x],[p x]);
    BN_copy([self y],[p y]);
    [self setInf:[p inf]];
}

- (void) dealloc
{
    if(!__fromCtx){
        BN_free([self x]);
        BN_free([self y]);
    }
}

- (void) finalize
{   if(!__fromCtx){
        BN_free([self x]);
        BN_free([self y]);
    }
    [super finalize];
}
@end