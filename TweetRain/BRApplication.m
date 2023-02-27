//
//  BRApplication.m
//  TweetRain
//
//  Created by b123400 on 2023/02/26.
//

#import "BRApplication.h"
#import "FloodAppDelegate.h"

@implementation BRApplication

- (NSArray *)statuses {
    FloodAppDelegate *delegate = (FloodAppDelegate*)[[NSApplication sharedApplication] delegate];
    NSArray *statuses = [[[delegate windowController] rainDrops] valueForKeyPath:@"status"];
    return statuses;
}

@end
