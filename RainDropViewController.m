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
#import "NSMutableAttributedString+Stripe.h"
#import "DummyStatus.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartAnimation) name:kWindowScreenChanged object:nil];
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
	
	if ([[SettingManager sharedManager]showProfileImage] && ![status isKindOfClass:[DummyStatus class]]) {
		viewWidth+=profileImageView.frame.size.width+margin;
		if(viewHeight<profileImageView.frame.size.height+margin*2){
			viewHeight=profileImageView.frame.size.height+margin*2;
		}
	}
	
	[[self view] setFrame:CGRectMake(0,0,viewWidth, viewHeight)];
    self.view.wantsLayer = YES;
	self.view.alphaValue = [[SettingManager sharedManager] opacity];
}

-(void)viewDidMovedToSuperview:(id)sender{
	NSView *parentView=[[self view]superview];
	[[self view] setFrame:CGRectMake(parentView.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
	CGRect rect=contentTextField.frame;
	rect.origin.x=rect.origin.y=5;
	rect.size.width+=5;
	contentTextField.frame=rect;
	
	if([[SettingManager sharedManager]showProfileImage] && ![status isKindOfClass:[DummyStatus class]]){
		CGRect frame=contentTextField.frame;
		frame.origin.x+=profileImageView.frame.size.width+margin;
		contentTextField.frame=frame;
		
		[profileImageView setHidden:NO];
		profileImageView.frame=CGRectMake(margin, margin, profileImageView.frame.size.width, profileImageView.frame.size.height);
		[profileImageView setImageURL:status.user.profileImageURL];
	}else{
		[profileImageView setHidden:YES];
	}
    
    for (int i = 0; i < contentTextField.attributedStringValue.length; i++) {
        NSRange charRange = NSMakeRange(i, 1);
        if (![contentTextField.attributedStringValue containsAttachmentsInRange:charRange]) continue;
        
        NSDictionary *attributes = [contentTextField.attributedStringValue attributesAtIndex:i effectiveRange:nil];
        NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
        NSImage *customImage = attributes[kPlaceholderOriginalImageAttributeName];
        
        if (!attachment || !customImage) continue;
        
        NSRect textBounds = [contentTextField.cell titleRectForBounds:contentTextField.bounds];
        NSLayoutManager *lm = [[NSLayoutManager alloc] init];
        NSTextStorage *ts = [[NSTextStorage alloc] initWithAttributedString:contentTextField.attributedStringValue];
        NSTextContainer *tc = [[NSTextContainer alloc] initWithContainerSize:textBounds.size];
        [lm setTextStorage:ts];
        [lm addTextContainer:tc];
        tc.lineFragmentPadding = 2;
        lm.typesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility;
        
        NSRange r;
        NSRange glyphRange = [lm glyphRangeForCharacterRange:charRange actualCharacterRange:&r];
        CGRect charRect = [lm boundingRectForGlyphRange:glyphRange inTextContainer:tc];

        NSImageView *imageView = [[NSImageView alloc] initWithFrame:[contentTextField convertRect:charRect toView:self.view]];
        [imageView setImageAlignment:NSImageAlignTop];
        [imageView setImage:customImage];
        [self.view addSubview:imageView];
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
    // The view flickers if we don't use animation to stop
	CGRect target=[self visibleFrame];
    paused = YES;
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];
    //animation.fromValue = [NSValue valueWithPoint:self.view.frame.origin];
	animation.duration=0.01;
	animation.toValue = [NSValue valueWithPoint:target.origin];
	[self.view setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameOrigin"]];
	[[self.view animator] setFrameOrigin:target.origin];
	self.view.frame = target;
	
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
- (CGRect)visibleFrame {
    CGRect frame = self.view.frame;
	if(paused){
		return frame;
	}
	float percentage=[self durationUntilDisappear]/[self animationDuration];
	frame.origin.x=(self.view.window.frame.size.width + frame.size.width)*percentage - frame.size.width;
	return frame;
}
#pragma mark interaction
- (void)didMouseOver {
    CursorBehaviour cursorBehaviour = [[SettingManager sharedManager] cursorBehaviour];
    if (cursorBehaviour == CursorBehaviourClickThrough) {
        return;
    } else if (cursorBehaviour == CursorBehaviourHide) {
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
- (void)didMouseOut {
    CursorBehaviour cursorBehaviour = [[SettingManager sharedManager] cursorBehaviour];
    if (cursorBehaviour == CursorBehaviourHide) {
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
- (void)viewDidClicked:(id)sender {
	if(![self paused]){
		[self pauseAnimation];
	}
    if ([status isKindOfClass:[DummyStatus class]]) return;
	if(!popover){
		popover=[[NSPopover alloc] init];
		NSViewController *newController=[[RainDropDetailViewController alloc]initWithStatus:status];
		popover.contentViewController=newController;
		popover.behavior=NSPopoverBehaviorTransient;
		popover.delegate=self;
	}
	if(![popover isShown]){
		NSPoint mouseLoc=[self.view.window mouseLocationOutsideOfEventStream];
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
    NSMutableAttributedString *attrString = [(status.attributedText ?: [[NSAttributedString alloc] initWithString:status.text]) mutableCopy];
    
    [attrString removeNewLines];
    [attrString removeColors];
    if (YES) { // animated gif
        [attrString replaceImagesWithPlaceholdersWithHeight:[[[SettingManager sharedManager] font] pointSize]];
    } else {
        [attrString resizeImagesWithHeight:[[[SettingManager sharedManager] font] pointSize]];
    }
    if ([[SettingManager sharedManager] removeLinks]) {
        [attrString removeLinks];
    } else {
        [attrString removeLinkAttributes];
    }
    
    if ([[SettingManager sharedManager] truncateStatus] && ![status isKindOfClass:[DummyStatus class]]) {
        attrString = [[attrString attributedSubstringFromRange:NSMakeRange(0, MIN(attrString.length, [[SettingManager sharedManager] truncateStatusLength]))] mutableCopy];
    }

    NSMutableDictionary *attributes=[NSMutableDictionary dictionary];
    NSFont *newFont=[[NSFontManager sharedFontManager] convertFont:[[SettingManager sharedManager]font] toHaveTrait:NSBoldFontMask];
    [attributes setObject:newFont forKey:NSFontAttributeName];

    [attributes setObject:[[SettingManager sharedManager]textColor] forKey:NSForegroundColorAttributeName];

    [attrString addAttributes:attributes range:NSMakeRange(0, attrString.length)];

    return attrString;
}

- (void)appearanceSettingChanged:(NSNotification*)notification {
    [contentTextField setAttributedStringValue:[self attributedStringForStatus]];
    self.view.alphaValue = [[SettingManager sharedManager] opacity];
    [self.view setNeedsDisplay:YES];
}

#pragma mark misc
-(BOOL)paused{
	return paused;
}
@end
