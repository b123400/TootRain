//
//  CustomTitleBar.h
//  Smarkin
//
//  Created by b123400 on 28/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CustomTitleBar : NSView {
	IBOutlet id delegate;
}

@property (assign,nonatomic) id delegate;


@end
