//
//  SettingAccountDetailMastodonView.h
//  TweetRain
//
//  Created by b123400 on 2022/11/30.
//

#import <Cocoa/Cocoa.h>
#import "MastodonAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingAccountDetailMastodonView : NSView

- (void)setAccount:(MastodonAccount *)account;

@end

NS_ASSUME_NONNULL_END
