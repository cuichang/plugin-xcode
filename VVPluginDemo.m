//
//
//  created by cuichang on 2/4/13.  cuichangdashi@gmail.com
//  Copyright (c) 2013 cc. All rights reserved.
//


#import "VVPluginDemo.h"
@interface VVPluginDemo()
@property (nonatomic,copy) NSString *selectedText;


@property (nonatomic,assign) NSTextView *textView;
@end


@implementation VVPluginDemo


- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)copyToNextLine:(NSNotification *)noti
{
    /*
     NSAlert *alert = [[[NSAlert alloc] init] autorelease];
     [alert setMessageText: self.selectedText==nil?@"":self.selectedText];
     
     */
    
    NSString *currentLineString = [self currentLineString];
    [self.textView moveToEndOfLine:nil];
    [self.textView insertNewline:nil];
    [self.textView insertText:currentLineString];
}

- (void)copyToPreviousLine:(NSNotification *)noti 
{
    NSString *currentLineString = [self currentLineString];
    [self.textView moveToBeginningOfLine:nil];
    [self.textView insertText:currentLineString];
    [self.textView insertNewline:nil];
    
}

- (void)uppercaseSelect:(NSNotification *)noti
{
    NSArray *selectedRanges = [self.textView selectedRanges];
    NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
    NSString *allInsertText = self.textView.textStorage.string;
    NSString *selectString = [allInsertText substringWithRange:selectedRange];
    
    NSString *upperString = [selectString uppercaseString];
    NSLog(@"uppercaseSelect selectString:%@ location:%ld ,length:%ld upperString:%@",selectString,(unsigned long)selectedRange.location,(unsigned long)selectedRange.length,upperString);
    [self.textView replaceCharactersInRange:selectedRange withString:upperString];
    [self.textView setSelectedRange:selectedRange];
    
}

- (void)lowercaseSelect:(NSNotification *)noti
{
    NSArray *selectedRanges = [self.textView selectedRanges];
    NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
    NSString *allInsertText = self.textView.textStorage.string;
    NSString *selectString = [allInsertText substringWithRange:selectedRange];
    
    NSString *lowerString = [selectString lowercaseString];
    NSLog(@"lowercaseSelect selectString:%@ location:%ld ,length:%ld lowerString:%@",selectString,(unsigned long)selectedRange.location,(unsigned long)selectedRange.length,lowerString);
    
    [self.textView replaceCharactersInRange:selectedRange withString:lowerString];
    [self.textView setSelectedRange:selectedRange];
    
}

- (void)deleteLine:(NSNotification *)noti
{
    [self.textView moveToBeginningOfLine:nil];
    [self.textView deleteToEndOfLine:nil];
    [self.textView deleteForward:nil];
}

- (void) applicationDidFinishLaunching: (NSNotification*) noti {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification object:nil];
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        unichar arrowKeyDown = NSDownArrowFunctionKey;
        NSMenuItem *copyToNextMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy lines to next" action:@selector(copyToNextLine:) keyEquivalent:[NSString stringWithCharacters:&arrowKeyDown length:1]];
        [copyToNextMenuItem setTarget:self];
        [copyToNextMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask + NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:copyToNextMenuItem];
        [copyToNextMenuItem release];
        
        
        unichar arrowKeyUp = NSUpArrowFunctionKey; 
        NSMenuItem *copyToPreviousMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy lines to previous" action:@selector(copyToPreviousLine:) keyEquivalent:[NSString stringWithCharacters:&arrowKeyUp length:1]];
        [copyToPreviousMenuItem setTarget:self];
        [copyToPreviousMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask + NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:copyToPreviousMenuItem];
        [copyToPreviousMenuItem release];
        
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        
        NSMenuItem *upCaseMenuItem = [[NSMenuItem alloc] initWithTitle:@"Uppercase" action:@selector(uppercaseSelect:) keyEquivalent:@"p"];
        [upCaseMenuItem setTarget:self];
        [upCaseMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask + NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:upCaseMenuItem];
        [upCaseMenuItem release];
        
        NSMenuItem *LowerCaseMenuItem = [[NSMenuItem alloc] initWithTitle:@"LowerCase" action:@selector(lowercaseSelect:) keyEquivalent:@"y"];
        [LowerCaseMenuItem setTarget:self];
        [LowerCaseMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask + NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:LowerCaseMenuItem];
        [LowerCaseMenuItem release];
        
        
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *deleteLineMenuItem = [[NSMenuItem alloc] initWithTitle:@"Delete line" action:@selector(deleteLine:) keyEquivalent:@"d"];
        [deleteLineMenuItem setTarget:self];
        [deleteLineMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        [[editMenuItem submenu] addItem:deleteLineMenuItem];
        [deleteLineMenuItem release];
        
        
    }
    
    
} 

- (void)selectionDidChange:(NSNotification *)noti {
    if ([[noti object] isKindOfClass:[NSTextView class]]) {
        NSTextView* textView = (NSTextView *)[noti object];
         self.textView = textView;
    }
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
        lineBeginLocation = lineBeginLocation + (int)newLineRange.location+1;
        newLineRange = [[beforeCursorStr substringFromIndex:lineBeginLocation] rangeOfCharacterFromSet:charSet];
        
    }
    
    NSString *afterCursorStr = [allInsertText substringFromIndex:(selectedRange.location)];
    
    int afterCursorNewLineLoca = 0;
    NSRange afterCursorNewLineRange = [afterCursorStr rangeOfCharacterFromSet:charSet];
    if (afterCursorNewLineRange.length>0) {
        afterCursorNewLineLoca = (int)selectedRange.location+ (int)afterCursorNewLineRange.location;
    }
    else
    {
        afterCursorNewLineLoca = (int)allInsertText.length;
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
