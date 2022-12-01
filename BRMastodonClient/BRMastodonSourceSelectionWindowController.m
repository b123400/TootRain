//
//  BRMastodonSourceSelectionWindowController.m
//  TweetRain
//
//  Created by b123400 on 2022/11/29.
//

#import "BRMastodonSourceSelectionWindowController.h"
#import "BRMastodonClient.h"

@interface BRMastodonSourceSelectionWindowController ()

@property (strong, nonatomic) BRMastodonAccount *account;

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
@property (weak) IBOutlet NSTextField *hashtagLocalTextField;
@property (weak) IBOutlet NSPopUpButton *listDropdownButton;

@property (weak) IBOutlet NSButton *okButton;

@property (assign, nonatomic) BRMastodonStreamSource selectedSource;
@property (strong, nonatomic) NSArray<BRMastodonList *> *lists;

@end

@implementation BRMastodonSourceSelectionWindowController

- (instancetype)initWithAccount:(BRMastodonAccount *)account {
    if (self = [self init]) {
        self.account = account;
        self.selectedSource = account.source;
    }
    return self;
}

- (instancetype)init {
    return [super initWithWindowNibName:@"BRMastodonSourceSelectionWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self reloadUI];
    
    [[BRMastodonClient shared] getListsWithAccount:self.account
                                 completionHandler:^(NSArray<BRMastodonList *> * _Nullable lists, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lists = lists;
            [self.listDropdownButton removeAllItems];
            if (lists.count == 0) return;
            [self.listDropdownButton addItemsWithTitles:[lists valueForKeyPath:@"title"]];
            NSUInteger index = [lists indexOfObjectPassingTest:^BOOL(BRMastodonList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [[obj listId] isEqualTo:self.account.sourceListId];
            }];
            if (index == NSNotFound) {
                index = 0;
            }
            [self.listDropdownButton selectItemAtIndex:index];
            [self reloadButtons];
        });
    }];
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
    self.selectedSource = source;
    [self reloadUI];
}

- (void)reloadUI {
    BRMastodonStreamSource source = self.selectedSource;
    if (source == BRMastodonStreamSourcePublic) {
        [self.publicRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourcePublicLocal) {
        [self.publicLocalRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourcePublicRemote) {
        [self.publicRemoteRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourceHashtag) {
        [self.hashtagRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourceHashtagLocal) {
        [self.hashtagLocalRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourceList) {
        [self.listLocalRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourceUser) {
        [self.userRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourceUserNotification) {
        [self.userNotificationRadioButton setState:NSControlStateValueOn];
    } else if (source == BRMastodonStreamSourceDirect) {
        [self.directRadioButton setState:NSControlStateValueOn];
    }
    
    [self.hashtagTextField setEnabled:source == BRMastodonStreamSourceHashtag];
    [self.hashtagLocalTextField setEnabled:source == BRMastodonStreamSourceHashtagLocal];
    [self.listDropdownButton setEnabled:source == BRMastodonStreamSourceList];
    [self reloadButtons];
}

- (void)reloadButtons {
    if ((self.selectedSource == BRMastodonStreamSourceHashtag && self.hashtagTextField.stringValue.length == 0) ||
        (self.selectedSource == BRMastodonStreamSourceHashtagLocal && self.hashtagLocalTextField.stringValue.length == 0) ||
        (self.selectedSource == BRMastodonStreamSourceList && ([self.listDropdownButton indexOfSelectedItem] == -1 || self.lists == nil))) {
        [self.okButton setEnabled:NO];
        return;
    }
    [self.okButton setEnabled:YES];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    [self reloadButtons];
}

- (IBAction)okButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                               returnCode:NSModalResponseOK];
}
- (IBAction)cancelButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseCancel];
}

- (NSString *)hashtag {
    if (self.selectedSource == BRMastodonStreamSourceHashtag) {
        return self.hashtagTextField.stringValue;
    } else if (self.selectedSource == BRMastodonStreamSourceHashtagLocal) {
        return self.hashtagLocalTextField.stringValue;
    }
    return self.hashtagTextField.stringValue;
}

- (NSString *)listId {
    NSInteger index = [self.listDropdownButton indexOfSelectedItem];
    if (index < 0 && index > self.lists.count) return nil;
    return self.lists[index].listId;
}
- (NSString *)listName {
    NSInteger index = [self.listDropdownButton indexOfSelectedItem];
    if (index < 0 && index > self.lists.count) return nil;
    return self.lists[index].title;
}

@end
