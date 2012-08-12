// 
//  MKFacebook.h
//  MKAbeFook
//
//  Created by Mike on 10/11/06.
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



@class MKLoginWindow;

extern NSString *MKAPIServerURL;
extern NSString *MKVideoAPIServerURL;
extern NSString *MKLoginUrl;
extern NSString *MKExtendPermissionsURL;
extern NSString *MKFacebookAPIVersion;
extern NSString *MKFacebookDefaultResponseFormat;
/*!
 
 @class MKFacebook
 MKFacebook is the starting point for logging in and communicating with Facebook.  It handles displaying a login window for the user and notifying your application when a login has been successful.  

 To provide a user with a login window for your application you must do the following:
 
 1. initialize a new MKFacebook object with your API key and a delegate object
 
 2. call login or loginWithPermissions:forSheet:
 
 3. receive confirmation of a successful login via the userLoginSuccessful delegate method
 
 Delegate Methods
 
 -(void)userLoginSuccessful; (required) Called when a session has been successfully retrieved from Facebook.  Your MKFacebook delegate must implement this method, an exception will be raised if it doesn't.

  
 */
@interface MKFacebook : NSObject {
	
	MKLoginWindow *loginWindow;


	id _delegate;
	BOOL _alertMessagesEnabled;
	BOOL _displayLoginAlerts;
	@private 
    BOOL useModalLogin;
}

#pragma mark Properties


#pragma mark -


#pragma mark Instantiate
/*! @name Creating and Initializing
 *	Create a new MKFacebook object.
 */
//@{


/*!
 @brief Setup new MKFacebook object.
 
 @param anAPIKey Your API key issued by Facebook.
 @param aDelegate A delegate object that will receive calls from the MKFacebook object.
  
 The delegate object must implement a userLoginSuccessful method that will called after a user has successfully logged in.
 
 @result Returns allocated and initiated MKFacebook object ready to be used to log into the Facebook API.
@version 0.7 and later
 */
+ (MKFacebook *)facebookWithAPIKey:(NSString *)anAPIKey delegate:(id)aDelegate;



/*!
 @brief Setup new MKFacebook object.
 
 @param anAPIKey Your API key issued by Facebook.
 @param aDelegate A delegate object that will receive calls from the MKFacebook object.
  
 The delegate object must implement a userLoginSuccessful method that will called after a user has successfully logged in.
 
 @result Returns initiated MKFacebook object ready to be used to log into the Facebook API.
  @version 0.7 and later
 */
- (MKFacebook *)initUsingAPIKey:(NSString *)anAPIKey delegate:(id)aDelegate;


//@}	//ENDS Instantiate group
#pragma mark -



#pragma mark Login and Logout
/*! @name Login and Logout
 *	Display login window, get information about user login status.
 */
//@{

/*!
 @brief Load existing session if available or display a login window.
 
 Tries to load existing session. If no session is available a login window will be displayed. If a user logs in successfully the session will automatically be saved to the application NSUserDefaults. If you need to display a login window while a modal window active use loginUsingModalWindow.
 
 
 You can customize the message displayed in the login window after a successful or failed login attempt by creating "FacebookLoginSuccess.html" and "FacebookLoginFailed.html" files and placing them in the Resources folder of your application.
 
 @see loginUsingModalWindow 
 @see loginWithPermissions:forSheet:
 
 @version 0.9 and later
 */
- (void)login;


/*!
 @brief Loads an existing session if available or displays a modal login window.
 
 Tries to load an existing session. If no session is available a modal login window will be displayed. Use this method if you need to display a modal login window while another modal window is already visible.
 
 If a user logs in successfully the session will automatically be saaved to the application NSUSerDefaults.

 @see login 
 @see loginWithPermissions:forSheet:

 @version 0.9 and later
 */
- (void)loginUsingModalWindow;


/*!
 @brief Attempts to log a user in using existing session.  If no session is available a login window is diplayed.
 
  Tries to load existing session. If no session is available a login window will be displayed. If a user logs in successfully the session will automatically be saved to the application NSUserDefaults. See http://wiki.developers.facebook.com/index.php/Extended_permissions for a list of available permissions.
 
 @param permissions List of permisisons to offer the user.
 @param sheet If YES is passed in a NSWindow will be returned, otherwise a login window will appear and nil will be returned.
 @return Either a NSWindow to be attached as a sheet or nil.
 
 @verbatim
 NSWindow *loginWindow = [fbConnection loginWithPermissions:[NSArray arrayWithObjects:@"offline_access",@"photo_upload",nil] forSheet:YES];
 @endverbatim
 
 @warning If additional permissions are requested the user must allow them or the login may not be successful.
 
 @see login
 @see loginUsingModalWindow

 @version 0.9 and later
 */
- (NSWindow *)loginWithPermissions:(NSArray *)permissions forSheet:(BOOL)sheet;



/*!
 @brief Checks for a valid session in NSUserDefaults.

 
 @result Returns TRUE if valid session exists.
 
 @see uid
 */
- (BOOL)userLoggedIn;



/*!
 @brief Get the UID of the logged in user.
 
 @result Returns uid as NSString of user currently logged in, returns nil if no user is logged in.
 
 @see userLoggedIn
 */
- (NSString *)uid;



/*!
 @brief Destoys login session.
 
 Removes any saved sessions and invalidates any future requests until a user logs in again.
 @version 0.9.0
 */
- (void)logout;


//called from MKLoginWindow after a successful login
- (void)userLoginSuccessful;


//@}	//ENDS Manage User Login group
#pragma mark -



#pragma mark Extend Permisisons
/*! @name Extend Permissions
 *	Display a window to allow user to extent application permissions.
 */
//@{


/*!
 @brief Display a window and a Facebook page to extend permisisons.
 
 @param aString Name of extended permission to grant. See Facebook documentation for allowed extended permissions.

 This method will display a new window and load the Facebook URL http://www.facebook.com/connect/prompt_permissions.php to extend permissions of the application.
 
 @see grantExtendedPermission:forSheet:
 
 @version 0.7.4 and later
*/
- (void)grantExtendedPermission:(NSString *)aString;



/*!
 @brief Display a window and a Facebook page to extend permisisons.
 
 @param aString Name of extended permission to grant. See Facebook documentation for allowed extended permissions.
 @param forSheet BOOL to request a NSWindow that can be attached as a sheet, pass in NO to simply display the window.

 This method will display a new window and load the Facebook URL http://www.facebook.com/connect/prompt_permissions.php to extend permissions of the application.
 
 @see grantExtendedPermission:

 @result Returns NSWindow or displays window.
 @version 0.8.2 and later
 */
- (NSWindow *)grantExtendedPermission:(NSString *)aString forSheet:(BOOL)forSheet;


//@}	//ENDS Extend Permissions group
#pragma mark -


#pragma mark Handle Login Alerts
/*! @name Handle Login Alerts
 *	
 */
//@{


/*!
 @brief Display alert window with details of error encountered. 
 
 Set whether or not alert windows should be displayed if Facebook returns an error during the login process.  Default is YES.
 
 @param aBool Should we display the error or should we not?
 
 @see displayLoginAlerts
 
 @version 0.8 and later
 */
- (void)setDisplayLoginAlerts:(BOOL)aBool;



/*!
 @brief Returns YES if login alerts are enabled, NO if they are not.
 
 @result Returns YES if login alerts are enabled, NO if they are not.
 
 @see setDisplayLoginAlerts:
 
 @version 0.8 and later
 */
- (BOOL)displayLoginAlerts;


//@}	//ENDS Handle Login Alerts group
#pragma mark -

@end





/*!
 Your MKFacebook delegate must implement the userLoginSuccessful method to receive a message when a user has successfully logged in.
 
 @version 0.8 and later
 */
@protocol MKFacebookDelegate


/*! @name Receive Login Notification
 *
 */
//@{

/*!
 Called when a session has been successfully retrieved from Facebook.  You may now start sending requests using MKFacebookRequest.
 
 @see MKFacebookRequest
 @version 0.8 and later
 */
@required
-(void)userLoginSuccessful;


//@}

@end





