//
//  PrimeCurve.m
//  CS290GECC
//
//  Created by Johan Henkens on 5/13/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "PrimeCurve.h"

@implementation PrimeCurve
@synthesize p = __p;
@synthesize n = __n;
@synthesize SEED = __SEED;
@synthesize c = __c;
@synthesize b = __b;
@synthesize Gx = __Gx;
@synthesize Gy = __Gy;

- (id) init
{
    if ( self = [super init])
    {
        [self setP:BN_new()];
        [self setN:BN_new()];
        [self setSEED:BN_new()];
        [self setC:BN_new()];
        [self setB:BN_new()];
        [self setGx:BN_new()];
        [self setGy:BN_new()];
    }
    return self;
}


- (void) dealloc
{
    BN_free([self p]);
    BN_free([self n]);
    BN_free([self SEED]);
    BN_free([self c]);
    BN_free([self b]);
    BN_free([self Gx]);
    BN_free([self Gy]);
}

- (void) finalize
{
    BN_free([self p]);
    BN_free([self n]);
    BN_free([self SEED]);
    BN_free([self c]);
    BN_free([self b]);
    BN_free([self Gx]);
    BN_free([self Gy]);
    [super finalize];
}

@end
