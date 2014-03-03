//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol TestBaseProtocol <NSObject>

- (void)testBaseRequiredMethod;

@optional

- (void)testBaseOptionalMethod;

@end
