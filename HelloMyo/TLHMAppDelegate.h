//
//  TLHMAppDelegate.h
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//

#import <UIKit/UIKit.h>

@interface TLHMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//- (IBAction)logIn:(id)sender;

@property (nonatomic, readwrite, copy) NSArray *scopes;
@property (nonatomic, readwrite, copy) NSArray *scopeDisplayNames;
@property (nonatomic, readwrite, strong) NSMutableArray *selectedScopes;

@end
