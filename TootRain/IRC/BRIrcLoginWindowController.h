//
//  BRIrcLoginWindowController.h
//  TweetRain
//
//  Created by b123400 on 2025/01/20.
//

#import <Cocoa/Cocoa.h>
#import "BRIrcAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRIrcLoginWindowController : NSWindowController

@property (nonatomic, strong) BRIrcAccount *account;

@end

NS_ASSUME_NONNULL_END
