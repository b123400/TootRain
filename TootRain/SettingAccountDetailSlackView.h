//
//  SettingAccountDetailSlackView.h
//  TweetRain
//
//  Created by b123400 on 2022/11/30.
//

#import <Cocoa/Cocoa.h>
#import "BRSlackAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingAccountDetailSlackView : NSView

- (void)setAccount:(BRSlackAccount *)account;

@end

NS_ASSUME_NONNULL_END
