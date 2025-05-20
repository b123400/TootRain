//
//  SettingAccountDetailIRCView.m
//  TweetRain
//
//  Created by b123400 on 2025/01/20.
//

#import "SettingAccountDetailIrcView.h"

@interface SettingAccountDetailIrcView ()
@property (weak) IBOutlet NSTextField *hostTextField;
@property (weak) IBOutlet NSTextField *portTextField;
@property (weak) IBOutlet NSTextField *tlsTextField;
@property (weak) IBOutlet NSTextField *nickTextField;
@property (weak) IBOutlet NSTextField *channelTextField;

@end

@implementation SettingAccountDetailIrcView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setAccount:(BRIrcAccount *)account {
    self.hostTextField.stringValue = account.host;
    self.portTextField.stringValue = [NSString stringWithFormat:@"%ld", account.port];
    self.tlsTextField.stringValue = account.tls ? NSLocalizedString(@"Yes", @"") : NSLocalizedString(@"No", @"");
    self.nickTextField.stringValue = account.nick;
    self.channelTextField.stringValue = [account.channels componentsJoinedByString:@", "];
}

@end
