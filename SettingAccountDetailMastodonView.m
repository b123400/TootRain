//
//  SettingAccountDetailMastodonView.m
//  TweetRain
//
//  Created by b123400 on 2022/11/30.
//

#import "SettingAccountDetailMastodonView.h"
#import "BRMastodonAccount.h"

@interface SettingAccountDetailMastodonView ()

@property (weak) IBOutlet NSTextField *accountIdTextField;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSTextField *displayNameTextField;
@property (weak) IBOutlet NSTextField *sourceTextField;

@end

@implementation SettingAccountDetailMastodonView

- (void)setAccount:(BRMastodonAccount *)a {
    self.accountIdTextField.stringValue = a.accountId;
    self.urlTextField.stringValue = a.url;
    self.displayNameTextField.stringValue = a.displayName;
    self.sourceTextField.stringValue = [a displayNameForStreamSource];
}

@end
