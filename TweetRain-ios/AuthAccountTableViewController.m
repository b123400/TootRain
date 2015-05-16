//
//  AuthAccountTableViewController.m
//  TweetRain
//
//  Created by b123400 on 17/5/15.
//
//

#import "AuthAccountTableViewController.h"

@interface AuthAccountTableViewController ()

@end

@implementation AuthAccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 300)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, CGRectGetWidth(self.tableView.frame), 56)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"Which account?", @"");
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48.0];
    titleLabel.textColor = [UIColor blackColor];
    [headerView addSubview:titleLabel];
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.tableView.frame), 24)];
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    captionLabel.text = NSLocalizedString(@"Choose one to connect to:", @"");
    [headerView addSubview:captionLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 300;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
