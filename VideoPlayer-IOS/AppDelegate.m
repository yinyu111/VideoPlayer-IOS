//
//  AppDelegate.m
//  VideoPlayer-IOS
//
//  Created by 尹玉 on 2024/6/12.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //这行代码创建了一个新的UIWindow对象，并将其设置为self的window属性
    //UIWindow是iOS应用程序的主窗口，它负责显示应用程序的界面。[[UIScreen mainScreen] bounds]获取了屏幕的边界，这是UIWindow的初始框架。
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //这行代码创建了一个新的UINavigationController对象，并将其设置为self的navigationController属性
    //UINavigationController是一个控制器，它管理一个导航栏和一组视图控制器。
    //[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil]创建了一个新的ViewController对象，并将其设置为导航控制器的根视图控制器。
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil]];
    //这行代码将navigationController设置为window的rootViewController属性，这意味着window将显示navigationController管理的界面。
    self.window.rootViewController = navigationController;
    //这行代码将window设置为关键窗口，并使其可见。这是启动应用程序时必须执行的最后一步，因为它使得应用程序的用户界面能够显示出来。
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
