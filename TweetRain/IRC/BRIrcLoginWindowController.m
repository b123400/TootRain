//
//  BRIrcLoginWindowController.m
//  TweetRain
//
//  Created by b123400 on 2025/01/20.
//

#import "BRIrcLoginWindowController.h"

@interface BRIrcLoginWindowController () <NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTextField *hostTextField;
@property (weak) IBOutlet NSTextField *portTextField;
@property (weak) IBOutlet NSButton *tlsCheckBox;
@property (weak) IBOutlet NSTextField *nickTextField;
@property (weak) IBOutlet NSTextField *passTextField;
@property (weak) IBOutlet NSTableView *channelsTableView;

@property (nonatomic, strong) NSMutableArray<NSString *> *channels;

@end

@implementation BRIrcLoginWindowController

- (instancetype)init {
    self = [super initWithWindowNibName:@"BRIrcLoginWindowController"];
    self.channels = [NSMutableArray array];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (void)setAccount:(BRIrcAccount *)account {
    _account = account;
    self.hostTextField.stringValue = account.host ?: @"";
    self.portTextField.stringValue = [NSString stringWithFormat:@"%ld", account.port];
    self.tlsCheckBox.state = account.tls ? NSControlStateValueOn : NSControlStateValueOff;
    self.nickTextField.stringValue = account.nick ?: @"";
    self.passTextField.stringValue = account.pass ?: @"";
    self.channels = [account mutableCopy];
    [self.channelsTableView reloadData];
}

- (IBAction)addChannelClicked:(id)sender {
    [self.channels addObject:@""];
    [self.channelsTableView reloadData];
    [self.channelsTableView editColumn:0 row:self.channels.count - 1 withEvent:nil select:YES];
}

- (IBAction)removeChannelClicked:(id)sender {
    [self.channels removeObjectsAtIndexes:[self.channelsTableView selectedRowIndexes]];
    [self.channelsTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.channels.count;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    self.channels[row] = object;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return self.channels[row];
}

- (IBAction)okClicked:(id)sender {
    if (!self.account) {
        _account = [[BRIrcAccount alloc] init];
    }
    self.account.host = self.hostTextField.stringValue;
    self.account.port = self.portTextField.integerValue;
    self.account.tls = self.tlsCheckBox.state == NSControlStateValueOn;
    self.account.nick = self.nickTextField.stringValue;
    self.account.pass = self.passTextField.stringValue;
    self.account.channels = [[NSArray arrayWithArray:self.channels] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseOK];
}
- (IBAction)cancelClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseCancel];
}

@end
