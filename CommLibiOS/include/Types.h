//
//  Types.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/15/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Types : NSObject {
	NSMutableDictionary	*abstractMappings;
	NSMutableDictionary	*clientMappings;
	NSMutableDictionary	*serverMappings;
}

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(Types *)sharedInstance;
// type mapping
-(void)addAbstractClassMapping:(Class)abstractType mapped:(Class)mappedType;
-(Class)getAbstractClassMapping:(Class)type;
-(void)addClientClassMapping:(NSString *)clientClass mapped:(Class)mappedServerType;
-(Class)getServerTypeForClientClass:(NSString *)clientClass;
-(NSString *)getClientClassForServerType:(NSString *)serverClassName;
// type reflection
+(NSString *)objectClassName:(id)obj;
+(NSString *)typeClassName:(Class)type;
+(id)classInstance:(Class)type;
+(Class)classByName:(NSString *)className;
+(id)classInstanceByClassName:(NSString *)className;
+(BOOL)isAssignableFrom:(Class)type toObject:(id)obj;
+(NSArray *)propertyKeys:(id)obj;
+(NSArray *)propertyAttributes:(id)obj;
+(NSDictionary *)propertyKeysWithAttributes:(id)obj;
+(NSDictionary *)propertyDictionary:(id)obj;
@end
