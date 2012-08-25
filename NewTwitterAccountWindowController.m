//
//  NewTwitterAccountWindowController.m
//  Canvas
//
//  Created by b123400 on 24/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "NewTwitterAccountWindowController.h"
#import "FloodAppDelegate.h"
#import "StatusesManager.h"
#import "TwitterConnector.h"
#import "MGTwitterEngine.h"

@implementation NewTwitterAccountWindowController
@synthesize delegate;

-(id)init{
	twitterTokenGetter=[[BRTwitterOAuthTokenGetter alloc]initWithComsumerKey:kTwitterOAuthConsumerKey consumerSecret:kTwitterOAuthConsumerSecret];
	twitterTokenGetter.delegate=self;
	return [self initWithWindowNibName:NSStringFromClass([self class])];
}

- (void)windowDidLoad{
	[[self window] setContentView:loadingView];
	[spinner startAnimation:self];
	[twitterTokenGetter getRequestToken];
	[super windowDidLoad];
}

-(void)didReceivedRequestTokenURL:(NSURL*)url{
	CGRect originalFrame=loadingView.frame;
	[loadingView setHidden:YES];
	CGRect currentFrame=[[self window] frame];
	currentFrame.origin.x-=([mainView frame].size.width-currentFrame.size.width)/2;
	currentFrame.size.width=[mainView frame].size.width;
	currentFrame.size.height=[mainView frame].size.height;
	[[self window]setFrame:currentFrame display:YES animate:YES];
	[[self window]setContentView:mainView];
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
	[loadingView setHidden:NO];
	loadingView.frame=originalFrame;
}
-(void)didReceivedAccessToken:(SSToken*)token{
	if(delegate){
		if([((NSObject*) delegate) respondsToSelector:@selector(didAddedTwitterAccount:sender:)]){
			
			OAToken *oToken=[[OAToken alloc]initWithKey:[token key] secret:[token secret]];
			Account *newAccount=[[Account alloc] init];
			newAccount.accessToken=oToken;
			newAccount.username=[token screenName];
			newAccount.type=BRUserTypeTwitter;
			newAccount.userID=[NSString stringWithFormat:@"%llu", token.userID];
			
			UserRequest *request=[[UserRequest alloc]init];
			request.target=self;
			request.account=newAccount;
			request.user=newAccount;
			request.successSelector=@selector(requestSucceeded:withUserinfo:);
			request.failSelector=@selector(requestFailed:withError:);
			
			[[StatusesManager sharedManager] getUserProfile:request];
			
		}
	}
}

-(void)requestSucceeded:(UserRequest*)request withUserinfo:(NSArray*)result{
	[delegate didAddedTwitterAccount:request.account sender:self];
}
-(void)requestFailed:(UserRequest*)request withError:(NSError*)error{
	
}

-(IBAction)cancelButtonClicked:(id)sender{
	if(delegate){
		if([((NSObject*) delegate) respondsToSelector:@selector(didCanceledAddingTwitterAccount:)]){
			[delegate didCanceledAddingTwitterAccount:self];
		}
	}
}
-(IBAction)nextButtonClicked:(id)sender{
	[twitterTokenGetter getAccessTokenWithPin:[pinTextField stringValue]];
	
	[mainView setHidden:YES];
	CGRect currentFrame=[[self window] frame];
	currentFrame.origin.x-=([loadingView frame].size.width-currentFrame.size.width)/2;
	currentFrame.size.width=[loadingView frame].size.width;
	currentFrame.size.height=[loadingView frame].size.height;
	[[self window]setFrame:currentFrame display:YES animate:YES];
	[[self window]setContentView:loadingView];
	[spinner startAnimation:self];
	[mainView setHidden:NO];
}


@end
