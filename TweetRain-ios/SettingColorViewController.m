//
//  SettingColorViewController.m
//  TweetRain
//
//  Created by b123400 on 30/3/15.
//
//

#import "SettingColorViewController.h"
#import <Color-Picker-for-iOS/HRBrightnessSlider.h>
#import <Color-Picker-for-iOS/HRColorMapView.h>

@interface SettingColorViewController ()

@property (nonatomic, strong) UIColor *color;

@end

@implementation SettingColorViewController

- (instancetype)initWithColor:(UIColor*)color {
    self = [super init];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.color = color;
    return self;
}

- (void)loadView {
    self.view = [[HRColorPickerView alloc] init];
    self.view.color = self.color;
    self.view.brightnessSlider.brightnessLowerLimit = @0;
    self.view.colorMapView.saturationUpperLimit = @1.0;
    self.view.colorMapView.backgroundColor = [UIColor whiteColor];
    [self.view addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fixRotation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)colorChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(settingColorViewController:didSelectedColor:)]) {
        [self.delegate settingColorViewController:self didSelectedColor:self.view.color];
    }
}

// I tried lots of different way to block auto rotate,
// but nothing works.
// I tried to return NO, but it is ignored.
- (void)fixRotation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
}

- (BOOL)shouldAutorotate {
    [self fixRotation];
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    [self fixRotation];
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    [self fixRotation];
    return UIInterfaceOrientationPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
