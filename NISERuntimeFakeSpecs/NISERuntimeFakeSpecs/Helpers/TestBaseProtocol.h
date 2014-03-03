/*
 * Copyright 2014 Taptera Inc. All rights reserved.
 */


#import <Foundation/Foundation.h>

@protocol TestBaseProtocol <NSObject>

-(void)testBaseRequiredMethod;

@optional

- (void)testBaseOptionalMethod;

@end
