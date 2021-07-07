//
//  NSImage+Resize.h
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (Resize)

-(NSImage *)resized:(NSSize)newSize;

@end

NS_ASSUME_NONNULL_END
