//
//  ViewController.m
//  RTMPStreamPlayer
//
//  Created by Vyacheslav Vdovichenko on 7/11/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "PlayerViewController.h"
#import "VideoPlayer.h"
#import "DEBUG.h"
#import "StreamConfig.h"
#import "StubhubStream.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController
@synthesize stream;
@synthesize socket;

#pragma mark -
#pragma mark  View lifecycle


-(void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Playing..";
    [self doConnect];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self doDisconnect];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Private Methods 

-(void)showAlert:(NSString *)message {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Receive" message:message delegate:self 
                                       cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [av show];
}

-(void)doConnect {
    
    FramesPlayer *_player = [[FramesPlayer alloc] initWithView:previewView];
    _player.orientation = UIImageOrientationRight;
   
    player = [[MediaStreamPlayer alloc] init:BROADCAST_URL];
    player.delegate = self;
    player.player = _player;
    player.isSynchronization = YES;
    [player stream:self.stream.streamID];
}

-(void)doDisconnect {
    
    player.delegate = nil;
    [player disconnect];
    player = nil;
    previewView.hidden = YES;
    [self unregisterClient];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)index {
	//[alertView release];	
}

#pragma mark -
#pragma mark IMediaStreamEvent Methods 

-(void)stateChanged:(MediaStreamState)state description:(NSString *)description {
    
    NSLog(@" $$$$$$ <IMediaStreamEvent> stateChangedEvent: %d = %@", (int)state, description);
    
    switch (state) {
            
        case CONN_DISCONNECTED: {
            
            [self doDisconnect];
            [self showAlert:[NSString stringWithString:description]];   
            
            break;
        }
            
        case STREAM_CREATED: {
            
            [player start];
            previewView.hidden = NO;
            [self registerClient];
            break;
            
        }
            
        case STREAM_PAUSED: {
            break;
        }
            
        case STREAM_PLAYING: {
            
            if ([description isEqualToString:@"NetStream.Play.StreamNotFound"]) {
                
                [player stop];
                [self showAlert:[NSString stringWithString:description]];   
                
                break;
            }
            break;
        }
            
        default:
            break;
    }
}

-(void)connectFailed:(int)code description:(NSString *)description {
    
    NSLog(@" $$$$$$ <IMediaStreamEvent> connectFailedEvent: %d = %@\n", code, description);
    
    [self doDisconnect];
    
    [self showAlert:(code == -1) ? 
     [NSString stringWithFormat:@"Unable to connect to the server. Make sure the hostname/IP address and port number are valid\n"] : 
     [NSString stringWithFormat:@"connectFailedEvent: %@ \n", description]];    
}

#pragma mark - register/unregister

-(void)onRegisterClient:(id)result {
    
    NSLog(@"onRegisterClient = %@\n", result);
    
    //[self showAlert:[NSString stringWithFormat:@"onRegisterClient = %@\n", result]];
}



-(void)registerClient
{
    printf(" SEND ----> registerClient\n");
	
	// set call parameters
	NSString *method = @"registerClient";
    
	// send invoke
	[self.socket invoke:method withArgs:nil responder:[AsynCall call:self method:@selector(onRegisterClient:)]];
}


-(void)onUnregisterClient:(id)result {
    
    NSLog(@"onUnregisterClient = %@\n", result);
    
    //[self showAlert:[NSString stringWithFormat:@"onUnregisterClient = %@\n", result]];
}



-(void)unregisterClient
{
    printf(" SEND ----> unregisterClient\n");
	
	// set call parameters
	NSString *method = @"unregisterClient";
    
	// send invoke
	[self.socket invoke:method withArgs:nil responder:[AsynCall call:self method:@selector(onUnregisterClient:)]];
}

@end
