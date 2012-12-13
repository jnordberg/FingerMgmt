//
//  AppDelegate.m
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-14.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import "AppDelegate.h"
#import "TouchPoint.h"

// header for MultitouchSupport.framework
#import "MultiTouch.h"

static int touchCallback(int device, mtTouch *data, int num_fingers, double timestamp, int frame) {

  // create TouchPoint objects for all touches
  NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:num_fingers];
  for (int i = 0; i < num_fingers; i++) {
    TouchPoint *point = [[TouchPoint alloc] initWithTouch:&data[i]];
    [points addObject:point];
  }

  // forward array of TouchPoints to AppDelegate on the main thread
  AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
  [delegate performSelectorOnMainThread:@selector(didTouchWithPoints:) withObject:points waitUntilDone:NO];

  // no idea what the return code should be, guessing 0 for success
  return 0;
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {

  // get a list of all multitouch devices
  NSArray *deviceList = (NSArray *)CFBridgingRelease(MTDeviceCreateList());
  for (int i = 0; i < [deviceList count]; i++) {
    // start sending touches to callback
    MTDeviceRef device = (__bridge MTDeviceRef)[deviceList objectAtIndex:i];
    MTRegisterContactFrameCallback(device, touchCallback);
    MTDeviceStart(device, 0);
  }

}

- (void)didTouchWithPoints:(NSArray *)points {
  self.trackpadView.touchView.touchPoints = points;
}

/*
 
 This was just annoying
 
- (void)applicationDidBecomeActive:(NSNotification *)notification {
  CGPoint pos;
  pos.x = _window.frame.origin.x + (_window.frame.size.width / 2);
  pos.y = _window.frame.origin.y + (_window.frame.size.height / 2);
  
  CGDisplayHideCursor(kCGNullDirectDisplay);
  CGDisplayMoveCursorToPoint(kCGDirectMainDisplay, pos);
  CGAssociateMouseAndMouseCursorPosition(false);
}

- (void)applicationWillResignActive:(NSNotification *)notification {
  CGDisplayShowCursor(kCGNullDirectDisplay);
  CGAssociateMouseAndMouseCursorPosition(true);
}
*/

@end
