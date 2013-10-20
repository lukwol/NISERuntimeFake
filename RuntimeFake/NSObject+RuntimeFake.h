//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RuntimeFake)

+ (id)fake;

+ (id)fakeDelegate:(Protocol *)protocol withOptionalMethods:(BOOL)optional;

- (void)overrideInstanceMethod:(SEL)selector withImplementation:(id)block;

@end
