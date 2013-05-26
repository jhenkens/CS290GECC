//
//  BigPoint.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/19/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "BigPoint.h"
#import "BigJacobPoint.h"

@implementation BigPoint

@synthesize x = __x;
@synthesize y = __y;
@synthesize inf = __inf;

- (id) init
{
    if ( self = [super init])
    {
        [self setX:BN_new()];
        [self setY:BN_new()];
        [self setInf:NO];
        __fromCtx = NO;
    }
    return self;
}

- (id) initWithDecStringX:(NSString*) x_
                        y:(NSString*) y_
{
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
                        y:(NSString*) y_
{
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

- (id) initFromBigNumX:(BIGNUM *)x_
                     y:(BIGNUM *)y_
{
    if ( self = [super init])
    {
        BN_free([self x]);
        BN_free([self y]);
        [self setX:x_];
        [self setY:y_];
        [self setInf:NO];
        __fromCtx = YES;
    }
    return self;
}

- (id) initFromBigNumMpiData:(NSData*) data_
{
    if ( self = [super init])
    {
        [self setToMpiNSData:data_];
        [self setInf:NO];
        __fromCtx = YES;
    }
    return self;
}

- (void) setToMpiNSData:(NSData*) data_
{
    unsigned char data[[data_ length]];
    [data_ getBytes:data length:[data_ length]];
    
    unsigned char xlen = data[0];
    unsigned char ylen = [data_ length]-xlen-1;
    
    unsigned char* temp = data+1;
    BN_mpi2bn(temp, xlen, [self x]);
    temp = data+1+xlen;
    BN_mpi2bn(temp, ylen, [self y]);
}

- (NSData*) getMpiNSData
{
    int lenx = BN_bn2mpi([self x], NULL);
    int leny = BN_bn2mpi([self y], NULL);
    
    unsigned char data[lenx+leny+1];
    unsigned char* temp = data+1;
    data[0]=(unsigned char)lenx;
    BN_bn2mpi([self x], temp);
    temp=data+lenx+1;
    BN_bn2mpi([self y], temp);
    NSData* result = [[NSData alloc] initWithBytes:data length:(lenx+leny+1)];
    NSLog(@"Made data, length: %d, data: %@",[result length], result);
    return result;
}


- (void) toJacobianPont:(BigJacobPoint *)p
{
    BN_copy([p x], [self x]);
    BN_copy([p y], [self y]);
    BN_set_word([p z], 1);
}

- (BOOL) isEqual:(BigPoint *)other{
    return (BN_cmp([self x], [other x]) == 0) && (BN_cmp([self y], [other y]) == 0);
}

- (NSString*) toDecimalString
{
    if(![self inf])
    {
        return [NSString stringWithFormat:@"(%s,%s)",BN_bn2dec([self x]),BN_bn2dec([self y])];
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
        return [NSString stringWithFormat:@"(%s,%s)",BN_bn2hex([self x]),BN_bn2hex([self y])];
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

- (void) copyPoint:(BigPoint*) p
{
    BN_copy([self x],[p x]);
    BN_copy([self y],[p y]);
    [self setInf:[p inf]];
}

- (void) dealloc
{
    if(!__fromCtx)
    {
        BN_free([self x]);
        BN_free([self y]);
    }
}

- (void) finalize
{
    if(!__fromCtx)
    {
        BN_free([self x]);
        BN_free([self y]);
    }
    [super finalize];
}
@end
