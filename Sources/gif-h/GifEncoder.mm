//
//  GifEncoder.m
//  Animatrice
//
//  Created by Morten Bertz on 8/25/16.
//  Copyright © 2016 telethon k.k. All rights reserved.
//

#import "GifEncoder.h"
#import "gif.h"
#import <CoreGraphics/CoreGraphics.h>


@interface GifEncoder ()
@property NSURL *url;
@end

@implementation GifEncoder{
    GifWriter _writer;
}


-(instancetype)initWithURL:(NSURL *)url{
    self=[super init];
    if (self){
        self.url=url;
        self.dither=YES;
    }
    return  self;
}

-(BOOL)addFrame:(nonnull CGImageRef)frame withDelay:(NSTimeInterval)delay{
    BOOL success=NO;
    uint32_t width=(uint32_t)CGImageGetWidth(frame);
    uint32_t height=(uint32_t)CGImageGetHeight(frame);
    if (_writer.oldImage == NULL){
        success=GifBegin(&_writer, self.url.fileSystemRepresentation, width,height, 100, 8, self.dither);
    }
    if (_writer.f != nil) {
        
        CGColorSpaceRef colorSpace = NULL;
        colorSpace = CGColorSpaceCreateDeviceRGB();
        uint8_t *bitmapData;
        
        size_t bitsPerPixel = CGImageGetBitsPerPixel(frame);
        size_t bitsPerComponent = CGImageGetBitsPerComponent(frame);
        size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
        
        size_t bytesPerRow = width * bytesPerPixel;
        size_t bufferLength = bytesPerRow * height;
        
        bitmapData=(uint8_t*)calloc(bufferLength, 1);
        CGContextRef context=  CGBitmapContextCreate(bitmapData, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), frame);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        success=GifWriteFrame( &_writer, bitmapData, width, height, delay, 8, self.dither);
        free(bitmapData);
    }
    return  success;
}

-(BOOL)finalize{
    return GifEnd(&_writer);
}



@end
