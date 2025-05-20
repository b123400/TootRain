//
//  BRMastodonList.m
//  TweetRain
//
//  Created by b123400 on 2022/12/01.
//

#import "BRMastodonList.h"

@implementation BRMastodonList

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.listId = dictionary[@"id"];
        self.title = dictionary[@"title"];
    }
    return self;
}

@end
