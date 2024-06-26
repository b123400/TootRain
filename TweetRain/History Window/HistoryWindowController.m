//
//  HistoryWindowController.m
//  TweetRain
//
//  Created by b123400 on 2023/11/22.
//

#import "HistoryWindowController.h"
#import "RainDropDetailViewController.h"
#import "DummyStatus.h"
#import "NSMutableAttributedString+Stripe.h"
#import "SettingManager.h"

@interface HistoryWindowController () <NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (strong) NSPopover *popover;

@property (nonatomic, strong) NSMutableArray<Status*> *statuses;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation HistoryWindowController

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static HistoryWindowController *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[HistoryWindowController alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super initWithWindowNibName:@"HistoryWindowController"];
    self.statuses = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cleanOldStatuses) userInfo:nil repeats:YES];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)addStatus:(Status *)s {
    [self.statuses addObject:s];
    if ([self.window isVisible]) {
        [self.tableView reloadData];
    }
}

- (void)cleanOldStatuses {
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.statuses.count; i++) {
        if ([[NSDate date] timeIntervalSinceDate:self.statuses[i].objectCreated] > [[SettingManager sharedManager] historyPreserveDuration]) {
            index = i;
        } else {
            break;
        }
    }
    if (index >= 0) {
        [self.statuses removeObjectsInRange:NSMakeRange(0, index + 1)];
    }
    NSInteger limit = [[SettingManager sharedManager] historyPreserveLimit];
    if (self.statuses.count > limit) {
        [self.statuses removeObjectsInRange:NSMakeRange(0, self.statuses.count - limit)];
    }
    [self.tableView reloadData];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.statuses.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Status *status = self.statuses[row];
    NSMutableAttributedString *attrString = [[status attributedSpoilerOrText] mutableCopy];
    if ([tableColumn.identifier isEqual:@"content"]) {
        [attrString addAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]} range:NSMakeRange(0, attrString.length)];
        [attrString resizeImagesWithHeight:20];
        return attrString;
    } else if ([tableColumn.identifier isEqual:@"user"]) {
        return status.user.screenName ?: status.user.username;
    } else if ([tableColumn.identifier isEqual:@"timestamp"]) {
        return [self.dateFormatter stringFromDate:status.createdAt ?: status.objectCreated];
    }
    return @"";
}

- (IBAction)tableViewDidDoubleClick:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row < 0) return;
    Status *status = self.statuses[row];
    if ([status isKindOfClass:[DummyStatus class]]) return;
    
    if (!self.popover) {
        self.popover = [[NSPopover alloc] init];
        NSViewController *newController = [[RainDropDetailViewController alloc] initWithStatus:status];
        self.popover.contentViewController = newController;
        self.popover.behavior = NSPopoverBehaviorTransient;
        self.popover.delegate = self;
    }
    if (![self.popover isShown]) {
        [self.popover showRelativeToRect:[self.tableView frameOfCellAtColumn:0 row:row] ofView:self.tableView preferredEdge:NSMaxXEdge];
    } else {
        [self.popover close];
        self.popover = nil;
    }
}

- (void)popoverDidClose:(NSNotification *)notification {
    self.popover = nil;
}

@end
