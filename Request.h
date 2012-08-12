//
//  Request.h
//  Canvas
//
//  Created by b123400 Chan on 11/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface Request : NSObject{
	Account *account;
	id target;
	SEL successSelector;
	SEL failSelector;
}
@property (retain,nonatomic) Account *account;
@property (assign,nonatomic) id target;
@property (assign,nonatomic) SEL successSelector;
@property (assign,nonatomic) SEL failSelector;

@end
