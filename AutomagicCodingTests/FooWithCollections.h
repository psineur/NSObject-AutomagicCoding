//
//  FooWithCollections.h
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FooWithCollections : NSObject
{
    NSArray *_array;
    NSDictionary *_dict;
}

@property(readwrite, retain) NSArray *array;
@property(readwrite, retain) NSDictionary *dict;

@end
