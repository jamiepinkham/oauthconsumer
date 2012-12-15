//
//  PPRWebViewController.m
//
//  Created by Matt Drance on 6/30/10.
//  Copyright 2010 Bookhouse. All rights reserved.
//

#import "PPRWebViewController.h"

NSString *const PPRWebViewControllerFadeIn  = @"PPRWebViewControllerFadeIn";

const float PPRWebViewControllerFadeDuration = 0.5;

@interface PPRWebViewController ()

- (void)fadeWebViewIn;
- (void)resetBackgroundColor;

@end

@implementation PPRWebViewController

@synthesize url;

@synthesize backgroundColor;
@synthesize webView;
@synthesize activityIndicator;

@synthesize shouldShowDoneButton;

@synthesize delegate;

- (void)dealloc {
    [url release], url = nil;
    [backgroundColor release], backgroundColor = nil;
    [webView stopLoading], webView.delegate = nil, [webView release], webView = nil;
    [activityIndicator release], activityIndicator = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.backgroundColor = nil;
    self.webView = nil;
    self.activityIndicator = nil;
}

- (void)loadView {
    UIViewAutoresizing resizeAllMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectZero];
    mainView.autoresizingMask = resizeAllMask;
    self.view = mainView;
    [mainView release];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = resizeAllMask;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // START:ViewCentering
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleBottomMargin |
                                            UIViewAutoresizingFlexibleLeftMargin;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.bounds), 
                                                CGRectGetMidY(self.view.bounds));
    // END:ViewCentering
    [self.view addSubview:activityIndicator];
}

- (void)viewDidLoad {
    [self resetBackgroundColor];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    self.webView.alpha = 0.0;
    
    [self.activityIndicator startAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL shouldRotate = YES;
    
    if ([self.delegate respondsToSelector:@selector(webController:shouldAutorotateToInterfaceOrientation:)]) {
        [self.delegate webController:self shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    return shouldRotate;
}

#pragma mark -
#pragma mark Actions
- (void)doneButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)fadeWebViewIn {
    [UIView beginAnimations:PPRWebViewControllerFadeIn context:nil];
    [UIView setAnimationDuration:PPRWebViewControllerFadeDuration];
    self.webView.alpha = 1.0;
    [UIView commitAnimations];    
}

#pragma mark -
#pragma mark Accessor overrides

// START:ShowDoneButton
- (void)setShouldShowDoneButton:(BOOL)shows {
    if (shouldShowDoneButton != shows) {
        [self willChangeValueForKey:@"showsDoneButton"];
        shouldShowDoneButton = shows;
        [self didChangeValueForKey:@"showsDoneButton"];
        if (shouldShowDoneButton) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)] autorelease];
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}
// END:ShowDoneButton

// START:SetBGColor
- (void)setBackgroundColor:(UIColor *)color {
    if (backgroundColor != color) {
        [self willChangeValueForKey:@"backgroundColor"];
        [backgroundColor release];
        backgroundColor = [color retain];
        [self didChangeValueForKey:@"backgroundColor"];
        [self resetBackgroundColor];
    }
}
// END:SetBGColor

// START:ResetBG
- (void)resetBackgroundColor {
    if ([self isViewLoaded]) {
        UIColor *bgColor = self.backgroundColor;
        if (bgColor == nil) {
            bgColor = [UIColor whiteColor];
        }
        self.view.backgroundColor = bgColor;
    }
}
// END:ResetBG

#pragma mark -
#pragma mark UIWebViewDelegate
// START:WebLoaded
- (void)webViewDidFinishLoad:(UIWebView *)wv {
    [self.activityIndicator stopAnimating];
    [self fadeWebViewIn];
    NSString *docTitle = [self.webView 
                        stringByEvaluatingJavaScriptFromString:@"document.title;"];
    if ([docTitle length] > 0) {
        self.navigationItem.title = docTitle;
    }
}
// END:WebLoaded

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    if ([self.delegate respondsToSelector:@selector(webController:didFailLoadWithError:)]) {
        [self.delegate webController:self didFailLoadWithError:error];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Failed"
                                                        message:@"The web page failed to load."
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

@end