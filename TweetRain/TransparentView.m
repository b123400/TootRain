//
//  TransparentView.m
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "TransparentView.h"
#import "QuartzCore/CAShapeLayer.h"
#import "SettingManager.h"

@interface TransparentView ()

@property (nonatomic, strong) NSBezierPath *maskPath;

@end

@implementation TransparentView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.wantsLayer = YES;
        self.clipsToBounds = YES;
        self.clipAroundCursor = NO;
        _cursorLocation = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cursorModeChanged:) name:kCursorBehaviourChanged object:nil];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSColor *color = [NSColor clearColor];
	[color set];
	NSRectFill(dirtyRect);
    [color setFill];
    NSRectFill(dirtyRect);
}

- (void)renewMaskPath {
    if (!self.maskPath) {
        self.maskPath = [NSBezierPath bezierPath];
    }
    [self.maskPath removeAllPoints];
    if (!self.clipAroundCursor || self.cursorLocation.x == CGFLOAT_MAX || self.cursorLocation.y == CGFLOAT_MAX) {
        return;
    }
    [self.maskPath appendBezierPathWithRect:self.layer.bounds];
    CGFloat radius = 100;
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(self.cursorLocation.x - radius, self.cursorLocation.y - radius, radius * 2, radius * 2)];
    [self.maskPath appendBezierPath:[circlePath bezierPathByReversingPath]];
}

- (void)setClipAroundCursor:(BOOL)clipAroundCursor {
    _clipAroundCursor = clipAroundCursor;
}

- (void)setCursorLocation:(CGPoint)cursorLocation {
    _cursorLocation = cursorLocation;
    [self renewMaskPath];
    if (self.clipAroundCursor) {
        if (!self.layer.mask) {
            self.layer.mask = [CAShapeLayer layer];
        }
        if (@available(macOS 14.0, *)) {
            // Force redraw
            ((CAShapeLayer*)self.layer.mask).path = self.maskPath.CGPath;
        }
    } else if (!self.clipAroundCursor && self.layer.mask) {
        self.layer.mask = nil;
    }
}

- (void)cursorModeChanged:(NSNotification *)notification {
    self.clipAroundCursor = [[SettingManager sharedManager] cursorBehaviour] == CursorBehaviourClipAround;
}

@end
