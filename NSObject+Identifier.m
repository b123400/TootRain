//
//  OADataFetcher+Identifier.m
//  perSecond
//
//  Created by b123400 on 21/07/2011.
//  Copyright 2011 home. All rights reserved.
//
#import <objc/runtime.h>
#import "NSObject+Identifier.h"
#import "NSString+UUID.h"

static const char *identifierKey = "identifier";

@implementation NSObject(Identifier)
@dynamic identifier;

-(NSString*)identifier{
	id identifier=objc_getAssociatedObject(self, &identifierKey);
	if(!identifier){
		identifier=[NSString stringWithNewUUID];
		objc_setAssociatedObject(self, &identifierKey, identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return identifier;
}
-(void)setIdentifier:(NSString*)identifier{
	objc_setAssociatedObject(self, &identifierKey, identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
