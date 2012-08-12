//
//  RainViewController.m
//  flood
//
//  Created by b123400 on 12/8/12.
//
//
#import <QuartzCore/QuartzCore.h>
#import "RainDropViewController.h"

@interface RainDropViewController ()

@end

@implementation RainDropViewController
@synthesize contentTextField,status;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (id)initWithStatus:(Status*)_status{
	status=[_status retain];
	return [self initWithNibName:@"RainDropViewController" bundle:nil];
}
-(void)loadView{
	[super loadView];
	[(RainDropView*)self.view setDelegate:self];
	
	//[self.view setWantsLayer:YES];
	
	NSMutableDictionary *attributes=[NSMutableDictionary dictionary];
	NSFont *newFont=[[NSFontManager sharedFontManager] convertFont:contentTextField.font toHaveTrait:NSBoldFontMask];
	[attributes setObject:newFont forKey:NSFontAttributeName];
	
	NSShadow *kShadow = [[[NSShadow alloc] init] autorelease];
    [kShadow setShadowColor:[NSColor blackColor]];
    [kShadow setShadowBlurRadius:5.0f];
    [kShadow setShadowOffset:NSMakeSize(0, 0)];
	[attributes setObject:kShadow forKey:NSShadowAttributeName];
	
	[attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *attributedString=[[[NSAttributedString alloc]initWithString:[contentTextField stringValue] attributes:attributes] autorelease];
	
	[contentTextField setAttributedStringValue:attributedString];
	
	[contentTextField sizeToFit];
}

-(void)viewDidMovedToSuperview:(id)sender{
	NSView *parentView=[[self view]superview];
	//[parentView setWantsLayer:YES];
	[[self view] setFrame:CGRectMake(parentView.frame.size.width, self.view.frame.origin.y-100, contentTextField.frame.size.width+20, contentTextField.frame.size.height+20)];
	CGRect rect=contentTextField.frame;
	rect.origin.x=rect.origin.y=10;
	rect.size.width+=10;
	contentTextField.frame=rect;
	[self startAnimation];
}

-(void)startAnimation{
	CGPoint target=CGPointMake(self.view.frame.origin.x*-1, self.view.frame.origin.y);
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];
    animation.fromValue = [NSValue valueWithPoint:self.view.frame.origin];
	animation.duration=10;
	animation.toValue = [NSValue valueWithPoint:target];
	[self.view setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameOrigin"]];
	[[self.view animator] setFrameOrigin:target];
}

@end
