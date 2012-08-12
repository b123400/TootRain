//
//  StatusesRequest.h
//  Canvas
//
//  Created by Chan KC on 22/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserRequest.h"
#import "Status.h"

@interface StatusesRequest : UserRequest{
	Status *sinceStatus;
	Status *beforeStatus;
	int count;
}
@property (nonatomic,retain) Status *sinceStatus;
@property (nonatomic,retain) Status *beforeStatus;
@property (nonatomic,assign) int count;

@end
