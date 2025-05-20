//
//  BRSlackChannelSelectionWindowController.m
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import "BRSlackChannelSelectionWindowController.h"

@interface BRSlackChannelSelectionWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic) NSMutableIndexSet *selectedIndexSet;

@end

@implementation BRSlackChannelSelectionWindowController

- (instancetype)init {
    self.selectedIndexSet = [NSMutableIndexSet indexSet];
    return [super initWithWindowNibName:@"BRSlackChannelSelectionWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.threadURLField.stringValue = self.selectedThreadId ?: @"";
    [self reloadButtons];
}

- (void)reloadButtons {
    self.okButton.enabled = self.selectedChannels.count > 0 || [self.selectedThreadId length] > 0;
}

- (void)setChannels:(NSArray *)channels {
    _channels = [channels sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    [self.channelsTableView reloadData];
}

- (NSArray<BRSlackChannel*> *)selectedChannels {
    return [self.channels objectsAtIndexes:self.selectedIndexSet];
}

- (void)setSelectedChannelIds:(NSArray<NSString *> *)channelIds {
    self.selectedIndexSet = [[self.channels indexesOfObjectsPassingTest:^BOOL(BRSlackChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [channelIds containsObject:obj.channelId];
    }] mutableCopy];
    [self.channelsTableView reloadData];
    [self reloadButtons];
}

- (NSString *)threadIdFromInputNumber {
    NSString *inputString = self.threadURLField.stringValue;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+$" options:0 error:nil];
    NSArray<NSTextCheckingResult*> *results = [regex matchesInString:inputString options:0 range:NSMakeRange(0, inputString.length)];
    if (!results.count) return nil;
    NSRange range = [[results firstObject] rangeAtIndex:0];
    return [inputString substringWithRange:range];
}

- (NSString *)threadIdFromInputURL {
    NSString *inputString = self.threadURLField.stringValue;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"slack.com/archives/[a-zA-Z0-9]+/p([0-9\\.]+)(\\?thread_ts=[0-9\\.]+)?" options:0 error:nil];
    
    // Handle both of these formats
    // https://herp-inc.slack.com/archives/CDZTR540M/p1657867942501739
    // https://herp-inc.slack.com/archives/CDZTR540M/p1657868823936069?thread_ts=1657867942.501739&cid=CDZTR540M
    NSArray<NSTextCheckingResult*> *results = [regex matchesInString:inputString options:0 range:NSMakeRange(0, inputString.length)];
    if (!results.count) return nil;
    NSRange firstRange = [[results firstObject] rangeAtIndex:1];
    NSRange secondRange = [[results firstObject] rangeAtIndex:2];
    NSString *firstString = [inputString substringWithRange:firstRange];
    NSString *secondString = secondRange.location != NSNotFound
        ? [[[inputString substringWithRange:secondRange]
            stringByReplacingOccurrencesOfString:@"?thread_ts=" withString:@""]
           stringByReplacingOccurrencesOfString:@"." withString:@""]
        : nil;
    return secondString ?: firstString;
}



- (void)tableView:(NSTableView *)tableView willDisplayCell:(NSButtonCell *)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    BRSlackChannel *channel = self.channels[row];
    cell.title = channel.name;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return @([self.selectedIndexSet containsIndex:row]);
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([object boolValue]) {
        [self.selectedIndexSet addIndex:row];
    } else {
        [self.selectedIndexSet removeIndex:row];
    }
    [self reloadButtons];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.channels.count;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    if ([notification object] == self.threadURLField) {
        self.selectedThreadId = [self threadIdFromInputNumber] ?: [self threadIdFromInputURL];
        [self reloadButtons];
    }
}

- (IBAction)nonePressed:(id)sender {
    [self.selectedIndexSet removeAllIndexes];
    [self.channelsTableView reloadData];
    [self reloadButtons];
}

- (IBAction)allPressed:(id)sender {
    [self.selectedIndexSet addIndexesInRange:NSMakeRange(0, self.channels.count)];
    [self.channelsTableView reloadData];
    [self reloadButtons];
}

- (IBAction)okPressed:(id)sender {
    [self.window.sheetParent endSheet:self.window
                               returnCode:NSModalResponseOK];
}
- (IBAction)cancelPressed:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseCancel];
}

@end
