//
//  AppDelegate.h
//  CocosBuilderConver
//
//  Created by Ghost on 12-12-7.
//  Copyright Ghost233 2012年. All rights reserved.
//

#import "cocos2d.h"

@interface CocosBuilderConverAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
