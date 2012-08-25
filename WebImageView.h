//
//  WebImageView.h
//  flood
//
//  Created by b123400 on 19/8/12.
//
//

#import <Cocoa/Cocoa.h>

@protocol WebImageViewDelegate <NSObject>

-(void)imageViewDidLoadedImage:(id)sender;
-(void)imageViewDidFailedToLoad:(id)sender;

@end

@interface WebImageView : NSImageView <NSURLConnectionDelegate>{
	NSURLConnection *connection;
	NSMutableData *cachedData;
	
	BOOL didLoadedImage;
	
	id <WebImageViewDelegate> __unsafe_unretained delegate;
}
@property (unsafe_unretained,nonatomic) id <WebImageViewDelegate> delegate;

-(void)setImageURL:(NSURL*)url;

-(BOOL)didLoadedImage;

@end
