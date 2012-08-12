//
//  UserRequest.m
//  Canvas
//
//  Created by b123400 Chan on 11/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "UserRequest.h"

@implementation UserRequest
@synthesize targetUsername,targetUserID,user,type;

-(NSString*)targetUsername{
	if(user){
		return user.username;
	}
	return targetUsername;
}
-(NSString*)targetUserID{
	if(user){
		return user.userID;
	}
	return targetUserID;
}
-(BRUserType)type{
	if(user){
		return user.type;
	}
	return type;
}

@end
