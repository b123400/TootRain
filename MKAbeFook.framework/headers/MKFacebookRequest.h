//
//  MKFacebookRequest.h
//  MKAbeFook
//
//  Created by Mike on 12/15/07.
/*
 Copyright (c) 2009, Mike Kinney
 All rights reserved.
 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 Neither the name of MKAbeFook nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import <Cocoa/Cocoa.h>
#import "MKFacebook.h"
#import "MKFacebookSession.h"
#import "MKFacebookResponseError.h"

extern NSString *MKFacebookRequestActivityStarted;
extern NSString *MKFacebookRequestActivityEnded;


/*!
 @enum MKFacebookRequestType
 */
enum MKFacebookRequestType
{
	MKFacebookRequestTypePOST,
	MKFacebookRequestTypeGET
};
typedef int MKFacebookRequestType;


/*!
 @enum MKFacebookRequestResponseFormat
 */
enum MKFacebookRequestResponseFormat
{
	MKFacebookRequestResponseFormatXML,
	MKFacebookRequestResponseFormatJSON
};
typedef int MKFacebookRequestResponseFormat;



/*!
 @class MKFacebookRequest
 MKFacebookRequest handles all requests to the Facebook API.  It can send requests as either POST or GET and return the results to a specified delegate and selector.  

 To send a request you must provide an instance of MKFacebookRequest with a NSDictionary containing the parameters for your request.  Included in the dictionary must be a key "method" with a value of the full Facebook method being requested, i.e. "facebook.users.getInfo".  Values that are required by all Facebook methods, "v", "api_key", "format", "session_key", "sig", and "call_id", do not need to be in the NSDictionary of parameters you pass in, they will be added automatically.
  
 
 The MKFacebookRequest class is be capable of handling most of the methods available by the Facebook API, including facebook.photos.upload.  To upload a photo using this class include a NSImage object in your NSDictionary of parameters you provide and set the method key value to "facebook.photos.upload".  The name of the key for the NSImage object can be any string.

 This class will post notifications named "MKFacebookRequestActivityStarted" and "MKFacebookRequestActivityEnded" when network activity starts and ends.  You are responsible for adding observers for handling the notifications.
 
 See the MKFacebookRequestQueue class for sending a series of requests that are sent sequentially.
 
  
 See MKFacebookRequestDelegate for information about receiving the responses from Facebook.
 
  @version 0.7 and later
 */
@interface MKFacebookRequest : NSObject {
	NSURLConnection *theConnection; //internal connection used if object is used multiple times.
	NSTimeInterval connectionTimeoutInterval;
	id _delegate;
	SEL _selector;
	NSMutableData *_responseData;
	BOOL _requestIsDone; //dirty stupid way of trying to prevent crashing when trying to cancel the request when it's not active.  isn't there a better way to do this?
	MKFacebookRequestType _urlRequestType;
	MKFacebookRequestResponseFormat responseFormat;
	NSMutableDictionary *_parameters;
	NSURL *requestURL;
	BOOL _displayAPIErrorAlert;
	int _numberOfRequestAttempts;
	int _requestAttemptCount;
	MKFacebookSession *_session;

	//exposed via properties
	NSString *method;
	NSString *rawResponse;
	
	//default selectors
	SEL defaultResponseSelector;
	SEL defaultErrorSelector;
	SEL defaultFailedSelector;
	
	//deprecated selectors
	SEL deprecatedResponseSelector;
	SEL deprecatedErrorSelector;
	SEL deprecatedFailedSelector;
}


/*! @name Properties */
//@{
/*!
 @brief Facebook method to call.
 
 This property may be set instead of including a 'method' key in the NSDictionary passed in as parameters. You can retrieve the method used in a request through this property even if you use a dictionary containing a 'method' key.
 
 @version 0.9 and later
 */
@property (retain, nonatomic) NSString *method;

/*!
 @brief Set the response format type, XML or JSON.  XML is default.
 
 Accepts MKFacebookRequestResponseFormatXML or MKFacebookRequestResponseFormatJSON to specify response type.
 
 Both XML and JSON will automatically be parsed to a NSDictionary or NSArray and returned via the appropriate delegate method. For direct access to the unparsed response see the rawResponse property.
 
 @version 0.9 and later

 @see rawResponse
 
 */
@property (nonatomic, assign) MKFacebookRequestResponseFormat responseFormat;

/*!
 @brief Unparsed response from Facebook.
 
 Contains unparsed XML or JSON result from Facebook. Use responseFormat property to specify which type of response you want returned from Facebook. Only available when using asynchronous requests.
 
 @see responseFormat
 
 @version 0.9 and later

 */
@property (readonly) NSString *rawResponse;

/*!
 @brief How long to wait before aborting the request.
 
 How long the connection should wait before giving up. Default is 30 seconds.
 
 @version 0.9 and later
 */
@property NSTimeInterval connectionTimeoutInterval;

//@}

#pragma mark init methods
/*! @name Creating and Initializing
 *
 */
//@{

/*!
 @brief Setup new MKFacebookRequest object.
 
 @param aDelegate The object that will receive the information returned by Facebook.  This should implement -(void)facebookResponseReceived:(id)response to handle data returned from Facebook.  Set a selector to have valid responses sent elsewhere.
 @version 0.9 and later
 */
+ (id)requestWithDelegate:(id)aDelegate;




/*!
 @brief Setup new MKFacebookRequest object.
 
 @param aDelegate The object that will receive the response returned by Facebook.
 @param aSelector Method in delegate object to be called and passed the valid response from Facebook.  This method should accept an (id) as an argument. Responses that contain an error will not be sent to this selector. Use the appropriate delegate methods for handling error responses.
 
 @see MKFacebookRequestDelegate
 
 @version 0.9 and later
 */
+ (id)requestWithDelegate:(id)aDelegate selector:(SEL)aSelector;



- (id)init;



/*!
 @brief Setup new MKFacebookRequest object.
 
 @param aDelegate The object that will receive the information returned by Facebook.
 @param aSelector Method in delegate object to be called and passed the valid response from Facebook.  This method should accept an (id) as an argument. Responses that contain an error will not be sent to this selector. Use the appropriate delegate methods for handling error responses.

 @see MKFacebookRequestDelegate
 
 @version 0.9 and later
 */
- (id)initWithDelegate:(id)aDelegate selector:(SEL)aSelector;




/*!
 @brief Setup new MKFacebookRequest object.
 
 @param parameters NSDictionary containing parameters for requested method.  The dictionary must contain a the key "method" with a value of the full Facebook method being requested, i.e. "facebook.users.getInfo". Values that are required by all Facebook methods, "v", "api_key", "format", "session_key", "sig", and "call_id" do not need to be included in this dictionary.
 @param aDelegate The object that will receive the information returned by Facebook.
 @param aSelector Method in delegate object to be called and passed the valid response from Facebook.  This method should accept an (id) as an argument. Responses that contain an error will not be sent to this selector. Use the appropriate delegate methods for handling error responses.
  
 @see MKFacebookRequestDelegate
 
  @version 0.9 and later
 */
- (id)initWithParameters:(NSDictionary *)parameters delegate:(id)aDelegate selector:(SEL)aSelector;
//@}

#pragma mark -


#pragma mark Instance Methods

/*! @name Preparing and Sending Asynchronous Requests
 *
 */
//@{

/*!
 @brief Pass in a NSDictionary of parameters for your request.
 
 @param parameters NSDictionary containing parameters for requested method.  
 
 The parameters dictionary must contain a the key "method" with a value of the full Facebook method being requested, i.e. "facebook.users.getInfo".  Values that are required by all Facebook methods, "v", "api_key", "format", "session_key", "sig", and "call_id" do not need to be included in this dictionary.
 
 
 @verbatim
 NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
 
 //set up parameters for request
 [parameters setValue:@"users.getInfo" forKey:@"method"];
 [parameters setValue:[fbConnection uid] forKey:@"uid"];
 
 //lists can be either comma separated strings or arrays containing strings, the next two lines are both valid
 [parameters setValue:[NSArray arrayWithObjects:@"first_name",@"last_name",nil] forKey:@"fields"];
 [parameters setValue:@"first_name,last_name" forKey:@"fields"];
 
 //add parameters to request
 [request setParameters:parameters];
 
 //send the request
 [request sendRequest];
 
 [parameters release];
 @endverbatim
 
 @warning Using a NSArray instead of a comma separated string for a list parameter is only available in 0.9 and later.
 
 @version 0.7 and later
 */
- (void)setParameters:(NSDictionary *)parameters;


/*!
 @brief Set the number of times to attempt a request before giving up.
 
 Sets how many times the request should be attempted before giving up.  Note: the delegate will not receive notification of a failed attempt unless all attempts fail.  Default is 5.
 @version 0.8 and later
 */
- (void)setNumberOfRequestAttempts:(int)requestAttempts;



/*!
 @brief Set the type of request (POST or GET).  POST is default.
 
 @param urlRequestType Accepts MKFacebookRequestTypePOST or MKFacebookRequestTypeGET to specify request type.  If no request type is set MKFacebookRequestTypePOST will be used.
 @version 0.7 and later
 */
- (void)setURLRequestType:(MKFacebookRequestType)urlRequestType;

//returns type of request that will be made
- (MKFacebookRequestType)urlRequestType;


/*!
 @brief Set the response format type, XML or JSON.  XML is default.
 
 @param requestFormat Accepts MKFacebookRequestResponseFormatXML or MKFacebookRequestResponseFormatJSON to specify response type.
 
 @deprecated Version 0.9
 
 @see responseFormat
 @see rawResponse
 */
-(void)setRequestFormat:(MKFacebookRequestResponseFormat)requestFormat;



/*!
 @brief Generates the appropriate URL and signature based on parameters for request.  Sends request to Facebook.
 
 MKFacebookRequest will automatically attempt the request again if any of the following errors are encountered:
 - max number of requests allowed reached
 - unknown error
 - service unavailable
 
 The result will be passed to the delegate / selector that were assigned to this object. Make sure you have either set the method property or have set the parameters value with a NSDictionary containing a 'method' key before calling sendRequest.
 
 @verbatim
 NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
 
 //set up parameters for request
 [parameters setValue:@"users.getInfo" forKey:@"method"];
 [parameters setValue:[fbConnection uid] forKey:@"uid"];
 
 //lists can be either comma separated strings or arrays containing strings, the next two lines are both valid
 [parameters setValue:[NSArray arrayWithObjects:@"first_name",@"last_name",nil] forKey:@"fields"];
 [parameters setValue:@"first_name,last_name" forKey:@"fields"];
 
 //add parameters to request
 [request setParameters:parameters];
 
 //send the request
 [request sendRequest];
 
 [parameters release];
 @endverbatim
 
 @warning Raises NSException if the method property has not been set or parameters has not been set with NSDictionary containing a 'method' key.
 
 @see method
 @see setParameters:
 @see sendRequestWithParameters:
 @see sendRequest:withParameters:
 @see MKFacebookRequestDelegate

 @version 0.7 and later
 */
- (void)sendRequest;

/*!
  @brief Sets the parameters before sending the request.

 Sets parameters before sending the request.
 
 See sendRequest for details about what happens when a request is sent to Facebook.
 
 @see sendRequest
  
 @version 0.9 and later
 */
- (void)sendRequestWithParameters:(NSDictionary *)parameters;

/*!
  @brief Sets method and parameters before sending the request.
 
 @param aMethod Facebook method to call.
 
 @param parameters NSDictionary of parameters to pass to method. Does not need to contain a 'method' key.
 
 Sets the method and parameters before sending the request.
 
 See sendRequest for details about what happens when a request is sent to Facebook.
 
 @see sendRequest

 @version 0.9 and later
*/
- (void)sendRequest:(NSString *)aMethod withParameters:(NSDictionary *)parameters;


//creates a signature string based on the parameters for the request
- (NSString *)generateSigForParameters:(NSDictionary *)parameters;


//returns a unix timestamp as a string
- (NSString *)generateTimeStamp;


//@}



/*! @name Synchronous Requests
 *
 */
//@{

/*!
 @brief Generates a full URL including a signature for the method name and parameters passed in.  
 
 @param aMethodName Full Facebook method name to be called.  Example: facebook.users.getInfo
 @param parameters NSDictionary containing parameters and values for the method being called.  They keys are the parameter names and the values are the arguments.
 
 This method will automatically include all parameters required by every Facebook method.  Parameters you do not need to include are "v", "api_key", "format", "session_key", and "call_id".  See official Facebook documentation for all other parameters available depending on the method you are calling.  As of 0.7 this method is considered deprecated, use generateFacebookURL: instead.
 
 @result Returns complete NSURL ready to be sent to the Facebook API.
 
 @see generateFacebookURL:
 @see fetchFacebookData:
 
 */
- (NSURL *)generateFacebookURL:(NSString *)aMethodName parameters:(NSDictionary *)parameters;


/*!
 @brief Generates a full URL including a signature for the parameters passed in.   
 
 @param parameters NSDictionary containing parameters and values for a desired method.  The dictionary must include a key "method" that has the value of the desired method to be called, i.e. "facebook.users.getInfo".  They keys are the parameter names and the values are the arguments.
 
 This method will automatically include all parameters required by every Facebook method.  Parameters you do not need to include are "v", "api_key", "format", "session_key", "sig", and "call_id".  See official Facebook documentation for all other parameters available depending on the method you are calling.
 
 @result Returns complete NSURL ready to be sent to the Facebook API.
 
 @see generateFacebookURL:parameters:
 @see fetchFacebookData:
 
 */
- (NSURL *)generateFacebookURL:(NSDictionary *)parameters;

/*!
 @brief Performs a synchronous request using URL generated by generateFacebookURL:parameters: or generateFacebookURL:
 
 @param theURL URL generated by generateFacebookURL:parameters: or generateFacebookURL:
 
 Initiates a synchronous request to Facebook.
 
 @result Returns NSXMLDocument that was returned from Facebook.  Returns nil if a network error was encountered.
 
 @see generateFacebookURL:parameters:
 @see generateFacebookURL:
 
 @version 0.7 and later
 */
- (id)fetchFacebookData:(NSURL *)theURL;
//@}


/*! @name Canceling a Request
 *
 */
//@{
/*!
 @brief Cancels a request if in progress.
 
 Cancels the current asynchronous request if one is in progress.  Synchronous requests cannot be cancelled.
 @version 0.7 and later
 */
- (void)cancelRequest;
//@}



/*!
 @brief Set the delegate to recieve request results.
 
 @param delegate The object that will receive the inforamtion returned by Facebook.
 
 @see MKFacebookRequestDelegate
 
 @version 0.7 and later
 */
- (void)setDelegate:(id)delegate;


- (id)delegate;


/*!
 @brief Set the selector to receive the request results.
 
 @param selector Method in delegate object to be called and passed the valid response from Facebook.  This method should accept an (id) as an argument. Responses containing errors will not be sent to this selector. Use the appropriate delegate methods for handling errors
 
 @see MKFacebookRequestDelegate
 
 @version 0.7 and later
 */
- (void)setSelector:(SEL)selector;




/*!
 @brief Set to optionally automatically display error window when an error is encountered during a request.
 
 @param aBool Automatically display errorr windows or not.
 
 Sets whether or not instance should automatically display error windows when network connection or xml parsing errors are encountered.  Default is yes.
 
 @see displayAPIErrorAlert
 
 @version 0.8 and later
 */
- (void)setDisplayAPIErrorAlert:(BOOL)aBool;



/*!
 @brief Returns TRUE if error windows will be displayed.
 
 @result Returns boolean indicating whether or not instance will automatically display error windows or not.
 
 @see setDisplayAPIErrorAlert:
 
 @version 0.8 and later
 */
- (BOOL)displayAPIErrorAlert;






#pragma mark -


@end



/*!
 @protocol MKFacebookRequestDelegate
 MKFacebookRequestDelegate is responsible for handling the XML or JSON that Facebook returns. Your delegate should implement either the default response methods or specify your own if you assigned a custom selector to your MKFacebookRequest.
 
 If you do not assign your MKFacebookRequest instance a custom selector, use the facebookRequest:responseReceived: method to catch responses.
 
 If you assigned your own selector it must accept a single (id) argument.
 
 Use facebookRequest:errorReceived: and facebookRequest:failed: to handle errors.
 */
@protocol MKFacebookRequestDelegate


/*! @name Receive Valid Response
 *
 */
//@{

/*!
  @brief Facebook returned a valid response.
 
 Called when Facebook returns a valid response and passes the response returned by Facebook.  The response will be a NSXMLDocument if the request type is XML or a NSDictionary or NSArray if the request type is JSON. If you want the responses sent elsewhere assign the request a selector.
 
 @param response The parsed response from Facebook (either a NSDictionary or NSArray).
 
 @see facebookRequest:responseReceived:
 
 @version 0.8 and later
 
 @deprecated Version 0.9
 */
@optional
- (void)facebookResponseReceived:(id)response;


/*!
 @brief Facebook returned a valid response.
 
 Called when Facebook returns a well formed JSON or XML response that does not contain errors from the Facebook API. If your request was missing required parameters you will not receive the response in this method because it will contain errors from the Facebook API; instead the error response will be sent to facebookRequest:errorReceived:

 If your request specified a JSON responseFormat the response passed to this method will be either a NSDictionary or NSArray. 
 
 If your request specified a XML responseFormat you will receive an unparsed NSXMLDocument object. See NSXMLElementAdditions category for additional XML parsing methods.
 
 @param request The request that returned an error from Facebook.
 
 @param response The response from Facebook. The response could be either a NSDictionary, NSArray, or NSXMLDocument depending on the responseFormat set in the request. 
 

 @see MKFacebookRequest
 @see responseFormat
 @see facebookRequest:errorReceived:
 
 @version 0.9 and later
 */
@optional
- (void)facebookRequest:(MKFacebookRequest *)request responseReceived:(id)response;
//@}



/*! @name Reveive Error Responses
 *
 */
//@{


/*!
 @brief Facebook returned a response containing an error.
 
 Called when an error is returned by Facebook.  Passes response returned by Facebook.
 
 @param error The error response from Facebook.
 
 @see facebookRequest:errorReceived:
 
 @version 0.8 and later
 
 @deprecated Version 0.9
 */
@optional
- (void)facebookErrorResponseReceived:(id)errorResponse;


/*!
 @brief Facebook returned a response containing an error.
 
 Called when an error is returned by Facebook.  Passes the request that caused the error along with details of the error.

 @param request The request that returned an error from Facebook.
 
 @param error The error Facebook returned.
 
  
 @version 0.9 and later
 */

@optional
- (void)facebookRequest:(MKFacebookRequest *)request errorReceived:(MKFacebookResponseError *)error;
//@}

/*! @name Request Failed */
//@{

/*!
 @brief Request has failed.
 
 Called when the request could not be made.  Passes NSError containing information about why it failed (usually due to NSURLConnection problem).
 
 @param Error explaining the failure.
 
 @see facebookRequest:failed:
 
 @version 0.8 and later
 
 @deprecated Version 0.9
 */
@optional
- (void)facebookRequestFailed:(id)error;


/*!
 @brief Request has failed.
 
 Called when the request could not be made. The error will not contain any information from Facebook because the request never got that far.  Passes NSError containing information about why it failed (usually due to NSURLConnection problem).
 
 @param request The request that failed.
 
 @param error Error explaining the failure.
 
 @version 0.9 and later
 */
@optional
- (void)facebookRequest:(MKFacebookRequest *)request failed:(NSError *)error;
//@}


/*! @name Request Progress
 *
 */
//@{
/*!
 @brief Receive progress of an a request.
 
 Called as the body of a POST request is transmitted. Direct wrapper for the internal NSURLConnection delegate method - connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite.
 
 @param request The request sending the message.
 
 @param bytesWritten The number of bytes written in the latest write.
 
 @param totalBytesWritten The total number of bytes written in the latest write.
 
 @param totalBytesExpectedToWrite The number of bytes the request expects to write.
 
 @version 0.9 and later (Mac OS X v10.6 required)
 */
@optional
- (void)facebookRequest:(MKFacebookRequest *)request bytesWritten:(NSUInteger)bytesWritten 
												totalBytesWritten:(NSUInteger)totalBytesWritten 
										totalBytesExpectedToWrite:(NSUInteger)totalBytesExpectedToWrite;
//@}


@end