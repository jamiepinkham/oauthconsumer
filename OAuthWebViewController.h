//
//  TwitterAuthWebViewController.h
//  Rexly
//
//  Created by Jamie Pinkham on 8/18/11.
//  Copyright 2011 Rexly. All rights reserved.
//

#import "PPRWebViewController.h"
#import "OAuthConsumer.h"

@class OAuthWebViewController;
@protocol OAuthWebViewControllerDelegate <NSObject>

- (void)oAuthWebViewController:(OAuthWebViewController *)owvc didAuthorizeWithToken:(OAToken *)token;
- (void)oAuthWebViewController:(OAuthWebViewController *)owvc didFailToAutorizeWithError:(NSError *)error;

@optional
- (void)webControllerDidFinishLoading:(OAuthWebViewController *)controller;

- (void)webController:(OAuthWebViewController *)controller 
 didFailLoadWithError:(NSError *)error;

- (void)webController:(OAuthWebViewController *)controller
shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@interface OAuthWebViewController : UIViewController <UIWebViewDelegate> {
    UIColor *backgroundColor;
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
    
    BOOL shouldShowDoneButton;
    
    id <OAuthWebViewControllerDelegate> delegate;
    
    OAConsumer *consumer;
    
    
}

@property (nonatomic, copy) NSURL *requestTokenURL;
@property (nonatomic, copy) NSURL *authorizeTokenURL;
@property (nonatomic, copy) NSURL *accessTokenURL;
@property (nonatomic, copy) NSURL *callbackURL;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL shouldShowDoneButton;

@property (nonatomic, assign) id <OAuthWebViewControllerDelegate> delegate;

- (id)initWithOAConsumer:(OAConsumer *)inConsumer requestTokenURL:(NSURL *)inRequestTokenURL authorizeTokenURL:(NSURL *)inAuthorizeTokenURL accessTokenURL:(NSURL *)inAccessTokenURL callbackURL:(NSURL *)inURL delegate:(id<OAuthWebViewControllerDelegate>)inDelegate;
- (id)initWithConsumerKey:(NSString *)inKey secret:(NSString *)inSecret requestTokenURL:(NSURL *)inRequestTokenURL authorizeTokenURL:(NSURL *)inAuthorizeTokenURL accessTokenURL:(NSURL *)inAccessTokenURL callbackURL:(NSURL *)inURL delegate:(id<OAuthWebViewControllerDelegate>)inDelegate;
@end

