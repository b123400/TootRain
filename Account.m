//
//  AuthedUser.m
//  Canvas
//
//  Created by b123400 Chan on 9/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Account.h"
#import "StatusesManager.h"
#import "TwitterConnector.h"

@implementation Account
@synthesize accessToken;

+(Account*)userWithDictionary:(NSDictionary *)dict{
	Account *thisAccount=[[Account alloc]init];
	thisAccount=(Account*)[thisAccount insertDataIntoUser:thisAccount WithDictionary:dict];
	
	NSString *key=[[dict objectForKey:@"oauthtoken"] objectForKey:@"key"];
	NSString *secret=[[dict objectForKey:@"oauthtoken"] objectForKey:@"secret"];
	thisAccount.accessToken=[[OAToken alloc] initWithKey:key secret:secret];
	return thisAccount;
}
-(NSDictionary*)dictionaryRepresentationWithAuthInformation:(BOOL)withAuth{
	if(!withAuth){
		return [super dictionaryRepresentation];
	}
	NSDictionary *accessTokenDict=[NSDictionary dictionaryWithObjectsAndKeys:
								   [accessToken key],@"key",
								   [accessToken secret],@"secret",nil];
	NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[super dictionaryRepresentation]];
	[dict setObject:accessTokenDict forKey:@"oauthtoken"];
	return dict;
}
-(id)engine{
	if(!engine){
		switch (type) {
			case BRUserTypeTwitter:
			{
				engine=[[TwitterConnector sharedConnector] engineForAccount:self];
			}
				break;
				
			default:
				break;
		}
	}
	return engine;
}
@end
