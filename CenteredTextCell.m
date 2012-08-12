//
//  CenteredTextCell.m
//  Smarkin
//
//  Created by b123400 on 04/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "CenteredTextCell.h"


@implementation CenteredTextCell

- (id)initWithCoder:(NSCoder *)aDecoder{
	return [super initWithCoder:aDecoder];
}
- (id)initImageCell:(NSImage *)anImage{
	return [super initImageCell:anImage];
}
- (id)initTextCell:(NSString *)aString{
	return [super initTextCell:aString];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	NSString *drawString=[self title];
	NSSize stringSize=[drawString sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
													  [self font],NSFontAttributeName,
													  nil]
					   ];
	float shift=(cellFrame.size.height-stringSize.height)/2;
	cellFrame.origin.y+=shift;
	cellFrame.size.height-=shift;
	return [super drawWithFrame:cellFrame inView:controlView];
}

@end
