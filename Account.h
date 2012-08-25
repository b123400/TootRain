//
//  AuthedUser.h
//  Canvas
//
//  Created by b123400 Chan on 9/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "User.h"
#import "TwitterEngine.h"

@interface Account : User{
	OAToken *accessToken;
	id engine;
}
@property (nonatomic,strong) OAToken *accessToken;

-(id)engine;

-(NSDictionary*)dictionaryRepresentationWithAuthInformation:(BOOL)withAuth;

@end
