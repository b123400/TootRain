//
//  ComposeStatusViewController.m
//  flood
//
//  Created by b123400 on 22/8/12.
//
//

#import "ComposeStatusViewController.h"
#import "SettingManager.h"
#import "BRMastodonClient.h"
#import "MastodonStatus.h"
//#import <STTwitter/STTwitter.h>

@interface ComposeStatusViewController ()

//@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation ComposeStatusViewController
@synthesize sendButton;
@synthesize contentTextView,inReplyTo,popover;

-(id)init{
	return [self initWithNibName:@"ComposeStatusViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
//        self.twitter = [STTwitterAPI twitterAPIOSWithAccount:[[SettingManager sharedManager]selectedAccount]];
    }
    
    return self;
}

- (IBAction)sendButtonClicked:(id)sender {
    if ([self.inReplyTo isKindOfClass:[MastodonStatus class]]) {
        MastodonStatus *inReplyTo = (MastodonStatus*)self.inReplyTo;
        [[BRMastodonClient shared] replyToStatus:inReplyTo.mastodonStatus
                                        withText:[[contentTextView textStorage] string]
                               completionHandler:^(BRMastodonStatus * _Nullable status, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [sendButton setTitle:NSLocalizedString(@"Sent", nil)];
                    [self.popover performSelector:@selector(close) withObject:nil afterDelay:0.5];
                } else {
                    [sendButton setEnabled:YES];
                    [sendButton setTitle:NSLocalizedString(@"Failed",nil)];
                    [sendButton performSelector:@selector(setTitle:) withObject:NSLocalizedString(@"Send",nil) afterDelay:0.5];
                }
            });
        }];
    }
	[sendButton setEnabled:NO];
	[sendButton setTitle:NSLocalizedString(@"Loading",nil)];
}

@end
