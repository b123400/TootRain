//
//  BRMastodonList.h
//  TweetRain
//
//  Created by b123400 on 2022/12/01.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BRMastodonList : NSObject

@property (strong, nonatomic) NSString *listId;
@property (strong, nonatomic) NSString *title;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
