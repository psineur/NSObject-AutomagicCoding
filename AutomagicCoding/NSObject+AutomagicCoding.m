//
//  NSObject+AutomagicCoding.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+AutomagicCoding.h"

@implementation NSObject (AutomagicCoding)

#pragma mark Decode/Create/Init

+ (id) objectWithDictionaryRepresentation: (NSDictionary *) aDict
{
    NSString *className = [aDict objectForKey: @"class"];
    if( ![className isKindOfClass:[NSString class]] )
        return nil;
    
    Class rClass = NSClassFromString(className);
    return [[[rClass alloc] initWithDictionaryRepresentation: aDict] autorelease];
}

- (id) initWithDictionaryRepresentation: (NSDictionary *) aDict
{
    if ( (self =  [self init]) )
    {
        NSArray *keysForValues = [self keysForValuesInDictionaryRepresentation];
        for (NSString *key in keysForValues)
        {
            id value = [aDict valueForKey: key];
            
            // Object as it's representation - create new.
            if ([self isObjectValueForKey: key ])
            {
                NSDictionary *objectDict = (NSDictionary *) objectDict;
                value = [NSObject objectWithDictionaryRepresentation: objectDict];
            }
            
            // Scalar or struct - simply use KVC.                       
            [self setValue:value forKey: key];
        }
        
    }
    return self;
}

#pragma mark Encode/Save

- (NSDictionary *) dictionaryRepresentation
{
    NSArray *keysForValues = [self keysForValuesInDictionaryRepresentation];
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithCapacity:[keysForValues count]];
       
    for (NSString *key in keysForValues)
    {
        id value = [self valueForKey: key];
        
        // Save object as it's dictionary representatin if needed.
        if ([self isObjectValueForKey: key ])
        {
            value = [(NSObject *) value dictionaryRepresentation];
        }
        
        // Scalar or struct - simply use KVC.                       
        [aDict setValue:value forKey: key];
    }
    
    return aDict;
}


#pragma Info for Serialization

- (NSArray *) keysForValuesInDictionaryRepresentation
{
    //TODO: use objc runtime to get all properties and return their names.
}

- (BOOL) isObjectValueForKey: (NSString *) aKey
{
    //TODO: use objc runtime to get all properties and return their names if their type is ObjC.
}

@end
