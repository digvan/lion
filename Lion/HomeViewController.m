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
#import "StubhubStream.h"

#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@implementation HomeViewController
@synthesize btnPublish;
@synthesize streamNameTextField;
@synthesize availableStreams;
@synthesize availableStreamsTableView;
@synthesize socket;

#pragma mark -
#pragma mark Private Methods 


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.socket = nil;
    isConnected = NO;
    return self;
}
-(void)showAlert:(NSString *)message {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [av show];
}

// ACTIONS

-(void)socketConnected {
    
    isConnected = YES;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(doDisconnect:));    
    btnPublish.enabled = YES;
    btnPublish.alpha = 1.0;
    streamNameTextField.enabled = YES;
    streamNameTextField.alpha = 1.0;
    availableStreamsTableView.alpha = 1.0;
    availableStreamsTableView.userInteractionEnabled = YES;
    
    [self getBroadcasters];
}

-(void)socketDisconnected {
    isConnected = NO;
	self.title = @"Stubhub Live";
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(doConnect:));
    btnPublish.enabled = NO;
    btnPublish.alpha = 0.8;

    streamNameTextField.enabled = NO;
    streamNameTextField.alpha = 0.8;
    
    availableStreamsTableView.alpha = 0.8;
    availableStreamsTableView.userInteractionEnabled = NO;
}

-(void)doConnect:(id)sender {				
    
    if (socket)
        [self.socket connect:BROADCAST_URL];
    else {
        self.socket = [[RTMPClient alloc] init:BROADCAST_URL];
        socket.delegate = self;
        [socket connect];
    }
}

-(void)onGetBroadcasters:(NSArray*)result {
    
    NSLog(@"onGetBroadcasters = %@\n", result);
    //[self showAlert:[NSString stringWithFormat:@"onGetBroadcasters = %@\n", result]];
    self.availableStreams = [NSMutableArray arrayWithCapacity:result.count];
    
    for (NSDictionary* streamDict in result) {
        StubhubStream* stream = [StubhubStream new];
        stream.streamID = [streamDict valueForKey:@"streamID"];
        stream.streamName = [streamDict valueForKey:@"streamName"];
        [self.availableStreams addObject:stream];
    }
    [self.availableStreamsTableView reloadData];
}



-(void)getBroadcasters
{
    printf(" SEND ----> registerBroadcaster\n");
	
	// set call parameters
	NSString *method = @"getBroadcasters";
	// send invoke
	[socket invoke:method withArgs:nil responder:[AsynCall call:self method:@selector(onGetBroadcasters:)]];
}


-(void)doDisconnect:(id)sender {	
    
    [self socketDisconnected];
    socket = nil;
}

-(IBAction)publish:(id)sender
{
#ifdef __i386__
    [self showAlert:@"No broadcasting from iPhone Simulator!"];
#else
    if ([self.streamNameTextField.text isEqualToString:@""]) {
        [self showAlert:@"Please enter a stream name!"];
    }
    else
    {
        [self.streamNameTextField resignFirstResponder];

        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        NSString* streamID = [NSString stringWithFormat:@"%@.stream",(__bridge NSString *)CFUUIDCreateString(NULL, theUUID)];
        
        StubhubStream* streamToPublish = [StubhubStream new];
        streamToPublish.streamID = streamID;
        streamToPublish.streamName = self.streamNameTextField.text;
        PublisherViewController* controller = [[PublisherViewController alloc] initWithNibName:@"PublisherViewController" bundle:nil];
        controller.socket = self.socket;
        controller.stream = streamToPublish;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
#endif
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [DebLog setIsActive:YES];

    self.title = @"Home";
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(doConnect:));
    socket = nil;
    [self socketDisconnected];
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
    
    if ([method isEqualToString:@"availableStreamsUpdate"])
    {
        [self getBroadcasters];
    }
    
    NSArray *args = [call getArguments];
    int invokeId = [call getInvokeId];
    id result = (args.count) ? [args objectAtIndex:0] : nil;
    
    NSLog(@" $$$$$$ <IRTMPClientDelegate>> resultReceived <---- status=%d, invokeID=%d, method='%@' arguments=%@\n", status, invokeId, method, result);
//    [self showAlert:[NSString stringWithFormat:@"'%@': arguments = %@\n", method, result]];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Available Streams";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (isConnected && availableStreams.count == 0) {
        return 1;
    }
    return availableStreams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    if (isConnected && availableStreams.count == 0) {
        cell.textLabel.text = @"No available streams";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        StubhubStream* stream = [availableStreams objectAtIndex:indexPath.row];
        cell.textLabel.text = stream.streamName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isConnected == availableStreams.count >0) {
        PlayerViewController* controller = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
        controller.stream = [self.availableStreams objectAtIndex:indexPath.row];
        controller.socket = self.socket;
        [self.navigationController pushViewController:controller animated:YES];

    }
}


@end
