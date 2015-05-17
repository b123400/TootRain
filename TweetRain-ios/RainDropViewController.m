//
//  RainDropViewController.m
//  TweetRain
//
//  Created by b123400 on 20/3/15.
//
//

#import "RainDropViewController.h"
#import "SettingManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RainDropViewController ()

@property (assign, nonatomic) BOOL paused;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentTextLabel;

@property (strong, nonatomic) NSDate *animationEnd;

@end

@implementation RainDropViewController

- (instancetype)initWithStatus:(Status*)status {
    self = [super initWithNibName:@"RainDropViewController" bundle:nil];
    
    self.status = status;
    self.paused = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyApperance)
                                                 name:kRainDropAppearanceChangedNotification
                                               object:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyApperance];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    CGSize size = [self.contentTextLabel.attributedText size];
    CGRect frame = self.contentTextLabel.frame;
    frame.size.width = size.width;
    self.contentTextLabel.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyApperance {
    self.view.alpha = [[SettingManager sharedManager] opacity];
    
    UIFont *font = [[SettingManager sharedManager] font];
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font
                                 };
    
    self.contentTextLabel.font = font;
    self.contentTextLabel.textColor = [[SettingManager sharedManager] textColor];
    self.contentTextLabel.attributedText = [[NSAttributedString alloc] initWithString:[self textToDisplay]
                                                                           attributes:attributes];
    self.contentTextLabel.shadowColor = [UIColor blackColor];
    self.contentTextLabel.shadowOffset = CGSizeMake(0, 1);
    
    if ([SettingManager sharedManager].showProfileImage) {
        self.profileImageView.hidden = NO;
        [self.profileImageView sd_setImageWithURL:self.status.user.profileImageURL];
    } else {
        self.profileImageView.hidden = YES;
    }
    
    CGRect frame = self.view.frame;
    frame.size.width = [self.contentTextLabel.attributedText size].width + ([SettingManager sharedManager].showProfileImage ? 73 : 0) + 8;
    self.view.frame = frame;
    [self.view layoutSubviews];
}

#pragma mark text

- (NSString*)textToDisplay {
    NSMutableString *contentString=[NSMutableString stringWithString:self.status.text];
    [contentString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentString.length)];
    [contentString replaceOccurrencesOfString:@"\r" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentString.length)];

    if(self.status.entities && [[SettingManager sharedManager]removeURL]){
        for(NSDictionary *thisURLSet in [self.status.entities objectForKey:@"urls"]){
            NSRange range=[contentString rangeOfString:[thisURLSet objectForKey:@"url"]];
            if(range.location!=NSNotFound){
                NSString *url=[thisURLSet objectForKey:@"url"];
                [contentString replaceOccurrencesOfString:url withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, contentString.length)];
            }
        }
    }
    return contentString;
}

#pragma mark animation

- (void)startAnimation {
    if (!self.paused) return;
    self.paused = NO;
    self.animationEnd = [NSDate dateWithTimeIntervalSinceNow:self.animationDuration];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.toValue = @(-self.view.frame.size.width);
    
    CGRect presentedFrame = self.view.frame;
    if (self.view.layer.presentationLayer) {
        presentedFrame = [self.view.layer.presentationLayer frame];
    }
    
    animation.duration = [self animationDuration]*(CGRectGetMaxX(presentedFrame)/(self.view.superview.frame.size.width+self.view.frame.size.width));
    
    animation.delegate = self;
    [self.view.layer addAnimation:animation forKey:@"position"];
}

- (void)pauseAnimation {
    if (self.paused) return;
    self.paused = YES;
    CGPoint point = [self.view.layer.presentationLayer position];
    [self.view.layer removeAnimationForKey:@"position"];
    self.view.layer.position = point;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (!self.paused && flag) {
        // end and remove
        if ([self.delegate respondsToSelector:@selector(rainDropViewControllerDidDisappeared:)]) {
            [self.delegate rainDropViewControllerDidDisappeared:self];
        }
    }
}

#pragma mark interaction

- (void)viewDidTapped:(UIGestureRecognizer*)recognizer {
    if ([self.delegate respondsToSelector:@selector(rainDropViewControllerDidTapped:)]) {
        [self.delegate rainDropViewControllerDidTapped:self];
    }
}

#pragma mark timing
-(float)animationDuration{
    //full duration from one side of the screen to the other side
    return 10;
}
-(float)durationUntilDisappear{
    if(self.paused){
        return -1;
    }
    NSDate *now=[NSDate date];
    NSTimeInterval interval=[self.animationEnd timeIntervalSinceDate:now];
    return interval;
}

-(float)durationBeforeReachingEdge{
    return [self animationDuration]*self.view.superview.frame.size.width/(self.view.superview.frame.size.width+self.view.frame.size.width);
}

-(BOOL)willCollideWithRainDrop:(RainDropViewController*)controller{
    if(self.paused){
        return YES;
    }
    CGRect frame = [(CALayer*)self.view.layer.presentationLayer frame];
    if(frame.origin.x+frame.size.width>self.view.superview.frame.size.width){
        //self not left the right edge yet
        return YES;
    }
    if([self durationUntilDisappear]<[controller durationBeforeReachingEdge]){
        return NO;
    }
    return YES;
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
