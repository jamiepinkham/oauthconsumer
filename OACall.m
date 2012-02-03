//
//  OACall.m
//  OAuthConsumer
//
//  Created by Alberto García Hierro on 04/09/08.
//  Copyright 2008 Alberto García Hierro. All rights reserved.
//	bynotes.com

#import "OAConsumer.h"
#import "OAToken.h"
#import "OAProblem.h"
#import "OADataFetcher.h"
#import "OAServiceTicket.h"
#import "OAMutableURLRequest.h"
#import "OACall.h"

@interface OACall (){
	NSURL *url;
	NSString *method;
	NSArray *parameters;
	NSDictionary *files;
//	OADataFetcher *fetcher;
//	OAMutableURLRequest *request;
//	OAServiceTicket *ticket;
}

/*- (void)callFinished:(OAServiceTicket *)ticket withData:(NSData *)data;
- (void)callFailed:(OAServiceTicket *)ticket withError:(NSError *)error;*/

@property (nonatomic, copy) OACallCompletionBlock completionBlock;

@end

@implementation OACall

@synthesize url, method, parameters, files, completionBlock;

- (id)init {
	return [self initWithURL:nil
					  method:nil
				  parameters:nil
					   files:nil];
}

- (id)initWithURL:(NSURL *)aURL {
	return [self initWithURL:aURL
					  method:nil
				  parameters:nil
					   files:nil];
}

- (id)initWithURL:(NSURL *)aURL method:(NSString *)aMethod {
	return [self initWithURL:aURL
					  method:aMethod
				  parameters:nil
					   files:nil];
}

- (id)initWithURL:(NSURL *)aURL parameters:(NSArray *)theParameters {
	return [self initWithURL:aURL
					  method:nil
				  parameters:theParameters];
}

- (id)initWithURL:(NSURL *)aURL method:(NSString *)aMethod parameters:(NSArray *)theParameters {
	return [self initWithURL:aURL
					  method:aMethod
				  parameters:theParameters
					   files:nil];
}

- (id)initWithURL:(NSURL *)aURL parameters:(NSArray *)theParameters files:(NSDictionary*)theFiles {
	return [self initWithURL:aURL
					  method:@"POST"
				  parameters:theParameters
					   files:theFiles];
}

- (id)initWithURL:(NSURL *)aURL
		   method:(NSString *)aMethod
	   parameters:(NSArray *)theParameters
			files:(NSDictionary*)theFiles {
	if ((self = [super init])) {
		url = [aURL retain];
		method = [aMethod retain];
		parameters = [theParameters retain];
		files = [theFiles retain];
//		fetcher = nil;
//		request = nil;
	}
	
	return self;
}

- (void)dealloc {
	[url release];
	[method release];
	[parameters release];
	[files release];
//	[fetcher release];
//	[request release];
//	[ticket release];
	[super dealloc];
}

//- (void)callFailed:(OAServiceTicket *)aTicket withError:(NSError *)error {
//	NSLog(@"error body: %@", aTicket.body);
//	self.ticket = aTicket;
//	[aTicket release];
//	OAProblem *problem = [OAProblem problemWithResponseBody:ticket.body];
//	if (problem) {
//		[delegate call:self failedWithProblem:problem];
//	} else {
//		[delegate call:self failedWithError:error];
//	}
//}
//
//- (void)callFinished:(OAServiceTicket *)aTicket withData:(NSData *)data {
//	self.ticket = aTicket;
//	[aTicket release];
//	if (ticket.didSucceed) {
////		NSLog(@"Call body: %@", ticket.body);
//		[delegate performSelector:finishedSelector withObject:self withObject:ticket.body];
//	} else {
////		NSLog(@"Failed call body: %@", ticket.body);
//		[self callFailed:[ticket retain] withError:nil];
//	}
//}

//- (void)perform:(OAConsumer *)consumer
//		  token:(OAToken *)token
//		  realm:(NSString *)realm
//	   delegate:(NSObject <OACallDelegate> *)aDelegate
//	didFinish:(SEL)finished
//
//{
//	delegate = aDelegate;
//	finishedSelector = finished;
//
//	request = [[OAMutableURLRequest alloc] initWithURL:url
//											  consumer:consumer
//												token:token
//												 realm:realm
//									 signatureProvider:nil];
//	if(method) {
//		[request setHTTPMethod:method];
//	}
//
//	if (self.parameters) {
//		[request setParameters:self.parameters];
//	}
////	if (self.files) {
////		for (NSString *key in self.files) {
////			[request attachFileWithName:@"file" filename:NSLocalizedString(@"Photo.jpg", @"") data:[self.files objectForKey:key]];
////		}
////	}
//	fetcher = [[OADataFetcher alloc] init];
//	[fetcher fetchDataWithRequest:request
//						 delegate:self
//				didFinishSelector:@selector(callFinished:withData:)
//				  didFailSelector:@selector(callFailed:withError:)];
//}

- (void)perform:(OAConsumer *)consumer token:(OAToken *)token realm:(NSString *)realm completionBlock:(OACallCompletionBlock)completion{
//    self.completionBlock = completion;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
											  consumer:consumer
                                                 token:token
												 realm:realm
									 signatureProvider:nil];
	if(method) {
		[request setHTTPMethod:method];
	}
    
	if (self.parameters) {
		[request setParameters:self.parameters];
	}
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request completionBlock:^(OAServiceTicket *ticket, NSData *data, NSError *error) {
        OAProblem *problem = nil;
        if(error){
            problem = [OAProblem problemWithResponseBody:ticket.body];
        }
        completion(ticket.body, error, problem);
    }];
    
    [request release];
    [fetcher release];
    
}

/*- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		return [self isEqualToCall:(OACall *)object];
	}
	return NO;
}

- (BOOL)isEqualToCall:(OACall *)aCall {
	return (delegate == aCall->delegate
			&& finishedSelector == aCall->finishedSelector 
			&& [url isEqualTo:aCall.url]
			&& [method isEqualToString:aCall.method]
			&& [parameters isEqualToArray:aCall.parameters]
			&& [files isEqualToDictionary:aCall.files]);
}*/

@end
