//
//  ComposeStatusViewController.h
//  TweetRain
//
//  Created by b123400 on 22/3/15.
//
//

#import <UIKit/UIKit.h>
#import "Status.h"

typedef enum : NSUInteger {
    ComposeStatusTypePlain,
    ComposeStatusTypeReply,
    ComposeStatusTypeRetweet,
} ComposeStatusType;

@interface ComposeStatusViewController : UIViewController

- (instancetype) initWithReplyStatus:(Status*)status type:(ComposeStatusType)type;

@end
