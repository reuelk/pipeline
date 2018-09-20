//
//  FCPXMLParserDelegate.swift
//  Pipeline
//
//  Created by Reuel Kim on 6/1/18.
//  Copyright © 2018 Reuel Kim. All rights reserved.
//

import Foundation

/// An XMLParser delegate for parsing roles and IDs from FCPXML documents.
class FCPXMLParserDelegate: NSObject, XMLParserDelegate {

	/// All roles found by the parser
	private var foundRoles: [String] = []
	
	/// All resource IDs found by the parser
	private var foundResourceIDs: [String] = []
	
	/// All text style IDs found by the parser
	private var foundTextStyleIDs: [String] = []
	
	
	/// The unique role values found
	var roles: [String] {
		get {
			var uniqueRoles: [String] = []
			for role in self.foundRoles {
				if uniqueRoles.contains(role) == false {
					uniqueRoles.append(role)
				}
			}
			return uniqueRoles
		}
	}
	
	/// The unique resource ID strings found
	var resourceIDs: [String] {
		get {
			var uniqueIDs: [String] = []
			for id in self.foundResourceIDs {
				
				if uniqueIDs.contains(id) == false {
					uniqueIDs.append(id)
				}
			}
			return uniqueIDs
		}
	}
	
	/// The unique ID numbers from resource IDs that follow the convention "rN" where N is an integer.
	var resourceIDNumbers: [Int] {
		get {
			var idNumbers: [Int] = []
			for resourceID in resourceIDs {
				let idSlice = resourceID.suffix(from: resourceID.index(resourceID.startIndex, offsetBy: 1))
				if let ID = Int(idSlice) {
					idNumbers.append(ID)
				}
			}
			return idNumbers.sorted()
		}
	}
	
	/// The largest resource ID number used in the document.
	var lastResourceIDNumber: Int {
		get {
			guard let last = self.resourceIDNumbers.sorted().last else {
				return 0
			}
			return last
		}
	}
	
	/// The unique text style ID strings found
	var textStyleIDs: [String] {
		get {
			var uniqueIDs: [String] = []
			for id in self.foundTextStyleIDs {
				
				if uniqueIDs.contains(id) == false {
					uniqueIDs.append(id)
				}
			}
			return uniqueIDs
		}
	}
	
	/// The unique ID numbers from text style IDs that follow the convention "tsN" where N is an integer.
	var textStyleIDNumbers: [Int] {
		get {
			var idNumbers: [Int] = []
			for textStyleID in textStyleIDs {
				let idSlice = textStyleID.suffix(from: textStyleID.index(textStyleID.startIndex, offsetBy: 2))
				if let ID = Int(idSlice) {
					idNumbers.append(ID)
				}
			}
			return idNumbers.sorted()
		}
	}
	
	/// The largest text style ID number used in the document.
	var lastTextStyleIDNumber: Int {
		get {
			guard let last = self.textStyleIDNumbers.sorted().last else {
				return 0
			}
			return last
		}
	}
	
	/// An XMLParserDelegate function that retrieves roles and resource IDs from an FCPXML file.
	///
	/// This method should not be called explicitly. Call the method parseFCPXIDsAndRoles() instead.
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		
		for (key, value) in attributeDict {
			switch key {
			case "id":
				if value.prefix(2) == "ts" { // The first letter of the value is "ts" for resource
					self.foundTextStyleIDs.append(value)
				} else if value.prefix(1) == "r" { // The first letter of the value is "r" for resource
					self.foundResourceIDs.append(value)
				}
				
			case "role":
				self.foundRoles.append(value)

			default:
				break
			}
		}
		
	}
	
}
