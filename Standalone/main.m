//
//  main.m
//  RadXMLReader
//
//  Created by Tim Burks on 1/16/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadXMLReader.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {   
        chdir("/Users/tim/Desktop/Radtastica/SYBD/meta/data");
        NSString *string = [NSString stringWithContentsOfFile:@"tips.xml" 
                                                     encoding:NSUTF8StringEncoding error:nil];
        
        RadXMLReader *reader = [[RadXMLReader alloc] init];
        RadXMLNode *stuff = [reader readXMLFromString:string];            
        NSLog(@"%@", stuff);
        
        NSDictionary *schema = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSDictionary dictionaryWithObjectsAndKeys:                                
                                 @"tips", @"tip", 
                                 nil], 
                                @"arrayNames",
                                [NSArray arrayWithObjects:@"text", @"title", nil], 
                                @"terminalNames",
                                nil];
                        
        
        NSLog(@"%@", [stuff dictionaryRepresentationWithSchema:schema]);
        [reader release];
    }
    return 0;
}

