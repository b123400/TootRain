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
@property (strong,nonatomic) User *user;
@property (strong,nonatomic) NSString *targetUsername;
@property (strong,nonatomic) NSString *targetUserID;
@property (assign,nonatomic) BRUserType type;

@end
