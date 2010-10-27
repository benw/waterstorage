//
//  FancyLabel.m
//  Slake
//
//  Created by Tim Riley on 19/05/10.
//
//  Copyright (c) 2010 Bureau of Meteorology
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "FancyLabel.h"


@implementation FancyLabel


- (id)initWithFrame:(CGRect)frame {
	
  if (self = [super initWithFrame:frame]) {
    // Initialization code
  }
  return self;
}

- (void)drawTextInRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
	
  // Pull basic text properties from UILabel
  CGContextSelectFont(context, [self.font.fontName cStringUsingEncoding:[NSString defaultCStringEncoding]], self.font.pointSize, kCGEncodingMacRoman);
  CGContextSetFillColorWithColor(context, self.textColor.CGColor);
	
	// Add shadow (TODO: Figure out why this reverses the shadow set in Interface Builder)
	CGContextSetShadowWithColor(context, self.shadowOffset, 0, self.shadowColor.CGColor);
	
  // Add custom kerning
  CGContextSetCharacterSpacing(context, 1.45);
  CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
  CGContextSetTextMatrix(context, transform);
  
  // Show the label text
  const char *text = [self.text cStringUsingEncoding:[NSString defaultCStringEncoding]];
  //CGContextShowTextAtPoint(context, 0.0, 20.0, text, strlen(text));
  CGContextShowTextAtPoint(context, 0.0, self.font.pointSize+2, text, text ? strlen(text) : 0);
}

- (void)dealloc {
  [super dealloc];
}

@end
