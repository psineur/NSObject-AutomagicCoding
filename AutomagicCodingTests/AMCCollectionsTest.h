//
//  AMCCollectionsTest.h
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FooWithCollections.h"
#import "AMCTest.h"

@interface AMCCollectionsTest : AMCTest
{
    FooWithCollections *_fooWithCollections;
}

@property(readwrite, retain) FooWithCollections *fooWithCollections;

@end
