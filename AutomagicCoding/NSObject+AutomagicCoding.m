//
//  NSObject+AutomagicCoding.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+AutomagicCoding.h"
#import "objc/runtime.h"

#define NSOBJECT_AUTOMAGICCODING_CLASSNAMEKEY @"class"

@implementation NSObject (AutomagicCoding)

+ (BOOL) isAutomagicCodingEnabled
{
    return NO;
}

#pragma mark Decode/Create/Init

+ (id) objectWithDictionaryRepresentation: (NSDictionary *) aDict
{
    if (![aDict isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *className = [aDict objectForKey: NSOBJECT_AUTOMAGICCODING_CLASSNAMEKEY];
    if( ![className isKindOfClass:[NSString class]] )
        return nil;
    
    Class rClass = NSClassFromString(className);
    if ( rClass && [rClass instancesRespondToSelector:@selector(initWithDictionaryRepresentation:) ] )
    {
        id instance = [[[rClass alloc] initWithDictionaryRepresentation: aDict] autorelease];
        return instance;
    }
    
    return nil;
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
                NSDictionary *objectDict = (NSDictionary *) value;
                id object = [NSObject objectWithDictionaryRepresentation: objectDict];
                if (object)
                    value = object;
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
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithCapacity:[keysForValues count] + 1];
       
    for (NSString *key in keysForValues)
    {
        id value = [self valueForKey: key];
        
        // Save object as it's dictionary representatin if needed & possible.
        if ([self isObjectValueForKey: key ])
        {
            if ([value respondsToSelector:@selector(dictionaryRepresentation)])
                value = [(NSObject *) value dictionaryRepresentation];
        }
        
        // Scalar or struct - simply use KVC.                       
        [aDict setValue:value forKey: key];
    }
    
    [aDict setValue:[self className] forKey: NSOBJECT_AUTOMAGICCODING_CLASSNAMEKEY];
    
    return aDict;
}


#pragma Info for Serialization

- (NSArray *) keysForValuesInDictionaryRepresentation
{
    id class = [self class];
    
    // Use objc runtime to get all properties and return their names.
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: outCount];
    for (int i = 0; i < outCount; ++i)
    {
        objc_property_t curProperty = properties[i];
        const char *name = property_getName(curProperty);
        
        NSString *propertyKey = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        [array addObject: propertyKey];        
    }
    
    return array;
}

- (BOOL) isObjectValueForKey: (NSString *) aKey
{    
    objc_property_t property = class_getProperty([self class], [aKey cStringUsingEncoding:NSUTF8StringEncoding]);
    if (property)
    {
        const char *attributes = property_getAttributes(property);
        char *classNameCString = strstr(attributes, "@\"");
        if ( classNameCString )
        {
            classNameCString += 2; //< skip @" substring
            NSString *classNameString = [NSString stringWithCString:classNameCString encoding:NSUTF8StringEncoding];
            NSRange range = [classNameString rangeOfString:@"\""];
            
            classNameString = [classNameString substringToIndex: range.location];
            
            id class = NSClassFromString(classNameString);
            if ([class isAutomagicCodingEnabled])
                return YES;
        }
    }
    
    return NO;
}

@end
