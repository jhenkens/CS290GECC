//
//  ECC.h
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bn.h>
#import "PrimeCurve.h"


@interface ECC : NSObject{
    BIGNUM *__privateKey;
    BigPoint *__publicKey;
    PrimeCurve *__curve;
    BigPoint *__sharedSecret;
}

@property (nonatomic, assign) BIGNUM* privateKey;
@property (nonatomic, retain) BigPoint* publicKey;
@property (nonatomic, retain) PrimeCurve* curve;
@property (nonatomic, retain) BigPoint* sharedSecret;

+ (PrimeCurve*) getD121Curve;
- (id) initWithCurve: (PrimeCurve*) curve_;
- (void) makeSharedSecretFromPublicPoint: (BigPoint*) point;

//- ;
//- phot
//
@end
