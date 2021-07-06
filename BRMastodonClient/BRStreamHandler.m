//
//  BRStreamHandler.m
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import "BRStreamHandler.h"

@implementation BRStreamHandler

- (instancetype)initWithTask:(NSURLSessionWebSocketTask *)task {
    if (self = [super init]) {
        self.task = task;
    }
    return self;
}

- (void)disconnect {
    [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
}

@end
