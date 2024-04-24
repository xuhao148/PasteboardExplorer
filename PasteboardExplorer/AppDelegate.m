//
//  AppDelegate.m
//  PasteboardExplorer
//
//  Created by Aya on 24/4/23.
//  Copyright © 2024年 Aya. All rights reserved.
//

#import "AppDelegate.h"

NSString *encodingNameList[] = {
    @"ASCII", @"Mac Roman", @"ISO Latin 1", @"Unicode", @"UTF-8",
    @"Non-lossy ASCII", @"UTF-16", @"UTF-16 BE", @"UTF-16 LE",
    @"UTF-32",@"UTF-32 BE", @"UTF-32 LE", @"Mac Japanese",
    @"Mac Korean", @"Mac Simp. Chinese", @"Mac Trad. Chinese",
    @"Mac Symbol", @"Mac Dingbats", @"Mac VT100102",
    @"Shift-JIS",@"EUC-JP",@"GB18030-2000",@"EUC-KR",
    @"BIG5",@"BIG5-HKSCS"
};

const int encodingList[] = {
    kCFStringEncodingASCII,
    kCFStringEncodingMacRoman,
    kCFStringEncodingISOLatin1,
    kCFStringEncodingUnicode,
    kCFStringEncodingUTF8,
    kCFStringEncodingNonLossyASCII,
    kCFStringEncodingUTF16,
    kCFStringEncodingUTF16BE,
    kCFStringEncodingUTF16LE,
    kCFStringEncodingUTF32,
    kCFStringEncodingUTF32BE,
    kCFStringEncodingUTF32LE,
    kCFStringEncodingMacJapanese,
    kCFStringEncodingMacKorean,
    kCFStringEncodingMacChineseSimp,
    kCFStringEncodingMacChineseTrad,
    kCFStringEncodingMacSymbol,
    kCFStringEncodingMacDingbats,
    kCFStringEncodingMacVT100,
    kCFStringEncodingShiftJIS,
    kCFStringEncodingEUC_JP,
    kCFStringEncodingGB_18030_2000,
    kCFStringEncodingEUC_KR,
    kCFStringEncodingBig5,
    kCFStringEncodingBig5_HKSCS_1999
};

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property IBOutlet NSPopUpButton *pubContentType;
@property NSArray *currentTypes;
@property NSPasteboard *shared;
@property IBOutlet NSTextView *textBox;
@property IBOutlet NSImageView *imgBox;
@property IBOutlet NSTabView *tabBox;
@property NSData *holdingData;
@property IBOutlet NSTextField *tbBegin;
@property IBOutlet NSTextField *tbLength;
@property IBOutlet NSTextField *tbPtBegin;
@property IBOutlet NSTextField *tbPtLength;
@property IBOutlet NSPopUpButton *pubEncodings;
@property NSFont *monofont;
@property NSSavePanel *savePanel;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _shared = [NSPasteboard generalPasteboard];
    _savePanel = [NSSavePanel savePanel];
    [self updateComboBoxTable];
    [self updateEncodingButton];
    _monofont = [NSFont fontWithName:@"Menlo" size:12];
    if (!_monofont) {
        _monofont = [NSFont systemFontOfSize:12];
    }
    _holdingData = nil;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (void) updateComboBoxTable {
    [_pubContentType removeAllItems];
    _currentTypes = [_shared types];
    [_pubContentType addItemsWithTitles:_currentTypes];
}

- (void) updateEncodingButton {
    [_pubEncodings removeAllItems];
    for (int i=0; i<25; i++) {
        [_pubEncodings addItemWithTitle:encodingNameList[i]];
    }
}

- (IBAction)updateInfo:(id)sender {
    [self updateComboBoxTable];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (BOOL)loadData {
    if ([[_pubContentType itemArray] count]==0 || [_pubContentType indexOfSelectedItem]==-1) {
        [_tabBox selectTabViewItemAtIndex:0];
        [_textBox setFont:_monofont];
        [_textBox setString:@"Error:\nNo content in Pasteboard, or no content type chosen."];
        return NO;
    }
    NSString *pbType = [_currentTypes objectAtIndex:[_pubContentType indexOfSelectedItem]];
    _holdingData = [_shared dataForType:pbType];
    if (!_holdingData) {
        NSLog(@"No data retrieved for such type.");
        [_tabBox selectTabViewItemAtIndex:0];
        [_textBox setFont:_monofont];
        [_textBox setString:@"Error:\nFailed to retrieve data for such type."];
        return NO;
    }
    return YES;
}

- (IBAction)showAsHex:(id)sender {
    [_textBox setString:@""];
    [_textBox setFont:_monofont];
    BOOL suc = [self loadData];
    unsigned char buf[16];
    if (!suc) return;
    long show_offset = [_tbBegin integerValue];
    long show_length = [_tbLength integerValue];
    long len = [_holdingData length];
    if (show_length <= 0) show_length = len;
    long show_limit = show_offset + show_length;
    if (show_limit > len) show_limit = len;
    NSLog(@"Showing at %d len %d",show_offset,show_length);
    NSMutableString *line = [NSMutableString new];
    [line appendFormat:@"Total %ld bytes\n",len];
    for (long i = show_offset; i < show_limit; i+=16) {
        [line appendFormat:@"%06x: ",i/16];
        int true_len = show_limit - i;
        if (true_len > 16) true_len = 16;
        [_holdingData getBytes:buf range:NSMakeRange(i,true_len)];
        for (int j=0; j<16; j++) {
            if (j < true_len) {
                [line appendFormat:@"%02x",buf[j]];
                if (j == 7 && (j+1)<true_len) [line appendString:@"-"];
                else [line appendString:@" "];
            } else [line appendString:@"   "];
        }
        [line appendString:@" |"];
        for (int j=0; j<true_len; j++) {
            unsigned char c = buf[j];
            if (c >= ' ' && c <= 0x7f) {
                [line appendFormat:@"%c",c];
            } else {
                [line appendString:@"."];
            }
        }
        [line appendString:@"|\n"];
    }
    [_textBox setString:line];
    [_textBox setNeedsDisplay:YES];
}

- (IBAction)showAsRtf:(id)sender {
    if (![self loadData]) return;
    [_textBox setString:@""];
    [_textBox setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
     NSAttributedString *rtf = [[NSAttributedString alloc] initWithRTF:_holdingData documentAttributes:nil];
     if (!rtf) {
         [_textBox setFont:_monofont];
         [_textBox setString:@"Error:\nFailed to initialize an NSAttributedString from the text as RTF"];
         return;
     }
     [[_textBox textStorage] setAttributedString:rtf];
}

- (IBAction) showAsText: (id)sender {
    if (![self loadData]) return;
    int len = [_holdingData length];
    unsigned char *buf = (unsigned char *)malloc(len);
    int idx = [_pubEncodings indexOfSelectedItem];
    [_holdingData getBytes:buf length:len];
    CFStringRef cfstr = CFStringCreateWithBytes(nil, buf, len, encodingList[idx], NO);
    if (!cfstr) {
        free(buf);
        [_textBox setFont:_monofont];
        [_textBox setString:@"Error:\nFailed to initialize a CFString with given encoding."];
        return;
    }
    [_textBox setFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];
    [_textBox setString:@""];
    int str_len = CFStringGetLength(cfstr);
    int sloc = [_tbPtBegin integerValue];
    int slen = [_tbPtLength integerValue];
    if (sloc < 0) sloc = 0;
    if (sloc < str_len) {
        if (slen == 0) {
            slen = str_len - sloc;
        } else if (sloc + slen > str_len) {
            slen = str_len - sloc;
        }
        CFRange r = CFRangeMake(sloc, slen);
        CFStringRef substr = CFStringCreateWithSubstring(nil, cfstr, r);
        [_textBox setString:[NSString stringWithFormat:@"%@",substr]];
        CFRelease(substr);
    }
    free(buf);
    CFRelease(cfstr);
}

- (IBAction) showAsImage:(id)sender {
    if (![self loadData]) return;
    NSImage *ni = [[NSImage alloc] initWithData:_holdingData];
    if (!ni) {
        [_tabBox selectTabViewItemAtIndex:0];
        [_textBox setFont:_monofont];
        [_textBox setString:@"Error:\nFailed to initialize NSImage with given data."];
        return;
    }
    NSSize siz = [ni size];
    [_textBox setFont:_monofont];
    [_textBox setString:[NSString stringWithFormat:@"Loaded NSImage sized %f x %f.\n",siz.width,siz.height]];
    [_imgBox setImage:ni];
    [_tabBox selectTabViewItemAtIndex:1];
}

- (IBAction) save:(id)sender {
    if (!_holdingData) {
        if (![self loadData]) return;
    }
    NSModalResponse nrp = [_savePanel runModal];
    if (nrp == NSModalResponseOK) {
        [_holdingData writeToURL:[_savePanel URL] atomically:NO];
    }
}

- (IBAction) excludeContent:(id)sender {
    if (![self loadData]) return;
    [_shared clearContents];
    [_shared setData:_holdingData forType:[_currentTypes objectAtIndex:[_pubContentType indexOfSelectedItem]]];
    [self updateComboBoxTable];
}

- (IBAction) clearPasteboard:(id)sender {
    [_shared clearContents];
    [self updateComboBoxTable];
}

@end
