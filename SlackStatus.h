//
//  SlackStatus.h
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "Status.h"
#import "BRSlackMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SlackStatus : Status

@property (nonatomic, strong) BRSlackMessage *slackMessage;

- (id)initWithSlackStatus:(BRSlackMessage *)message;

@end

NS_ASSUME_NONNULL_END
