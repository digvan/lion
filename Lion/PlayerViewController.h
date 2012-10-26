//
//  ViewController.h
//  RTMPStreamPlayer
//
//  Created by Vyacheslav Vdovichenko on 7/11/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaStreamPlayer.h"

@class StubhubStream;
@interface PlayerViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, IMediaStreamEvent>
{    
    MediaStreamPlayer       *player;
    IBOutlet UIImageView    *previewView;    
}

@property (nonatomic, strong) RTMPClient	*socket;
@property (nonatomic, strong) StubhubStream* stream;
@end
