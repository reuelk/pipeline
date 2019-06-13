//
//  FCPXMLDocument.swift
//  Pipeline
//
//  Created by Reuel Kim on 4/10/18.
//  Copyright © 2018 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia

class FCPXMLDocument: XMLDocument {
	
	// MARK: - XMLDocument Class Overrides
	override init() {
		super.init()
	}
	
	override init(data: Data, options mask: XMLNode.Options = []) throws {
		do {
			try super.init(data: data, options: mask)
		} catch {
			throw error
		}
	}
	
	override func rootElement() -> XMLElement? {
		return super.rootElement()
	}
	
	override func setChildren(_ children: [XMLNode]?) {
		super.setChildren(children)
	}
	
	override func removeChild(at index: Int) {
		super.removeChild(at: index)
	}

	override func insertChild(_ child: XMLNode, at index: Int) {
		super.insertChild(child, at: index)
	}
	
	override var characterEncoding: String? {
		get {
			return super.characterEncoding
		}
		set {
			super.characterEncoding = newValue
		}
	}
	
	override var documentContentKind: XMLDocument.ContentKind {
		get {
			return super.documentContentKind
		}
		set {
			super.documentContentKind = newValue
		}
	}
	
	override var dtd: XMLDTD? {
		get {
			return super.dtd
		}
		set {
			super.dtd = newValue
		}
	}
	
	override var mimeType: String? {
		get {
			return super.mimeType
		}
		set {
			super.mimeType = newValue
		}
	}
	
	override var isStandalone: Bool {
		get {
			return super.isStandalone
		}
		set {
			super.isStandalone = newValue
		}
	}
	
	override var uri: String? {
		get {
			return super.uri
		}
		set {
			super.uri = newValue
		}
	}
	
	override var version: String? {
		get {
			return super.version
		}
		set {
			super.version = newValue
		}
	}
	
	// MARK: - Subclass Properties
	
	// MARK: - Subclass Functions
	public init(URL: URL) throws {
		
		do {
			let data = try Data.init(contentsOf: URL)
			try super.init(data: data, options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement])
		} catch {
			print("Could not initialize the FCPXMLDocument from the given URL.")
			throw error
		}
	}
	
	
	
}
