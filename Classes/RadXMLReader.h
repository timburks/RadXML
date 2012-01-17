//
//  RadXMLReader.h
//  Rad
//
//  Created by Tim Burks on 9/18/11.
//  Copyright (c) 2011 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RadXMLNode : NSObject 
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain) NSMutableDictionary *attributes;
- (NSDictionary *) dictionaryRepresentationWithSchema:(NSDictionary *) schema;
@end

@interface RadXMLReader : NSObject {
    NSMutableArray *xmlStack;
}
@property (nonatomic, retain) RadXMLNode *rootNode;
- (id) readXMLFromString:(NSString *) string;
@end

