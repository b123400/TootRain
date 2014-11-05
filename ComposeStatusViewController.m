//
//  ComposeStatusViewController.m
//  flood
//
//  Created by b123400 on 22/8/12.
//
//

#import "ComposeStatusViewController.h"
#import "SettingManager.h"

@interface ComposeStatusViewController ()

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
    }
    
    return self;
}

- (IBAction)sendButtonClicked:(id)sender {
//	ComposeRequest *request=[[ComposeRequest alloc]init];
//	request.text=[[contentTextView textStorage]string];
//	request.account=[[[SettingManager sharedManager]accounts]objectAtIndex:0];
//	request.target=self;
//	request.successSelector=@selector(request:didFinishedWithResult:);
//	request.failSelector=@selector(request:didFailedWithError:);
//	if(inReplyTo){
//		request.inReplyTo=inReplyTo;
//	}
//	[[StatusesManager sharedManager] sendStatus:request];
//	[sendButton setEnabled:NO];
//	[sendButton setTitle:@"Loading"];
}

//-(void)request:(ComposeRequest*)request didFinishedWithResult:(id)result{
//	[sendButton setTitle:@"Sent"];
//	[self.popover performSelector:@selector(close) withObject:nil afterDelay:0.5];
//}
//-(void)request:(ComposeRequest*)request didFailedWithError:(NSError *)error{
//	[sendButton setEnabled:YES];
//	[sendButton setTitle:@"Failed"];
//	[sendButton performSelector:@selector(setTitle:) withObject:@"Send" afterDelay:0.5];
//}
@end
