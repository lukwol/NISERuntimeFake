//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NISERuntimeFake)

+ (id)fake;

+ (id)fakeObjectWithProtocol:(Protocol *)protocol includeOptionalMethods:(BOOL)optional;

- (void)overrideInstanceMethod:(SEL)selector withImplementation:(id)block;

@end
