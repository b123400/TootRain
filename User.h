//
//  Account.h
//  Smarkin
//
//  Created by b123400 on 07/05/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OAToken.h"

typedef enum BRUserType {
    BRUserTypeTwitter    = 0,
    BRUserTypeFacebook   = 1,
	
	BRUserTypeUnknown   = 99,
} BRUserType;

@interface User : NSObject {
	BRUserType type;
	
	NSString *username;
	NSString *screenName;
	NSString *userID;
	NSString *description;
	
	NSURL *profileImageURL;
	
	NSMutableDictionary *otherInfos;
}

@property (nonatomic,assign) BRUserType type;

@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *screenName;
@property (nonatomic,retain) NSString *userID;
@property (nonatomic,retain) NSString *description;

@property (nonatomic,retain) NSURL *profileImageURL;

@property (nonatomic,retain) NSMutableDictionary *otherInfos;

+(NSString*)networkNameOfType:(BRUserType)type;
+(BRUserType)typeOfNetworkName:(NSString*)networkName;

+(User*)userWithDictionary:(NSDictionary*)dict;
-(User*)insertDataIntoUser:(User*)thisUser WithDictionary:(NSDictionary*)dict;

-(NSDictionary*)dictionaryRepresentation;
-(NSString*)javascriptRepresentation;

@end
