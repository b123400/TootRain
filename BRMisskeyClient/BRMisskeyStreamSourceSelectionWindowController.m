//
//  BRMisskeyStreamSourceSelectionWindowController.m
//  TweetRain
//
//  Created by b123400 on 2022/12/26.
//

#import "BRMisskeyStreamSourceSelectionWindowController.h"
#import "BRMisskeyClient.h"

@interface BRMisskeyStreamSourceSelectionWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) NSMutableOrderedSet<BRMisskeyStreamSource*> *sources;
@property (nonatomic) NSMutableIndexSet *selectedIndexSet;

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation BRMisskeyStreamSourceSelectionWindowController

- (instancetype)init {
    if (self = [super initWithWindowNibName:@"BRMisskeyStreamSourceSelectionWindowController"]) {
        self.selectedIndexSet = [NSMutableIndexSet indexSet];
        [self reloadSourcesWithAccount];
    }
    return self;
}

- (void)reloadSourcesWithAccount {
    self.sources = [[NSMutableOrderedSet alloc] initWithArray:[BRMisskeyStreamSource defaultSources]];
    if (!self.account) return;
    typeof(self) __weak _self = self;
    [[BRMisskeyClient shared] getAntennaSourcesWithAccount:self.account
                                         completionHandler:^(NSArray<BRMisskeyStreamSource *> * _Nullable sources, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.sources addObjectsFromArray:sources];
            [_self.tableView reloadData];
        });
    }];
    [[BRMisskeyClient shared] getUserListSourcesWithAccount:self.account
                                          completionHandler:^(NSArray<BRMisskeyStreamSource *> * _Nullable sources, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.sources addObjectsFromArray:sources];
            [_self.tableView reloadData];
        });
    }];
    [[BRMisskeyClient shared] getChannelSourcesWithAccount:self.account
                                         completionHandler:^(NSArray<BRMisskeyStreamSource *> * _Nullable sources, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.sources addObjectsFromArray:sources];
            [_self.tableView reloadData];
        });
    }];
}

- (void)setAccount:(BRMisskeyAccount *)account {
    _account = account;
    [self reloadSourcesWithAccount];

    NSArray<BRMisskeyStreamSource*> *selectedSources = account.streamSources;
    for (BRMisskeyStreamSource *s in selectedSources) {
        [self.sources addObject:s];
    }
    self.selectedIndexSet = [[self.sources indexesOfObjectsPassingTest:^BOOL(BRMisskeyStreamSource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [selectedSources containsObject:obj];
    }] mutableCopy];
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
    return @([self.selectedIndexSet containsIndex:row]);
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
