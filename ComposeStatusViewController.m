//
//  ComposeStatusViewController.m
//  flood
//
//  Created by b123400 on 22/8/12.
//
//

#import "ComposeStatusViewController.h"
#import "SettingManager.h"
#import <STTwitter/STTwitter.h>

@interface ComposeStatusViewController ()

@property (nonatomic, strong) STTwitterAPI *twitter;

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
        self.twitter = [STTwitterAPI twitterAPIOSWithAccount:[[SettingManager sharedManager]selectedAccount]];
    }
    
    return self;
}

- (IBAction)sendButtonClicked:(id)sender {
    [self.twitter postStatusUpdate:[[contentTextView textStorage] string]
                 inReplyToStatusID:inReplyTo.statusID
                          latitude:nil
                         longitude:nil
                           placeID:nil
                displayCoordinates:nil
                          trimUser:nil
                      successBlock:^(NSDictionary *status) {
                          [sendButton setTitle:@"Sent"];
                          [self.popover performSelector:@selector(close) withObject:nil afterDelay:0.5];
                      } errorBlock:^(NSError *error) {
                          [sendButton setEnabled:YES];
                          [sendButton setTitle:@"Failed"];
                          [sendButton performSelector:@selector(setTitle:) withObject:@"Send" afterDelay:0.5];
                      }];
	[sendButton setEnabled:NO];
	[sendButton setTitle:@"Loading"];
}

@end
