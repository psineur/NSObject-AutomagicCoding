//
//  FooWithMutableCollections.h
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FooWithMutableCollections : NSObject
{
    NSMutableArray *_array;
    NSMutableDictionary *_dict;
}

@property(readwrite, retain) NSMutableArray *array;
@property(readwrite, retain) NSMutableDictionary *dict;

@end
