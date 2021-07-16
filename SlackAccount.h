//
//  SlackAccount.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import <Cocoa/Cocoa.h>
#import "Account.h"
#import "BRSlackAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface SlackAccount : Account

@property (nonatomic, strong) BRSlackAccount *slackAccount;

- (instancetype)initWithSlackAccount:(BRSlackAccount *)account;

@end

NS_ASSUME_NONNULL_END
