//
//  BRAnimatedTextField.h
//  TweetRain
//
//  Created by b123400 on 2023/01/31.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRAnimatedTextField : NSTextField

@property (nonatomic, assign) BOOL animates;
@property (nonatomic, assign) CGFloat maxGifHeight; // 0 means equal to font size

- (void)setAttributedStringValue:(NSAttributedString *)attributedStringValue withMaxImageHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
