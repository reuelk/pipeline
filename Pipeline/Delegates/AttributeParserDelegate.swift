//
//  AttributeParserDelegate.swift
//  Pipeline
//
//  Created by Reuel Kim on 1/15/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia

/// An XMLParser delegate for parsing attributes in XMLElement objects.
class AttributeParserDelegate: NSObject, XMLParserDelegate {
	
	var attribute: String = ""
	var elementName: String? = nil
	var values: [String] = []
	
	init(element: XMLElement, attribute: String, inElementsWithName elementName: String?) {
		super.init()
		
		self.attribute = attribute
		self.elementName = elementName
		let xmlDoc = XMLDocument(rootElement: element.copy() as? XMLElement)
		let parser = XMLParser(data: xmlDoc.xmlData)
		parser.delegate = self
		parser.parse()
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		
		if self.elementName != nil {
			if elementName == self.elementName! {
				
				for attribute in attributeDict {
					if attribute.0 == self.attribute {
						self.values.append(attribute.1)
					}
				}
			}
			
		} else {
			
			for attribute in attributeDict {
				if attribute.0 == self.attribute {
					self.values.append(attribute.1)
				}
			}
		}
	}
	
}

