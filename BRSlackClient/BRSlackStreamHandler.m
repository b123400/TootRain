//
//  BRSlackStreamHandler.m
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import "BRSlackStreamHandler.h"

@implementation BRSlackStreamHandler

- (void)disconnect {
    [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
}

@end
