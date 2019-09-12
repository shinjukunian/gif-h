//
//  GifEncoder.h
//  Animatrice
//
//  Created by Morten Bertz on 8/25/16.
//  Copyright © 2016 telethon k.k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface GifEncoder : NSObject


@property BOOL dither; //default is YES

-(nonnull instancetype)initWithURL:(nonnull NSURL*)url;
-(BOOL)addFrame:(nonnull CGImageRef)frame withDelay:(NSTimeInterval)delay;
-(BOOL)finalize;


@end
