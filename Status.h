//
//  Status.h
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Status : NSObject{
	User *user;
	
	NSString *statusID;
	NSDate *createdAt;
	NSString *text;
	
	BOOL liked;
	
	NSMutableDictionary *otherInfos;
}
@property (retain,nonatomic) User *user;
@property (retain,nonatomic) NSString *statusID;
@property (retain,nonatomic) NSDate *createdAt;
@property (retain,nonatomic) NSString *text;

@property (assign,nonatomic) BOOL liked;

@property (retain,nonatomic) NSMutableDictionary *otherInfos;

-(NSMutableDictionary*)dictionaryRepresentation;
-(NSMutableDictionary*)dictionaryRepresentationToPlist:(BOOL)toPlist;
-(NSString*)javascriptRepresentation;

@end
