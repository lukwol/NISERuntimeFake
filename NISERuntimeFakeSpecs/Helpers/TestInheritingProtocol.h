//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "TestBaseProtocol.h"

@protocol TestInheritingProtocol <TestBaseProtocol>

- (void)testInheritingRequiredMethod;

@optional

- (void)testInheritingOptionalMethod;

@end
 