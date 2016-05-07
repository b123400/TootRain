//
//  BRSearchViewController.h
//  TweetRain
//
//  Created by b123400 on 8/5/2016.
//
//

#import <UIKit/UIKit.h>

@protocol BRSearchViewControllerDelegate <NSObject>

- (void)searchViewControllerDidCancelled:(id)controller;
- (void)searchViewController:(id)controller didEnteredSearchTerm:(NSString*)searchTerm;

@end

@interface BRSearchViewController : UITableViewController

@property (nonatomic, weak) id <BRSearchViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *searchTerm;

@end
