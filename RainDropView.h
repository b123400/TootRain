//
//  RainDropView.h
//  flood
//
//  Created by b123400 on 12/8/12.
//
//

#import <Cocoa/Cocoa.h>

@protocol RainDropViewDelegate

@optional
-(void)viewDidMovedToSuperview:(id)sender;

@end

@interface RainDropView : NSView{
	id <RainDropViewDelegate> delegate;
}
@property (assign) id delegate;

@end
