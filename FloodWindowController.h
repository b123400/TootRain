//
//  FloodWindowController.h
//  flood
//
//  Created by b123400 on 11/8/12.
//
//

#import <Cocoa/Cocoa.h>
#import "StreamController.h"

@interface FloodWindowController : NSWindowController<StreamControllerDelegate>{
	NSMutableArray *currentRequests;
	IBOutlet NSButton *moveButton;
	
	NSMutableArray *rainDrops;
	
	CGPoint lastMousePosition;
	NSTimer *timer;
	
	NSMutableSet<NSString*> *shownStatusIds;
}

-(void)resetFrame;

@end
