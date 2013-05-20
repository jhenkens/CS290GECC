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

@interface PrimeCurve : NSObject
{
    BIGNUM *__p;
    BIGNUM *__n;
    BIGNUM *__SEED;
    BIGNUM *__c;
    BIGNUM *__b;
    BIGNUM *__a;
    BigPoint *__g;
}

@property (nonatomic, assign) BIGNUM* p;
@property (nonatomic, assign) BIGNUM* n;
@property (nonatomic, assign) BIGNUM* SEED;
@property (nonatomic, assign) BIGNUM* c;
@property (nonatomic, assign) BIGNUM* b;
@property (nonatomic, assign) BIGNUM* a;
@property (nonatomic, retain) BigPoint* g;


- (id) initWithDecStringP:(NSString*) p_
                        n:(NSString*) n_
                     SEED:(NSString*) SEED_
                        c:(NSString*) c_
                        b:(NSString*) b_
                        a:(NSString*) a_
                       Gx:(NSString*) Gx_
                       Gy:(NSString*) Gy_;
- (id) initWithHexStringP:(NSString*) p_
                        n:(NSString*) n_
                     SEED:(NSString*) SEED_
                        c:(NSString*) c_
                        b:(NSString*) b_
                        a:(NSString*) a_
                       Gx:(NSString*) Gx_
                       Gy:(NSString*) Gy_;
- (void) addPoints: (BigPoint*) p1
            point2: (BigPoint*) p2
            result: (BigPoint*) r;
- (void) multGByD:(BIGNUM*) d
           result:(BigPoint*) r;

@end
