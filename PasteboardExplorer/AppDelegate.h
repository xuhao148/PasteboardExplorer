//
//  AppDelegate.h
//  PasteboardExplorer
//
//  Created by Aya on 24/4/23.
//  Copyright © 2024年 Aya. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)updateInfo:(id)sender;
- (IBAction)showAsHex:(id)sender;
- (IBAction)showAsRtf:(id)sender;
- (IBAction) showAsText: (id)sender;
- (IBAction) showAsImage:(id)sender;
- (IBAction) save:(id)sender;
- (IBAction) excludeContent:(id)sender;
- (IBAction) clearPasteboard:(id)sender;

@end

