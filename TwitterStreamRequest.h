//
//  TwitterStreamRequest.h
//  Canvas
//
//  Created by b123400 Chan on 21/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Request.h"

@interface TwitterStreamRequest : Request{
	SEL timelineSelector;
	SEL mentionSelector;
	SEL directMessageSelector;
	SEL eventSelector;
}
@property (assign,nonatomic) SEL timelineSelector;
@property (assign,nonatomic) SEL mentionSelector;
@property (assign,nonatomic) SEL directMessageSelector;
@property (assign,nonatomic) SEL eventSelector;


@end
