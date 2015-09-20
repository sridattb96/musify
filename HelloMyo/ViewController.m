//
//  ViewController.m
//  ACRCloudDemo
//
//  Created by olym on 15/3/29.
//  Copyright (c) 2015年 ACRCloud. All rights reserved.
//

#import "ViewController.h"

#import "ACRCloudRecognition.h"
#import "ACRCloudConfig.h"

#import "TLHMAppDelegate.h"
#import <MyoKit/MyoKit.h>
#import "TLHMViewController.h"

#import <Spotify/Spotify.h>

#import "Variables.m"

@interface ViewController ()

@property (strong, nonatomic) TLMPose *currentPose;
@property (weak, nonatomic) IBOutlet UILabel *helloLabel;

@end

@implementation ViewController
{
    ACRCloudRecognition         *_client;
    ACRCloudConfig          *_config;
    UITextView              *_resultTextView;
    NSTimeInterval          startTime;
    __block BOOL    _start;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _start = NO;
    
    _config = [[ACRCloudConfig alloc] init];
    
    _config.accessKey = @"c4082563fa709170f1a0dc5055190e94";
    _config.accessSecret = @"qpHUivwnXfQO5I6NVfG2SQbsgyj5fEo5RsRr8ozv";
    _config.host = @"ap-southeast-1.api.acrcloud.com";
    //if you want to identify your offline db, set the recMode to "rec_mode_local"
    _config.recMode = rec_mode_remote;
    _config.audioType = @"recording";
    _config.requestTimeout = 10;
    
    /* used for local model */
    if (_config.recMode == rec_mode_local)
        _config.homedir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"acrcloud_local_db"];
    
    __weak typeof(self) weakSelf = self;
    
    _config.stateBlock = ^(NSString *state) {
        [weakSelf handleState:state];
    };
    _config.volumeBlock = ^(float volume) {
        //do some animations with volume
        [weakSelf handleVolume:volume];
    };
    _config.resultBlock = ^(NSString *result, ACRCloudResultType resType) {
        [weakSelf handleResult:result resultType:resType];
    };
    
    _client = [[ACRCloudRecognition alloc] initWithConfig:_config];
    
    //myo stuff
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (IBAction)connectMyo:(id)sender {
    
    TLHMViewController *vc = [[TLHMViewController alloc] initWithNibName:@"TLHMViewController" bundle:nil];
    
    [self presentViewController:vc animated:YES completion:nil ];
    
}

- (IBAction)startRecognition:(id)sender {
    if (_start) {
        return;
    }
    self.resultView.text = @"";
    self.costLable.text = @"";
    
    [_client startRecordRec];
    _start = YES;
    
    startTime = [[NSDate date] timeIntervalSince1970];
}

- (IBAction)stopRecognition:(id)sender {
    if(_client) {
        [_client stopRecordRec];
    }
    _start = NO;
}

-(void)handleResult:(NSString *)result
         resultType:(ACRCloudResultType)resType
{
    
    NSLog(result);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultView.text = result;
        [_client stopRecordRec];
        _start = NO;
        
        
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@",[json objectForKey:@"status"]);

        if ( [[[json objectForKey:@"status"] objectForKey:@"msg"]  isEqual: @"Success"]) {
            // parse for title and artist
            
            NSArray *arr = [result componentsSeparatedByString:@"title:"];
            NSArray *arr2 = [arr[1] componentsSeparatedByString:@","];
            NSString *title = arr2[0];
            

        }
        
        else {
            NSLog(@"Musify was not able to detect the song");
        }
        
    [self createPlaylistAddTrack];
        

//        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
//        int cost = nowTime - startTime;
//        self.costLable.text = [NSString stringWithFormat:@"cost : %ds", cost];

    });
}

-(void)handleVolume:(float)volume
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.volumeLable.text = [NSString stringWithFormat:@"Volume : %f",volume];
        
    });
}

-(void)handleState:(NSString *)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stateLable.text = [NSString stringWithFormat:@"State : %@",state];
    });
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    
    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeDoubleTap:
            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
            self.helloLabel.text = @"Hello Myo";
            self.helloLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:50];
            self.helloLabel.textColor = [UIColor blackColor];
            break;
        case TLMPoseTypeFist:
            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
            self.helloLabel.text = @"Fist";
            self.helloLabel.font = [UIFont fontWithName:@"Noteworthy" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeWaveIn:
            // Changes helloLabel's font to Courier New when the user is in a wave in pose.
            self.helloLabel.text = @"Wave In";
            self.helloLabel.font = [UIFont fontWithName:@"Courier New" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            
            if (_start) {
                return;
            }
            self.resultView.text = @"";
            self.costLable.text = @"";
            
            [_client startRecordRec];
            _start = YES;
            
            startTime = [[NSDate date] timeIntervalSince1970];

            //create spotify playlist
        
            break;
        case TLMPoseTypeWaveOut:
            // Changes helloLabel's font to Snell Roundhand when the user is in a wave out pose.
            self.helloLabel.text = @"Wave Out";
            self.helloLabel.font = [UIFont fontWithName:@"Snell Roundhand" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeFingersSpread:
            // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
            self.helloLabel.text = @"Fingers Spread";
            self.helloLabel.font = [UIFont fontWithName:@"Chalkduster" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            break;
    }
    
    // Unlock the Myo whenever we receive a pose
    if (pose.type == TLMPoseTypeUnknown || pose.type == TLMPoseTypeRest) {
        // Causes the Myo to lock after a short period.
        [pose.myo unlockWithType:TLMUnlockTypeTimed];
    } else {
        // Keeps the Myo unlocked until specified.
        // This is required to keep Myo unlocked while holding a pose, but if a pose is not being held, use
        // TLMUnlockTypeTimed to restart the timer.
        [pose.myo unlockWithType:TLMUnlockTypeHold];
        // Indicates that a user action has been performed.
        [pose.myo indicateUserAction];
    }
}

- (void)createPlaylistAddTrack {
    
//    [SPTSearch performSearchWithQuery:@"Call Me Maybe" queryType:SPTQueryTypeTrack accessToken:session.accessToken callback:^(NSError *error, SPTListPage *lp) {
//        
//        NSLog(@"SONG");
//        }
//     ];
    
    [SPTSearch performSearchWithQuery:@"Call Me Maybe" queryType:SPTQueryTypeTrack accessToken:mySession.accessToken callback:^(NSError *error, SPTListPage *lp) {
        
        //NSArray *tracks = @[[lp items][0]];
        
        /* http attempt */
        NSString *s = [NSString stringWithFormat:@"https://api.spotify.com/v1/users/%@/playlists/%@/tracks?uris=%@", userName, playlistId, [[lp items][0] playableUri]];
        
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]];
        NSString *header = [NSString stringWithFormat:@"Bearer %@", mySession.accessToken];
        [postRequest setValue:header forHTTPHeaderField:@"Authorization"];
        [postRequest setHTTPMethod:@"POST"];
        
        NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
        
        if (!con) {
            NSLog(@"failed");
        }
        
        
    }
     ];
    
    
    

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"gets here");
}

@end
