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

@interface PlayerViewController ()

@end

@implementation PlayerViewController

#pragma mark -
#pragma mark  View lifecycle

-(void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Playing..";
    //[DebLog setIsActive:YES];
    [self doConnect];
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
    [player stream:STREAM_NAME];    
}

-(void)doDisconnect {
    
    [player disconnect];
    player = nil;
    previewView.hidden = YES;    
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

@end
