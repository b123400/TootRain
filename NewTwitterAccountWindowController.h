//
//  NewTwitterAccountWindowController.h
//  Canvas
//
//  Created by b123400 on 24/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BRTwitterOAuthTokenGetter.h"
#import "Account.h"

@protocol NewTwitterAccountWindowControllerDelegate

-(void)didCanceledAddingTwitterAccount:(id)sender;
-(void)didAddedTwitterAccount:(User*)account sender:(id)sender;

@end


@interface NewTwitterAccountWindowController : NSWindowController <BROAuthTokenGetterDelegate,BRTwitterOAuthTokenGetterDelegate> {
	IBOutlet NSTextField *pinTextField;
	IBOutlet NSProgressIndicator *spinner;
	IBOutlet NSView *loadingView;
	IBOutlet NSView *mainView;
	IBOutlet WebView *webView;
	
	BRTwitterOAuthTokenGetter *twitterTokenGetter;
	
	id <NewTwitterAccountWindowControllerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic,unsafe_unretained) id <NewTwitterAccountWindowControllerDelegate> delegate;

-(IBAction)cancelButtonClicked:(id)sender;
-(IBAction)nextButtonClicked:(id)sender;

@end
