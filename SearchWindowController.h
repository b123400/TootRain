//
//  SearchWindowController.h
//  flood
//
//  Created by b123400 on 21/8/12.
//
//

#import <Cocoa/Cocoa.h>

@protocol SearchWindowControllerDelegate <NSObject>

-(void)searchTermChangedTo:(NSString*)searchTerm;

@end

@interface SearchWindowController : NSWindowController{
	id <SearchWindowControllerDelegate> __unsafe_unretained delegate;
	IBOutlet NSTextField *inputTextField;
	IBOutlet NSButton *finishButton;
}
@property (unsafe_unretained,nonatomic) id delegate;
- (IBAction)finishButtonClicked:(id)sender;

@end
