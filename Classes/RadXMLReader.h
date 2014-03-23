//
//  RadXMLReader.h
//  Rad
//
//  Created by Tim Burks on 9/18/11.
//  Copyright (c) 2011 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RadXMLNode : NSObject 
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *namespaceURI;

@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSMutableDictionary *attributes;

- (NSString *) universalName;

- (NSDictionary *) dictionaryRepresentationWithSchema:(NSDictionary *) schema;
@end

@interface RadXMLReader : NSObject {
    NSMutableArray *xmlStack;
}
@property (nonatomic, strong) RadXMLNode *rootNode;
@property (nonatomic, strong) NSError *error;
- (id) readXMLFromString:(NSString *) string error:(NSError **) error;
@end

