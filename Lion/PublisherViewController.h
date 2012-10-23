//
//  ViewController.h
//  RTMPStreamPublisher
//
//  Created by Vyacheslav Vdovichenko on 7/10/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BroadcastStreamClient.h"

@interface PublisherViewController : UIViewController <UITextFieldDelegate, IMediaStreamEvent> {
    
    BroadcastStreamClient   *upstream;
    
    IBOutlet UIView         *previewView;
    IBOutlet UIBarButtonItem *btnToggle;
    IBOutlet UIBarButtonItem *btnPublish;
}

-(IBAction)publishControl:(id)sender;
-(IBAction)camerasToggle:(id)sender;

@end
