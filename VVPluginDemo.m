//
//
//  Created by cuichang on 2/4/13.
//  Copyright (c) 2013 cc. All rights reserved.
//

#import "VVPluginDemo.h"
@interface VVPluginDemo()
@property (nonatomic,copy) NSString *selectedText;


@property (nonatomic,assign) NSTextView *textView;
@end


@implementation VVPluginDemo

//+(void)pluginDidLoad:(NSBundle *)plugin {
//    NSLog(@"Hello World");
//}


- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void) applicationDidFinishLaunching: (NSNotification*) noti {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification object:nil];
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        unichar arrowKey = NSDownArrowFunctionKey;
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy lines" action:@selector(showSelected:) keyEquivalent:[NSString stringWithCharacters:&arrowKey length:1]];
        [newMenuItem setTarget:self];
        [newMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask + NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:newMenuItem];
        [newMenuItem release];
    }
    
    
} 

-(void) selectionDidChange:(NSNotification *)noti {
    if ([[noti object] isKindOfClass:[NSTextView class]]) {
        NSTextView* textView = (NSTextView *)[noti object];
         self.textView = textView;
    }
}

-(void) showSelected:(NSNotification *)noti {
    /*
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText: self.selectedText==nil?@"":self.selectedText];
    [alert runModal];
*/

    NSString *currentLineString = [self currentLineString];
    [self.textView moveToEndOfLine:nil];
    [self.textView insertNewline:nil];
    [self.textView insertText:currentLineString];
}

- (NSString*)currentLineString
{
    NSArray* selectedRanges = [self.textView selectedRanges];
    
    
    NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
    NSString* allInsertText = self.textView.textStorage.string;
    
    
    NSString *beforeCursorStr = [allInsertText substringWithRange:NSMakeRange(0, selectedRange.location)];
    NSCharacterSet *charSet = [NSCharacterSet newlineCharacterSet];
    
    int changeLine = 0;
    NSRange newLineRange = [beforeCursorStr rangeOfCharacterFromSet:charSet];
    int lineBeginLocation = 0;
    while (newLineRange.length>0) {
        changeLine++;
        NSLog(@"%ld, %ld changeLine：%d", newLineRange.location ,newLineRange.length ,changeLine);
        lineBeginLocation = lineBeginLocation + newLineRange.location+1;
        newLineRange = [[beforeCursorStr substringFromIndex:lineBeginLocation] rangeOfCharacterFromSet:charSet];
        
    }
    
    NSString *afterCursorStr = [allInsertText substringFromIndex:(selectedRange.location)];
    
    int afterCursorNewLineLoca = 0;
    NSRange afterCursorNewLineRange = [afterCursorStr rangeOfCharacterFromSet:charSet];
    if (afterCursorNewLineRange.length>0) {
        afterCursorNewLineLoca = selectedRange.location+ afterCursorNewLineRange.location;
    }
    else
    {
        afterCursorNewLineLoca = allInsertText.length;
    }
    NSString *currentLineString = [allInsertText substringWithRange:NSMakeRange(lineBeginLocation, afterCursorNewLineLoca-lineBeginLocation)];
    NSLog(@"currentLineString:1%@1",currentLineString);
    currentLineString = [currentLineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"currentLineString:1%@1",currentLineString);
    return currentLineString;
}


+ (void) pluginDidLoad: (NSBundle*) plugin {
    [self shared];
}

+(id) shared {
    static dispatch_once_t once;
    static id instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
