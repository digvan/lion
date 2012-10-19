//
//  ViewController.m
//  ClientInvoke
//
//  Created by Vyacheslav Vdovichenko on 7/29/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//  Modified by T.Selim Bebek


#import "ViewController.h"
#import "BinaryCodec.h"

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define STATUS_PENDING 0x01


@implementation ViewController

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
	[args addObject:[NSNumber numberWithInt:12]];	
	// send invoke
	[socket invoke:method withArgs:args responder:[AsynCall call:self method:@selector(onEchoInt:)]];
}

// ACTIONS

-(void)socketConnected {
    
    state = 1;
    
    self.title = [NSString stringWithFormat:@"%@:%@/%@", hostTextField.text, portTextField.text, appTextField.text];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(doDisconnect:));
    
    btnProtocol.hidden = YES;
    protocolLabel.hidden = YES;
    portLabel.hidden = YES;
    appLabel.hidden = YES;
    hostTextField.hidden = YES;
    portTextField.hidden = YES;
    appTextField.hidden = YES;
    
    infoImage.hidden = YES;
    btnInfo.hidden = YES;
    
    btnEchoInt.hidden = NO;
    btnEchoFloat.hidden = NO;
    btnEchoString.hidden = NO;
    btnEchoStringArray.hidden = NO;
    btnEchoIntArray.hidden = NO;
    btnEchoArrayList.hidden = NO;
    btnEchoByteArray.hidden = NO;
}

-(void)socketDisconnected {
    
    state = 0;
    
	self.title = @"Home";
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(doConnect:));
    
    btnProtocol.hidden = NO;
    protocolLabel.hidden = NO;
    portLabel.hidden = NO;
    appLabel.hidden = NO;
    hostTextField.hidden = NO;
    portTextField.hidden = NO;
    appTextField.hidden = NO;
    
    infoImage.hidden = YES;
    [btnInfo setTitle:@"Info" forState:UIControlStateNormal];
    btnInfo.hidden = NO;
    
    btnEchoInt.hidden = YES;
    btnEchoFloat.hidden = YES;
    btnEchoString.hidden = YES;
    btnEchoStringArray.hidden = YES;
    btnEchoIntArray.hidden = YES;
    btnEchoArrayList.hidden = YES;
    btnEchoByteArray.hidden = YES;
}

-(void)doConnect:(id)sender {				
    
    NSString *protocol = (isRTMPS) ? @"rtmps://%@:%d/%@" : @"rtmp://%@:%d/%@";
    NSString *url = [NSString stringWithFormat:protocol, hostTextField.text, [portTextField.text intValue], appTextField.text];
    
    if (socket)
        [socket connect:url];
    else {
        socket = [[RTMPClient alloc] init:url];
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
    [btnProtocol setTitle:(isRTMPS)?@"rtmps":@"rtmp" forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Home";
    //
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(doConnect:));
    
	//button
	btnProtocol = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btnProtocol.frame = CGRectMake(0.0, 0.0, 50.0, 30.0);
	btnProtocol.center = CGPointMake(35.0, 25.0);
	btnProtocol.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [btnProtocol setTitle:@"rtmp" forState:UIControlStateNormal];
	[btnProtocol addTarget:self action:@selector(doProtocol) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnProtocol];
    
	//labels
	protocolLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 10.0, 23.0, 30.0)];
	protocolLabel.text = @"://";
	[self.view addSubview:protocolLabel];
	//[protocolLabel release];
    
	portLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 50.0, 5.0, 30.0)];
	portLabel.text = @":";
	[self.view addSubview:portLabel];
	//[portLabel release];
	
	appLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 90.0, 10.0, 30.0)];
	appLabel.text = @"/";
	[self.view addSubview:appLabel];
	//[appLabel release];
	
	// textFields
	hostTextField = [[UITextField alloc] initWithFrame:CGRectMake(80.0, 10.0, 235.0, 30.0)];
	hostTextField.borderStyle = UITextBorderStyleRoundedRect;
	hostTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	hostTextField.placeholder = @"hostname or IP";
    hostTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	hostTextField.returnKeyType = UIReturnKeyDone;
	hostTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	hostTextField.text = @"localhost";
	//hostTextField.text = @"10.0.1.2";
	hostTextField.delegate = self;
	[self.view addSubview:hostTextField];
	//[hostTextField release];
	
	portTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 50.0, 80.0, 30.0)];
	portTextField.borderStyle = UITextBorderStyleRoundedRect;
	portTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	portTextField.placeholder = @"port";
    portTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	portTextField.returnKeyType = UIReturnKeyDone;
	portTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	portTextField.text = @"1935";
	portTextField.delegate = self;
	[self.view addSubview:portTextField];
	//[portTextField release];
	
	appTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 90.0, 300.0, 30.0)];
	appTextField.borderStyle = UITextBorderStyleRoundedRect;
	appTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	appTextField.placeholder = @"app";
	appTextField.returnKeyType = UIReturnKeyDone;
	appTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	appTextField.text = @"live";
	appTextField.delegate = self;
	[self.view addSubview:appTextField];
	//[appTextField release];
	
	//buttons
	btnEchoInt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btnEchoInt.frame = CGRectMake(0.0, 0.0, 300.0, 30.0);
	btnEchoInt.center = CGPointMake(160.0, 30.0);
	btnEchoInt.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [btnEchoInt setTitle:@"echoInt (12)" forState:UIControlStateNormal];
    [btnEchoInt addTarget:self action:@selector(echoInt) forControlEvents:UIControlEventTouchUpInside];
    btnEchoInt.hidden = YES;
	[self.view addSubview:btnEchoInt];
    
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
    if (status != STATUS_PENDING) // this call is not a server response
        return;
    
    NSString *method = [call getServiceMethodName];
    NSArray *args = [call getArguments];
    int invokeId = [call getInvokeId];
    id result = (args.count) ? [args objectAtIndex:0] : nil;
    
    NSLog(@" $$$$$$ <IRTMPClientDelegate>> resultReceived <---- status=%d, invokeID=%d, method='%@' arguments=%@\n", status, invokeId, method, result);
    
    [self showAlert:[NSString stringWithFormat:@"'%@': arguments = %@\n", method, result]];    
}

@end
