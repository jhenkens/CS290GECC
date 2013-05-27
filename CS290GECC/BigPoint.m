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

- (id) init
{
    if ((self = [super init])){
        self.x = BN_new();
        self.y = BN_new();
        self.inf = NO;
        self.fromContext = NO;
    }
    return self;
}

- (id) initWithDecStringX:(NSString *)x
                        y:(NSString *)y
{
    if ((self = [self init])){
        BIGNUM *temp = BN_new();
        BN_dec2bn(&temp,[x UTF8String]);
        BN_copy(self.x,temp);
        
        BN_dec2bn(&temp,[y UTF8String]);
        BN_copy(self.y,temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initWithHexStringX:(NSString *)x
                        y:(NSString *)y
{
    if ((self = [self init])){
        BIGNUM *temp = BN_new();
        BN_hex2bn(&temp,[x UTF8String]);
        BN_copy(self.x,temp);
        
        BN_hex2bn(&temp,[y UTF8String]);
        BN_copy(self.y,temp);
        
        BN_free(temp);
    }
    return self;
}

- (id) initFromContext:(BN_CTX *)context
{
    if ((self = [super init])){
        self.x = BN_CTX_get(context);
        self.y = BN_CTX_get(context);
        self.inf = NO;
        self.fromContext = YES;
    }
    return self;
}

- (id) initFromBigNumMpiData:(NSData *)data;
{
    if ((self = [self init])){
        [self copyFromMpiNSData:data];
    }
    return self;
}

- (void) copyFromMpiNSData:(NSData *)data
{
    unsigned char dataBytes[[data length]];
    [data getBytes:dataBytes length:[data length]];
    
    unsigned char xlen = dataBytes[0];
    unsigned char ylen = [data length]-xlen-1;
    
    unsigned char *temp = dataBytes+1;
    BN_mpi2bn(temp, xlen, self.x);
    temp = dataBytes+1+xlen;
    BN_mpi2bn(temp, ylen, self.y);
}

- (NSData *) getMpiNSData
{
    int lenx = BN_bn2mpi(self.x, NULL);
    int leny = BN_bn2mpi(self.y, NULL);
    
    unsigned char data[lenx+leny+1];
    unsigned char *temp = data+1;
    
    data[0] = (unsigned char)lenx;
    
    BN_bn2mpi(self.x, temp);
    
    temp = data+lenx+1;
    
    BN_bn2mpi(self.y, temp);
    
    NSData *result = [[NSData alloc] initWithBytes:data length:(lenx+leny+1)];
    NSLog(@"Made data, length: %d, data: %@",[result length], result);
    return result;
}


- (void) convertToJacobianPoint:(BigJacobPoint *)point
{
    BN_copy(point.x, self.x);
    BN_copy(point.y, self.y);
    BN_set_word(point.z, 1);
}

- (BOOL) isEqualToPoint:(BigPoint *)other
{
    return (BN_cmp(self.x, other.x) == 0) && (BN_cmp(self.y, other.y) == 0);
}

- (NSString *) asDecimalString
{
    if (!self.inf){
        return [NSString stringWithFormat:@"(%s,%s)",BN_bn2dec(self.x),BN_bn2dec(self.y)];
    }
    else {
        return @"(inf,inf)";
    }
}

- (NSString *) asHexString
{
    if (!self.inf){
        return [NSString stringWithFormat:@"(%s,%s)",BN_bn2hex(self.x),BN_bn2hex(self.y)];
    }
    else {
        return @"(inf,inf)";
    }
}

- (NSString *) getXCoordinateHexString
{
    return [NSString stringWithUTF8String:BN_bn2hex(self.x)];
}

- (NSString*) description
{
    return [self asDecimalString];
}

- (void) copyFromPoint:(BigPoint *)point
{
    BN_copy(self.x,point.x);
    BN_copy(self.y,point.y);
    self.inf = point.inf;
}

- (void) dealloc
{
    if(!_fromContext)
    {
        BN_free(_x);
        BN_free(_y);
    }
}
@end
