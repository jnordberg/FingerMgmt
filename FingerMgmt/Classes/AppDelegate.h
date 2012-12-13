//
//  AppDelegate.h
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-14.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import "TrackpadView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet TrackpadView *trackpadView;

@end
