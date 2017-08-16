//
//  ViewController.m
//  ibeacon
//
//  Created by Troyan on 12/27/16.
//  Copyright © 2016 Troyan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Lottie/Lottie.h>

@import CoreLocation;
@import UserNotifications;

@interface ViewController ()<CLLocationManagerDelegate>



@end

@implementation ViewController{
    CLBeaconRegion * _region;
    CLLocationManager * _locMan;
    NSMutableDictionary<NSString *, CLBeacon *> *_beaconDictionary;
    NSTimer * timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LOTAnimationView *animation = [LOTAnimationView animationNamed:@"Beacon2.json"];
    animation.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    animation.center = self.view.center;
    [self.view addSubview: animation];
    [animation setLoopAnimation: true];
    [animation play];

    _locMan=[[CLLocationManager alloc]init];
    _locMan.delegate=self;
    [_locMan requestAlwaysAuthorization];
    _beaconDictionary = [[NSMutableDictionary alloc] init];
    [self startMonitoring];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert  completionHandler:^(BOOL granted, NSError * _Nullable error) {

    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];


    
}

-(void)enterBackground{
    NSLog(@"enterBackground");
    [self startMonitoring];

}
-(void)startMonitoring{

    _region=[[CLBeaconRegion alloc]initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:@"699EBC80-E1F3-11E3-9A0F-0CF3EE3BC012"]  identifier:@"BeaconRegion"];
    _region.notifyOnEntry=YES;
    _region.notifyOnExit=YES;
    _region.notifyEntryStateOnDisplay=YES;

    [_locMan startMonitoringForRegion:_region];
     [_locMan startRangingBeaconsInRegion:_region];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{

    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            manager.allowsBackgroundLocationUpdates = true;
            [self startMonitoring];
            break;
    default:
            break;
    }

}



- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region{
    NSLog(@"didRangeBeacons %lu", (unsigned long)beacons.count);
    NSLog(@"Array of beacons: %@", beacons);
        for (CLBeacon *beacon in beacons) {
            NSString *beaconID = [NSString stringWithFormat:@"%@-%@", beacon.major, beacon.minor];
            NSLog(@"Beacon identified: %@", beaconID);
                if (_beaconDictionary[beaconID]) {
                } else if (!_beaconDictionary[beaconID]) {
                    [self sendLocalNotification:@"Sighted Beacon"
                                        message:[NSString stringWithFormat:@"Beacon ID: %@", beaconID]
                                     identifier:beaconID];
                    _beaconDictionary[beaconID] = beacon;
                }
        }

}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{

    NSLog(@"didDetermineState %@, %li", region.identifier, (long)state);
      [_locMan startRangingBeaconsInRegion:_region];
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region{

    NSLog(@"didEnterRegion %@", region.identifier);
    
    UIApplicationState state =[[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground) {
        AppDelegate * app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [app startBackgroundTask];
    }
    [_locMan startRangingBeaconsInRegion:(CLBeaconRegion*)region];

}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region{

    NSLog(@"didExitRegion %@", region.identifier);
    AppDelegate * app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app startBackgroundTask];

}

-(void)sendLocalNotification:(NSString*)title
                     message:(NSString*)message
                  identifier:(NSString*)identifier{

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];            UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
            objNotificationContent.title = title;
            objNotificationContent.body = message;
            objNotificationContent.sound=[UNNotificationSound defaultSound];
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                                  content:objNotificationContent trigger:trigger];

            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"Local Notification succeeded");
                }
                else {
                    NSLog(@"Local Notification failed");
                }
            }];


    } else {
        [self showMessage:message
                withTitle:title
                     type:UIAlertControllerStyleAlert
                cancelBtn:@"Ok"];
    }


}

-(void)showMessage:(NSString *)message
         withTitle:(NSString *)title
              type:(UIAlertControllerStyle)type
         cancelBtn:(NSString *)cancelBtn
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:type];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelBtn
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                         }];

    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
