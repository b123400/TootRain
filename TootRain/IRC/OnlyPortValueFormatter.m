//
//  OnlyIntegerValueFormatter.m
//  TweetRain
//
//  Created by b123400 on 2025/01/22.
//

#import "OnlyPortValueFormatter.h"

@implementation OnlyPortValueFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0) {
        return YES;
    }

    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    int port = 0;
    if(!([scanner scanInt:&port] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    if (port <= 0 || port > 65535) {
        NSBeep();
        return NO;
    }

    return YES;
}

@end
