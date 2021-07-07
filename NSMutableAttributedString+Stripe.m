//
//  NSMutableAttributedString+Stripe.m
//  TweetRain
//
//  Created by b123400 on 2021/07/06.
//

#import "NSMutableAttributedString+Stripe.h"
#import "NSImage+Resize.h"

@implementation NSMutableAttributedString (Stripe)

- (void)removeNewLines {
    NSRange r = NSMakeRange(NSNotFound, NSNotFound);
    while ((r = [[self mutableString] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]]).location != NSNotFound) {
        [self replaceCharactersInRange:r withString:@" "];
    }
}

- (void)removeColors {
    NSRange r = NSMakeRange(NSNotFound, NSNotFound);
    NSInteger index = 0;
    while (index < self.length) {
        NSDictionary<NSAttributedStringKey, id> *attributes = [self attributesAtIndex:index effectiveRange:&r];
        index = r.length + r.location;
        if (attributes[NSStrokeColorAttributeName]) {
            [self removeAttribute:NSStrokeColorAttributeName range:r];
        }
        if (attributes[NSForegroundColorAttributeName]) {
            [self removeAttribute:NSForegroundColorAttributeName range:r];
        }
    }
}

- (void)removeLinks {
    NSRange r = NSMakeRange(NSNotFound, NSNotFound);
    NSInteger index = 0;
    while (index < self.length) {
        NSDictionary<NSAttributedStringKey, id> *attributes = [self attributesAtIndex:index effectiveRange:&r];
        index = r.length + r.location;
        if (attributes[NSLinkAttributeName]) {
            [self deleteCharactersInRange:r];
            index = r.location;
        }
    }
}

- (void)removeLinkAttributes {
    NSRange r = NSMakeRange(NSNotFound, NSNotFound);
    NSInteger index = 0;
    while (index < self.length) {
        NSDictionary<NSAttributedStringKey, id> *attributes = [self attributesAtIndex:index effectiveRange:&r];
        index = r.length + r.location;
        if (attributes[NSLinkAttributeName]) {
            [self removeAttribute:NSLinkAttributeName range:r];
        }
    }
}


- (void)removeImages {
    NSRange r = NSMakeRange(NSNotFound, NSNotFound);
    NSInteger index = 0;
    while (index < self.length) {
        NSDictionary<NSAttributedStringKey, id> *attributes = [self attributesAtIndex:index effectiveRange:&r];
        index = r.length + r.location;
        if (attributes[NSAttachmentAttributeName]) {
            [self removeAttribute:NSAttachmentAttributeName range:r];
        }
    }
    while ((r = [[self mutableString] rangeOfString:@"\uFFFC"]).location != NSNotFound) {
        [self replaceCharactersInRange:r withString:@" "];
    }
}

- (void)resizeImagesWithHeight:(CGFloat)height {
    NSRange r = NSMakeRange(NSNotFound, NSNotFound);
    NSInteger index = 0;
    while (index < self.length) {
        NSDictionary<NSAttributedStringKey, id> *attributes = [self attributesAtIndex:index effectiveRange:&r];
        index = r.length + r.location;
        if (attributes[NSAttachmentAttributeName]) {
            NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
            NSImage *image = [attachment imageForBounds:attachment.bounds
                                          textContainer:nil
                                         characterIndex:r.location];
            if (image && (image.size.height > height)) {
                int newWidth = height / image.size.height * image.size.width;
                NSImage *newImage = [image resized:NSMakeSize(newWidth, height)];
                [attachment setImage:newImage];
                attachment.bounds = NSMakeRect(0, 0, newImage.size.width, newImage.size.height);
            }
        }
    }
}

@end
