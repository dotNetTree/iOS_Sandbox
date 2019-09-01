//
//  ExceptionCatcher.h
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/08/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
