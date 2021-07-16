//
//  BRSlackUser.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "BRSlackUser.h"

@implementation BRSlackUser

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.username = dictionary[@"name"];
        self.displayName = dictionary[@"real_name"];
        self.userId = dictionary[@"id"];
        self.profileImageURL = [NSURL URLWithString:dictionary[@"profile"][@"image_192"]];
    }
    return self;
}

@end
