//
//  TwitterAuthWebViewController.m
//  Rexly
//
//  Created by Jamie Pinkham on 8/18/11.
//  Copyright 2011 Rexly. All rights reserved.
//

#import "OAuthWebViewController.h"

@interface OAuthWebViewController()
- (void)resetBackgroundColor;
@property (nonatomic, retain) OAConsumer *consumer;
@end

@implementation OAuthWebViewController

@synthesize callbackURL, requestTokenURL, authorizeTokenURL, accessTokenURL, backgroundColor, webView, activityIndicator, delegate, shouldShowDoneButton, consumer;

- (void)dealloc{
    [callbackURL release];
    [authorizeTokenURL release];
    [requestTokenURL release];
    [accessTokenURL release];
    [backgroundColor release];
    [webView stopLoading], 
    webView.delegate = nil; 
    [webView release];
    [activityIndicator release];
    [consumer release];
    [super dealloc];
}


- (id)initWithOAConsumer:(OAConsumer *)inConsumer requestTokenURL:(NSURL *)inRequestTokenURL authorizeTokenURL:(NSURL *)inAuthorizeTokenURL accessTokenURL:(NSURL *)inAccessTokenURL callbackURL:(NSURL *)inURL delegate:(id<OAuthWebViewControllerDelegate>)inDelegate{
    self = [super init];
    if(self){
        self.requestTokenURL = inRequestTokenURL;
        self.authorizeTokenURL = inAuthorizeTokenURL;
        self.accessTokenURL = inAccessTokenURL;
        self.callbackURL = inURL;
        self.delegate = inDelegate;
        self.consumer = inConsumer;
        self.shouldShowDoneButton = YES;
    } 
    return self;
}
- (id)initWithConsumerKey:(NSString *)inKey secret:(NSString *)inSecret requestTokenURL:(NSURL *)inRequestTokenURL authorizeTokenURL:(NSURL *)inAuthorizeTokenURL accessTokenURL:(NSURL *)inAccessTokenURL callbackURL:(NSURL *)inURL delegate:(id<OAuthWebViewControllerDelegate>)inDelegate{
    OAConsumer *aConsumer = [[[OAConsumer alloc] initWithKey:inKey secret:inSecret] autorelease];
    return [self initWithOAConsumer:aConsumer requestTokenURL:inRequestTokenURL authorizeTokenURL:inAuthorizeTokenURL accessTokenURL:inAccessTokenURL callbackURL:inURL delegate:inDelegate];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if([[[request URL] scheme] isEqualToString:[self.callbackURL scheme]]){
        NSLog(@"query = %@", [[request URL] query]);
        OAToken *token = [[[OAToken alloc] initWithHTTPResponseBody:[[request URL] query]] autorelease];
        if(token.secret){
            if([self.delegate respondsToSelector:@selector(oAuthWebViewController:didAuthorizeWithToken:)]){
                [self.delegate oAuthWebViewController:self didAuthorizeWithToken:token];
            }
        }else{
            OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.accessTokenURL consumer:self.consumer token:token realm:nil signatureProvider:nil];
            [request setHTTPMethod:@"POST"];
            
            OARequestParameter *parameter = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[self.callbackURL absoluteString]];
            [request setParameters:[NSArray arrayWithObject:parameter]];
            [parameter release];
            
            OADataFetcher *fetcher = [[OADataFetcher alloc] init];
            [fetcher fetchDataWithRequest:request completionBlock:^(OAServiceTicket *ticket, NSData *data, NSError *error) {
                NSString *responseBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                if(ticket.didSucceed){
                    OAToken *token = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
                    if(token.secret){
                        if([self.delegate respondsToSelector:@selector(oAuthWebViewController:didAuthorizeWithToken:)]){
                            [self.delegate oAuthWebViewController:self didAuthorizeWithToken:token];
                        }
                    }
                }else{
                    [self.delegate oAuthWebViewController:self didFailToAutorizeWithError:error];
                }
            }];
            
            [fetcher release];
            [request release];
        }
        return NO;
        
    }
    return YES;
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
    self.webView.alpha = 0.0;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.requestTokenURL consumer:self.consumer token:nil realm:nil signatureProvider:nil];
    
    [request setHTTPMethod:@"POST"];
    
    OARequestParameter *parameter = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:[self.callbackURL absoluteString]];
    [request setParameters:[NSArray arrayWithObject:parameter]];
    [parameter release];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request completionBlock:^(OAServiceTicket *ticket, NSData *data, NSError *error) {
        NSString *responseBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        if(ticket.didSucceed){
            OAToken *token = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@",[self.authorizeTokenURL absoluteString], token.key]];
            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }else{
            [self.delegate oAuthWebViewController:self didFailToAutorizeWithError:error];
        }
    }];
    
    [fetcher release];
    [request release];
    
    
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
    [UIView animateWithDuration:0.3 animations:^{
        self.webView.alpha = 1.0;
    }];
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
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)] autorelease];
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
