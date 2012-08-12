//
//  MKFacebookResponseError.h
//  MKAbeFook
//
//  Created by Mike Kinney on 3/6/10.
//  Copyright 2010 Mike Kinney. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MKFacebookRequest;


/*!
 @class MKFacebookResponseError
 
 The MKFacebookResponseError class provides access to details about why Facebook returned an error.
 
 */
@interface MKFacebookResponseError : NSObject {

	NSUInteger errorCode;
	NSString *errorMessage;
	NSArray *requestArgs;
}

/*! @name Properties */
//@{
/*!
 @brief Facebook API error code.
 
 Error code found in response from request. 0 if no error code was found.
 
 @version 0.9 and later
 */
@property (readonly) NSUInteger errorCode;

/*!
 @brief Facebook API error message.
 
 Error message found in resposne from request. nil if no error message was found.
 
 @version 0.9 and later
 */
@property (readonly) NSString *errorMessage;

/*!
 @brief Arguments from request.
 
 All arguments that were passed to Facebook. nil if arguments could not be found.
 
 @version 0.9 and later
 */
@property (readonly) NSArray *requestArgs;
//@}



+ (MKFacebookResponseError *)errorFromRequest:(MKFacebookRequest *)request;
- (id)initWithRequest:(MKFacebookRequest *)request;


@end
