//
//  PrimeCurve.h
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bn.h>
#import "BigPoint.h"
#import "BigJacobPoint.h"

@interface PrimeCurve : NSObject
{
}

@property (nonatomic, assign) BIGNUM *p;
@property (nonatomic, assign) BIGNUM *n;
@property (nonatomic, assign) BIGNUM *SEED;
@property (nonatomic, assign) BIGNUM *c;
@property (nonatomic, assign) BIGNUM *b;
@property (nonatomic, assign) BIGNUM *a;
@property (nonatomic, strong) BigPoint *g;


- (id) initWithDecStringP:(NSString *)p
                        n:(NSString *)n
                     SEED:(NSString *)seed
                        c:(NSString *)c
                        b:(NSString *)b
                        a:(NSString *)a
                       Gx:(NSString *)gx
                       Gy:(NSString *)gy;

- (id) initWithHexStringP:(NSString *)p
                        n:(NSString *)n
                     SEED:(NSString *)seed
                        c:(NSString *)c
                        b:(NSString *)b
                        a:(NSString *)a
                       Gx:(NSString *)gx
                       Gy:(NSString *)gy;

- (void) addPoint:(BigPoint *)point
          toPoint:(BigPoint *)other
             into:(BigPoint *)result;

- (void) addJacobPoint:(BigJacobPoint *)point
               toPoint:(BigJacobPoint *)other
                  into:(BigJacobPoint *)result;

- (void) addJacobPoint:(BigJacobPoint *)point
               toPoint:(BigJacobPoint *)other
                  into:(BigJacobPoint *)result
           withContext:(BN_CTX *)context;

- (void) multiplyPoint:(BigPoint *)point
              byNumber:(BIGNUM *)num
                  into:(BigPoint *)result;

@end
