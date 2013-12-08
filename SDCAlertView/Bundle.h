//
//  Bundle.h
//  SDCAlertView
//
//  Created by Luke Stringer on 01/12/2013.
//  Copyright (c) 2013 Luke Stringer. All rights reserved.
//

#ifndef SDCAlertView_Bundle_h
#define SDCAlertView_Bundle_h

// Helper function to see if current bundle is the injected test bundle
extern BOOL isRunningFromTestBundle(void) {
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return ([[injectBundle pathExtension] isEqualToString:@"octest"] || [[injectBundle pathExtension] isEqualToString:@"xctest"]);
}


#endif
