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
<UITextFieldDelegate, UIAlertViewDelegate,  IRTMPClientDelegate> {
	
	RTMPClient	*socket;
	int			state;
	int			alerts;
    BOOL        isRTMPS;
    	// controls    
	UIButton	*btnEchoInt;
    UIButton	*btnPublish;
    UIButton    *btnPlay;

}
@end
