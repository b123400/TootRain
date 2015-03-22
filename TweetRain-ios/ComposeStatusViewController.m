//
//  ComposeStatusViewController.m
//  TweetRain
//
//  Created by b123400 on 22/3/15.
//
//

#import "ComposeStatusViewController.h"
#import "Status.h"
#import <STTwitter/STTwitter.h>
#import "SettingManager.h"

@interface ComposeStatusViewController ()

@property (nonatomic, strong) Status *status;
@property (nonatomic, assign) ComposeStatusType type;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation ComposeStatusViewController

- (instancetype) initWithReplyStatus:(Status*)status type:(ComposeStatusType)type {
    self = [super init];
    
    self.status = status;
    self.type = type;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:[[SettingManager sharedManager]selectedAccount]];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    switch (self.type) {
        case ComposeStatusTypeReply:
            self.contentTextView.text = [NSString stringWithFormat:@"@%@ ", self.status.user.username];
            self.contentTextView.selectedRange = NSMakeRange(self.contentTextView.text.length, 0);
            break;
            
        case ComposeStatusTypeRetweet:
            self.contentTextView.text = [NSString stringWithFormat:@"RT @%@: %@",
                                         self.status.user.username,
                                         self.status.text];
            self.contentTextView.selectedRange = NSMakeRange(0, 0);
            
        default:
            break;
    }
    [self.contentTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButtonPressed:(id)sender {
    [self.twitter postStatusUpdate:self.contentTextView.text
                 inReplyToStatusID:self.status.statusID
                          latitude:nil
                         longitude:nil
                           placeID:nil
                displayCoordinates:nil
                          trimUser:nil
                      successBlock:^(NSDictionary *status) {
                          [self.sendButton setTitle:NSLocalizedString(@"Sent", nil) forState:UIControlStateNormal];
                          [self dismissViewControllerAnimated:YES completion:nil];
                      } errorBlock:^(NSError *error) {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                                          message:error.localizedDescription
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles: nil];
                          [alert show];
                          [self.sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
                      }];
    self.sendButton.enabled = NO;
    [self.sendButton setTitle:@"Loading" forState:UIControlStateNormal];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
