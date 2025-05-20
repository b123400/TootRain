//
//  BRSlackStreamHandler.m
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import "BRSlackStreamHandle.h"

@implementation BRSlackStreamHandle

- (void)disconnect {
    [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
}

@end
