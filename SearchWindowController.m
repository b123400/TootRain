//
//  SearchWindowController.m
//  flood
//
//  Created by b123400 on 21/8/12.
//
//

#import "SearchWindowController.h"
#import "SettingManager.h"
#import <STTwitter/STTwitter.h>

@interface SearchWindowController ()

@property (nonatomic, strong) STTwitterAPI *twitter;

@property (nonatomic, strong) NSArray <NSString*> *savedSearches;
@property (nonatomic, strong) NSArray <NSString*> *trends;

@end

@implementation SearchWindowController
@synthesize delegate;

-(id)init{
	self = [self initWithWindowNibName:@"SearchWindowController"];
    self.savedSearches = @[];
    self.trends = @[];
    [self loadSavedSearches];
    [self loadTrends];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    searchTextField.recentsAutosaveName = @"Search term";
    [self setupSearchMenu];
}

- (void)setupSearchMenu {
    NSMenu *searchMenu = [[NSMenu alloc] init];
    
    NSMenuItem *recentSearchTitleItem = [[NSMenuItem alloc] init];
    recentSearchTitleItem.title = NSLocalizedString(@"Recent Search", @"");
    recentSearchTitleItem.tag = NSSearchFieldRecentsTitleMenuItemTag;
    [searchMenu addItem:recentSearchTitleItem];
    
    NSMenuItem *recentItem = [[NSMenuItem alloc] init];
    recentItem.tag = NSSearchFieldRecentsMenuItemTag;
    [searchMenu addItem:recentItem];
    
    [searchMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *clearItem = [[NSMenuItem alloc] init];
    clearItem.title = NSLocalizedString(@"Clear search history", @"");
    clearItem.tag = NSSearchFieldClearRecentsMenuItemTag;
    [searchMenu addItem:clearItem];
    
    if (self.savedSearches.count) {
        [searchMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *titleItem = [[NSMenuItem alloc] init];
        titleItem.title = NSLocalizedString(@"Saved Searches", @"");
        [searchMenu addItem:titleItem];

        for (NSString *savedSearch in self.savedSearches) {
            NSMenuItem *item = [[NSMenuItem alloc] init];
            item.target = self;
            item.action = @selector(menuItemClicked:);
            item.title = savedSearch;
            [searchMenu addItem:item];
        }
    }
    
    if (self.trends.count) {
        [searchMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *titleItem = [[NSMenuItem alloc] init];
        titleItem.title = NSLocalizedString(@"Trends", @"");
        [searchMenu addItem:titleItem];
        
        for (NSString *savedSearch in self.trends) {
            NSMenuItem *item = [[NSMenuItem alloc] init];
            item.target = self;
            item.action = @selector(menuItemClicked:);
            item.title = savedSearch;
            [searchMenu addItem:item];
        }
    }
    
    searchTextField.searchMenuTemplate = searchMenu;
}

- (void)menuItemClicked:(NSMenuItem*)item {
    searchTextField.stringValue = item.title;
}

- (IBAction)finishButtonClicked:(id)sender {
    [searchTextField performClick:self];
    [self finishedEditing];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [searchTextField performClick:self];
        [self finishedEditing];
        return YES;
    }
    return NO;
}

- (void)finishedEditing {
    [delegate searchTermChangedTo:searchTextField.stringValue];
    [self close];
}

#pragma mark - Twitter

- (STTwitterAPI *)twitter {
    if (!_twitter) {
        ACAccount *selectedAccount = [[SettingManager sharedManager] selectedAccount];
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:selectedAccount delegate:nil];
    }
    return _twitter;
}

#pragma mark - Save searches

- (void)loadSavedSearches {
    [self.twitter getSavedSearchesListWithSuccessBlock:^(NSArray *savedSearches) {
        NSMutableArray *savedSearchesString = [NSMutableArray arrayWithCapacity:savedSearches.count];
        for (NSDictionary *savedSearch in savedSearches) {
            NSString *name = savedSearch[@"name"];
            if (name) {
                [savedSearchesString addObject:name];
            }
        }
        self.savedSearches = savedSearchesString;
        [self setupSearchMenu];
    } errorBlock:^(NSError *error) {
        
    }];
}

#pragma mark - Trend

- (void)loadTrends {
    [self.twitter getTrendsForWOEID:@"1"
                    excludeHashtags:@NO
                       successBlock:^(NSDate *asOf, NSDate *createdAt, NSArray *locations, NSArray *trends) {
                           NSMutableArray *trendStrings = [NSMutableArray arrayWithCapacity:trends.count];
                           for (NSDictionary *trend in trends) {
                               NSString *name = trend[@"name"];
                               if (name) {
                                   [trendStrings addObject:name];
                               }
                           }
                           self.trends = trendStrings;
                           [self setupSearchMenu];
                       } errorBlock:^(NSError *error) {
                           
                       }];
}

@end
