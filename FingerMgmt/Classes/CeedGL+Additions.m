//
//  CeedGL+Additions.m
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-18.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import "CeedGL+Additions.h"


@implementation GLTexture (Additions)

+ (GLTexture *)textureNamed:(NSString *)name {
  NSImage *image = [NSImage imageNamed:name];
  return [self textureWithImage:image];
}

+ (GLTexture *)textureWithImage:(NSImage *)image {
  GLTexture *texture = [GLTexture texture];

  if (![image isFlipped]) {
    NSImage *drawImage = [[NSImage alloc] initWithSize:image.size];
    NSAffineTransform *transform = [NSAffineTransform transform];

    [drawImage lockFocus];

    [transform translateXBy:0 yBy:image.size.height];
    [transform scaleXBy:1 yBy:-1];
    [transform concat];

    [image drawAtPoint:NSZeroPoint
              fromRect:(NSRect){NSZeroPoint, image.size}
             operation:NSCompositeCopy
              fraction:1];

    [drawImage unlockFocus];

    image = drawImage;
  }

  NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];

  [texture createHandle];
  [texture bind:GL_TEXTURE_2D];
  
  // Set proper unpacking row length for bitmap.
  glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)[bitmap pixelsWide]);
  
  // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  GLCheckError();
  
  NSInteger samplesPerPixel = [bitmap samplesPerPixel];
  
  // Nonplanar, RGB 24 bit bitmap, or RGBA 32 bit bitmap.
  if(![bitmap isPlanar] && (samplesPerPixel == 3 || samplesPerPixel == 4)) {
    glTexImage2D(GL_TEXTURE_2D, 0,
                 samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
                 (GLint)[bitmap pixelsWide],
                 (GLint)[bitmap pixelsHigh],
                 0,
                 samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
                 GL_UNSIGNED_BYTE,
                 [bitmap bitmapData]);
    GLCheckError();
  } else {
    [[NSException exceptionWithName:@"ImageFormat" reason:@"Unsupported image format" userInfo:nil] raise];
    return nil;
  }
  
  return texture;

}

@end

@implementation NSString (Additions)

+ (NSString *)stringWithContentsOfResource:(NSString *)resource ofType:(NSString *)type encoding:(NSStringEncoding)encoding {
  NSError *error;
  
  NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:type];
  NSString *string = [NSString stringWithContentsOfFile:path encoding:encoding error:&error];
  
  if (error) {
    NSLog(@"Failed loading bundle resource %@.%@: %@", resource, type, error);
  }
  
  return string;
}
+ (NSString *)stringWithContentsOfResource:(NSString *)resource ofType:(NSString *)type {
  return [NSString stringWithContentsOfResource:resource ofType:type encoding:NSUTF8StringEncoding];
}
@end

@implementation GLShader (Additions)

+ (GLShader *)fragmentShaderNamed:(NSString *)name {
  GLShader *shader = [GLShader fragmentShader];
  [shader setSource:[NSString stringWithContentsOfResource:name ofType:@"fsh"]];
  return shader;
}

+ (GLShader *)vertexShaderNamed:(NSString *)name {
  GLShader *shader = [GLShader vertexShader];
  [shader setSource:[NSString stringWithContentsOfResource:name ofType:@"vsh"]];
  return shader;
}

@end

@implementation GLProgram (Additions)

+ (GLProgram *)programNamed:(NSString *)name {
  NSError *error;
  GLProgram *program = [GLProgram program];

  GLShader *vshader = [GLShader vertexShaderNamed:name];
  GLShader *fshader = [GLShader fragmentShaderNamed:name];

  if (![vshader compile:&error]) {
    NSLog(@"Vertex shader compilation error: %@", error);
  }
  
	if (![fshader compile:&error]) {
    NSLog(@"Fragment shader compilation error: %@", error);
  }
  
	[program attachShader:vshader];
	[program attachShader:fshader];

	if (![program link:&error]) {
    NSLog(@"Could not link program error: %@", error);
  }

  return program;
}

@end



