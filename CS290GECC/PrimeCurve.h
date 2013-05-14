//
//  PrimeCurve.h
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bn.h>

@interface PrimeCurve : NSObject
{
    BIGNUM *__p;
    BIGNUM *__n;
    BIGNUM *__SEED;
    BIGNUM *__c;
    BIGNUM *__b;
    BIGNUM *__Gx;
    BIGNUM *__Gy;
}

@property (nonatomic, assign) BIGNUM* p;
@property (nonatomic, assign) BIGNUM* n;
@property (nonatomic, assign) BIGNUM* SEED;
@property (nonatomic, assign) BIGNUM* c;
@property (nonatomic, assign) BIGNUM* b;
@property (nonatomic, assign) BIGNUM* Gx;
@property (nonatomic, assign) BIGNUM* Gy;

@end
