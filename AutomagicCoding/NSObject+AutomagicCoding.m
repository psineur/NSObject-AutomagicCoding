//
//  NSObject+AutomagicCoding.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+AutomagicCoding.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#define NSPoint CGPoint
#define NSSize CGSize
#define NSRect CGRect

#define NSPointFromString CGPointFromString
#define NSSizeFromString CGSizeFromString
#define NSRectFromString CGRectFromString

#define pointValue CGPointValue
#define sizeValue CGSizeValue
#define rectValue CGRectValue

#define NSStringFromPoint NSStringFromCGPoint
#define NSStringFromSize NSStringFromCGSize
#define NSStringFromRect NSStringFromCGRect

#endif


#define NSOBJECT_AUTOMAGICCODING_CLASSNAMEKEY @"class"

@interface AMCStructHackishObject : NSObject 
{
    @public
    NSPoint _nsPoint;
    NSSize  _nsSize;
    NSRect  _nsRect;
}
@end

@implementation AMCStructHackishObject  
@end

@implementation NSObject (AutomagicCoding)

+ (BOOL) AMCEnabled
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
        NSArray *keysForValues = [self AMCKeysForDictionaryRepresentation];
        for (NSString *key in keysForValues)
        {
            id value = [aDict valueForKey: key];
            
            AMCFieldType fieldType = [self AMCFieldTypeForValueWithKey: key];
            objc_property_t property = class_getProperty([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
            if ( kAMCFieldTypeStructure == fieldType)
            {
                [self AMCSetStructWithName: AMCPropertyStructName(property) decodedFromString: (NSString *)value forKey: key];
            }
            else
            {
                id class = AMCPropertyClass(property);
                value = AMCDecodeObject(value, fieldType, class);
                [self setValue:value forKey: key];
            }
        }
        
    }
    return self;
}

#pragma mark Encode/Save

- (id) AMCEncodeFieldWithKey: (NSString *) aKey
{
    id value = [self valueForKey: aKey];
    
    AMCFieldType fieldType = [self AMCFieldTypeForValueWithKey: aKey]; 
    
    if ( kAMCFieldTypeStructure == fieldType)
    {
        objc_property_t property = class_getProperty([self class], [aKey cStringUsingEncoding:NSUTF8StringEncoding]);
        value = [self AMCEncodeStructWithValue: value withName: AMCPropertyStructName(property)];
    }
    else
    {
        value = AMCEncodeObject(value, fieldType);
    }
    
    return value;
}

- (NSDictionary *) dictionaryRepresentation
{
    NSArray *keysForValues = [self AMCKeysForDictionaryRepresentation];
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithCapacity:[keysForValues count] + 1];
       
    for (NSString *key in keysForValues)
    {
        id value = [self AMCEncodeFieldWithKey: key];
        
        // Scalar or struct - simply use KVC.                       
        [aDict setValue:value forKey: key];
    }
    
    [aDict setValue:[self className] forKey: NSOBJECT_AUTOMAGICCODING_CLASSNAMEKEY];
    
    return aDict;
}


#pragma Info for Serialization

- (NSArray *) AMCKeysForDictionaryRepresentation
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

- (AMCFieldType) AMCFieldTypeForValueWithKey: (NSString *) aKey
{
    // isAutomagicCodingEnabled == YES? Then it's custom object.
    objc_property_t property = class_getProperty([self class], [aKey cStringUsingEncoding:NSUTF8StringEncoding]);
    id class = AMCPropertyClass(property);
    
    if ([class AMCEnabled])
        return kAMCFieldTypeCustomObject;
    
    // Is it ordered collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayMutableProtocol) ) )
            return kAMCFieldTypeCollectionArrayMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionArray;
    }
    
    // Is it hash collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashMutableProtocol) ) )
            return kAMCFieldTypeCollectionHashMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionHash;
    }
    
    // Is it a structure?
    NSString *structName = AMCPropertyStructName(property);
    if (structName)
        return kAMCFieldTypeStructure;
    
    // Otherwise - it's a scalar or PLIST-Compatible object (i.e. NSString)
    return kAMCFieldTypeScalar;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (NSString *) className
{
    const char* name = class_getName([self class]);
    
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

+ (NSString *) className
{
    const char* name = class_getName([self class]);
    
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

#endif

#pragma mark Structure Support

- (void) AMCSetStructWithName: (NSString *) structName decodedFromString: (NSString *)value forKey: (NSString *)key
{
    // valueForKey: never returns CGPoint, CGRect, etc - it returns NSPoint, NSRect stored in NSValue instead.
    // This is why here was made no difference between struct names such CGP
    
    AMCStructHackishObject *hackishObject = [AMCStructHackishObject new];
    
    if ([structName isEqualToString:@"CGPoint"])
    {
        NSPoint p = NSPointFromString(value);

        hackishObject->_nsPoint = p;
        
        [self setValue:[hackishObject valueForKey:@"nsPoint"] forKey:key];
    }
    else if ([structName isEqualToString:@"NSPoint"])
    {
        NSPoint p = NSPointFromString(value);
        hackishObject->_nsPoint = p;
        
        [self setValue:[hackishObject valueForKey:@"nsPoint"] forKey:key];
    }
    else if ([structName isEqualToString:@"CGSize"])
    {
        NSSize s = NSSizeFromString(value);
        hackishObject->_nsSize = s;
        
        [self setValue:[hackishObject valueForKey:@"nsSize"] forKey:key];
    }
    else if ([structName isEqualToString:@"NSSize"])
    {
        NSSize s = NSSizeFromString(value);
        hackishObject->_nsSize = s;
        
        [self setValue:[hackishObject valueForKey:@"nsSize"] forKey:key];
    }
    else if ([structName isEqualToString:@"CGRect"])
    {
        NSRect r = NSRectFromString(value);
        hackishObject->_nsRect = r;
        
        [self setValue:[hackishObject valueForKey:@"nsRect"] forKey:key];   
    }
    else if ([structName isEqualToString:@"NSRect"])
    {
        NSRect r = NSRectFromString(value);
        hackishObject->_nsRect = r;
        
        [self setValue:[hackishObject valueForKey:@"nsRect"] forKey:key];
    }
    
    [hackishObject release];
}

- (NSString *) AMCEncodeStructWithValue: (NSValue *) structValue withName: (NSString *) structName
{
    // valueForKey: never returns CGPoint, CGRect, etc - it returns NSPoint, NSRect stored in NSValue instead.
    // This is why here was made no difference between struct names such CGPoint & NSPoint.
    
    if ( [structName isEqualToString:@"CGPoint"] || [structName isEqualToString:@"NSPoint"])
    {
        NSPoint point = [structValue pointValue];
        
        return NSStringFromPoint(point);
    }
    else if ( [structName isEqualToString:@"CGSize"] || [structName isEqualToString:@"NSSize"])
    {
        NSSize size = [structValue sizeValue];
        
        return NSStringFromSize(size);
    }
    else if ( [structName isEqualToString:@"CGRect"] || [structName isEqualToString:@"NSRect"])
    {
        NSRect rect = [structValue rectValue];
        
        return NSStringFromRect(rect);
    }
    
    return nil;
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

NSString *AMCPropertyStructName(objc_property_t property)
{
    if (!property)
        return nil;
    
    const char *attributes = property_getAttributes(property);
    char *structNameCString = strstr(attributes, "T{");
    if ( structNameCString )
    {
        structNameCString += 2; //< skip T{ substring
        NSString *structNameString = [NSString stringWithCString:structNameCString encoding:NSUTF8StringEncoding];
        NSRange range = [structNameString rangeOfString:@"="];
        
        structNameString = [structNameString substringToIndex: range.location];
        
        return structNameString;
    }
    
    return nil;
}

BOOL classInstancesRespondsToAllSelectorsInProtocol(id class, Protocol *p )
{
    unsigned int outCount = 0;
    struct objc_method_description *methods = NULL;
    
    methods = protocol_copyMethodDescriptionList( p, YES, YES, &outCount);
    
    for (unsigned int i = 0; i < outCount; ++i)
    {
        SEL selector = methods[i].name;
        if (![class instancesRespondToSelector: selector])
            return NO;
    }
        
    
    return YES;
}

id AMCDecodeObject (id value, AMCFieldType fieldType, id collectionClass )
{
    switch (fieldType) 
    {
            
        // Object as it's representation - create new.
        case kAMCFieldTypeCustomObject:
        {
            id object = [NSObject objectWithDictionaryRepresentation: (NSDictionary *) value];
            
            if (object)
                value = object;
        }
        break;
            
            
        case kAMCFieldTypeCollectionArray:
        case kAMCFieldTypeCollectionArrayMutable:
        {
            // Create temporary array of all objects in collection.
            id <AMCArrayProtocol> srcCollection = (id <AMCArrayProtocol> ) value;
            NSMutableArray *dstCollection = [NSMutableArray arrayWithCapacity:[srcCollection count]];
            for (unsigned int i = 0; i < [srcCollection count]; ++i)
            {
                id curEncodedObjectInCollection = [srcCollection objectAtIndex: i];
                id curDecodedObjectInCollection = AMCDecodeObject( curEncodedObjectInCollection, AMCFieldTypeForEncodedObject(curEncodedObjectInCollection), nil );
                [dstCollection addObject: curDecodedObjectInCollection];
            }
            
            // Get Collection Array Class from property and create object
            id class = collectionClass;
            if (!collectionClass)
            {
                if (kAMCFieldTypeCollectionArray)
                    class = [NSArray class];
                else
                    class = [NSMutableArray class];
            }
            
            id <AMCArrayProtocol> object = (id <AMCArrayProtocol> )[class alloc];
            object = [object initWithArray: dstCollection];
            
            if (object)
                value = object;
        }
            break;
            
        case kAMCFieldTypeCollectionHash:
        case kAMCFieldTypeCollectionHashMutable:
        {
            // Create temporary array of all objects in collection.
            NSObject <AMCHashProtocol> *srcCollection = (NSObject <AMCHashProtocol> *) value;
            NSMutableDictionary *dstCollection = [NSMutableDictionary dictionaryWithCapacity:[srcCollection count]];
            for (NSString *curKey in [srcCollection allKeys])
            {
                id curEncodedObjectInCollection = [srcCollection valueForKey: curKey];
                id curDecodedObjectInCollection = AMCDecodeObject( curEncodedObjectInCollection, AMCFieldTypeForEncodedObject(curEncodedObjectInCollection), nil );
                [dstCollection setObject: curDecodedObjectInCollection forKey: curKey];
            }
            
            // Get Collection Array Class from property and create object
            id class = collectionClass;
            if (!collectionClass)
            {
                if (kAMCFieldTypeCollectionArray)
                    class = [NSDictionary class];
                else
                    class = [NSMutableDictionary class];
            }
            
            id <AMCHashProtocol> object = (id <AMCHashProtocol> )[class alloc];
            object = [object initWithDictionary: dstCollection];
            
            if (object)
                value = object;
        }            break;     
            
            // Scalar or struct - simply use KVC.
        case kAMCFieldTypeScalar:
            break;                    
        default:
            break;
    }
    
    return value;
}

id AMCEncodeObject (id value, AMCFieldType fieldType)
{
    switch (fieldType) 
    {
            
        // Object as it's representation - create new.
        case kAMCFieldTypeCustomObject:
        {
            if ([value respondsToSelector:@selector(dictionaryRepresentation)])
                value = [(NSObject *) value dictionaryRepresentation];
        }
        break;
            
        case kAMCFieldTypeCollectionArray:
        case kAMCFieldTypeCollectionArrayMutable:
        {
            
            id <AMCArrayProtocol> collection = (id <AMCArrayProtocol> )value;
            NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity: [collection count]];
            
            for (unsigned int i = 0; i < [collection count]; ++i)
            {
                NSObject *curObjectInCollection = [collection objectAtIndex: i];
                NSObject *curObjectInCollectionEncoded = AMCEncodeObject (curObjectInCollection, AMCFieldTypeForObjectToEncode(curObjectInCollection) );
                
                [tmpArray addObject: curObjectInCollectionEncoded];
            }
            
            value = tmpArray;
        }
            break;
            
        case kAMCFieldTypeCollectionHash:
        case kAMCFieldTypeCollectionHashMutable:
        {
            NSObject <AMCHashProtocol> *collection = (NSObject <AMCHashProtocol> *)value;
            NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity: [collection count]];
            
            for (NSString *curKey in [collection allKeys])
            {
                NSObject *curObjectInCollection = [collection valueForKey: curKey];
                NSObject *curObjectInCollectionEncoded = AMCEncodeObject (curObjectInCollection, AMCFieldTypeForObjectToEncode(curObjectInCollection));
                
                [tmpDict setObject:curObjectInCollectionEncoded forKey:curKey];
            }
            
            value = tmpDict;
        }
            break;
            
            
            // Scalar or struct - simply use KVC.
        case kAMCFieldTypeScalar:
            break;                    
        default:
            break;
    }
    
    return value;
}

AMCFieldType AMCFieldTypeForEncodedObject(id object)
{    
    id class = [object class];
    
    // Is it ordered collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayMutableProtocol) ) )
            return kAMCFieldTypeCollectionArrayMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionArray;
    }
    
    // Is it hash collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashProtocol) ) )
    {
        
        // Maybe it's custom object encoded in NSDictionary?
        if ([object respondsToSelector:@selector(objectForKey:)])
        {
            NSString *className = [object objectForKey:NSOBJECT_AUTOMAGICCODING_CLASSNAMEKEY];
            if ([className isKindOfClass:[NSString class]])
            {
                id encodedObjectClass = NSClassFromString(className);
                
                if ([encodedObjectClass AMCEnabled])
                    return kAMCFieldTypeCustomObject;
            }
        }        
        
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashMutableProtocol) ) )
            return kAMCFieldTypeCollectionHashMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionHash;
    }
    
    
    return kAMCFieldTypeScalar;
}



AMCFieldType AMCFieldTypeForObjectToEncode(id object)
{    
    id class = [object class];
    
    // Is it custom object with dictionaryRepresentation support?
    if (([[object class] AMCEnabled]
        && ([object respondsToSelector:@selector(dictionaryRepresentation)]))
        )
    {
        return kAMCFieldTypeCustomObject;
    }
    
    // Is it ordered collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayProtocol) ) )
    {
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCArrayMutableProtocol) ) )
            return kAMCFieldTypeCollectionArrayMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionArray;
    }
    
    // Is it hash collection?
    if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashProtocol) ) )
    {        
        // Mutable?
        if ( classInstancesRespondsToAllSelectorsInProtocol(class, @protocol(AMCHashMutableProtocol) ) )
            return kAMCFieldTypeCollectionHashMutable;
        
        // Not Mutable.
        return kAMCFieldTypeCollectionHash;
    }    
    
    return kAMCFieldTypeScalar;
}





