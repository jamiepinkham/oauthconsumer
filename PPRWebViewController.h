//
//  PPRWebViewController.h
//
//  Created by Matt Drance on 6/30/10.
//  Copyright 2010 Bookhouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPRWebViewControllerDelegate;

@interface PPRWebViewController : UIViewController <UIWebViewDelegate> {
    NSURL *url;
    
    UIColor *backgroundColor;
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
    
    BOOL shouldShowDoneButton;
    
    id <PPRWebViewControllerDelegate> delegate;
}

@property (nonatomic, retain) NSURL *url;

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL shouldShowDoneButton;

@property (nonatomic, assign) id <PPRWebViewControllerDelegate> delegate;

@end

// START:PPRWebViewControllerDelegate
@protocol PPRWebViewControllerDelegate <NSObject>
@optional
    - (void)webControllerDidFinishLoading:(PPRWebViewController *)controller;

    - (void)webController:(PPRWebViewController *)controller 
     didFailLoadWithError:(NSError *)error;

    - (void)webController:(PPRWebViewController *)controller
shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;
@end
// END:PPRWebViewControllerDelegate