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
}

@property (nonatomic, assign) BIGNUM* privateKey;
@property (nonatomic, strong) BigPoint* publicKey;
@property (nonatomic, strong) PrimeCurve* curve;
@property (nonatomic, strong) BigPoint* sharedSecret;

+ (PrimeCurve *) getD121Curve;
- (id) initWithRandomSeed:(uint8_t *) seed
               withLength:(int) length;
- (id) initWithCurve:(PrimeCurve *)curve;
- (id) initWithCurve:(PrimeCurve *)curve
       andRandomSeed:(uint8_t *) seed
          withLength:(int) length;
- (void) makeSharedSecretFromPublicPoint:(BigPoint *)point;

//- ;
//- phot
//
@end
