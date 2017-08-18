//
//  MDLRuntimeUtil.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/16.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "MDLRuntimeUtil.h"

@implementation MDLRuntimeUtil

+ (objc_property_t)getPropertyForClass:(Class)klass propertyName:(NSString *)propertyName {
    objc_property_t property = class_getProperty(klass, (const char *)[propertyName UTF8String]);
    if (property == NULL) {
        @throw [NSException exceptionWithName:@"MDLRuntimeException" reason:[NSString stringWithFormat:@"Unable to find property declaration: '%@' for class '%@'", propertyName, NSStringFromClass(klass)] userInfo:nil];
    }
    return property;
}

+ (NSString *)getClassOrProtocolForProperty:(objc_property_t)property {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            if (strlen(attribute) <= 4) {
                break;
            }
            return [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
        }
    }
    return nil;
}

@end
