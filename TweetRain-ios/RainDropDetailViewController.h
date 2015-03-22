//
//  RainDropDetailViewController.h
//  TweetRain
//
//  Created by b123400 on 22/3/15.
//
//

#import <UIKit/UIKit.h>
#import "Status.h"

@protocol RainDropDetailViewControllerDelegate <NSObject>

- (void)rainDropDetailViewControllerDidClosed:(id)sender;

@end

@interface RainDropDetailViewController : UIViewController

@property (nonatomic, weak) id <RainDropDetailViewControllerDelegate> delegate;

- (instancetype) initWithStatus:(Status*)status;

- (Status*)status;

@end
