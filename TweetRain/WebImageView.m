//
//  WebImageView.m
//  flood
//
//  Created by b123400 on 19/8/12.
//
//

#import "WebImageView.h"

@implementation WebImageView;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(void)dealloc{
	if(connection){
		[connection cancel];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	[super drawRect:dirtyRect];
}

-(void)setImageURL:(NSURL*)url{
	didLoadedImage=NO;
	NSURLRequest *request=[NSURLRequest requestWithURL:url];
	if(connection){
		[connection cancel];
	}
	connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];
}
-(BOOL)didLoadedImage{
	return didLoadedImage;
}
#pragma mark delegate
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
	return cachedResponse;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	cachedData=[[NSMutableData alloc]init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[cachedData appendData:data];
}
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
	return request;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSImage *image=[[NSImage alloc] initWithData:cachedData];
	[image setSize:self.frame.size];
	[self setImage:image];
	[self setNeedsDisplay:YES];
	didLoadedImage=YES;
	if(self.delegate&&[delegate respondsToSelector:@selector(imageViewDidLoadedImage:)]){
		[delegate imageViewDidLoadedImage:self];
	}
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if(self.delegate&&[delegate respondsToSelector:@selector(imageViewDidFailedToLoad:)]){
		[delegate imageViewDidFailedToLoad:self];
	}
}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
}

@end
