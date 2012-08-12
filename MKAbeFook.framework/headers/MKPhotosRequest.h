//
//  MKPhotosRequest.h
//  MKAbeFook
//
//  Created by Mike Kinney on 11/3/08.
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
#import "MKFacebookRequest.h"


/*!
 
 @class MKPhotosRequest
 
 Provides wrappers for some photos methods.
 
 @version 0.9
 */
@interface MKPhotosRequest : MKFacebookRequest {

}

/*! @name Init Methods */
//@{

/*!
 @brief Create a new MKPhotosRequest.
 
 @version 0.9 and later
*/
+ (id)requestWithDelegate:(id)aDelegate;
//@}


/*! @name Get Methods */
//@{
/*!
 
 @brief Wrapper for photos.get.
 
 @param pids Array of photo pids to filter by.
 
 @param aid Filter by this album id.
 
 @param subj_id Filter by photos tagged with this user id.
 
 See Facebook photos.get documentation at http://wiki.developers.facebook.com/index.php/Photos.get.
 
 @see photosGet:
 
 @version 0.9 and later
 */
-(void)photosGet:(NSArray *)pids aid:(NSString *)aid subjId:(NSString *)subj_id;

/*!

 @brief Wrapper for photos.get.
 
 @param aid Filter by this album id.

 See Facebook photos.get documentation at http://wiki.developers.facebook.com/index.php/Photos.get.
 
 @see photosGet:aid:subjId:
 
 @version 0.9 and later
 */
-(void)photosGet:(NSString *)aid;

/*!
 
 @brief Wrapper for photos.getTags.
 
 @param pids List of photo ids to extract tags from.
 
 See Facebook photos.getTags documentation at http://wiki.developers.facebook.com/index.php/Photos.getTags
 
 @version 0.9 and later
 */
-(void)photosGetTags:(NSArray *)pids;


/*!
 @brief Wrapper for photos.getAlbums
 
 @param aids Return albums with aids in this list. Array of aid strings.
 
 See Facebook photos.getAlbums documentation http://wiki.developers.facebook.com/index.php/Photos.getAlbums
 
 @version 0.9 and later
 */
- (void)photosGetAlbums:(NSArray *)aids;
//@}


/*! @name Upload Methods */
//@{

/*!
 
 @brief Wrapper for photos.upload.

 @param photo The photo to upload.
 
 @param aid Album id to add photo to.
 
 @param caption A caption for the photo.
 
 See Facebook photos.upload documentation at http://wiki.developers.facebook.com/index.php/Photos.upload
 
 See MKFacebookRequestDelegate method facebookRequest:bytesWritten:totalBytesWritten:totalBytesExpectedToWrite: for a way to check upload progress.
 
 @see photoUploads:
 
 @version 0.9 and later
 */
-(void)photosUpload:(NSImage *)photo aid:(NSString *)aid caption:(NSString *)caption;

/*!
 
 @brief Wrapper for photos.upload.

 @param photo The photo to upload.
 
 Photo will be added to application album because no album id is specified.
 
 See Facebook photos.upload documentation at http://wiki.developers.facebook.com/index.php/Photos.upload

 See MKFacebookRequestDelegate method facebookRequest:bytesWritten:totalBytesWritten:totalBytesExpectedToWrite: for a way to check upload progress.
 
 @see photosUpload:aid:caption:
 
 @version 0.9 and later
 */
-(void)photosUpload:(NSImage *)photo;
//@}

@end

