//
//  SettingAccountDetailSlackView.m
//  TweetRain
//
//  Created by b123400 on 2022/11/30.
//

#import "SettingAccountDetailSlackView.h"
#import "BRSlackAccount.h"

@interface SettingAccountDetailSlackView ()

@property (weak) IBOutlet NSTextField *accountIdTextField;
@property (weak) IBOutlet NSTextField *teamIdTextField;
@property (weak) IBOutlet NSTextField *teamNameTextField;
@property (weak) IBOutlet NSTextField *channelsTextField;

@end

@implementation SettingAccountDetailSlackView

- (void)setAccount:(SlackAccount *)account {
    BRSlackAccount *a = account.slackAccount;
    self.accountIdTextField.stringValue = a.accountId;
    self.teamIdTextField.stringValue = a.teamId;
    self.teamNameTextField.stringValue = a.teamName;
    self.channelsTextField.stringValue = [a.channelNames componentsJoinedByString:@", "];
}

@end
