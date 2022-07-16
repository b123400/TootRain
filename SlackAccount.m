//
//  SlackAccount.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "SlackAccount.h"

@implementation SlackAccount

- (instancetype)initWithSlackAccount:(BRSlackAccount *)account {
    if (self = [super init]) {
        self.slackAccount = account;
    }
    return self;
}

- (NSString *)identifier {
    return self.slackAccount.uuid;
}

- (NSString *)displayName {
    return self.slackAccount.displayName;
}

- (void)deleteAccount {
    [self.slackAccount deleteAccount];
}

@end
