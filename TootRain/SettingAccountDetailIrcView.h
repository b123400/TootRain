//
//  SettingAccountDetailIRCView.h
//  TweetRain
//
//  Created by b123400 on 2025/01/20.
//

#import <Cocoa/Cocoa.h>
#import "IRC/BRIrcAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingAccountDetailIrcView : NSView

- (void)setAccount:(BRIrcAccount *)account;

@end

NS_ASSUME_NONNULL_END
