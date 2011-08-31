//
//  Foo.h
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bar.h"

@interface Foo : NSObject
{
    int _integerValue;
    Bar *_bar;
    
    Bar *_privateBar;
}

@property int integerValue;
@property(retain) Bar *publicBar;

@end
