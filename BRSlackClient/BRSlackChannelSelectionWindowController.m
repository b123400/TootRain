//
//  BRSlackChannelSelectionWindowController.m
//  TweetRain
//
//  Created by b123400 on 2021/07/14.
//

#import "BRSlackChannelSelectionWindowController.h"

@interface BRSlackChannelSelectionWindowController ()

@end

@implementation BRSlackChannelSelectionWindowController

- (instancetype)init {
    return [super initWithWindowNibName:@"BRSlackChannelSelectionWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.okButton.enabled = self.dropdown.indexOfSelectedItem != -1;
    [self.dropdown removeAllItems];
    [self.dropdown addItemsWithTitles:[self.channels valueForKey:@"name"]];
}
- (IBAction)dropdownDidSelect:(id)sender {
    self.okButton.enabled = self.dropdown.indexOfSelectedItem != -1;
}

- (void)setChannels:(NSArray *)channels {
    _channels = [channels sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    [self.dropdown removeAllItems];
    [self.dropdown addItemsWithTitles:[self.channels valueForKey:@"name"]];
}

- (BRSlackChannel *)selectedChannel {
    NSInteger index = [self.dropdown indexOfSelectedItem];
    if (index == -1) {
        return nil;
    }
    return self.channels[index];
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
