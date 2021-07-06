//
//  RainViewController.m
//  flood
//
//  Created by b123400 on 12/8/12.
//
//
#import <QuartzCore/QuartzCore.h>
#import "RainDropViewController.h"
#import "RainDropDetailViewController.h"
#import "SettingManager.h"
#import "SettingViewController.h"

@interface RainDropViewController () <CAAnimationDelegate>

- (NSAttributedString*)attributedStringForStatus;

@end

@implementation RainDropViewController
@synthesize contentTextField,status,delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (id)initWithStatus:(Status*)_status{
	status=_status;
	paused=YES;
	margin=5;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appearanceSettingChanged:) name:kRainDropAppearanceChangedNotification object:nil];
    
    // need to restart animation once window level is changed
    // because there is a bug in OS X which stops CAAnimation when window level is changed.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartAnimation) name:kWindowLevelChanged object:nil];
	return [self initWithNibName:@"RainDropViewController" bundle:nil];
}
-(void)loadView{
	[super loadView];
	[(RainDropView*)self.view setDelegate:self];
	
    NSAttributedString *attributedString = [self attributedStringForStatus];
	
	[contentTextField setAttributedStringValue:attributedString];
	[contentTextField sizeToFit];
	
	float viewWidth=contentTextField.frame.size.width+margin*2;
	float viewHeight=contentTextField.frame.size.height+margin*2;
	
	if([[SettingManager sharedManager]showProfileImage]){
		viewWidth+=profileImageView.frame.size.width+margin;
		if(viewHeight<profileImageView.frame.size.height+margin*2){
			viewHeight=profileImageView.frame.size.height+margin*2;
		}
	}
	
	[[self view] setFrame:CGRectMake(0,0,viewWidth, viewHeight)];
	self.view.alphaValue=[[SettingManager sharedManager] opacity];
}

-(void)viewDidMovedToSuperview:(id)sender{
	NSView *parentView=[[self view]superview];
	[[self view] setFrame:CGRectMake(parentView.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
	CGRect rect=contentTextField.frame;
	rect.origin.x=rect.origin.y=5;
	rect.size.width+=5;
	contentTextField.frame=rect;
	
	if([[SettingManager sharedManager]showProfileImage]){
		CGRect frame=contentTextField.frame;
		frame.origin.x+=profileImageView.frame.size.width+margin;
		contentTextField.frame=frame;
		
		[profileImageView setHidden:NO];
		profileImageView.frame=CGRectMake(margin, margin, profileImageView.frame.size.width, profileImageView.frame.size.height);
		[profileImageView setImageURL:status.user.profileImageURL];
	}else{
		[profileImageView setHidden:YES];
	}
	
	[self startAnimation];
}

#pragma mark animation

-(void)startAnimation{
	if(!paused){
		return;
	}
	paused=NO;
	CGPoint target=CGPointMake(self.view.frame.size.width*-1, self.view.frame.origin.y);
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];
    animation.fromValue = [NSValue valueWithPoint:self.view.frame.origin];
    animation.duration=[self animationDuration] * ((self.view.frame.origin.x + self.view.frame.size.width) / (self.view.superview.frame.size.width + self.view.frame.size.width));
	animation.toValue = [NSValue valueWithPoint:target];
	animation.delegate=self;
	[self.view setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameOrigin"]];
	[[self.view animator] setFrameOrigin:target];
	
	animationEnd=[[NSDate alloc] initWithTimeIntervalSinceNow:animation.duration];
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
	if(flag){
		[self.delegate rainDropDidDisappear:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}
-(void)pauseAnimation{
	if(paused){
		return;
	}
	paused=YES;
    // The view flickers if we don't use animation to stop
	CGRect target=[self visibleFrame];
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];
    //animation.fromValue = [NSValue valueWithPoint:self.view.frame.origin];
	animation.duration=0.01;
	animation.toValue = [NSValue valueWithPoint:target.origin];
	[self.view setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameOrigin"]];
	[[self.view animator] setFrameOrigin:target.origin];
	self.view.frame=target;
	
	if(animationEnd){
		animationEnd=nil;
	}
}

- (void)restartAnimation {
    // we need this, read comment in init.
    [self pauseAnimation];
    [self startAnimation];
}

#pragma mark timing
-(float)animationDuration{
	//full duration from one side of the screen to the other side
	return 10;
}
-(float)durationUntilDisappear{
	if(paused){
		return -1;
	}
	NSDate *now=[NSDate date];
	NSTimeInterval interval=[animationEnd timeIntervalSinceDate:now];
	return interval;
}
-(float)durationBeforeReachingEdge{
	return [self animationDuration]*[[NSScreen mainScreen] frame].size.width/([[NSScreen mainScreen] frame].size.width+self.view.frame.size.width);
}
-(BOOL)willCollideWithRainDrop:(RainDropViewController*)controller{
	if(paused||[self isPopoverShown]){
		return YES;
	}
	CGRect frame=[self visibleFrame];
	if(frame.origin.x+frame.size.width>self.view.superview.frame.size.width){
		//self not left the right edge yet
		return YES;
	}
	if([self durationUntilDisappear]<[controller durationBeforeReachingEdge]){
		return NO;
	}
	return YES;
}
#pragma mark geometry
-(CGRect)visibleFrame{
	if(paused){
		return self.view.frame;
	}
	float percentage=[self durationUntilDisappear]/[self animationDuration];
	CGRect frame=self.view.frame;
	frame.origin.x=(self.view.window.frame.size.width+self.view.frame.size.width)*percentage-self.view.frame.size.width;
	return frame;
}
#pragma mark interaction
-(void)didMouseOver{
	if([[SettingManager sharedManager] hideTweetAroundCursor]){
		[self.view setHidden:YES];
		return;
	}
	self.view.alphaValue=1;
	[self pauseAnimation];
    
    BOOL changed = NO;
    NSColor *color = [[SettingManager sharedManager]hoverBackgroundColor];
    if (![[(RainDropView*)self.view backgroundColor] isEqualTo:color]) {
        [(RainDropView*)self.view setBackgroundColor:color];
        changed = YES;
    }
    if (![(RainDropView*)self.view needsShadow]) {
        [(RainDropView*)self.view setNeedsShadow:YES];
        changed = YES;
    }
    if (changed) {
        [self.view setNeedsDisplay:YES];
    }
}
-(void)didMouseOut{
	if([[SettingManager sharedManager] hideTweetAroundCursor]){
		[self.view setHidden:NO];
		return;
	}
	if(popover&&[popover isShown]){
		return;
	}
	self.view.alphaValue=[[SettingManager sharedManager] opacity];
	[self startAnimation];
    
    BOOL changed = NO;
    if (![[(RainDropView*)self.view backgroundColor] isEqualTo:[NSColor clearColor]]) {
        [(RainDropView*)self.view setBackgroundColor:[NSColor clearColor]];
        changed = YES;
    }
    if ([(RainDropView*)self.view needsShadow]) {
        [(RainDropView*)self.view setNeedsShadow:NO];
        changed = YES;
    }
    if (changed) {
        [self.view setNeedsDisplay:YES];
    }
}
-(void)viewDidClicked:(id)sender{
	if(![self paused]){
		[self pauseAnimation];
	}
	if(!popover){
		popover=[[NSPopover alloc] init];
		NSViewController *newController=[[RainDropDetailViewController alloc]initWithStatus:status];
		popover.contentViewController=newController;
		popover.behavior=NSPopoverBehaviorTransient;
		popover.delegate=self;
	}
	if(![popover isShown]){
		NSPoint mouseLoc=[NSEvent mouseLocation];
		NSPoint localLoc=[self.view convertPoint:mouseLoc fromView:nil];
		CGRect frame=CGRectMake(localLoc.x, 0, 1, self.view.frame.size.height);
		[popover showRelativeToRect:frame ofView:self.view preferredEdge:NSMaxYEdge];
	}else{
		[popover close];
	}
}
#pragma mark popover delegate
- (void)popoverDidClose:(NSNotification *)notification{
	[self didMouseOut];
}
-(BOOL)isPopoverShown{
	if(popover&&[popover isShown])return YES;
	return NO;
}

#pragma mark appearance

- (NSAttributedString*)attributedStringForStatus{
    
    NSMutableString *contentString=[NSMutableString stringWithString:status.text];
    [contentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentString.length)];
    [contentString replaceOccurrencesOfString:@"\r" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentString.length)];
    
    BOOL hasURL=NO;
    if(status.entities){
        for(NSDictionary *thisURLSet in [status.entities objectForKey:@"urls"]){
            NSRange range=[contentString rangeOfString:[thisURLSet objectForKey:@"url"]];
            if(range.location!=NSNotFound){
                hasURL=YES;
                NSString *url=[thisURLSet objectForKey:@"url"];
                if([[SettingManager sharedManager]removeURL]){
                    [contentString replaceOccurrencesOfString:url withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentString.length)];
                }
            }
        }
    }
    
    NSMutableDictionary *attributes=[NSMutableDictionary dictionary];
    NSFont *newFont=[[NSFontManager sharedFontManager] convertFont:[[SettingManager sharedManager]font] toHaveTrait:NSBoldFontMask];
    [attributes setObject:newFont forKey:NSFontAttributeName];
    
    NSShadow *kShadow = [[NSShadow alloc] init];
    [kShadow setShadowColor:[[SettingManager sharedManager]shadowColor]];
    [kShadow setShadowBlurRadius:5.0f];
    [kShadow setShadowOffset:NSMakeSize(0, 0)];
    [attributes setObject:kShadow forKey:NSShadowAttributeName];
    
    [attributes setObject:[[SettingManager sharedManager]textColor] forKey:NSForegroundColorAttributeName];
    
    if(hasURL&&[[SettingManager sharedManager]underlineTweetsWithURL]){
        [attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    }
    
    NSAttributedString *attributedString=[[NSAttributedString alloc]initWithString:contentString attributes:attributes];
    return attributedString;
}

- (void)appearanceSettingChanged:(NSNotification*)notification {
    [contentTextField setAttributedStringValue:[self attributedStringForStatus]];
    [self.view setNeedsDisplay:YES];
}

#pragma mark misc
-(BOOL)paused{
	return paused;
}
@end
