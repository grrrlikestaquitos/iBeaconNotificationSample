//
//  AppDelegate.m
//  ibeacon
//
//  Created by Troyan on 12/27/16.
//  Copyright © 2016 Troyan. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate{
    NSTimer * updateTimer;
    UIBackgroundTaskIdentifier myBackgroundTask;
    NSDecimalNumber * previous;
    NSDecimalNumber * current;
    NSUInteger position;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    myBackgroundTask = UIBackgroundTaskInvalid;
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
      //  NSLog(@"applicationDidEnterBackground");
 //   [self startBackgroundTasks];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  //  [self stopBackgroundTasks];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - background task

-(void)startBackgroundTask{
    [self resetCalculation];
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(calculateNextNumber)
                                                userInfo:nil
                                                 repeats:true];
    [self registerBackgroundTask];
}

-(void)stopBackgroundTask{
    [updateTimer invalidate];
    updateTimer = nil;

    if (myBackgroundTask != UIBackgroundTaskInvalid) {
        [self endBackgroundTask];
    }
}

-(void)resetCalculation{
    previous = NSDecimalNumber.one;
    current = NSDecimalNumber.one;
    position = 1;

}

-(void)calculateNextNumber{

    NSLog(@"backgroundTimeRemaining %f ", [[UIApplication sharedApplication] backgroundTimeRemaining]);
   NSDecimalNumber * number =  [current decimalNumberByAdding:previous];
    NSDecimalNumber * bigNumber = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                    exponent:40
                                                                  isNegative:false];
    if ([number compare:bigNumber] == NSOrderedAscending) {
        previous = current;
        current = number;
        position+=1;
    } else {
        [self resetCalculation];
    }

}
-(void)registerBackgroundTask{
    myBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];

}

-(void)endBackgroundTask{
    [UIApplication.sharedApplication endBackgroundTask:myBackgroundTask];
    myBackgroundTask = UIBackgroundTaskInvalid ;

}


@end
