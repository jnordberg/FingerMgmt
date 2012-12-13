//
//  TouchView.m
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-14.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import "TouchView.h"
#import "TouchPoint.h"

@interface TouchView () {
  NSColor *_fillColor;
  NSColor *_borderColor;
  NSBitmapImageRep *_lastDraw;
}

@end

@implementation TouchView

@synthesize touchPoints = _touchPoints;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _fillColor = [NSColor colorWithCalibratedRed:0.99 green:1 blue:0.97 alpha:1];
    _borderColor = [_fillColor shadowWithLevel:0.5];
  }
  return self;
}

- (void)setTouchPoints:(NSArray *)touchPoints {
  _touchPoints = touchPoints;
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  NSRect b = [self bounds];
  CGFloat w = b.size.width, h = b.size.height, smod = 0.8 + (w / kTrackpadWidth);
  NSUInteger i, count = [_touchPoints count];
  
  [_fillColor setFill];
  [_borderColor setStroke];
  
  // NSGraphicsContext graphicsContextWithGraphicsPort:flipped
  
  for (i = 0; i < count; i++) {
    TouchPoint *point = [_touchPoints objectAtIndex:i];
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    // Magnify weak touches to get a better visual effect
    CGFloat s = logf(point.size * 12) * smod;
    if (0.1 > s) s = 0.1;
    
    // Point size
    CGFloat pw = point.majorAxis * s + 0.5;
    CGFloat ph = point.minorAxis * s + 0.5;
    
    // Transformation that positions and rotates oval
    NSAffineTransform *transformation = [NSAffineTransform transform];
    [transformation translateXBy:point.x * w yBy:point.y * h];
    [transformation rotateByRadians:point.angle];
    
    // Draw and transform touch point oval
    [path appendBezierPathWithOvalInRect:(NSRect){{-(pw / 2), -(ph / 2)}, {pw, ph}}];
    [path transformUsingAffineTransform:transformation];
    [path fill];
    [path setLineWidth:2];
    [path stroke];
  }
  
  // Draw
  //NSImage *frame = [[NSImage alloc] initWithSize:b.size];
  
  //CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  
  
}

@end
