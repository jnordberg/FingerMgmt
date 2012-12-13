//
//  TouchView.h
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-14.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import <OpenGL/OpenGL.h>
#import <CeedGL/CeedGL.h>
#import "CeedGL+Additions.h"

@interface TouchView : NSOpenGLView

@property (nonatomic, strong) NSArray *touchPoints;
@property (nonatomic, strong) NSImage *mask;

@end
