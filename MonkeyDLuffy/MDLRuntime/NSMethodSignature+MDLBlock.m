//
//  NSMethodSignature+MDLBlock.m
//  MonkeyDLuffy
//
//  Created by Duanww on 2017/8/11.
//  Copyright © 2017年 Duanww. All rights reserved.
//

#import "NSMethodSignature+MDLBlock.h"

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;     // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        // void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        // void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        // const char *signature;                         // IFF (1<<30)
        void* rest[1];
    } *descriptor;
    // imported variables
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

static const char *__BlockSignature__(id blockObj) {
    struct Block_literal_1 *block = (__bridge void *)blockObj;
    struct Block_descriptor_1 *descriptor = block->descriptor;
    assert(block->flags & BLOCK_HAS_SIGNATURE);
    int offset = 0;
    if(block->flags & BLOCK_HAS_COPY_DISPOSE)
        offset += 2;
    return (char*)(descriptor->rest[offset]);
}

@implementation NSMethodSignature (MDLBlock)

+ (instancetype)mdlblock_methodSignatureWithBlock:(id)block {
    return [NSMethodSignature signatureWithObjCTypes:__BlockSignature__(block)];
}

@end
