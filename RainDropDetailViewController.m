//
//  RainDropDetailViewController.m
//  flood
//
//  Created by b123400 on 19/8/12.
//
//

#import "RainDropDetailViewController.h"
#import "ComposeStatusViewController.h"
#import "SettingManager.h"

@interface RainDropDetailViewController ()

@end

@implementation RainDropDetailViewController
@synthesize contentTextField;
@synthesize profileImageView;
@synthesize nameField;
@synthesize usernameField;
@synthesize retweetButton;
@synthesize favButton;

-(id)initWithStatus:(Status*)_status{
	status=_status;
	return [self init];
}

-(id)init{
	return [self initWithNibName:@"RainDropDetailViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(void)loadView{
	[super loadView];
	
	nameField.stringValue=status.user.screenName;
	usernameField.stringValue=[NSString stringWithFormat:@"@%@", status.user.username];
	
	NSMutableString *contentString=[NSMutableString stringWithString:status.text];
	if(status.entities){
		for(NSDictionary *thisURLSet in [status.entities objectForKey:@"urls"]){
			NSRange range=[contentString rangeOfString:[thisURLSet objectForKey:@"url"]];
			if(range.location!=NSNotFound){
				[contentString replaceCharactersInRange:range withString:[thisURLSet objectForKey:@"display_url"]];
			}
		}
	}
	
	NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:contentString];
	if(status.entities){
		for(NSDictionary *thisURLSet in [status.entities objectForKey:@"urls"]){
			NSRange range=[contentString rangeOfString:[thisURLSet objectForKey:@"display_url"]];
			if(range.location!=NSNotFound){
				NSURL *url=[NSURL URLWithString:[thisURLSet objectForKey:@"expanded_url"]];
				[attributedString addAttribute:NSLinkAttributeName value:url range:range];
				[attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
				[attributedString addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
				[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
			}
		}
	}
	[attributedString addAttribute:NSFontAttributeName value:contentTextField.font range:NSMakeRange(0, attributedString.length)];
	[contentTextField setAttributedStringValue:attributedString];
	
	CGRect frame=contentTextField.frame;
	frame.size.height=MAXFLOAT;
	
	NSSize minSize=[[contentTextField cell] cellSizeForBounds:NSRectFromCGRect(frame)];
	
	float viewWidth=minSize.width+contentTextField.frame.origin.x+12;
	if(viewWidth<300){
		viewWidth=300;
	}
	float viewHeight=minSize.height+(32+12+48+12*2);
	if(viewHeight<100){
		viewHeight=100;
	}
	[[self view] setFrame:CGRectMake(0,0,viewWidth, viewHeight)];
	
	frame.size=minSize;
	frame.origin.y=viewHeight-(12*2+48)-minSize.height;
	contentTextField.frame=frame;
	
	[profileImageView setImageURL:status.user.profileImageURL];
}
#pragma mark button actions
- (IBAction)replyClicked:(id)sender {
	ComposeStatusViewController *controller=[[ComposeStatusViewController alloc] init];
	[controller loadView];
	
	NSPopover *popover=[[NSPopover alloc] init];
	popover.contentViewController=controller;
	popover.behavior=NSPopoverBehaviorTransient;
	
	controller.contentTextView.string=[NSString stringWithFormat:@"@%@ ", status.user.username];
	controller.popover=popover;
	controller.inReplyTo=status;
	
	[popover showRelativeToRect:[(NSButton*)sender frame] ofView:[(NSButton*)sender superview] preferredEdge:NSMaxYEdge];
}
- (IBAction)RTClicked:(id)sender {
	ComposeStatusViewController *controller=[[ComposeStatusViewController alloc] init];
	[controller loadView];
	
	NSPopover *popover=[[NSPopover alloc] init];
	popover.contentViewController=controller;
	popover.behavior=NSPopoverBehaviorTransient;
	
	controller.contentTextView.string=[NSString stringWithFormat:@"RT @%@: %@", status.user.username,status.text];
	[controller.contentTextView setSelectedRange:NSMakeRange(0, 0)];
	controller.popover=popover;
	
	[popover showRelativeToRect:[(NSButton*)sender frame] ofView:[(NSButton*)sender superview] preferredEdge:NSMaxYEdge];
}
- (IBAction)retweetClicked:(id)sender {
//    ACAccount *account = [[SettingManager sharedManager] selectedAccount];
    
//	ComposeRequest *request=[[ComposeRequest alloc]init];
//	request.account=[[[SettingManager sharedManager]accounts]objectAtIndex:0];
//	request.target=self;
//	request.successSelector=@selector(request:didFinishedRetweetWithResult:);
//	request.failSelector=@selector(request:didFailedRetweetWithError:);
//	request.inReplyTo=status;
//	[[StatusesManager sharedManager] retweetStatus:request];
	[(NSButton*)sender setEnabled:NO];
	[(NSButton*)sender setTitle:@"Loading"];
}
- (IBAction)favClicked:(id)sender {
//	ComposeRequest *request=[[ComposeRequest alloc]init];
//	request.account=[[[SettingManager sharedManager]accounts]objectAtIndex:0];
//	request.target=self;
//	request.successSelector=@selector(request:didFinishedFavWithResult:);
//	request.failSelector=@selector(request:didFailedFavWithError:);
//	request.inReplyTo=status;
//	[[StatusesManager sharedManager] favouriteStatus:request];
//	[(NSButton*)sender setEnabled:NO];
//	[(NSButton*)sender setTitle:@"..."];
}
#pragma mark api delegate
//-(void)request:(ComposeRequest*)request didFinishedRetweetWithResult:(id)result{
//	[retweetButton setTitle:@"Done"];
//}
//-(void)request:(ComposeRequest*)request didFailedRetweetWithError:(NSError*)error{
//	[retweetButton setEnabled:YES];
//	[retweetButton setTitle:@"Failed"];
//	[retweetButton performSelector:@selector(setTitle:) withObject:@"Retweet" afterDelay:0.5];
//}
//-(void)request:(ComposeRequest*)request didFinishedFavWithResult:(id)result{
//	[favButton setTitle:@"Done"];
//}
//-(void)request:(ComposeRequest*)request didFailedFavWithError:(NSError*)error{
//	[favButton setEnabled:YES];
//	[favButton setTitle:@"Failed"];
//	[favButton performSelector:@selector(setTitle:) withObject:@"Fav" afterDelay:0.5];
//}

@end
