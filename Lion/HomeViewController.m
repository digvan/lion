//
//  ViewController.m
//  ClientInvoke
//
//  Created by Vyacheslav Vdovichenko on 7/29/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//  Modified by T.Selim Bebek


#import "HomeViewController.h"
#import "BinaryCodec.h"
#import "DEBUG.h"
#import "StreamConfig.h"
#import "PublisherViewController.h"
#import "PlayerViewController.h"

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define STATUS_PENDING 0x01
//#define WOWZA_IP @"10.80.188.21"
#define WOWZA_IP @"localhost"

@implementation HomeViewController

#pragma mark -
#pragma mark Private Methods 

-(void)showAlert:(NSString *)message {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Receive" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	alerts++;
	av.tag = alerts;
    [av show];
}

// BIG DATA - ARRAY OF BYTES

-(NSData *)bigData {
    
    int len = 100000;
    char *buf = malloc(len);
    
    for (int i = 0; i < len; i++)
        buf[i] = (char)i%256;
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    
    free(buf);
    
    return data;
}

// CALLBACKS

-(void)onEchoInt:(id)result {
    
    NSLog(@"onEchoInt = %@\n", result);
    
    [self showAlert:[NSString stringWithFormat:@"onEchoInt = %@\n", result]];
}


// INVOKE

-(void)echoInt {	
	
	printf(" SEND ----> echoInt\n");
	
	// set call parameters
	NSMutableArray *args = [NSMutableArray array];
	NSString *method = @"echoInt";
	[args addObject:[NSNumber numberWithInt:20]];
	// send invoke
	[socket invoke:method withArgs:args responder:[AsynCall call:self method:@selector(onEchoInt:)]];
}

// ACTIONS

-(void)socketConnected {
    
    state = 1;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(doDisconnect:));    
    btnEchoInt.enabled = YES;
    btnPublish.enabled = YES;
    btnPlay.enabled = YES;
}

-(void)socketDisconnected {
    
    state = 0;
	self.title = @"Home";
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(doConnect:));
    btnEchoInt.enabled = NO;
    btnPublish.enabled = NO;
    btnPlay.enabled = NO;
}

-(void)doConnect:(id)sender {				
    
    if (socket)
        [socket connect:BROADCAST_URL];
    else {
        socket = [[RTMPClient alloc] init:BROADCAST_URL];
        socket.delegate = self;
        [socket connect];
    }
}

-(void)doDisconnect:(id)sender {	
    
    if (state == 0) 
        return;
    
    [self socketDisconnected];
    //[socket release];
    socket = nil;
}

-(void)doProtocol {
    isRTMPS = (isRTMPS)?NO:YES;    
}

-(void)publish
{
    PublisherViewController* controller = [[PublisherViewController alloc] initWithNibName:@"PublishViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}


-(void)play
{
    PlayerViewController* controller = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [DebLog setIsActive:YES];

    self.title = @"Home";
    //
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(doConnect:));
    
	//buttons
	btnEchoInt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btnEchoInt.frame = CGRectMake(0.0, 0.0, 300.0, 44.0);
	btnEchoInt.center = CGPointMake(160.0, 44.0);
	btnEchoInt.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [btnEchoInt setTitle:@"echoInt (12)" forState:UIControlStateNormal];
    [btnEchoInt addTarget:self action:@selector(echoInt) forControlEvents:UIControlEventTouchUpInside];
    btnEchoInt.enabled = NO;
	[self.view addSubview:btnEchoInt];
    
    btnPublish = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btnPublish.frame = CGRectMake(0.0, 0.0, 300.0, 44.0);
	btnPublish.center = CGPointMake(160.0, 110);
	btnPublish.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [btnPublish setTitle:@"publish" forState:UIControlStateNormal];
    [btnPublish addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
    btnPublish.enabled = NO;
	[self.view addSubview:btnPublish];
    
    btnPlay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btnPlay.frame = CGRectMake(0.0, 0.0, 300.0, 44.0);
	btnPlay.center = CGPointMake(160.0, 176.0);
	btnPlay.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [btnPlay setTitle:@"play" forState:UIControlStateNormal];
    [btnPlay addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    btnPlay.enabled = NO;
	[self.view addSubview:btnPlay];

    
    isRTMPS = NO;
	alerts = 100;
	state = 0;
    socket = nil;

    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods 

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark IRTMPClientDelegate Methods 

-(void)connectedEvent {	
    NSLog(@" $$$$$$ <IRTMPClientDelegate>> connectedEvent\n");
    
    [self socketConnected];
}

-(void)disconnectedEvent {	
    NSLog(@" $$$$$$ <IRTMPClientDelegate>> disconnectedEvent\n");
    
    [self performSelector:@selector(doDisconnect:) withObject:nil afterDelay:0.1f];    
 	[self showAlert:@" !!! disconnectedEvent \n"];   
}

-(void)connectFailedEvent:(int)code description:(NSString *)description {	
    NSLog(@" $$$$$$ <IRTMPClientDelegate>> connectFailedEvent: %d = '%@'\n", code, description);
    
    [self performSelector:@selector(doDisconnect:) withObject:nil afterDelay:0.1f];
    
    if (code == -1)
        [self showAlert:[NSString stringWithFormat:
                         @"Unable to connect to the server. Make sure the hostname/IP address and port number are valid\n"]];       
    else
        [self showAlert:[NSString stringWithFormat:@" !!! connectFailedEvent: %@ \n", description]];       
}

-(void)resultReceived:(id <IServiceCall>)call {
    
    int status = [call getStatus];
    
    
    NSString *method = [call getServiceMethodName];
    NSArray *args = [call getArguments];
    int invokeId = [call getInvokeId];
    id result = (args.count) ? [args objectAtIndex:0] : nil;
    
    NSLog(@" $$$$$$ <IRTMPClientDelegate>> resultReceived <---- status=%d, invokeID=%d, method='%@' arguments=%@\n", status, invokeId, method, result);
    
    if (status != STATUS_PENDING) // this call is not a server response
        return;
    
    [self showAlert:[NSString stringWithFormat:@"'%@': arguments = %@\n", method, result]];    
}

@end
