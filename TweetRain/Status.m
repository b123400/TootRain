//
//  Status.m
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Status.h"

@implementation Status
@synthesize user,statusID,createdAt,text,favourited,reblogged,bookmarked,attributedText;

- (BOOL)canReply {
    return NO;
}
- (void)replyToStatusWithText:(NSString *)text
            completionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [NSException raise:NSGenericException format:@"Not implemented"];
}

- (BOOL)canBookmark {
    return NO;
}
- (void)bookmarkStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [NSException raise:NSGenericException format:@"Not implemented"];
}

- (BOOL)canFavourite {
    return NO;
}
- (void)favouriteStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [NSException raise:NSGenericException format:@"Not implemented"];
}

- (BOOL)canReblog {
    return NO;
}
- (void)reblogStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [NSException raise:NSGenericException format:@"Not implemented"];
}

- (NSUniqueIDSpecifier *)objectSpecifier {
    NSScriptClassDescription *appDescription = (NSScriptClassDescription *)[NSApp classDescription];
    return [[NSUniqueIDSpecifier alloc] initWithContainerClassDescription:appDescription containerSpecifier:nil key:@"statuses" uniqueID:self.statusID];
}

- (NSString *)textForScripting {
    return self.text ?: self.attributedText.string ?: @"";
}

- (NSString *)usernameForScripting {
    return self.user.username ?: @"";
}

- (NSString *)screenNameForScripting {
    return self.user.screenName ?: @"";
}

@end
