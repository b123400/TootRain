//
//  MKVideoRequest.h
//  MKAbeFook
//
//  Created by Mike Kinney on 3/5/10.
//  Copyright 2010 Mike Kinney. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MKFacebookRequest.h"

/*!
 
 @class MKVideoRequest
 
 Provides wrappers for some video methods. Untested as of 3.19.2010.
 
 @version 0.9 and later
 */
@interface MKVideoRequest : MKFacebookRequest {

}

/*! @name Init */
//@{
/*!
 @brief New MKVideoRequest.
 
 Returns a new autoreleased instance of MKVideoRequest.
 
 @version 0.9 and later
 */
+ (MKVideoRequest *)requestWithDelegate:(id)aDelegate;
//@}


/*! @name Get Methods */
//@{

/*!
 @brief Get upload limits.
 
 Returns upload limits for the user.
 
 See Facebook documentation for video.getUploadLimits at http://wiki.developers.facebook.com/index.php/Video.getUploadLimits
 
 @version 0.9 and later
 */
- (void)videoGetUploadLimits;
//@}


/*! @name Upload Methods */
//@{
/*!
 
 @brief Uploads a video to Facebook.
 
 @param video The video data to upload.
 
 @param title Title for the video. Should be 65 characters or less, Facebook will truncate anything past 65 characters.
 
 @param description A description of the video.
 
 See Facebook documentation for video.upload at http://wiki.developers.facebook.com/index.php/Video.upload
 
 @version 0.9 and later
 */
- (void)videoUpload:(NSData *)video title:(NSString *)title description:(NSString *)description;
//@}

@end
