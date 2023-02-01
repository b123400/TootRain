//
//  BRAnimatedTextField.m
//  TweetRain
//
//  Created by b123400 on 2023/01/31.
//

#import "BRAnimatedTextField.h"
#import "NSMutableAttributedString+Stripe.h"

@interface BRAnimatedTextField ()

@property (nonatomic, strong) NSAttributedString *originalAttributedString;
@property (nonatomic, strong) NSArray<NSImageView*> *gifImageViews;

@end

@implementation BRAnimatedTextField

- (instancetype)initWithFrame:(NSRect)frameRect {
    _animates = YES;
    _maxGifHeight = 0;
    if (self = [super initWithFrame:frameRect]) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    _animates = YES;
    _maxGifHeight = 0;
    if (self = [super initWithCoder:coder]) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = NO;
    }
    return self;
}

- (BOOL)wantsDefaultClipping {
    return NO;
}

- (NSAttributedString *)attributedStringValue {
    return self.originalAttributedString;
}

- (void)setAttributedStringValue:(NSAttributedString *)attributedStringValue {
    [self setAttributedStringValue:attributedStringValue withMaxImageHeight:self.maxGifHeight ?: self.font.pointSize];
}

- (void)setAttributedStringValue:(NSAttributedString *)attributedStringValue withMaxImageHeight:(CGFloat)height {
    self.originalAttributedString = attributedStringValue;
    NSMutableAttributedString *string = [attributedStringValue mutableCopy];
    if (self.animates) {
        [string replaceImagesWithPlaceholdersWithHeight:height];
    } else {
        [string resizeImagesWithHeight:height];
    }
    [super setAttributedStringValue:string];
    [self setupSubviewsForGifs];
}

- (void)setAnimates:(BOOL)animates {
    _animates = animates;
    [self setAttributedStringValue:self.originalAttributedString];
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self setupSubviewsForGifs];
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self setupSubviewsForGifs];
}

- (void)setupSubviewsForGifs {
    for (NSView *v in self.gifImageViews) {
        [v removeFromSuperview];
    }
    self.gifImageViews = nil;
    if (!self.animates || !self.window) return;
    NSMutableArray *newGifViews = [NSMutableArray array];
    NSAttributedString *attributedString = super.attributedStringValue;
    for (int i = 0; i < self.attributedStringValue.length; i++) {
        NSRange charRange = NSMakeRange(i, 1);
        if (![attributedString containsAttachmentsInRange:charRange]) continue;
        
        NSDictionary *attributes = [attributedString attributesAtIndex:i effectiveRange:nil];
        NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
        NSImage *customImage = attributes[kPlaceholderOriginalImageAttributeName];
        
        if (!attachment || !customImage) continue;
        
        NSRect textBounds = [self.cell titleRectForBounds:self.bounds];
        NSLayoutManager *lm = [[NSLayoutManager alloc] init];
        NSTextStorage *ts = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        NSTextContainer *tc = [[NSTextContainer alloc] initWithContainerSize:textBounds.size];
        [lm setTextStorage:ts];
        [lm addTextContainer:tc];
        tc.lineFragmentPadding = 2;
        lm.typesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility;
        
        NSRange r;
        NSRange glyphRange = [lm glyphRangeForCharacterRange:charRange actualCharacterRange:&r];
        CGRect charRect = [lm boundingRectForGlyphRange:glyphRange inTextContainer:tc];

        NSImageView *imageView = [[NSImageView alloc] initWithFrame:charRect];
        [imageView setImageAlignment:NSImageAlignTop];
        [imageView setImage:customImage];
        [self addSubview:imageView];
        [newGifViews addObject:imageView];
    }
    self.gifImageViews = newGifViews;
}

@end
