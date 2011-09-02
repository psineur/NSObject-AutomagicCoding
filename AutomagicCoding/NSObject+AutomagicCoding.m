//
//  NSObject+AutomagicCoding.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+AutomagicCoding.h"


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
            
            AMCObjectFieldType fieldType = [self fieldTypeForValueWithKey: key];            
            switch (fieldType) 
            {
                     
                // Object as it's representation - create new.
                case kAMCObjectFieldTypeCustom:
                {
                    id object = [NSObject objectWithDictionaryRepresentation: (NSDictionary *) value];
                
                    if (object)
                        value = object;
                }
                break;
                    
                    
                // Scalar or struct - simply use KVC.
                case kAMCObjectFieldTypeSimple:
                    break;                    
                default:
                    break;
            }            
                                   
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
        
        
        AMCObjectFieldType fieldType = [self fieldTypeForValueWithKey: key];            
        switch (fieldType) 
        {
                
            // Object as it's representation - create new.
            case kAMCObjectFieldTypeCustom:
            {
                if ([value respondsToSelector:@selector(dictionaryRepresentation)])
                    value = [(NSObject *) value dictionaryRepresentation];
            }
            break;
                
                
                // Scalar or struct - simply use KVC.
            case kAMCObjectFieldTypeSimple:
                break;                    
            default:
                break;
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

- (AMCObjectFieldType) fieldTypeForValueWithKey: (NSString *) aKey
{
    // isAutomagicCodingEnabled == YES? Then it's custom object.
    objc_property_t property = class_getProperty([self class], [aKey cStringUsingEncoding:NSUTF8StringEncoding]);
    id class = AMCPropertyClass(property);
    
    if ([class isAutomagicCodingEnabled])
        return kAMCObjectFieldTypeCustom;
    
    // Is it ordered collection?
    if ( ([class instancesRespondToSelector:@selector(count)])
        && ([class instancesRespondToSelector:@selector(objectAtIndex:)])
             && ([class instancesRespondToSelector:@selector(initWithArray:)]) 
        )
    {
        // Mutable or not?
        if ( [class instancesRespondToSelector:@selector(addObject:)] )
            return kAMCObjectFieldTypeCollectionArrayMutable;
        
        return kAMCObjectFieldTypeCollectionArray;
    }
    
    // Is it hash collection?
    if ( ([class instancesRespondToSelector:@selector(count)])
        && ([class instancesRespondToSelector:@selector(allKeys)])
        && ([class instancesRespondToSelector:@selector(initWithDictionary:)]) 
        )
    {
        // Mutable or not?
        if ([class instancesRespondToSelector:@selector(setObject:forKey:)] )
            return kAMCObjectFieldTypeCollectionHashMutable;
        
        return kAMCObjectFieldTypeCollectionHash;
    }
    
    
    return kAMCObjectFieldTypeSimple;
}

@end


#pragma mark Helper Functions

id AMCPropertyClass (objc_property_t property)
{
    if (!property)
        return nil;
    
    const char *attributes = property_getAttributes(property);
    char *classNameCString = strstr(attributes, "@\"");
    if ( classNameCString )
    {
        classNameCString += 2; //< skip @" substring
        NSString *classNameString = [NSString stringWithCString:classNameCString encoding:NSUTF8StringEncoding];
        NSRange range = [classNameString rangeOfString:@"\""];
        
        classNameString = [classNameString substringToIndex: range.location];
        
        id class = NSClassFromString(classNameString);
        return class;
    }
    
    return nil;
}
