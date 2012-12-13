//
//  TouchPoint.m
//  FingerMgmt
//
//  Created by Johan Nordberg on 2009-11-06.
//  Copyright 2009 FFFF00 Agents AB. All rights reserved.
//

#import "TouchPoint.h"

@implementation TouchPoint

@synthesize x, y;
@synthesize velX, velY;
@synthesize minorAxis;
@synthesize majorAxis;
@synthesize angle;
@synthesize size;
@synthesize timestamp;

- (id)initWithTouch:(mtTouch *)touch {
  if ((self = [self init])) {
    x = touch->normalized.position.x;
    y = touch->normalized.position.y;
    minorAxis = touch->minorAxis;
    majorAxis = touch->majorAxis;
    angle = touch->angle;
    size = touch->size;
    velX = touch->normalized.velocity.x;
    velY = touch->normalized.velocity.y;
    timestamp = touch->timestamp;
  }
  return self;
}

@end
