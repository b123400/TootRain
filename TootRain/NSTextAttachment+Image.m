//
//  NSTextAttachment+Imagex.m
//  TweetRain
//
//  Created by b123400 on 2023/01/26.
//

#import "NSTextAttachment+Image.h"

@implementation NSTextAttachment (Image)

- (NSImage*)tryGetImage {
    NSImage *image = nil;
    @try {
        image = [[NSImage alloc] initWithData:[[self fileWrapper] regularFileContents]];
        if (!image) {
            image = [self image];
        }
        return image;
    } @catch (NSException *exception) {
        // ignore
    }
    return nil;
}

@end
