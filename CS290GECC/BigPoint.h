//
//  BigPoint.h
//  CS290GECC
//
//  Created by Johan Henkens on 5/19/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bn.h>

@class BigJacobPoint;

@interface BigPoint : NSObject
{
}
@property (nonatomic, assign) BIGNUM *x;
@property (nonatomic, assign) BIGNUM *y;
@property (nonatomic, assign) BOOL inf;
@property (nonatomic, assign) BOOL fromContext;

- (id) initWithDecStringX:(NSString *)x
                        y:(NSString *)y;

- (id) initWithHexStringX:(NSString *)x
                        y:(NSString *)y;

- (id) initFromContext:(BN_CTX *)context;

- (id) initFromBigNumMpiData:(NSData *)data;

- (void) copyFromPoint:(BigPoint *)point;

- (void) convertToJacobianPoint:(BigJacobPoint *)point;

- (NSString *) asDecimalString;
- (NSString *) asHexString;
- (NSString *) getXCoordinateHexString;

- (BOOL) isEqualToPoint:(BigPoint *)other;
- (void) copyFromMpiNSData:(NSData *)data;
- (NSData *) getMpiNSData;
@end
