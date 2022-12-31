//
//  SettingAccountCellView.m
//  TweetRain
//
//  Created by b123400 on 2022/11/29.
//

#import "SettingAccountCellView.h"
#import "SettingAccountCellObject.h"

@interface SettingAccountCellView ()

@property (weak) IBOutlet NSTextField *connectStatusTextField;
@property (weak) IBOutlet NSImageView *connectStatusImageView;

@end

@implementation SettingAccountCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setObjectValue:(SettingAccountCellObject*)objectValue {
    if (objectValue == nil) {
        return;
    }
    switch (objectValue.accountType) {
        case SettingAccountTypeMastodon:
            [self.imageView setImage:[NSImage imageNamed:@"Mastodon"]];
            break;
        case SettingAccountTypeSlack:
            [self.imageView setImage:[NSImage imageNamed:@"Slack"]];
            break;
        case SettingAccountTypeMisskey:
            [self.imageView setImage:[NSImage imageNamed:@"Misskey"]];
            break;
    }
    self.textField.stringValue = objectValue.accountName;
    if (objectValue.isConnected) {
        [self.connectStatusImageView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
        [self.connectStatusTextField setStringValue:NSLocalizedString(@"Connected", @"Account table cell")];
    } else {
        [self.connectStatusImageView setImage:[NSImage imageNamed:@"NSStatusNone"]];
        [self.connectStatusTextField setStringValue:NSLocalizedString(@"Disconnected", @"Account table cell")];
    }
}

- (IBAction)serviceImageView:(NSImageView *)sender {
}
@end
