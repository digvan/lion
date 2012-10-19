//
//  Responder.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 26.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fault : NSObject {
    NSString    *message;
    NSString    *detail;
}
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *detail;

-(id)initWithMessage:(NSString *)_message;
-(id)initWithMessage:(NSString *)_message detail:(NSString *)_detail;
+(id)fault:(NSString *)_message;
+(id)fault:(NSString *)_message detail:(NSString *)_detail;
@end


@interface SubscribeResponse : NSObject {
    id              response;
    NSDictionary    *headers;    
}
@property (nonatomic, readonly) id response;
@property (nonatomic, readonly) NSDictionary *headers;

-(id)initWithResponse:(id)_response;
-(id)initWithResponse:(id)_response heasers:(NSDictionary *)_headers;
+(id)response:(id)_response;
+(id)response:(id)_response heasers:(NSDictionary *)_headers;

@end

@protocol IResponder <NSObject>
-(void)responseHandler:(id)response;
-(void)errorHandler:(Fault *)fault;
@end


@interface Responder : NSObject <IResponder> {
    id  _responder;
    SEL _responseHandler;
    SEL _errorHandler;
}

-(id)initWithResponder:(id)responder selResponseHandler:(SEL)selResponseHandler selErrorHandler:(SEL)selErrorHandler;
+(id)responder:(id)responder selResponseHandler:(SEL)selResponseHandler selErrorHandler:(SEL)selErrorHandler;
@end


@interface SubscribeResponder : Responder 
@end
