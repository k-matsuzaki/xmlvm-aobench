//
//  main.m
//  Untit
//
//  Created by matsuzaki on 12/07/31.
//  Copyright (c) 2012 KITec Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#include "xmlvm.h"
#include "java_lang_Thread.h"

int main(int argc, char *argv[])
{
    xmlvm_init();

    // Initialize the main thread before entering XMLVM_SETJMP
    java_lang_Thread* mainThread = java_lang_Thread_currentThread__();

    if (XMLVM_SETJMP(xmlvm_exception_env_main_thread)) {
        // Technically, XMLVM_UNWIND_EXCEPTION() should be called, but
        // exceptions will not be used anymore and XMLVM_ENTER_METHOD() wasn't
        // called (excessive), so a compilation error would occur
        xmlvm_unhandled_exception();
    } else {
      @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
      }
    }
    xmlvm_destroy(mainThread);
}
