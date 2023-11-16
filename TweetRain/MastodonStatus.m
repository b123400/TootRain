//
//  MastodonStatus.m
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "MastodonStatus.h"
#import "MastodonUser.h"
#import "BRMastodonClient.h"

@implementation MastodonStatus

- (id)initWithMastodonStatus:(BRMastodonStatus *)status {
    if (self = [super init]) {
        self.user = [[MastodonUser alloc] initWithMastodonUser:status.user];
        self.statusID = status.statusID;
        self.createdAt = status.createdAt;
        self.text = status.text;
        self.spoilerText = status.spoiler;
        self.favourited = status.favourited;
        self.reblogged = status.reblogged;
        self.bookmarked = status.bookmarked;
        
        self.mastodonStatus = status;

        // Make attributed string in init, so the images are loaded when status is init-ed
        // such that we can load the image in background
        self.attributedText = [status attributedStringWithEmojisReplaced];
        self.attributedSpoilerText = [status attributedSpoilerWithEmojisReplaced];
    }
    return self;
}

- (BOOL)canReply {
    return YES;
}
- (void)replyToStatusWithText:(NSString *)text
            completionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [[BRMastodonClient shared] replyToStatus:self.mastodonStatus
                                    withText:text
                           completionHandler:^(BRMastodonStatus * _Nullable status, NSError * _Nullable error) {
        callback(error);
    }];
}

- (BOOL)canBookmark {
    return YES;
}
- (void)bookmarkStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [[BRMastodonClient shared] bookmarkStatus:self.mastodonStatus
                            completionHandler:callback];
}

- (BOOL)canFavourite {
    return YES;
}
- (void)favouriteStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [[BRMastodonClient shared] favouriteStatus:self.mastodonStatus completionHandler:callback];
}

- (BOOL)canReblog {
    return YES;
}
- (void)reblogStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    [[BRMastodonClient shared] reblogStatus:self.mastodonStatus completionHandler:callback];
}

@end
