//
//  BRStreamHandler.m
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import "BRMastodonStreamHandler.h"

@implementation BRMastodonStreamHandler

- (void)disconnect {
    [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
}

@end
