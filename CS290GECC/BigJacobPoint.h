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
    BIGNUM *__x;
    BIGNUM *__y;
    BIGNUM *__z;
    BOOL __inf;
    BOOL __fromCtx;
}
@property (nonatomic, assign) BIGNUM* x;
@property (nonatomic, assign) BIGNUM* y;
@property (nonatomic, assign) BIGNUM* z;
@property (nonatomic, assign) BOOL inf;

- (id) initWithDecStringX:(NSString*) x_
                        y:(NSString*) y_
                        z:(NSString*) z_;
- (id) initWithHexStringX:(NSString*) x_
                        y:(NSString*) y_
                        z:(NSString*) z_;
- (id) initFromBigNumX:(BIGNUM*) x_
                     y:(BIGNUM*) y_
                     z:(BIGNUM*) z_;
- (void) copyJacobPoint:(BigJacobPoint*) p;

- (void) toPoint:(BigPoint*) p
          modulo:(BIGNUM*)m;
- (void) toPoint:(BigPoint*) p
          modulo:(BIGNUM*)m
         context:(BN_CTX*) context;
- (NSString*) toDecimalString;
- (NSString*) toHexString;
@end
