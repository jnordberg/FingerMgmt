//
//  TouchView.m
//  FingerMgmt
//
//  Created by Johan Nordberg on 2012-12-14.
//  Copyright (c) 2012 FFFF00 Agents AB. All rights reserved.
//

#import "TouchView.h"
#import "TouchPoint.h"

#define kNumCircleSegments 64

void makeOrtho(GLfloat *m, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat znear, GLfloat zfar) {
  GLfloat tx = - (right + left) / (right - left);
  GLfloat ty = - (top + bottom) / (top - bottom);
  GLfloat tz = - (zfar + znear) / (zfar - znear);
  m[0] = 2 / (right - left);
  m[1] = 0;
  m[2] = 0;
  m[3] = tx;
  m[4] = 0;
  m[5] = 2 / (top - bottom);
  m[6] = 0;
  m[7] = ty;
  m[8] = 0;
  m[9] = 0;
  m[10] = -2 / (zfar - znear);
  m[11] = tz;
  m[12] = 0;
  m[13] = 0;
  m[14] = 0;
  m[15] = 1;
}

enum {
  u_rotate,
  u_translate,
  u_size,
  u_mode,
  u_pass,
  u_mix,
  u_sigma,
  u_blur,
  u_mask,
  u_velocity,
};

@interface TouchView () {
  GLProgram *_program;
  GLProgram *_effectProgram;
  GLProgram *_trailsProgram;

  GLfloat _aspect;
  
  GLint _uniforms[10];

  NSTimer *_timer;
  
  GLTexture *_maskTexture;
  
  GLuint _textures[4];
  GLuint _framebuffers[4];

  GLuint _fsBuffer;
  GLuint _fsTexBuffer;
}

@end

@implementation TouchView

@synthesize touchPoints = _touchPoints;
@synthesize mask = _mask;

- (BOOL)isOpaque {
  return NO;
}

- (void)setTouchPoints:(NSArray *)touchPoints {
  _touchPoints = touchPoints;
  [self setNeedsDisplay:YES];
}

- (void)prepareOpenGL {
  _program = [GLProgram programNamed:@"touchPoint"];
  _effectProgram = [GLProgram programNamed:@"effect"];
  _trailsProgram = [GLProgram programNamed:@"trails"];

  _uniforms[u_rotate] = glGetUniformLocation(_program.handle, "u_rotate");
  _uniforms[u_translate] = glGetUniformLocation(_program.handle, "u_translate");
  _uniforms[u_size] = glGetUniformLocation(_program.handle, "u_size");
  _uniforms[u_mode] = glGetUniformLocation(_program.handle, "u_mode");
  _uniforms[u_velocity] = glGetUniformLocation(_program.handle, "u_velocity");
  _uniforms[u_pass] = glGetUniformLocation(_effectProgram.handle, "u_pass");
  _uniforms[u_sigma] = glGetUniformLocation(_effectProgram.handle, "u_sigma");
  _uniforms[u_blur] = glGetUniformLocation(_effectProgram.handle, "u_blur");
  _uniforms[u_mix] = glGetUniformLocation(_trailsProgram.handle, "u_mix");
  _uniforms[u_mask] = glGetUniformLocation(_trailsProgram.handle, "u_mask");

	GLint zeroOpacity = 0;
	[[self openGLContext] setValues:&zeroOpacity forParameter:NSOpenGLCPSurfaceOpacity];

  glDisable(GL_ALPHA_TEST);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_SCISSOR_TEST);
  glDisable(GL_BLEND);
  glDisable(GL_DITHER);
  glDisable(GL_CULL_FACE);
  glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
  glDepthMask(GL_FALSE);
  glStencilMask(0);
  glClearColor(0, 0, 0, 0);
  glHint(GL_TRANSFORM_HINT_APPLE, GL_FASTEST);
  
  _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)tick {
  [self setNeedsDisplay:YES];
}

- (void)reshape {
	[[self openGLContext] makeCurrentContext];

  NSSize size = self.bounds.size;
	glViewport(0, 0, size.width, size.height);

  GLfloat projection[16];
  _aspect = size.width / size.height;
  makeOrtho(projection, 0, _aspect, 0, 1, -1.0f, 1.0f);

  [_program use];
  glUniformMatrix4fv([_program uniformLocationForName:@"u_projection"], 1, GL_TRUE, projection);
  glUniform2f([_program uniformLocationForName:@"u_resolution"], size.width, size.height);

  [_effectProgram use];
  glUniformMatrix4fv([_effectProgram uniformLocationForName:@"u_projection"], 1, GL_TRUE, projection);
  glUniform2f([_effectProgram uniformLocationForName:@"u_resolution"], size.width, size.height);
  glUniform1i(glGetUniformLocation(_effectProgram.handle, "u_texture"), 0);

  [_trailsProgram use];
  glUniformMatrix4fv([_trailsProgram uniformLocationForName:@"u_projection"], 1, GL_TRUE, projection);
  glUniform2f([_trailsProgram uniformLocationForName:@"u_resolution"], size.width, size.height);
  glUniform1i(glGetUniformLocation(_trailsProgram.handle, "u_texture1"), 0);
  glUniform1i(glGetUniformLocation(_trailsProgram.handle, "u_texture2"), 1);
  
  [self setupOffscreenRender];
  [self setupMask];
  [self setupDrawBuffers];

  [self setNeedsDisplay:YES];
}

- (void)setupMask {
  if (_mask) {
    if (_maskTexture) [_maskTexture destroyHandle];
    _maskTexture = [GLTexture textureWithImage:_mask];
  }
}

- (void)setupOffscreenRender {
  NSSize size = self.bounds.size;

  for (int i = 0; i < 4; i++) {
    if (_textures[i]) glDeleteTextures(1, &_textures[i]);
    if (_framebuffers[i]) glDeleteFramebuffers(1, &_framebuffers[i]);

    glGenTextures(1, &_textures[i]);
    glBindTexture(GL_TEXTURE_2D, _textures[i]);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    GLCheckError();
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    GLCheckError();
    
    glGenFramebuffers(1, &_framebuffers[i]);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[i]);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[i], 0);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
      NSLog(@"Failed to setup framebuffer!");
    }

    glClear(GL_COLOR_BUFFER_BIT);
  }
  
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)setupDrawBuffers {
  if (_fsBuffer) glDeleteBuffers(1, &_fsBuffer);
  glGenBuffers(1, &_fsBuffer);

  GLfloat vertices[] = {
    0, 1,
    _aspect, 1,
    0, 0,
    _aspect, 0,
  };

  glBindBuffer(GL_ARRAY_BUFFER, _fsBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

#pragma mark Drawing

- (void)drawTouches {
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glEnableVertexAttribArray(0);
  for (TouchPoint *point in _touchPoints) {
    [self drawTouchPoint:point];
  }
}

- (void)drawTouchPoint:(TouchPoint *)point {
  GLfloat vertices[kNumCircleSegments * 2];
  for (int i = 0; i < kNumCircleSegments * 2; i += 2) {
    float theta = M_PI * (float)i / kNumCircleSegments;
    vertices[i] = (cosf(theta) / point.minorAxis) * point.size;
    vertices[i + 1] = (sinf(theta) / point.majorAxis) * point.size;
  }

  glUniform2f(_uniforms[u_translate], point.x * _aspect, point.y);
  glUniform1f(_uniforms[u_rotate], -point.angle);
  glUniform1f(_uniforms[u_size], point.size);
  glUniform2f(_uniforms[u_velocity], point.velX , point.velY);

  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, vertices);
  glDrawArrays(GL_TRIANGLE_FAN, 0, kNumCircleSegments);
}

- (void)drawFull {
  glBindBuffer(GL_ARRAY_BUFFER, _fsBuffer);
  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)drawRect:(NSRect)dirtyRect {
  [[self openGLContext] makeCurrentContext];

  // render touches to tex 0
  [_program use];
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[0]);
  glClear(GL_COLOR_BUFFER_BIT);
  glUniform1i(_uniforms[u_mode], 0);
  [self drawTouches];

  // mix tex 0(current frame) and tex 2(prev frame) to tex 1
  [_trailsProgram use];
  glUniform1i(_uniforms[u_mask], 0);
  glUniform1f(_uniforms[u_mix], 0.95);
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[1]);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _textures[0]);
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, _textures[2]);
  glClear(GL_COLOR_BUFFER_BIT);
  [self drawFull];

  // blur
  [_effectProgram use];
  glUniform1f(_uniforms[u_blur], 10);
  glUniform1f(_uniforms[u_sigma], 30);

  // first pass
  glUniform1i(_uniforms[u_pass], 0);
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[0]);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _textures[1]);
  glClear(GL_COLOR_BUFFER_BIT);
  [self drawFull];
  
  // second pass - renders to texture 2 (prev frame)
  glUniform1i(_uniforms[u_pass], 1);
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[2]);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _textures[0]);
  glClear(GL_COLOR_BUFFER_BIT);
  [self drawFull];
  
  // copy prev frame to tex 0
  [_trailsProgram use];
  glUniform1f(_uniforms[u_mix], 0);
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[0]);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _textures[2]);
  glClear(GL_COLOR_BUFFER_BIT);
  [self drawFull];

  // draw dots on top
  [_program use];
  glUniform1i(_uniforms[u_mode], 1);
  [self drawTouches];
  
  // antialias with blur
  [_effectProgram use];
  glUniform1f(_uniforms[u_blur], 2);
  glUniform1f(_uniforms[u_sigma], 1);

  glUniform1i(_uniforms[u_pass], 0);
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[1]);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _textures[0]);
  glClear(GL_COLOR_BUFFER_BIT);
  [self drawFull];

  glUniform1i(_uniforms[u_pass], 1);
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffers[0]);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _textures[1]);
  glClear(GL_COLOR_BUFFER_BIT);
  [self drawFull];
  
  // mask and draw to main buffer
  [_trailsProgram use];
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  glUniform1i(_uniforms[u_mask], 1);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _textures[0]);
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, _maskTexture.handle);
  glClear(GL_COLOR_BUFFER_BIT);  
  [self drawFull];

  glSwapAPPLE();
}

@end
