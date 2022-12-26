//
//  BRMisskeyStreamSourceSelectionWindowController.m
//  TweetRain
//
//  Created by b123400 on 2022/12/26.
//

#import "BRMisskeyStreamSourceSelectionWindowController.h"

@interface BRMisskeyStreamSourceSelectionWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic) NSMutableIndexSet *selectedIndexSet;

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation BRMisskeyStreamSourceSelectionWindowController

- (instancetype)init {
    if (self = [super initWithWindowNibName:@"BRMisskeyStreamSourceSelectionWindowController"]) {
        self.selectedIndexSet = [NSMutableIndexSet indexSet];
    }
    return self;
}


- (void)setSources:(NSArray<BRMisskeyStreamSource *> *)sources {
    _sources = sources;
    [self.tableView reloadData];
}

- (void)setSelectedSources:(NSArray<BRMisskeyStreamSource *> *)selectedSources {
    self.selectedIndexSet = [[self.sources indexesOfObjectsPassingTest:^BOOL(BRMisskeyStreamSource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [selectedSources containsObject:obj];
    }] mutableCopy];
    [self.tableView reloadData];
}

- (NSArray<BRMisskeyStreamSource*> *)selectedSources {
    return [self.sources objectsAtIndexes:self.selectedIndexSet];
}

- (IBAction)okClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseOK];
}

- (IBAction)cancelClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window
                           returnCode:NSModalResponseCancel];
}

# pragma mark: - Table view

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.sources.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    BRMisskeyStreamSource *source = self.sources[row];
    return @([self.selectedSources containsObject:source]);
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(NSButtonCell *)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    BRMisskeyStreamSource *source = self.sources[row];
    cell.title = [source displayName];
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    BRMisskeyStreamSource *source = self.sources[row];
    if ([object boolValue]) {
        [self.selectedIndexSet addIndex:row];
    } else {
        [self.selectedIndexSet removeIndex:row];
    }
}

@end
