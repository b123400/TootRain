//
//  SlackStatus.m
//  TweetRain
//
//  Created by b123400 on 2021/07/15.
//

#import "SlackStatus.h"
#import "SlackUser.h"

@implementation SlackStatus

- (id)initWithSlackStatus:(BRSlackMessage *)message {
    if (self = [super init]) {
        self.user = [[SlackUser alloc] initWithSlackUser:message.user];
        self.text = message.text;
        self.url = message.url;
        
        self.slackMessage = message;

        // Make attributed string in init, so the images are loaded when status is init-ed
        // such that we can load the image in background
        self.attributedText = [message attributedStringWithEmojisReplaced];
    }
    return self;
}

@end
