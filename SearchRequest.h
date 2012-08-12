//
//  SearchRequest.h
//  Canvas
//
//  Created by b123400 Chan on 20/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Request.h"

@interface SearchRequest : Request{
	NSString *searchTerm;
}
@property (nonatomic,retain) NSString *searchTerm;

@end
