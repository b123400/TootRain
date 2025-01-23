//
//  SettingViewController.m
//  Smarkin
//
//  Created by b123400 on 28/05/2011.
//  Copyright 2011 home. All rights reserved.
//
#import "SettingViewController.h"
#import "FloodAppDelegate.h"
#import "SettingManager.h"
#import "BRMastodonClient.h"
#import "SettingOAuthWindowController.h"
#import "InstanceInputWindowController.h"
#import "Account.h"
#import "BRSlackClient.h"
#import "BRSlackChannelSelectionWindowController.h"
#import "SettingAccountCellObject.h"
#import "SettingAccountDetailMastodonView.h"
#import "SettingAccountDetailSlackView.h"
#import "BRMastodonSourceSelectionWindowController.h"
#import "BRMisskeyClient.h"
#import "SettingAccountDetailMisskeyView.h"
#import "BRMisskeyStreamSourceSelectionWindowController.h"
#import "SettingAccountDetailIrcView.h"
#import "IRC/BRIrcAccount.h"
#import "IRC/BRIrcLoginWindowController.h"

@interface SettingViewController () <SettingOAuthWindowControllerDelegate>

@property (strong, nonatomic) SettingOAuthWindowController *oauthController;
@property (weak) IBOutlet NSBox *accountDetailBox;
@property (weak) IBOutlet NSView *noAccountDetailView;
@property (weak) IBOutlet SettingAccountDetailMastodonView *mastodonDetailView;
@property (weak) IBOutlet SettingAccountDetailSlackView *slackDetailView;
@property (strong) IBOutlet SettingAccountDetailMisskeyView *misskeyDetailView;
@property (strong) IBOutlet SettingAccountDetailIrcView *ircDetailView;
@property (weak) IBOutlet NSButton *reconnectButton;
@property Account *detailSelectedAccount;

- (void)updateAccountView;

@end

@implementation SettingViewController

-(instancetype)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupToolbar{
	[self addView:accountsSettingView label:NSLocalizedString(@"Accounts", nil) image:[NSImage imageNamed:@"NSUser"] identifier:@"accounts"];
	[self addView:appearanceSettingView label:NSLocalizedString(@"Appearance",nil) image:[NSImage imageNamed:@"NSColorPanel"] identifier:@"appearance"];
}

+ (NSString *)nibName{
	return @"SettingViewController";
}

- (void)windowDidLoad{
	[super windowDidLoad];
    
    [self.screenPopup removeAllItems];
    NSMutableArray *screenNames = [NSMutableArray array];
    NSInteger i = 0;
    NSInteger selectedIndex = -1;
    FloodAppDelegate *appDelegate = (FloodAppDelegate *)[[NSApplication sharedApplication] delegate];
    NSScreen *currentScreen = [[[appDelegate windowController] window] screen];
    for (NSScreen *screen in [NSScreen screens]) {
        NSString *screenName = [NSString stringWithFormat:@"Screen %ld (%.0fx%.0f)", i + 1, screen.frame.size.width, screen.frame.size.height];
        [screenNames addObject:screenName];
        if (screen == currentScreen) {
            selectedIndex = i;
        }
        i++;
    }
    [self.screenPopup addItemsWithTitles:screenNames];
    [[self.screenPopup selectedItem] setState:NSControlStateValueOff];
    if (selectedIndex >= 0) {
        [[self.screenPopup itemAtIndex:selectedIndex] setState:NSControlStateValueOn];
        [self.screenPopup selectItemAtIndex:selectedIndex];
    }

    WindowLevel savedWindowLevel = [[SettingManager sharedManager] windowLevel];
    [[self.windowsLevelPopup selectedItem] setState:NSControlStateValueOff];
    [self.windowsLevelPopup selectItemAtIndex:savedWindowLevel];
    [[self.windowsLevelPopup itemAtIndex:savedWindowLevel] setState:1];
    
    CursorBehaviour savedCursorBehaviour = [[SettingManager sharedManager] cursorBehaviour];
    [[self.cursorBehaviourPopup selectedItem] setState:NSControlStateValueOff];
    [self.cursorBehaviourPopup selectItemAtIndex:savedCursorBehaviour];
    [[self.cursorBehaviourPopup itemAtIndex:savedCursorBehaviour] setState:1];

	showProfileImageCheckBox.state = [[SettingManager sharedManager] showProfileImage] ? NSControlStateValueOn : NSControlStateValueOff;
	self.removeLinksCheckBox.state = [[SettingManager sharedManager] removeLinks] ? NSControlStateValueOn : NSControlStateValueOff;
    self.truncateStatusCheckBox.state = [[SettingManager sharedManager] truncateStatus] ? NSControlStateValueOn : NSControlStateValueOff;
    if (self.truncateStatusCheckBox.state == NSControlStateValueOn) {
        self.truncateStatusField.enabled = self.truncateStatusStepper.enabled = YES;
    } else {
        self.truncateStatusField.enabled = self.truncateStatusStepper.enabled = NO;
    }
    self.truncateStatusField.integerValue = self.truncateStatusStepper.integerValue = [[SettingManager sharedManager] truncateStatusLength];
    self.animateGifCheckbox.state = [[SettingManager sharedManager] animateGif] ? NSControlStateValueOn : NSControlStateValueOff;
    
    self.ignoreContentWarningsCheckbox.state = [[SettingManager sharedManager] ignoreContentWarnings] ? NSControlStateValueOn : NSControlStateValueOff;
    self.flipUpDownCheckbox.state = [[SettingManager sharedManager] flipUpDown] ? NSControlStateValueOn : NSControlStateValueOff;
    self.historyPreserveLimitStepper.integerValue = self.historyPreserveLimitField.integerValue = [[SettingManager sharedManager] historyPreserveLimit];
    
    NSTimeInterval historyPreserveLimit = [[SettingManager sharedManager] historyPreserveDuration];
    self.historyPreserveDurationSlider.doubleValue = historyPreserveLimit;
    
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
    formatter.allowedUnits = NSCalendarUnitMinute;
    self.historyPreserveDurationLabel.stringValue = [formatter stringFromTimeInterval:historyPreserveLimit];

	opacitySlider.floatValue=[[SettingManager sharedManager]opacity];
	
    self.shadowCheckbox.state = [[SettingManager sharedManager] showShadow] ? NSControlStateValueOn : NSControlStateValueOff;
    shadowColorWell.enabled = [[SettingManager sharedManager] showShadow];
    
	[textColorWell setColor:[[SettingManager sharedManager] textColor]];
	[shadowColorWell setColor:[[SettingManager sharedManager]shadowColor]];
	[hoverBackgroundColorWell setColor:[[SettingManager sharedManager]hoverBackgroundColor]];
    [self.speedSlider setFloatValue:[[SettingManager sharedManager] speed]];
	NSFont *theFont=[[SettingManager sharedManager]font];
	[self.chooseFontButton setTitle:[NSString stringWithFormat:@"%@ %.0f",[theFont displayName],[theFont pointSize]]];

    self.appIconDefaultButton.state = self.appIconRIPButton.state = self.appIconRIP2Button.state = NSControlStateValueOff;
    NSString *appIcon = [[SettingManager sharedManager] customIcon];
    if ([appIcon isEqual:@"RIP"]) {
        self.appIconRIPButton.state = NSControlStateValueOn;
    } else if ([appIcon isEqual:@"RIP2"]) {
        self.appIconRIP2Button.state = NSControlStateValueOn;
    } else {
        self.appIconDefaultButton.state = NSControlStateValueOn;
    }
    
    [self updateAccountView];
    
    // need to find using identifier becoz system api doesn't compare it well
    NSArray<Account*> *accounts = [[SettingManager sharedManager] accounts];
    Account *selectedAccount = [[SettingManager sharedManager] selectedAccount];
    NSUInteger index = [self indexOfAccountByIdentifier:selectedAccount];

    if (index != NSNotFound) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [accountsTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    
    if (!accounts.count) {
        [self displayViewForIdentifier:@"accounts" animate:NO];
    }
}

- (NSUInteger)indexOfAccountByIdentifier:(Account *)a {
    NSArray<Account*> *accounts = [[SettingManager sharedManager] accounts];
    return [accounts indexOfObjectPassingTest:^BOOL(Account * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.identifier isEqualToString:a.identifier];
    }];
}

#pragma mark tableview datasource+delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
	if (aTableView==accountsTableView) {
        return [SettingManager sharedManager].accounts.count;
	}
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	if (aTableView == accountsTableView) {
        if ([aTableColumn.identifier isEqualTo:@"name"]) {
            Account *account = [[[SettingManager sharedManager] accounts] objectAtIndex:rowIndex];
            SettingAccountCellObject *obj = [[SettingAccountCellObject alloc] init];
            obj.accountName = account.shortDisplayName;
            obj.isConnected = [account.identifier isEqualToString:[SettingManager sharedManager].selectedAccount.identifier];
            obj.accountType =
                  [account isKindOfClass:[BRSlackAccount class]] ? SettingAccountTypeSlack
                : [account isKindOfClass:[BRMastodonAccount class]] ? SettingAccountTypeMastodon
                : [account isKindOfClass:[BRMisskeyAccount class]] ? SettingAccountTypeMisskey
                : [account isKindOfClass:[BRIrcAccount class]] ? SettingAccountTypeIrc
                : SettingAccountTypeMastodon;
            return obj;
        }
        return nil;
	}
	return nil;
}

- (IBAction)reconnectClicked:(id)sender {
    [[SettingManager sharedManager] setSelectedAccount:self.detailSelectedAccount];
    [self updateAccountView];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    if(tableView==accountsTableView){
        return 44;
    }
    return 0;
}

#pragma mark Accounts

- (void)addAccountWithHostName:(NSString *)hostName accountType:(SettingAccountType)accountType {
    [self addAccountWithHostName:hostName accountType:accountType updatingSlackAccount:nil];
}

- (void)addAccountWithHostName:(NSString *)hostName
                   accountType:(SettingAccountType)accountType
          updatingSlackAccount:(BRSlackAccount * _Nullable)slackAccount {
    if (![hostName hasPrefix:@"http://"] && ![hostName hasPrefix:@"https://"]) {
        hostName = [NSString stringWithFormat:@"https://%@", hostName];
    }
    if ([hostName hasSuffix:@"/"]) {
        hostName = [hostName substringToIndex:hostName.length - 1];
    }
    if (accountType == SettingAccountTypeSlack || [hostName hasSuffix:@".slack.com"]) {
        SettingOAuthWindowController *oauthController = [[SettingOAuthWindowController alloc] initWithSlackURL:[NSURL URLWithString:hostName]];
        oauthController.delegate = self;
        oauthController.updatingSlackAccount = slackAccount;
        [oauthController showWindow:self];
        self.oauthController = oauthController;
        return;
    }
    if (accountType == SettingAccountTypeMastodon) {
        [[BRMastodonClient shared] registerAppFor:hostName
                                completionHandler:^(BRMastodonApp * _Nonnull app, NSError * _Nonnull error) {
            NSLog(@"App: %@, Error: %@", app, error);
            NSLog(@"URL: %@", [app authorisationURL]);
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SettingOAuthWindowController *oauthController = [[SettingOAuthWindowController alloc] initWithApp:app];
                    oauthController.delegate = self;
                    [oauthController showWindow:self];
                    self.oauthController = oauthController;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAlert *alert = [NSAlert alertWithError:error];
                    [alert runModal];
                });
            }
        }];
        return;
    }
    if (accountType == SettingAccountTypeMisskey) {
        SettingOAuthWindowController *oauthController = [[SettingOAuthWindowController alloc] initWithMisskeyHostName:[NSURL URLWithString:hostName]];
        oauthController.delegate = self;
        [oauthController showWindow:self];
        self.oauthController = oauthController;
    }
}

- (IBAction)addAccountButtonClicked:(NSButton *)sender {
    NSPoint point = NSMakePoint(sender.frame.origin.x, sender.frame.origin.y);
    [sender.menu popUpMenuPositioningItem:nil atLocation:point inView:sender.superview];
}

- (IBAction)addMastodonAccountClicked:(id)sender {
    [self showInstanceInputWindowWithAccountType: SettingAccountTypeMastodon];
}
- (IBAction)addMisskeyAccountClicked:(id)sender {
    [self showInstanceInputWindowWithAccountType: SettingAccountTypeMisskey];
}

- (IBAction)addIrcAccountClicked:(id)sender {
    BRIrcLoginWindowController *controller = [[BRIrcLoginWindowController alloc] init];
    [self.window beginSheet:controller.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSModalResponseOK) return;
        [controller.account save];
        [self updateAccountView];
    }];
}


- (void)showInstanceInputWindowWithAccountType:(SettingAccountType)accountType {
    InstanceInputWindowController *controller = [[InstanceInputWindowController alloc] init];
    controller.accountType = accountType;
    [self.window beginSheet:controller.window
          completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            [self addAccountWithHostName:[controller hostName] accountType:controller.accountType];
        }
    }];
}

- (IBAction)deleteAccountClicked:(id)sender {
    NSInteger row = [accountsTableView selectedRow];
    if (row == -1) return;
    Account *account = [SettingManager sharedManager].accounts[row];
    [account deleteAccount];
    [[SettingManager sharedManager] reloadAccounts];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedAccountChanged object:nil];
    [self updateAccountView];
}

- (void)settingOAuthWindowController:(nonnull id)sender didLoggedInAccount:(nonnull BRMastodonAccount *)account {
    [self handleDidLoginAccount:account];
}

- (void)settingOAuthWindowController:(nonnull id)sender didLoggedInSlackAccount:(nonnull BRSlackAccount *)account {
    [self handleDidLoginAccount:account];
}

- (void)settingOAuthWindowController:(id)sender didLoggedInMisskeyAccount:(nonnull BRMisskeyAccount *)account {
    [self handleDidLoginAccount:account];
}

- (void)handleDidLoginAccount:(id)newAccount {
    typeof(self) __weak _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SettingManager sharedManager] reloadAccounts];
        [_self updateAccountView];
        [self.oauthController.window close];
        self.oauthController = nil;
        
        [[SettingManager sharedManager] setSelectedAccount: nil];
        [[SettingManager sharedManager] setSelectedAccount:newAccount];
    });
}

- (void)settingOAuthWindowController:(nonnull id)sender receivedError:(nonnull NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    });
}

- (void)updateAccountView {
    Account *lastDetailSelectedAccount = self.detailSelectedAccount;
    [[SettingManager sharedManager] reloadAccounts];
    [accountsTableView reloadData];

    NSUInteger index = [self indexOfAccountByIdentifier:lastDetailSelectedAccount];
    if (index != NSNotFound) {
        [accountsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
                       byExtendingSelection:NO];
    } else {
        [self updateAccountDetailView];
    }
}

- (void)updateAccountDetailView {
    if ([[[SettingManager sharedManager] accounts] count] == 0) {
        self.accountDetailBox.contentView = self.noAccountDetailView;
        self.reconnectButton.enabled = NO;
        return;
    }
    self.reconnectButton.enabled = YES;
    if ([self.detailSelectedAccount isKindOfClass:[BRMastodonAccount class]]) {
        self.accountDetailBox.contentView = self.mastodonDetailView;
        [self.mastodonDetailView setAccount:(BRMastodonAccount*)self.detailSelectedAccount];
    } else if ([self.detailSelectedAccount isKindOfClass:[BRSlackAccount class]]) {
        self.accountDetailBox.contentView = self.slackDetailView;
        [self.slackDetailView setAccount:(BRSlackAccount *)self.detailSelectedAccount];
    } else if ([self.detailSelectedAccount isKindOfClass:[BRMisskeyAccount class]]) {
        self.accountDetailBox.contentView = self.misskeyDetailView;
        [self.misskeyDetailView setAccount:(BRMisskeyAccount*)self.detailSelectedAccount];
    } else if ([self.detailSelectedAccount isKindOfClass:[BRIrcAccount class]]) {
        self.accountDetailBox.contentView = self.ircDetailView;
        [self.ircDetailView setAccount:(BRIrcAccount *)self.detailSelectedAccount];
    }
    Account *selectedAccount = [[SettingManager sharedManager] selectedAccount];
    if ([selectedAccount.identifier isEqualTo:self.detailSelectedAccount.identifier]) {
        self.reconnectButton.title = NSLocalizedString(@"Reconnect", @"setting account reconnect button");
    } else {
        self.reconnectButton.title = NSLocalizedString(@"Connect", @"setting account reconnect button");
    }
}

- (IBAction)mastodonOptionClicked:(id)sender {
    if (![self.detailSelectedAccount isKindOfClass:[BRMastodonAccount class]]) return;
    BRMastodonAccount *a = (BRMastodonAccount*)self.detailSelectedAccount;
    BRMastodonSourceSelectionWindowController *controller = [[BRMastodonSourceSelectionWindowController alloc] initWithAccount:a];
    [self.window beginSheet:controller.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSModalResponseOK) return;
        a.source = controller.selectedSource;
        a.sourceHashtag = controller.hashtag;
        a.sourceListId = controller.listId;
        a.sourceListName = controller.listName;
        [a save];
        
        BOOL needReconnect = self.detailSelectedAccount == [SettingManager sharedManager].selectedAccount;
        NSString *currentAccountIdentifier = self.detailSelectedAccount.identifier;

        [self updateAccountView];
        
        if (needReconnect) {
            [[SettingManager sharedManager] setSelectedAccount:[[SettingManager sharedManager] accountWithIdentifier:currentAccountIdentifier]];
        }
    }];
}

- (IBAction)slackOptionClicked:(id)sender {
    if (![self.detailSelectedAccount isKindOfClass:[BRSlackAccount class]]) return;
    BRSlackAccount *account = (BRSlackAccount *)self.detailSelectedAccount;
    [[BRSlackClient shared] getChannelListWithAccount:account
                                    completionHandler:^(NSArray<BRSlackChannel *> * _Nonnull channels, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BRSlackChannelSelectionWindowController *controller = [[BRSlackChannelSelectionWindowController alloc] init];
            controller.channels = channels;
            controller.selectedChannelIds = account.channelIds;
            controller.selectedThreadId = account.threadId;
            [self.window beginSheet:controller.window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSModalResponseOK) {
                    account.channelIds = [controller.selectedChannels valueForKeyPath:@"channelId"];
                    account.channelNames = [controller.selectedChannels valueForKeyPath:@"name"];
                    account.threadId = controller.selectedThreadId;
                    [account save];
                    
                    BOOL needReconnect = self.detailSelectedAccount == [SettingManager sharedManager].selectedAccount;
                    NSString *currentAccountIdentifier = self.detailSelectedAccount.identifier;

                    [self updateAccountView];
                    
                    if (needReconnect) {
                        [[SettingManager sharedManager] setSelectedAccount:[[SettingManager sharedManager] accountWithIdentifier:currentAccountIdentifier]];
                    }
                }
            }];
        });
    }];
}

- (IBAction)misskeyOptionClicked:(id)sender {
    BRMisskeyStreamSourceSelectionWindowController *controller = [[BRMisskeyStreamSourceSelectionWindowController alloc] init];
    BRMisskeyAccount *account = (BRMisskeyAccount *)self.detailSelectedAccount;
    controller.account = account;
    [self.window beginSheet:controller.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            account.streamSources = controller.selectedSources;
            [account save];
            [self updateAccountView];
            
            // Reconnect
            [[SettingManager sharedManager] setSelectedAccount:[[SettingManager sharedManager] accountWithIdentifier:account.identifier]];
        }
    }];
}

- (IBAction)ircOptionClicked:(id)sender {
    NSUInteger index = [accountsTableView selectedRow];
    if (index == -1) return;
    Account *detailSelectedAccount = [[SettingManager sharedManager].accounts objectAtIndex:index];
    if (![detailSelectedAccount isKindOfClass:[BRIrcAccount class]]) return;
    BRIrcLoginWindowController *controller = [[BRIrcLoginWindowController alloc] init];
    controller.account = (BRIrcAccount*)detailSelectedAccount;
    [self.window beginSheet:controller.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSModalResponseOK) return;
        [controller.account save];
        [self updateAccountView];
        // TODO: reconnect?
    }];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSUInteger index = [accountsTableView selectedRow];
    if (index == -1) return;
    Account *detailSelectedAccount = [[SettingManager sharedManager].accounts objectAtIndex:index];
    self.detailSelectedAccount = detailSelectedAccount;
    [self updateAccountDetailView];
}

#pragma mark Appearance

- (IBAction)screenChanged:(id)sender {
    NSInteger index = [self.screenPopup indexOfSelectedItem];
    FloodAppDelegate *appDelegate = (FloodAppDelegate *)[[NSApplication sharedApplication] delegate];
    NSScreen *targetScreen = [[NSScreen screens] objectAtIndex:index];
    NSWindow *window = [[appDelegate windowController] window];
    [window setFrame:targetScreen.frame display:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWindowScreenChanged object:nil];
}

- (IBAction)windowsLevelChanged:(id)sender {
    NSUInteger tag = [self.windowsLevelPopup selectedTag];
    [[SettingManager sharedManager] setWindowLevel:tag];
}

- (IBAction)cursorBehaviourChanged:(id)sender {
    NSUInteger tag = [self.cursorBehaviourPopup selectedTag];
    [[SettingManager sharedManager] setCursorBehaviour:tag];
}

- (IBAction)showProfileImageCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSControlStateValueOn;
    [[SettingManager sharedManager] setShowProfileImage:enabled];
}
- (IBAction)removeLinksCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSControlStateValueOn;
    [[SettingManager sharedManager] setRemoveLinks:enabled];
}
- (IBAction)truncateStatusCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSControlStateValueOn;
    [[SettingManager sharedManager] setTruncateStatus:enabled];
    if (enabled) {
        self.truncateStatusField.enabled = self.truncateStatusStepper.enabled = YES;
    } else {
        self.truncateStatusField.enabled = self.truncateStatusStepper.enabled = NO;
    }
}
- (IBAction)truncateStatusFieldChanged:(id)sender {
    NSInteger num = [self.truncateStatusField integerValue];
    self.truncateStatusField.integerValue = self.truncateStatusStepper.integerValue = MIN(500, MAX(10, num));
    [[SettingManager sharedManager] setTruncateStatusLength:num];
}
- (IBAction)truncateStatusSteppedChanged:(id)sender {
    NSInteger num = [sender integerValue];
    [[SettingManager sharedManager] setTruncateStatusLength:num];
    self.truncateStatusField.integerValue = num;
}

- (IBAction)animateGifCheckboxChanged:(id)sender {
    BOOL enabled = [(NSButton*)sender state] == NSControlStateValueOn;
    [[SettingManager sharedManager] setAnimateGif:enabled];
}

- (IBAction)ignoreContentWarningsCheckboxChanged:(id)sender {
    BOOL enabled = [(NSButton*)sender state] == NSControlStateValueOn;
    [[SettingManager sharedManager] setIgnoreContentWarnings:enabled];
}

- (IBAction)flipUpDownCheckvoxChanged:(id)sender {
    BOOL enabled = [(NSButton*)sender state] == NSControlStateValueOn;
    [[SettingManager sharedManager] setFlipUpDown:enabled];
}

- (IBAction)historyPreserveLimitFieldChanged:(id)sender {
    NSInteger num = [self.historyPreserveLimitField integerValue];
    self.historyPreserveLimitField.integerValue = self.historyPreserveLimitStepper.integerValue = MIN(1500, MAX(0, num));
    [[SettingManager sharedManager] setHistoryPreserveLimit:num];
}
- (IBAction)historyPreserveLimitSteppedChanged:(id)sender {
    NSTimeInterval num = [sender doubleValue];
    [[SettingManager sharedManager] setHistoryPreserveLimit:num];
    self.historyPreserveLimitField.doubleValue = num;
}
- (IBAction)historyPreserveDurationSliderChanged:(id)sender {
    NSSlider* slider=sender;
    [[SettingManager sharedManager] setHistoryPreserveDuration:[slider doubleValue]];
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
    formatter.allowedUnits = NSCalendarUnitMinute;
    self.historyPreserveDurationLabel.stringValue = [formatter stringFromTimeInterval:[slider doubleValue]];
}

- (IBAction)opacitySliderChanged:(id)sender {
	NSSlider* slider=sender;
    [[SettingManager sharedManager] setOpacity:slider.floatValue];
}

- (IBAction)textColorWellChanged:(id)sender {
	NSColorWell *well=sender;
    [[SettingManager sharedManager] setTextColor:well.color];
}

- (IBAction)shadowColorWellChanged:(id)sender {
	NSColorWell *well=sender;
    [[SettingManager sharedManager] setShadowColor:well.color];
}
- (IBAction)shadowCheckboxChanged:(id)sender {
    BOOL enabled = self.shadowCheckbox.state == NSControlStateValueOn;
    [[SettingManager sharedManager] setShowShadow:enabled];
    shadowColorWell.enabled = enabled;
}

- (IBAction)hoverBackgroundColor:(id)sender {
	NSColorWell *well=sender;
    [[SettingManager sharedManager] setHoverBackgroundColor:well.color];
}

- (IBAction)speedSliderChanged:(id)sender {
    [[SettingManager sharedManager] setSpeed:[(NSSlider*)sender floatValue]];
}

- (IBAction)chooseFontClicked:(id)sender {
	NSFontManager * fontManager = [NSFontManager sharedFontManager];
	[fontManager setTarget:self];
	[fontManager setSelectedFont:[[SettingManager sharedManager] font] isMultiple:NO];
	[fontManager orderFrontFontPanel:self];
}
- (void)changeFont:(id)sender{
	NSFontManager *manager=sender;
	NSFont *theFont=manager.selectedFont;
    theFont = [manager convertFont:theFont];
    [[SettingManager sharedManager] setFont:theFont];
	
    [self.chooseFontButton setTitle:[NSString stringWithFormat:@"%@ %.0f",[theFont displayName],[theFont pointSize]]];
}

- (IBAction)appIconDefaultButtonClicked:(id)sender {
    self.appIconDefaultButton.state = NSControlStateValueOn;
    self.appIconRIPButton.state = self.appIconRIP2Button.state = NSControlStateValueOff;
    [[SettingManager sharedManager] setCustomIcon:nil];
}
- (IBAction)appIconRIPButtonClicked:(id)sender {
    self.appIconDefaultButton.state = self.appIconRIP2Button.state = NSControlStateValueOff;
    self.appIconRIPButton.state = NSControlStateValueOn;
    [[SettingManager sharedManager] setCustomIcon:@"RIP1"];
}
- (IBAction)appIconRIP2ButtonClicked:(id)sender {
    self.appIconDefaultButton.state = self.appIconRIPButton.state = NSControlStateValueOff;
    self.appIconRIP2Button.state = NSControlStateValueOn;
    [[SettingManager sharedManager] setCustomIcon:@"RIP2"];
}

@end
