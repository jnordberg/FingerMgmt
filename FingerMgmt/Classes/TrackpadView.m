//
//  TrackpadView.m
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-14.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import "TrackpadView.h"

@implementation TrackpadView

@synthesize touchView = _touchView;

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    _touchView = [[TouchView alloc] initWithFrame:[self trackpadFrame]];
    [_touchView setMask:[self trackpadMask]];
    [self addSubview:_touchView];
  }
  return self;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
  _touchView.frame = [self trackpadFrame];
  [_touchView setMask:[self trackpadMask]];
}

- (NSRect)trackpadFrame {
	CGRect rv, bounds = NSRectToCGRect(self.bounds);

  CGSize trackpadSize = {kTrackpadWidth, kTrackpadHeight};
  CGFloat trackpadRatio = trackpadSize.width / trackpadSize.height;
  CGFloat boundsRatio = bounds.size.width / bounds.size.height;

  rv = bounds;
  if (trackpadRatio > boundsRatio) {
    rv.size.height = bounds.size.width * trackpadSize.height / trackpadSize.width;
    rv.origin.y += (bounds.size.height - rv.size.height) / 2;
  } else {
    rv.size.width = bounds.size.height * trackpadSize.width / trackpadSize.height;
    rv.origin.x += (bounds.size.width - rv.size.width) / 2;
  }

  return NSRectFromCGRect(CGRectInset(rv, kTrackpadPadding, kTrackpadPadding));
}

- (NSImage *)trackpadMask {
  NSSize size = [self trackpadFrame].size;
  NSRect frame = (NSRect){NSZeroPoint, size};
  NSImage *mask = [[NSImage alloc] initWithSize:size];
  NSBezierPath* path;

  [mask lockFocus];
  path = [NSBezierPath bezierPathWithRect:frame];
  [[NSColor whiteColor] setFill];
  [path fill];

  [[NSColor blackColor] setFill];
  [[NSColor whiteColor] setStroke];
  [self drawTrackpadInFrame:frame];
  [mask unlockFocus];

  return mask;
}

- (void)drawRect:(NSRect)dirtyRect {
  NSRect bounds = self.bounds;
  
  //// Color Declarations
  NSColor* backgroundColor = [NSColor colorWithCalibratedRed: 0.912 green: 0.912 blue: 0.912 alpha: 1];
  NSColor* trackpadColor = [backgroundColor shadowWithLevel: 0.04];
  NSColor* borderColor = [trackpadColor highlightWithLevel: 0.4];

  //// background Drawing
  NSBezierPath* backgroundPath = [NSBezierPath bezierPathWithRect:bounds];
  [[backgroundColor colorWithNoiseWithOpacity:kNoiseAmount] setFill];
  [backgroundPath fill];
  
  [[trackpadColor colorWithNoiseWithOpacity:kNoiseAmount] setFill];
  [borderColor setStroke];
  [self drawTrackpadInFrame:[self trackpadFrame]];

}

- (void)drawTrackpadInFrame:(NSRect)frame {
  NSShadow* innerShadow = [[NSShadow alloc] init];
  [innerShadow setShadowColor: [NSColor blackColor]];
  [innerShadow setShadowOffset: NSMakeSize(0.1, -1.1)];
  [innerShadow setShadowBlurRadius: 2];

  //// trackpad Drawing
  NSBezierPath* trackpadPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius: 14 yRadius: 14];
  [trackpadPath fill];
  
  ////// trackpad Inner Shadow
  NSRect trackpadBorderRect = NSInsetRect([trackpadPath bounds], -innerShadow.shadowBlurRadius, -innerShadow.shadowBlurRadius);
  trackpadBorderRect = NSOffsetRect(trackpadBorderRect, -innerShadow.shadowOffset.width, -innerShadow.shadowOffset.height);
  trackpadBorderRect = NSInsetRect(NSUnionRect(trackpadBorderRect, [trackpadPath bounds]), -1, -1);
  
  NSBezierPath* trackpadNegativePath = [NSBezierPath bezierPathWithRect: trackpadBorderRect];
  [trackpadNegativePath appendBezierPath: trackpadPath];
  [trackpadNegativePath setWindingRule: NSEvenOddWindingRule];
  
  [NSGraphicsContext saveGraphicsState];
  {
    NSShadow* innerShadowWithOffset = [innerShadow copy];
    CGFloat xOffset = innerShadowWithOffset.shadowOffset.width + round(trackpadBorderRect.size.width);
    CGFloat yOffset = innerShadowWithOffset.shadowOffset.height;
    innerShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
    [innerShadowWithOffset set];
    [[NSColor grayColor] setFill];
    [trackpadPath addClip];
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform translateXBy: -round(trackpadBorderRect.size.width) yBy: 0];
    [[transform transformBezierPath: trackpadNegativePath] fill];
  }
  [NSGraphicsContext restoreGraphicsState];
  
  [trackpadPath setLineWidth: 1];
  [trackpadPath stroke];
}

@end
