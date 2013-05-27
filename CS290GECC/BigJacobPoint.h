//
//  BigJacobPoint.h
//  CS290GECC
//
//  Created by Johan Henkens on 5/20/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bn.h>

@class BigPoint;
@interface BigJacobPoint : NSObject
{
}
@property (nonatomic, assign) BIGNUM *x;
@property (nonatomic, assign) BIGNUM *y;
@property (nonatomic, assign) BIGNUM *z;
@property (nonatomic, assign) BOOL inf;
@property (nonatomic, assign) BOOL fromContext;

- (id) initWithDecStringX:(NSString *)x
                        y:(NSString *)y
                        z:(NSString *)z;

- (id) initWithHexStringX:(NSString *)x
                        y:(NSString *)y
                        z:(NSString *)z;

- (id) initFromContext:(BN_CTX *)context;

- (void) copyFromJacobPoint:(BigJacobPoint *)point;

- (void) convertToPoint:(BigPoint *)point
            usingModulo:(BIGNUM *)mod;

- (void) convertToPoint:(BigPoint *)point
            usingModulo:(BIGNUM *)mod
            withContext:(BN_CTX *)context;

- (void) printAsAffinePointUsingModulo:(BIGNUM *)mod;

- (NSString *) asDecimalString;
- (NSString *) asHexString;
@end
