//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OADataFetcher.h"

@interface OADataFetcher(){
@private
    OAMutableURLRequest *request;
    NSURLResponse *response;
    NSURLConnection *connection;
    NSMutableData *responseData;
}
@property (nonatomic, copy) OADataFetcherCompletionBlock completionBlock;
@property (nonatomic, retain) OAMutableURLRequest *request;
@end


@implementation OADataFetcher

@synthesize completionBlock, request;

- (id)init {
	if ((self = [super init])) {
		responseData = [[NSMutableData alloc] init];
	}
	return self;
}

- (void)dealloc {
	[connection release];
	[response release];
	[responseData release];
	[request release];
	[super dealloc];
}

/* Protocol for async URL loading */
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse {
	[response release];
	response = [aResponse retain];
	[responseData setLength:0];
}
	
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
															  response:response
																  data:responseData
															didSucceed:NO];
    self.completionBlock(ticket, nil, error);
    self.completionBlock = nil;
	[ticket release];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    SecTrustRef trustRef = challenge.protectionSpace.serverTrust;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:trustRef];
    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
															  response:response
																  data:responseData
															didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];

    self.completionBlock(ticket, [[responseData copy] autorelease], nil);
    self.completionBlock = nil;
	[ticket release];
}


- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest completionBlock:(OADataFetcherCompletionBlock)block{
    self.completionBlock = block;
    self.request = aRequest;
    [[self request] prepare];
    dispatch_async(dispatch_get_main_queue(), ^{
        connection = [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
    });
}

@end
