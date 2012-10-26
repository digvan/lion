//
//  ViewController.h
//  ClientInvoke
//
//  Created by Vyacheslav Vdovichenko on 7/29/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//  Modified by T.Selim Bebek

#import <UIKit/UIKit.h>
#import "RTMPClient.h"

@interface HomeViewController : UIViewController

<UITextFieldDelegate, UIAlertViewDelegate,  IRTMPClientDelegate, UITableViewDelegate, UITableViewDataSource>
{	
    BOOL isConnected;
}

@property (nonatomic, strong) RTMPClient	*socket;

@property (nonatomic, strong) NSMutableArray* availableStreams;

@property (nonatomic, strong) IBOutlet UITextField* streamNameTextField;
@property (nonatomic, strong) IBOutlet UIButton* btnPublish;
@property (nonatomic, strong) IBOutlet UITableView* availableStreamsTableView;

-(IBAction)publish:(id)sender;

@end
