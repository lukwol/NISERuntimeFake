//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NISERuntimeFake)

+ (id)fake;

+ (Class)fakeClass;

+ (id)fakeObjectWithProtocol:(Protocol *)protocol optionalMethods:(BOOL)optional;

- (void)overrideInstanceMethod:(SEL)selector withImplementation:(id)block;

@end
