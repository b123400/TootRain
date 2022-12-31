//
//  BRMisskeyStreamHandle.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "BRMisskeyStreamHandle.h"

@implementation BRMisskeyStreamHandle

- (void)disconnect {
    [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
}

@end
