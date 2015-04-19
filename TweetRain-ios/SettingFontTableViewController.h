//
//  SettingFontTableViewController.h
//  TweetRain
//
//  Created by b123400 on 20/4/15.
//
//

#import <UIKit/UIKit.h>

@protocol SettingFontTableViewControllerDelegate <NSObject>

- (void)settingFontTableViewController:(id)sender didSelectedFontName:(NSString*)fontName;

@end

@interface SettingFontTableViewController : UITableViewController

@property (nonatomic, weak) id <SettingFontTableViewControllerDelegate> delegate;

@end
