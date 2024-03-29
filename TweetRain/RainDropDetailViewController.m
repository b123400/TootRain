//
//  RainDropDetailViewController.m
//  flood
//
//  Created by b123400 on 19/8/12.
//
//

#import "RainDropDetailViewController.h"
#import "ComposeStatusViewController.h"
#import "SettingManager.h"
#import "NS(Attributed)String+Geometrics.h"

@interface RainDropDetailViewController ()

@end

@implementation RainDropDetailViewController
@synthesize contentTextField;
@synthesize profileImageView;
@synthesize nameField;
@synthesize usernameField;
@synthesize repostButton;
@synthesize favButton;

-(id)initWithStatus:(Status*)_status{
	status=_status;
	return [self init];
}

-(id)init{
	return [self initWithNibName:@"RainDropDetailViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
-(void)loadView{
	[super loadView];
    NSAttributedString *nameAttributedString = status.user.attributedScreenName;
    if (nameAttributedString) {
        NSMutableAttributedString *str = [nameAttributedString mutableCopy];
        [str addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:16] range:NSMakeRange(0, str.length)];
        nameAttributedString = str;
    } else {
        nameAttributedString = [[NSAttributedString alloc] init];
    }

    nameField.attributedStringValue = nameAttributedString;
	usernameField.stringValue = [NSString stringWithFormat:@"@%@", status.user.username];

    NSMutableAttributedString *attributedString = [status.attributedText mutableCopy];
	[attributedString addAttribute:NSFontAttributeName value:contentTextField.font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor labelColor] range:NSMakeRange(0, attributedString.length)];
	[contentTextField setAttributedStringValue:attributedString];

    NSRange r = NSMakeRange(NSNotFound, NSNotFound);
    NSInteger index = 0;
    while (index < attributedString.length) {
        NSDictionary<NSAttributedStringKey, id> *attributes = [attributedString attributesAtIndex:index effectiveRange:&r];
        index = r.length + r.location;
        if (attributes[NSLinkAttributeName]) {
            [attributedString addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:r];
        }
    }
    
    if (status.bookmarked) {
        [self.bookmarkButton setEnabled:NO];
        [self.bookmarkButton setTitle:NSLocalizedString(@"Bookmarked", nil)];
    } else if (!status.canBookmark) {
        self.bookmarkButton.hidden = YES;
    }
    if (status.favourited) {
        [self.favButton setEnabled:NO];
        [self.favButton setTitle:NSLocalizedString(@"Done", nil)];
    } else if (!status.canFavourite) {
        self.favButton.hidden = YES;
    }
    if (status.reblogged) {
        [self.repostButton setEnabled:NO];
        [self.repostButton setTitle:NSLocalizedString(@"Reposted", nil)];
    } else if (!status.canReblog) {
        self.repostButton.hidden = YES;
    }
    
    if (!status.canReply) {
        self.replyButton.hidden = YES;
    }
    
    self.openInBrowserButton.hidden = status.url == nil;
	
	[profileImageView setImageURL:status.user.profileImageURL];
    [profileImageView setAnimates:[[SettingManager sharedManager] animateGif]];
}

#pragma mark button actions
- (IBAction)replyClicked:(id)sender {
    if (![status canReply]) return;
	ComposeStatusViewController *controller=[[ComposeStatusViewController alloc] init];
	[controller loadView];
	
	NSPopover *popover=[[NSPopover alloc] init];
	popover.contentViewController=controller;
	popover.behavior=NSPopoverBehaviorTransient;
	
	controller.contentTextView.string=[NSString stringWithFormat:@"@%@ ", status.user.username];
	controller.popover=popover;
	controller.inReplyTo=status;
	
	[popover showRelativeToRect:[(NSButton*)sender frame] ofView:[(NSButton*)sender superview] preferredEdge:NSMaxYEdge];
}
- (IBAction)bookmarkClicked:(id)sender {
    if (![status canBookmark]) return;
    [status bookmarkStatusWithCompletionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [sender setEnabled:YES];
                [sender setTitle:NSLocalizedString(@"Failed",nil)];
                [sender performSelector:@selector(setTitle:) withObject:NSLocalizedString(@"Bookmark",nil) afterDelay:0.5];
            } else {
                [sender setTitle:NSLocalizedString(@"Bookmarked", nil)];
            }
        });
    }];
    [(NSButton*)sender setEnabled:NO];
    [(NSButton*)sender setTitle:NSLocalizedString(@"Loading",nil)];
}
- (IBAction)repostClicked:(id)sender {
    if (![status canReblog]) return;
    [status reblogStatusWithCompletionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [sender setEnabled:YES];
                [sender setTitle:NSLocalizedString(@"Failed",nil)];
                [sender performSelector:@selector(setTitle:) withObject:NSLocalizedString(@"Repost",nil) afterDelay:0.5];
            } else {
                [sender setTitle:NSLocalizedString(@"Reposted", nil)];
            }
        });
    }];
	[(NSButton*)sender setEnabled:NO];
	[(NSButton*)sender setTitle:NSLocalizedString(@"Loading",nil)];
}
- (IBAction)favClicked:(id)sender {
    if (![status canFavourite]) return;
    [status favouriteStatusWithCompletionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [sender setEnabled:YES];
                [sender setTitle:NSLocalizedString(@"Failed",nil)];
                [sender performSelector:@selector(setTitle:) withObject:NSLocalizedString(@"Done",nil) afterDelay:0.5];
            } else {
                [sender setTitle:NSLocalizedString(@"Done", nil)];
            }
        });
    }];
	[(NSButton*)sender setEnabled:NO];
	[(NSButton*)sender setTitle:@"..."];
}

- (IBAction)openInBrowserClicked:(id)sender {
    if (status.url) {
        [[NSWorkspace sharedWorkspace] openURL:status.url];
    }
}

@end
