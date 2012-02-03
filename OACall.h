//
//  OACall.h
//  OAuthConsumer
//
//  Created by Alberto García Hierro on 04/09/08.
//  Copyright 2008 Alberto García Hierro. All rights reserved.
//	bynotes.com

#import <Foundation/Foundation.h>

@class OAProblem;

typedef void (^OACallCompletionBlock)(NSString *responseString, NSError *error, OAProblem *problem);

@class OAConsumer;
@class OAToken;

@interface OACall : NSObject {}

@property(readonly) NSURL *url;
@property(readonly) NSString *method;
@property(readonly) NSArray *parameters;
@property(readonly) NSDictionary *files;


- (id)init;
- (id)initWithURL:(NSURL *)aURL;
- (id)initWithURL:(NSURL *)aURL method:(NSString *)aMethod;
- (id)initWithURL:(NSURL *)aURL parameters:(NSArray *)theParameters;
- (id)initWithURL:(NSURL *)aURL method:(NSString *)aMethod parameters:(NSArray *)theParameters;
- (id)initWithURL:(NSURL *)aURL parameters:(NSArray *)theParameters files:(NSDictionary*)theFiles;

- (id)initWithURL:(NSURL *)aURL
		   method:(NSString *)aMethod
	   parameters:(NSArray *)theParameters
			files:(NSDictionary*)theFiles;

- (void)perform:(OAConsumer *)consumer token:(OAToken *)token realm:(NSString *)realm completionBlock:(OACallCompletionBlock)completion;

@end
