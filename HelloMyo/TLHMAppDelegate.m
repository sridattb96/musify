//
//  TLHMAppDelegate.m
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//

#import "TLHMAppDelegate.h"
#import <MyoKit/MyoKit.h>
#import "TLHMViewController.h"
#import <Spotify/Spotify.h>

#import "Variables.m"

@interface TLHMAppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@end

@implementation TLHMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Instantiate the hub using the singleton accessor, and set the applicationIdentifier of our application.
    [[TLMHub sharedHub] setApplicationIdentifier:@"com.example.hellomyo"];
    
     //Instantiate our view controller
    
    //spotify stuff
    [[SPTAuth defaultInstance] setClientID:@"f7cbc443a8b7454f8faf8e344b23db44"];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"hack-the-north-login://callback"]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthPlaylistModifyPublicScope]];
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [application performSelector:@selector(openURL:)
                      withObject:loginURL afterDelay:0.1];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        mySession = session;
        
        if (error != nil) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Authentication Failed"
                                                           message:[NSString stringWithFormat:@"%@\n\n Are you sure your token swap service is set up correctly?",
                                                                    error.userInfo[NSLocalizedDescriptionKey]]
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [view show];
            return;
        }
        [self performTestCallWithSession:session];
    };
    
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}

-(void)performTestCallWithSession:(SPTSession *)session {

    [SPTRequest userInformationForUserInSession:session callback:^(NSError *error, SPTUser *user) {
        if (error != nil) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Getting User Info Failed"
                                                           message:error.userInfo[NSLocalizedDescriptionKey]
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [view show];
            return;
        }
        
        NSString *userDetailsString = [NSString stringWithFormat:@""
                                       "Display name: %@\n"
                                       "Canonical name: %@\n"
                                       "Territory: %@\n"
                                       "Email: %@\n"
                                       "Images: %@",
                                       user.displayName, user.canonicalUserName, user.territory, user.emailAddress, @(user.images.count)];
        
        userName = user.canonicalUserName;
        
//        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"User Information"
//                                                       message:userDetailsString
//                                                      delegate:nil
//                                             cancelButtonTitle:@"OK"
//                                             otherButtonTitles:nil];
//        [view show];
        
    }];
    
    //name playlist by date
    [SPTPlaylistList createPlaylistWithName:@"helloplaylist" publicFlag:true session:mySession callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            NSLog(@"playlist created via publicflag");
        //_uri = [playlist uri];
        
        NSArray *arr = [[[playlist uri] absoluteString] componentsSeparatedByString:@"playlist:"];
        playlistId = arr[1];

        }
     
     
     
     ];
    
    //BELOW ALL DONE IN ONE FUNCTION
    
    //get "title" attribute from acrcloud api, use for search query
    
//    [SPTSearch performSearchWithQuery:@"Call Me Maybe" queryType:SPTQueryTypeTrack accessToken:session.accessToken callback:^(NSError *error, SPTListPage *lp) {
//        
//        //NSArray *tracks = @[[lp items][0]];
//        
//        /* http attempt */
//        NSString *s = [NSString stringWithFormat:@"https://api.spotify.com/v1/users/%@/playlists/%@/tracks?uris=%@", userName, playlistId, [[lp items][0] playableUri]];
//        
//        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]];
//        NSString *header = [NSString stringWithFormat:@"Bearer %@", session.accessToken];
//        [postRequest setValue:header forHTTPHeaderField:@"Authorization"];
//        [postRequest setHTTPMethod:@"POST"];
//        
//        NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
//        
//        if (!con) {
//            NSLog(@"failed");
//        }
//        
//
//        }
//     ];
}


@end
