//
//  TouchPoint.h
//  FingerMgmt
//
//  Created by Johan Nordberg on 2009-11-06.
//  Copyright 2009 FFFF00 Agents AB. All rights reserved.
//

#import "MultiTouch.h"

@interface TouchPoint : NSObject

@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float minorAxis;
@property (readonly) float majorAxis;
@property (readonly) float angle;
@property (readonly) float size;
@property (readonly) float velX;
@property (readonly) float velY;
@property (readonly) float timestamp;

- (id)initWithTouch:(mtTouch *)touch;

@end
