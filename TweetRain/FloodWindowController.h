//
//  FloodWindowController.h
//  flood
//
//  Created by b123400 on 11/8/12.
//
//

#import <Cocoa/Cocoa.h>
#import "StreamController.h"

#define kRainDropAppearedNotification @"kRainDropAppearedNotification"

@interface FloodWindowController : NSWindowController<StreamControllerDelegate>{
	CGPoint lastMousePosition;
	NSTimer *timer;
	
	NSMutableSet<NSString*> *shownStatusIds;
}

@property (nonatomic, strong) NSMutableArray *rainDrops;

-(void)resetFrame;

@end
