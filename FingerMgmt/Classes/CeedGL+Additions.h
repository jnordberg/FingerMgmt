//
//  CeedGL+Additions.h
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-18.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import <CeedGL/CeedGL.h>

@interface GLProgram (Additions)

+ (GLProgram *)programNamed:(NSString *)name;

@end

@interface GLShader (Additions)

+ (GLShader *)fragmentShaderNamed:(NSString *)name;
+ (GLShader *)vertexShaderNamed:(NSString *)name;

@end


@interface GLTexture (Additions)

+ (GLTexture *)textureNamed:(NSString *)name;
+ (GLTexture *)textureWithImage:(NSImage *)image;

@end


@interface NSString (Additions)

+ (NSString *)stringWithContentsOfResource:(NSString *)resource ofType:(NSString *)type encoding:(NSStringEncoding)encoding;
+ (NSString *)stringWithContentsOfResource:(NSString *)resource ofType:(NSString *)type;

@end
