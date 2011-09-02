//
//  AMCTestSimple.h
//  AutomagicCodingTests
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AMCTest.h"

@class Foo;
@interface AutomagicCodingTests : AMCTest
{
    Foo *_foo;
}
@property(readwrite, retain) Foo *foo;

@end
