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

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *screenName;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *description;

@property (nonatomic,strong) NSURL *profileImageURL;

@property (nonatomic,strong) NSMutableDictionary *otherInfos;

+(NSString*)networkNameOfType:(BRUserType)type;
+(BRUserType)typeOfNetworkName:(NSString*)networkName;

+(User*)userWithDictionary:(NSDictionary*)dict;
-(User*)insertDataIntoUser:(User*)thisUser WithDictionary:(NSDictionary*)dict;

-(NSDictionary*)dictionaryRepresentation;
-(NSString*)javascriptRepresentation;

@end
