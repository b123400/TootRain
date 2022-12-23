//
//  InstanceInputView.m
//  TweetRain
//
//  Created by b123400 on 2021/07/02.
//

#import "InstanceInputWindowController.h"

@interface InstanceInputWindowController ()

@property (weak) IBOutlet NSTextField *descriptionTextField;

@end

@implementation InstanceInputWindowController

- (instancetype)init {
    return [self initWithWindowNibName:@"InstanceInputWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self reloadUI];
}

- (void)setAccountType:(SettingAccountType )accountType {
    _accountType = accountType;
    [self reloadUI];
}

- (void)reloadUI {
    switch (self.accountType) {
        case SettingAccountTypeMastodon:
            self.descriptionTextField.stringValue = NSLocalizedString(@"Please enter your Mastodon / Pleroma instance host name.", @"");
            break;
        case SettingAccountTypeSlack:
            self.descriptionTextField.stringValue = NSLocalizedString(@"Please enter your Slack workspace URL.", @"");
            break;
    }
}

- (NSString*)hostName {
    return self.hostNameTextField.stringValue;
}

- (IBAction)authorizeButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseOK];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseCancel];
}

@end
