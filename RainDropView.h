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
-(void)viewDidClicked:(id)sender;

@end

@interface RainDropView : NSView{
	id <RainDropViewDelegate> delegate;
	NSColor *backgroundColor;
	BOOL needsShadow;
}
@property (assign) id delegate;
@property (retain,nonatomic) NSColor *backgroundColor;
@property (assign,nonatomic) BOOL needsShadow;

@end
