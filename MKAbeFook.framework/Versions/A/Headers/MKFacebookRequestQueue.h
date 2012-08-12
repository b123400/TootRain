// 
//  MKFacebookRequestQueue.h
//  MKAbeFook
//
//  Created by Mike Kinney on 12/12/07.
/*
 Copyright (c) 2009, Mike Kinney
 All rights reserved.
 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 Neither the name of MKAbeFook nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */
//IMPORTANT NOTE: As of this writing this object will release itself when it's done with the queue.  Do not try to autorelease or release this object manually.

#import <Cocoa/Cocoa.h>
#import "MKFacebookRequest.h"
/*!
 @brief Sends series of requests to Facebook
 
 @class MKFacebookRequestQueue
  This class is used to send a series of requests to the Facebook API.  Requests are sent sequentially and do not begin until the previous request has been completed.  This class is useful for sending multiple photo uploads or when you need to ensure you have information from one request before processing another.
 
 
 Note: The queue will override all delegate / selector settings on the individual requests. The queue pass all request responses back to the delegate accordingly via the MKFacebookRequestDelegate protocol.
 
 Use the MKFacebookRequestQueueDelegate protocol to receive queue progress information.
 
  @version 0.7 and later
 */
@interface MKFacebookRequestQueue : NSObject <MKFacebookRequestDelegate> {
	NSMutableArray *_requestsArray;
	id _delegate;
	int _currentRequest;
	BOOL _cancelRequestQueue;
	float _timeBetweenRequests;
	BOOL _shouldPauseBetweenRequests;
}


/*! @name Creating and Initializing
 *
 */
//@{


- (id)init;
/*!
 @brief New MKFacebookRequestQueue instance.
 
 @param requests NSArray of prepared MKFacebookRequest objects.
 
 @version 0.7 and later
 */
- (id)initWithRequests:(NSArray *)requests;
//@}


/*!
 @param delegate
  Set delegate object.
  @version 0.7 and later
 */
- (void)setDelegate:(id)delegate;


/*! @name Manage the queue
 *
 */
//@{

/*!
 @brief Sets the array of MKFacebookRequests to send to Facebook.
 
 @see addRequest:

 @warning Requests added to the queue will not send delegate messages back to custom selectors set on MKFacebookRequest objects. Use the MKFacebookRequestDelegate protocol to receive responses.
 
 @version 0.7 and later
 */
- (void)setRequests:(NSArray *)requests;


/*!
 @brief Add a request to the queue.
 
 @param request MKFacebookRequest object that is ready to be sent.
 
 @warning Requests added to the queue will not send delegate messages back to custom selectors set on MKFacebookRequest objects. Use the MKFacebookRequestDelegate protocol to receive responses.
 
 @see setRequests:
 
 @version 0.7 and later
 */
- (void)addRequest:(MKFacebookRequest *)request;

/*!
  @brief Starts processing the request queue.

  Requests in the queue will be sent to Facebook in the same order they were added. You can receive response information from each request by implementing the MKFacebookRequestDelegate methods in your queue delegate.
 
  See the MKFacebookRequestQueueDelegate documentation for receiving information about the progress of the queue.
 
  @see MKFacebookRequestQueueDelegate
 
  @version 0.7 and later
 */
- (void)startRequestQueue;

/*!
 Set whether or not queue should automatically pause between requests in order to try to prevent the too many requests error.  Default is NO.
 @param aBool Should we wait or should we go now?
 @version 0.8 and later
 */
- (void)setShouldPauseBetweenRequests:(BOOL)aBool;


/*!
 Time in seconds between requests.
 @result time in seconds
 @version 0.8 and later
 */
- (float)timeBetweenRequests;

/*!
 @param waitTime Number of seconds to wait between requests. Default is 1.0
 @version 0.8 and later
 */
- (void)setTimeBetweenRequests:(float)waitTime;
//@}

/*!
  Attempts to stop the current request being processed and prevents any further requests from starting.
  @version 0.7 and later
 */
- (void)cancelRequestQueue;

@end



@protocol MKFacebookRequestQueueDelegate
/*!
 @protocol MKFacebookRequestQueueDelegate
 
 Receives information regarding progress of MKFacebookRequestQueue.
 
 */

/*! @name Progress */
//@{

/*!
 @Brief Index of active request in queue.
 
 Sent immediately before the new request number (index) is started.
 
 @param queue The request queue.
 
 @param index Number of the request being send. First index is 1.
 
 @param total Total number of requests in queue.
 
 @version 0.9 and later
 */
@optional
- (void)requestQueue:(MKFacebookRequestQueue *)queue activeRequest:(NSUInteger)index ofRequests:(NSUInteger)total;

/*!
 @brief Sent when all requests have finished.
 
 Sent when the queue has finished sending all requests and all responses have been received.
 
 @param queue The queue.
 
 @version 0.9 and later
 */
@optional
- (void)requestQueueDidFinish:(MKFacebookRequestQueue *)queue;


/*
 @brief Sent if the last request completed was completed successfully.
 
 @param queue The queue the request was in.
 
 @param request The request that was completed.
 
 @param response The response from Facebook.
 */
@optional
- (void)requestQueue:(MKFacebookRequestQueue *)queue lastRequest:(MKFacebookRequest *)request responseReceived:(id)response;




/*
 @brief Sent if the last request completed contains an error.
 
 @param queue The queue the request was in.
 
 @param request The request that was completed.
 
 @param errorResponse The error returned by Facebook. 
 */
@optional
- (void)requestQueue:(MKFacebookRequestQueue *)queue lastRequest:(MKFacebookRequest *)request errorReceived:(MKFacebookResponseError *)errorResponse;


/*
 @brief Called if the request could not be sent.
 
 @param queue The queue the request was in.
 
 @param request The request that was completed.
 
 @param error The error that occurred.
 */
@optional
- (void)requestQueue:(MKFacebookRequestQueue *)queue lastRequest:(MKFacebookRequest *)request failed:(NSError *)error;

//@}

@end

