//
//  ViewController.m
//  RTMPStreamPublisher
//
//  Created by Vyacheslav Vdovichenko on 7/10/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "PublisherViewController.h"
#import "DEBUG.h"
#import "StreamConfig.h"
#import "StubhubStream.h"

@interface PublisherViewController ()

@end

@implementation PublisherViewController
@synthesize stream;
@synthesize socket;

#pragma mark -
#pragma mark  View lifecycle

-(void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Publishing..";
    //[DebLog setIsActive:YES];
    [self doConnect];
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self doDisconnect];
}

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    
    upstream = [[BroadcastStreamClient alloc] init:BROADCAST_URL resolution:RESOLUTION_LOW];
    upstream.delegate = self;
    [upstream setPreviewLayer:previewView orientation:AVCaptureVideoOrientationPortrait];
    [upstream stream:self.stream.streamID publishType:PUBLISH_LIVE];
}

-(void)doDisconnect
{
    [self unregisterBroadcaster:self.stream.streamID];
    upstream.delegate = nil;
    [upstream disconnect];
    upstream = nil;
    
    btnToggle.enabled = NO;
    previewView.hidden = YES;
}

#pragma mark - register/unregister

-(void)onRegisterBroadcaster:(id)result {
    
    NSLog(@"onRegisterBroadcaster = %@\n", result);
    
    //[self showAlert:[NSString stringWithFormat:@"onRegisterBroadcaster = %@\n", result]];
}



-(void)registerBroadcaster:(NSString*)streamID withName:(NSString*)streamName
{
    printf(" SEND ----> registerBroadcaster\n");
	
	// set call parameters
	NSMutableArray *args = [NSMutableArray array];
	NSString *method = @"registerBroadcaster";
	[args addObject:streamID];
    [args addObject:streamName];
    
	// send invoke
	[self.socket invoke:method withArgs:args responder:[AsynCall call:self method:@selector(onRegisterBroadcaster:)]];
}


-(void)onUnRegisterBroadcaster:(id)result {
    
    NSLog(@"onUnRegisterBroadcaster = %@\n", result);
    
    //[self showAlert:[NSString stringWithFormat:@"onRegisterBroadcaster = %@\n", result]];
}



-(void)unregisterBroadcaster:(NSString*)streamID
{
    printf(" SEND ----> unregisterBroadcaster\n");
	
	// set call parameters
	NSMutableArray *args = [NSMutableArray array];
	NSString *method = @"unregisterBroadcaster";
	[args addObject:streamID];
    
	// send invoke
	[self.socket invoke:method withArgs:args responder:[AsynCall call:self method:@selector(onUnRegisterBroadcaster:)]];
}



#pragma mark -
#pragma mark Public Methods 

// ACTIONS

-(IBAction)publishControl:(id)sender
{
    (upstream.state != STREAM_PLAYING) ? [upstream start] : [upstream pause];
}

-(IBAction)camerasToggle:(id)sender
{
    if (upstream.state == STREAM_PLAYING)
        [upstream switchCameras];
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods 

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
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
            
        case CONN_CONNECTED: {
            
            if (![description isEqualToString:@"RTMP.Client.isConnected"])
                break;
            
            [self publishControl:nil];
            previewView.hidden = NO;
            [self registerBroadcaster:self.stream.streamID withName:self.stream.streamName];
            break;
           
        }
            
        case STREAM_PAUSED: {
            
            btnToggle.enabled = NO;
            
            break;
        }
            
        case STREAM_PLAYING: {
            
            btnToggle.enabled = YES;
            
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
