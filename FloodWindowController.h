//
//  FloodWindowController.h
//  flood
//
//  Created by b123400 on 11/8/12.
//
//

#import <Cocoa/Cocoa.h>

@interface FloodWindowController : NSWindowController{
	NSMutableArray *currentRequests;
	IBOutlet NSButton *moveButton;
	
	NSMutableArray *rainDrops;
}
- (IBAction)clicked:(id)sender;

@end
