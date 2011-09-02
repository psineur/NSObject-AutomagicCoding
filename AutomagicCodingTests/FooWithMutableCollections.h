//
//  FooWithMutableCollections.h
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @class FooWithMutableCollections Almost like FooWithCollections, but ivars & properties are mutable.
 * You must use NSMutableArray instead of NSArray in order to AMC work properly.
 * NSObject(AutoMagicCoding)#fieldTypeForValueWithKey: uses property type to get class 
 * and ask it about is it mutable or not.
 */
@interface FooWithMutableCollections : NSObject
{
    NSMutableArray *_array;
    NSMutableDictionary *_dict;
}

@property(readwrite, retain) NSMutableArray *array;
@property(readwrite, retain) NSMutableDictionary *dict;

@end
