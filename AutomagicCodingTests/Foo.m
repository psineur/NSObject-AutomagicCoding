//
//  Foo.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Foo.h"
#import "NSObject+AutomagicCoding.h"

@implementation Foo

@synthesize integerValue = _integerValue;
@synthesize publicBar = _publicBar;

+ (BOOL) isAutomagicCodingEnabled
{
    return YES;
}

- (id)initWithDictionaryRepresentation: (NSDictionary *) aDict
{
    self = [super initWithDictionaryRepresentation: aDict];
    if (self) {
        [_publicBar retain];
    }
    
    return self;
}

- (AMCObjectFieldType) fieldTypeForValueWithKey: (NSString *) aKey
{
    if ([aKey isEqualToString:@"privateBar"])
    {
        return kAMCObjectFieldTypeCustom;
    }
    
    return [super fieldTypeForValueWithKey: aKey];
}

- (NSArray *) keysForValuesInDictionaryRepresentation
{
    NSArray *array = [super keysForValuesInDictionaryRepresentation];
    return [array arrayByAddingObject:@"privateBar"];
}

- (void) dealloc
{
    [_publicBar release]; 
    _publicBar = nil;
    
    [super dealloc];
}

- (BOOL) isEqual:(id)object
{
    if ([object isMemberOfClass:[self class]])
    {
        Foo *other = (Foo *)object;
        if(self.integerValue == other.integerValue)
        {
            BOOL equal = YES;
            
            if (self.publicBar != other.publicBar)
            {
                if (![self.publicBar isEqual: other.publicBar])
                    equal = NO;
            }
            
            if ( _privateBar != [other valueForKey: @"privateBar" ])
            {
                if (![_privateBar isEqual:  [other valueForKey: @"privateBar" ]])
                    equal = NO;
            }
                
            
            return equal;
        }
        
        return NO;
    }
    
    return [super isEqual: object];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ integerValue={%d}, publicBar = %@, pribateBar = %@",
            [self class], 
            self.integerValue,
            self.publicBar,
            _privateBar ];
}

@end
