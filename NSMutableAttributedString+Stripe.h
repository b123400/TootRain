//
//  NSMutableAttributedString+Stripe.h
//  TweetRain
//
//  Created by b123400 on 2021/07/06.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kPlaceholderOriginalImageAttributeName @"PlaceholderOriginalImageAttributeName"

@interface NSMutableAttributedString (Stripe)

- (void)removeNewLines;
- (void)removeColors;
- (void)removeLinks;
- (void)removeLinkAttributes;
- (void)removeImages;
- (void)resizeImagesWithHeight:(CGFloat)height;
- (void)replaceImagesWithPlaceholdersWithHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
