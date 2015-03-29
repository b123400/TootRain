//
//  SettingColorViewController.h
//  TweetRain
//
//  Created by b123400 on 30/3/15.
//
//

#import <UIKit/UIKit.h>
#import <Color-Picker-for-iOS/HRColorPickerView.h>

@protocol SettingColorViewControllerDelegate <NSObject>

@optional
- (void)settingColorViewController:(id)sender didSelectedColor:(UIColor*)color;

@end

@interface SettingColorViewController : UIViewController

- (instancetype)initWithColor:(UIColor*)color;

@property (nonatomic, weak) id <SettingColorViewControllerDelegate> delegate;

@property (nonatomic, strong) HRColorPickerView *view;

@end
