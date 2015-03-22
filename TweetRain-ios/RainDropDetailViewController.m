//
//  RainDropDetailViewController.m
//  TweetRain
//
//  Created by b123400 on 22/3/15.
//
//

#import "RainDropDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ComposeStatusViewController.h"

@interface RainDropDetailViewController ()

@property (nonatomic, strong) Status *status;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *rtButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@end

@implementation RainDropDetailViewController

- (instancetype) initWithStatus:(Status*)status {
    self = [super initWithNibName:@"RainDropDetailViewController" bundle:nil];
    
    self.status = status;
    self.title = NSLocalizedString(@"Status", nil);
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"")
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(closeButtonPressed:)];
    self.usernameLabel.text = self.status.user.username;
    self.nameLabel.text = self.status.user.screenName;
    self.contentTextView.text = self.status.text;
    [self.profileImageView sd_setImageWithURL:self.status.user.profileImageURL];
    
    for (UIButton *button in @[self.rtButton, self.replyButton, self.retweetButton, self.favButton]) {
        button.layer.cornerRadius = button.frame.size.width/2;
        button.layer.masksToBounds = YES;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize newSize = [self.contentTextView sizeThatFits:CGSizeMake(self.contentTextView.frame.size.width,
                                                                   MAXFLOAT)];
    
    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, newSize.height+160);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate rainDropDetailViewControllerDidClosed:self];
    }];
}

- (IBAction)replyButtonPressed:(id)sender {
    ComposeStatusViewController *controller = [[ComposeStatusViewController alloc] initWithReplyStatus:self.status type:ComposeStatusTypeReply];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)retweetButtonPressed:(id)sender {

}

- (IBAction)rtButtonPressed:(id)sender {
    ComposeStatusViewController *controller = [[ComposeStatusViewController alloc] initWithReplyStatus:self.status type:ComposeStatusTypeRetweet];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)favButtonPressed:(id)sender {
    
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
