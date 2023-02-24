//
//  SettingAccountDetailMisskeyView.m
//  TweetRain
//
//  Created by b123400 on 2022/12/26.
//

#import "SettingAccountDetailMisskeyView.h"

@interface SettingAccountDetailMisskeyView ()

@property (weak) IBOutlet NSTextField *accountIdTextField;
@property (weak) IBOutlet NSTextField *displayNameTextField;
@property (weak) IBOutlet NSTextField *streamsTextField;


@end

@implementation SettingAccountDetailMisskeyView

- (void)setAccount:(BRMisskeyAccount *)account {
    self.accountIdTextField.stringValue = account.accountId;
    self.displayNameTextField.stringValue = account.displayName;
    self.streamsTextField.stringValue = [account displayNameForStreamSource];
}

@end
