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
    BIGNUM *__x;
    BIGNUM *__y;
    BOOL __inf;
    BOOL __fromCtx;
}
@property (nonatomic, assign) BIGNUM* x;
@property (nonatomic, assign) BIGNUM* y;
@property (nonatomic, assign) BOOL inf;

- (id) initWithDecStringX:(NSString*) x_
                        y:(NSString*) y_;
- (id) initWithHexStringX:(NSString*) x_
                        y:(NSString*) y_;
- (id) initFromBigNumX:(BIGNUM*) x_
                     y:(BIGNUM*) y_;
- (void) copyPoint:(BigPoint*) p;

- (void) toJacobianPont:(BigJacobPoint*) p;
- (NSString*) toDecimalString;
- (NSString*) toHexString;

@end
