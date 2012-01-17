//
//  RadXMLReader.m
//  Rad
//
//  Created by Tim Burks on 9/18/11.
//  Copyright (c) 2011 Radtastical Inc. All rights reserved.
//

#import "RadXMLReader.h"
#include <libxml/xmlreader.h>

@interface RadXMLTextNode : NSObject
@property (nonatomic, retain) NSString *text;
@end

@implementation RadXMLTextNode
@synthesize text;

- (NSString *) stringValue {
    return text;
}

@end

@implementation RadXMLNode
@synthesize name, children, attributes;

- (id) init {
    if ((self = [super init])) {
        self.children = [NSMutableArray array];
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) dealloc {
    self.children = nil;
    self.name = nil;
    [super dealloc];
}

- (NSString *) stringContents {
    NSMutableString *result = [NSMutableString string];
    for (id child in children) {
        [result appendString:[child stringValue]];
    }
    return result;
}

- (NSString *) stringValue {
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"<"];
    [result appendString:name];
    for (id key in [self.attributes allKeys]) {
        [result appendFormat:@" %@=\"%@\"", key, [self.attributes objectForKey:key]];    
    }
    [result appendString:@">"];
    [result appendString:[self stringContents]];
    [result appendString:@"</"];
    [result appendString:name];
    [result appendString:@">\n"];
    return result;
}

- (NSString *) description {
    return [self stringValue];
}

- (NSDictionary *) dictionaryRepresentationWithSchema:(NSDictionary *) schema {
  
    
    NSDictionary *arrayNames = [schema objectForKey:@"arrayNames"];
    NSArray *terminalNames = [schema objectForKey:@"terminalNames"];
    

    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id key in [self.attributes allKeys]) {
        [result setObject:[self.attributes objectForKey:key] forKey:key];    
    }
    for (id child in children) {
        NSString *childName = [child name];
        NSString *arrayName = [arrayNames objectForKey:childName];
        if (arrayName) {
            NSMutableArray *childArray = [result objectForKey:arrayName];
            if (!childArray) {
                childArray = [NSMutableArray array];
                [result setObject:childArray forKey:arrayName];
            }
            [childArray addObject:[child dictionaryRepresentationWithSchema:schema]];
        } else if ([terminalNames containsObject:childName]) {
            [result setObject:[child stringContents] forKey:childName];
        } else {
            [result setObject:[child dictionaryRepresentationWithSchema:schema] forKey:childName];
        }
    }
    return result;
}

@end

@implementation RadXMLReader
@synthesize rootNode;

- (id) init {
    if ((self = [super init])) {
        xmlStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    [xmlStack release];
    [rootNode release];
    [super dealloc];
}

- (void) processNode:(xmlTextReaderPtr) reader {
    
    xmlChar *node_name = xmlTextReaderName(reader);
    if (node_name == NULL)
        node_name = xmlStrdup(BAD_CAST "--");
    xmlChar *node_value = xmlTextReaderValue(reader);
    
    // int node_depth = xmlTextReaderDepth(reader);
    int node_type = xmlTextReaderNodeType(reader);
    int node_isempty = xmlTextReaderIsEmptyElement(reader);
    int node_hasattributes = xmlTextReaderHasAttributes(reader);
    
    if (node_type == XML_READER_TYPE_SIGNIFICANT_WHITESPACE) {
        return;
    }
    if (node_type == XML_READER_TYPE_COMMENT) {
        return;
    }
    if (node_type == XML_READER_TYPE_END_ELEMENT) {
        // NSLog(@"closing node %s", node_name);
        RadXMLNode *lastObject = [xmlStack lastObject];
        [xmlStack removeLastObject];
        RadXMLNode *newLastObject = [xmlStack lastObject];
        [newLastObject.children addObject:lastObject];
        return;
    }
    if (node_type == XML_READER_TYPE_TEXT) {
        // NSLog(@"xml text %s:%s", node_name, node_value);
        RadXMLTextNode *node = [[[RadXMLTextNode alloc] init] autorelease];
        node.text = [NSString stringWithCString:(const char *)node_value encoding:NSUTF8StringEncoding];
        RadXMLNode *lastObject = [xmlStack lastObject];
        [[lastObject children] addObject:node];
        return;
    }
    if (node_type == XML_READER_TYPE_ELEMENT) {
        // NSLog(@"opening node %s", node_name);
        RadXMLNode *node = [[[RadXMLNode alloc] init] autorelease];
        node.name = [NSString stringWithCString:(const char *)node_name encoding:NSUTF8StringEncoding];
        [xmlStack addObject:node];
        if (!rootNode) {
            self.rootNode = node;
        }
        /*
         XML_READER_TYPE_NONE = 0,
         XML_READER_TYPE_ELEMENT = 1,
         XML_READER_TYPE_ATTRIBUTE = 2,
         XML_READER_TYPE_TEXT = 3,
         XML_READER_TYPE_CDATA = 4,
         XML_READER_TYPE_ENTITY_REFERENCE = 5,
         XML_READER_TYPE_ENTITY = 6,
         XML_READER_TYPE_PROCESSING_INSTRUCTION = 7,
         XML_READER_TYPE_COMMENT = 8,
         XML_READER_TYPE_DOCUMENT = 9,
         XML_READER_TYPE_DOCUMENT_TYPE = 10,
         XML_READER_TYPE_DOCUMENT_FRAGMENT = 11,
         XML_READER_TYPE_NOTATION = 12,
         XML_READER_TYPE_WHITESPACE = 13,
         XML_READER_TYPE_SIGNIFICANT_WHITESPACE = 14,
         XML_READER_TYPE_END_ELEMENT = 15,
         XML_READER_TYPE_END_ENTITY = 16,
         XML_READER_TYPE_XML_DECLARATION = 17
         */
        
        if (node_hasattributes) {         
            int more = xmlTextReaderMoveToNextAttribute(reader);
            while (more) {
                int nodeType = xmlTextReaderNodeType(reader);
                const char *name = (const char *) xmlTextReaderName(reader);
                const char *value = (const char *) xmlTextReaderValue(reader);
                // NSLog(@"attribute: %s=%s", name, value);
                if (nodeType == XML_READER_TYPE_ATTRIBUTE) {                    
                    RadXMLNode *topObject = [xmlStack lastObject];
                    [topObject.attributes setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];                    
                }            
                more = xmlTextReaderMoveToNextAttribute(reader);
            }            
        }
        
        if (node_isempty) {            
            id lastObject = [xmlStack lastObject];
            NSLog(@"last object %@", lastObject);            
            [xmlStack removeLastObject];
            RadXMLNode *newLastObject = [xmlStack lastObject];
            [newLastObject.children addObject:lastObject];
        }
    }
    xmlFree(node_name);
    if (node_value) {
        xmlFree(node_value);
    }
}

- (id) readXMLFromString:(NSString *)string {
    if (!string) 
        return nil;
    const char *buffer = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int size = (int) strlen(buffer);    
    xmlTextReaderPtr reader = xmlReaderForMemory(buffer, size, "", NULL, XML_PARSE_NOBLANKS|XML_PARSE_DTDVALID);
                                                 // XML_PARSE_DTDVALID
    // to read directly from a file, use this:    
    // xmlTextReaderPtr reader = xmlNewTextReaderFilename([filename UTF8String]);
    if (reader != NULL) {
        int ret = xmlTextReaderRead(reader);
        while (ret == 1) {
            [self processNode:reader];
            ret = xmlTextReaderRead(reader);
        }
        xmlFreeTextReader(reader);
        if (ret != 0) {
            NSLog(@"failed to parse HTML");
        }
    } else {
        NSLog(@"Unable to open HTML");
    }    
    // the stack should be empty now
    [xmlStack removeAllObjects];    
    return self.rootNode;
}

@end

