//
//  Status.h
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "BRMastodonStatus.h"

@interface Status : NSObject{
}
@property (strong, nonatomic, nullable) User *user;
@property (strong, nonatomic, nonnull) NSString *statusID;
@property (strong, nonatomic, nullable) NSDate *createdAt;
@property (strong, nonatomic, nullable) NSString *text;
@property (strong, nonatomic, nullable) NSString *spoilerText;

@property (assign, nonatomic) BOOL favourited;
@property (assign, nonatomic) BOOL bookmarked;
@property (assign, nonatomic) BOOL reblogged;

@property (strong, nonatomic, nullable) NSAttributedString *attributedText;
@property (strong, nonatomic, nullable) NSAttributedString *attributedSpoilerText;

- (NSString * _Nonnull)spoilerOrText;
- (NSAttributedString * _Nonnull)attributedSpoilerOrText;

- (BOOL)canReply;
- (void)replyToStatusWithText:(NSString * _Nonnull)text
            completionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback;

- (BOOL)canBookmark;
- (void)bookmarkStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback;

- (BOOL)canFavourite;
- (void)favouriteStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback;

- (BOOL)canReblog;
- (void)reblogStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback;

- (NSString * _Nonnull)textForScripting;

@end
