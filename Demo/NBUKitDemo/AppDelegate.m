//
//  AppDelegate.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 12/07/24.
//  Copyright (c) 2012 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    NBUSplashView * _splashView;
}
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure NBULog
#ifdef PRODUCTION
    [NBULog setAppLogLevel:LOG_LEVEL_WARN];
    [NBULog setKitLogLevel:LOG_LEVEL_WARN];
#else
    [NBULog setAppLogLevel:LOG_LEVEL_VERBOSE];  // Also verbose for debug and testing builds
    [NBULog setKitLogLevel:LOG_LEVEL_INFO];
    [NBULog setKitLogLevel:LOG_LEVEL_VERBOSE forModule:NBUKIT_MODULE_IMAGE];
    [NBULog addDashboardLogger];                // Add log dashboard
#endif

    NBULogTrace();
    
    // Prepare window
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UITabBarController * rootController = [[NSBundle mainBundle] loadNibNamed:@"MainController"
                                                                        owner:self
                                                                      options:nil][0];
    rootController.customizableViewControllers = nil;
    _window.rootViewController = rootController;
    [_window makeKeyAndVisible];
    
    // Start splash screen
    _splashView = [NSBundle loadNibNamed:@"NBUSplashView"
                                   owner:nil
                                 options:nil][0];
    [_splashView startWithStatus:@"Launching..."
                          window:_window];
    
    // Async launch tasks
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // *** Do some real work here ***
        
        [self mockLaunchTasks];
    });
    
    return YES;
}

- (void)mockLaunchTasks
{
    // Mock 10 tasks
    for (NSUInteger i = 1; i <= 10; i++)
    {
        // Using GCD to mock updates
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, i * 0.20 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           // Update splash view
                           [_splashView updateProgress:i * 0.1
                                            withStatus:[NSString stringWithFormat:@"Finished task %d of 10", i]];
                           
                           // Finish splash view
                           if (i == 10)
                           {
                               [_splashView finishWithStatus:@"Finished!"
                                                    animated:YES];
                               _splashView = nil;
                           }
                       });
    }
}

@end

