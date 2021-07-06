//
//  BRMastodonUser.h
//  TweetRain
//
//  Created by b123400 on 2021/07/05.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonUser : NSObject

@property (nonatomic,strong) NSString *username; // e.g. "b"
@property (nonatomic,strong) NSString *accountName; // e.g. "b" "b@is-he.re"
@property (nonatomic,strong) NSString *displayName; // e.g. "b123400"
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *note;

@property (nonatomic,strong) NSURL *profileImageURL;
@property (nonatomic,strong) NSURL *URL;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
