//
//  BRMastodonSourceSelectionWindowController.m
//  TweetRain
//
//  Created by b123400 on 2022/11/29.
//

#import "BRMastodonSourceSelectionWindowController.h"
#import "BRMastodonClient.h"

@interface BRMastodonSourceSelectionWindowController ()

@property (weak) IBOutlet NSButton *publicRadioButton;
@property (weak) IBOutlet NSButton *publicLocalRadioButton;
@property (weak) IBOutlet NSButton *publicRemoteRadioButton;
@property (weak) IBOutlet NSButton *hashtagRadioButton;
@property (weak) IBOutlet NSButton *hashtagLocalRadioButton;
@property (weak) IBOutlet NSButton *listLocalRadioButton;
@property (weak) IBOutlet NSButton *userRadioButton;
@property (weak) IBOutlet NSButton *userNotificationRadioButton;
@property (weak) IBOutlet NSButton *directRadioButton;

@property (weak) IBOutlet NSTextField *hashtagTextField;
@property (weak) IBOutlet NSPopUpButton *listDropdownButton;

@end

@implementation BRMastodonSourceSelectionWindowController

- (instancetype)init {
    return [super initWithWindowNibName:@"BRMastodonSourceSelectionWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)radioButtonSelected:(id)sender {
    BRMastodonStreamSource source = BRMastodonStreamSourceUser;
    if (sender == self.publicRadioButton) {
        source = BRMastodonStreamSourcePublic;
    } else if (sender == self.publicLocalRadioButton) {
        source = BRMastodonStreamSourcePublicLocal;
    } else if (sender == self.publicRemoteRadioButton) {
        source = BRMastodonStreamSourcePublicRemote;
    } else if (sender == self.hashtagRadioButton) {
        source = BRMastodonStreamSourceHashtag;
    } else if (sender == self.hashtagLocalRadioButton) {
        source = BRMastodonStreamSourceHashtagLocal;
    } else if (sender == self.listLocalRadioButton) {
        source = BRMastodonStreamSourceList;
    } else if (sender == self.userRadioButton) {
        source = BRMastodonStreamSourceUser;
    } else if (sender == self.userNotificationRadioButton) {
        source = BRMastodonStreamSourceUserNotification;
    } else if (sender == self.directRadioButton) {
        source = BRMastodonStreamSourceDirect;
    }
}

- (IBAction)okButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                               returnCode:NSModalResponseOK];
}
- (IBAction)cancelButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseCancel];
}

@end
