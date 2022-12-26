//
//  MisskeyStatus.m
//  TweetRain
//
//  Created by b123400 on 2022/12/24.
//

#import "MisskeyStatus.h"
#import "MisskeyUser.h"

@implementation MisskeyStatus

- (id)initWithMisskeyStatus:(BRMisskeyStatus *)status {
    if (self = [super init]) {
        BOOL useRenote = status.text.length == 0 && status.renote;
        if (useRenote) {
            self = [self initWithMisskeyStatus:status.renote];
        } else {
            self.user = [[MisskeyUser alloc] initWithMisskeyUser:status.user];
            self.statusID = status.statusID;
            self.text = status.text;
            self.misskeyStatus = status;
            
            // Make attributed string in init, so the images are loaded when status is init-ed
            // such that we can load the image in background
            self.attributedText = [status attributedStringWithEmojisReplaced];
        }
    }
    return self;
}

- (BOOL)canReply {
    return NO;
}
- (void)replyToStatusWithText:(NSString *)text
            completionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    
}

- (BOOL)canBookmark {
    return NO;
}
- (void)bookmarkStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    
}

- (BOOL)canFavourite {
    return NO;
}
- (void)favouriteStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {

}

- (BOOL)canReblog {
    return NO;
}

- (void)reblogStatusWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))callback {
    
}

@end
