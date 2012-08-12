//
//  UserRequest.h
//  Canvas
//
//  Created by b123400 Chan on 11/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Request.h"
#import "User.h"

@interface UserRequest : Request{
	User *user;
	NSString *targetUsername;
	NSString *targetUserID;
	BRUserType type;
}
@property (retain,nonatomic) User *user;
@property (retain,nonatomic) NSString *targetUsername;
@property (retain,nonatomic) NSString *targetUserID;
@property (assign,nonatomic) BRUserType type;

@end
