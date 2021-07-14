//
//  BRSlackChannel.m
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import "BRSlackChannel.h"

@implementation BRSlackChannel

- (instancetype)initWithAPIJSON:(NSDictionary *)dict {
    if (self = [super init]) {
        self.channelId = dict[@"id"];
        self.name = dict[@"name"];
    }
    return self;
}

@end
