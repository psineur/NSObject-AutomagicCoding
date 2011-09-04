//
//  FooWithCustomCollection.h
//  AutoMagicCoding-iOS
//
//  Created by Stepan Generalov on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCArray.h"

@interface FooWithCustomCollection : NSObject
{
    CCArray *_array;
}
@property(readwrite, retain) CCArray *array;

@end
