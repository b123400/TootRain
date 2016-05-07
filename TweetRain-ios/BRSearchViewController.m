//
//  BRSearchViewController.m
//  TweetRain
//
//  Created by b123400 on 8/5/2016.
//
//

#import <STTwitter/STTwitter.h>
#import "SettingManager.h"
#import "BRSearchViewController.h"
#import "TextFieldTableViewCell.h"

@interface BRSearchViewController () <TextFieldTableViewCellDelegate>
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) NSArray <NSString*> *trends;
@property (nonatomic, strong) NSArray <NSString*> *savedSearches;
@end

@implementation BRSearchViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.trends = @[];
    self.savedSearches = @[];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Search", @"title");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(donePressed)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadTrends];
    [self loadSavedSearches];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSearchTerm:(NSString *)searchTerm {
    if ([_searchTerm isEqualToString:searchTerm]) {
        return;
    }
    _searchTerm = searchTerm;
    TextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.textField.text = searchTerm;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.savedSearches.count;
        case 2:
            return self.trends.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Current search term", @"search table header");
        case 1:
            return NSLocalizedString(@"Saved searches", @"search table header");
        case 2:
            return NSLocalizedString(@"Trends", @"search table header");
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.textField.text = self.searchTerm;
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"
                                                            forIndexPath:indexPath];
    if (indexPath.section == 1) {
        cell.textLabel.text = self.savedSearches[indexPath.row];
    } else if (indexPath.section == 2) {
        cell.textLabel.text = self.trends[indexPath.row];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TextFieldTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textLabel becomeFirstResponder];
    } else if (indexPath.section == 1) {
        [self.delegate searchViewController:self
                       didEnteredSearchTerm:self.savedSearches[indexPath.row]];
    } else if (indexPath.section == 2) {
        [self.delegate searchViewController:self
                       didEnteredSearchTerm:self.trends[indexPath.row]];
    }
}

#pragma mark - interaction

- (void)cancelPressed {
    [self.delegate searchViewControllerDidCancelled:self];
}

- (void)donePressed {
    [self.delegate searchViewController:self didEnteredSearchTerm:self.searchTerm];
}

- (void)textFieldCell:(id)cell textDidChanged:(NSString *)text {
    self.searchTerm = text;
}

- (void)textFieldCellDidPressedEnter:(id)cell {
    [self donePressed];
}

#pragma mark - Twitter

- (STTwitterAPI *)twitter {
    if (!_twitter) {
        ACAccount *selectedAccount = [[SettingManager sharedManager] selectedAccount];
        _twitter = [STTwitterAPI twitterAPIOSWithAccount:selectedAccount delegate:nil];
    }
    return _twitter;
}

#pragma mark - Fetching

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
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.savedSearches.count];
        for (NSInteger i = 0; i < self.savedSearches.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    } errorBlock:^(NSError *error) {
        
    }];
}

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
                           NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.trends.count];
                           for (NSInteger i = 0; i < self.trends.count; i++) {
                               [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:2]];
                           }
                           [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                       } errorBlock:^(NSError *error) {
                           
                       }];
}

@end
