//
//  XMLDocumentExtension.swift
//  Pipeline
//
//  Created by Reuel Kim on 1/15/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia

extension XMLDocument: XMLParserDelegate {  //, NSCoding {
	
	enum FCPXMLDocumentError: Error {
		case DTDResourceNotFound
		case DTDResourceUnreadable
	}
	
	// MARK: - Properties
	
	/// The FCPXML document as a properly formatted string.
	public var fcpxmlString: String {
		let formattedData = self.xmlData(options: [XMLNode.Options.nodePrettyPrint, XMLNode.Options.nodeCompactEmptyElement])
		let formattedString = NSString(data: formattedData, encoding: String.Encoding.utf8.rawValue)
		return formattedString as! String
	}
	
	/// The "fcpxml" element at the root of the XMLDocument
	public var fcpxmlElement: XMLElement? {
		get {
			guard let children = self.children else {
				return nil
			}
			
			for child in children {
				let childElement = child as! XMLElement
				
				if childElement.name == "fcpxml" {
					return childElement
				}
			}
			return nil
		}
	}

	/// The "resource" element child of the "fcpxml" element.
	public var fcpxResourceElement: XMLElement? {
		get {
			guard let fcpxmlElement = self.fcpxmlElement, fcpxmlElement.elements(forName: "resources").count > 0 else {
				return nil
			}
			return fcpxmlElement.elements(forName: "resources")[0]
		}
	}
	
	/// An array of all resources in the FCPXML document.
	public var fcpxResources: [XMLElement] {
		get {
			if let resourceNodes = self.fcpxResourceElement?.children {
				return resourceNodes as! [XMLElement]
			} else {
				return []
			}
		}
	}
	
	/// The library XMLElement in the FCPXML document.
	public var fcpxLibraryElement: XMLElement? {
		get {
			guard let fcpxmlElement = self.fcpxmlElement, fcpxmlElement.elements(forName: "library").count > 0 else {
				return nil
			}
			return fcpxmlElement.elements(forName: "library")[0]
		}
	}
	
	/// An array of all event elements in the FCPXML document.
	public var fcpxEvents: [XMLElement] {
		get {
			guard let libraryElement = self.fcpxLibraryElement else {
				return []
			}
			return libraryElement.elements(forName: "event")
		}
	}
	
	/// An array of format resources in the FCPXML document.
	public var fcpxFormatResources: [XMLElement] {
		get {
			return FCPXMLUtility().filter(fcpxElements: self.fcpxResources, ofTypes: [.formatResource])
		}
	}
	
	/// An array of asset resources in the FCPXML document.
	public var fcpxAssetResources: [XMLElement] {
		get {
			return FCPXMLUtility().filter(fcpxElements: self.fcpxResources, ofTypes: [.assetResource])
		}
	}
	
	/// An array of multicam resources in the FCPXML document.
	public var fcpxMulticamResources: [XMLElement] {
		get {
			return FCPXMLUtility().filter(fcpxElements: self.fcpxResources, ofTypes: [.multicamResource])
		}
	}
	
	/// An array of compound clip resources in the FCPXML document.
	public var fcpxCompoundResources: [XMLElement] {
		get {
			return FCPXMLUtility().filter(fcpxElements: self.fcpxResources, ofTypes: [.compoundResource])
		}
	}
	
	/// An array of effect resources in the FCPXML document.
	public var fcpxEffectResources: [XMLElement] {
		get {
			return FCPXMLUtility().filter(fcpxElements: self.fcpxResources, ofTypes: [.effectResource])
		}
	}
	
	/// An array of all projects in all events in the FCPXML document.
	public var fcpxAllProjects: [XMLElement] {
		get {
			var projects: [XMLElement] = []
			for event in self.fcpxEvents {
				guard let eventChildren = event.children else {
					continue
				}
				
				let eventChildrenElements = eventChildren as! [XMLElement]
				
				projects.append(contentsOf: FCPXMLUtility().filter(fcpxElements: eventChildrenElements, ofTypes: [.project]))
			}
			return projects
		}
	}
	
	/// An array of all clips in all events in the FCPXML document.
	public var fcpxAllClips: [XMLElement] {
		get {
			var clips: [XMLElement] = []
			for event in self.fcpxEvents {
				guard let eventChildren = event.children else {
					continue
				}
				
				let eventChildrenElements = eventChildren as! [XMLElement]
				
				clips.append(contentsOf: FCPXMLUtility().filter(fcpxElements: eventChildrenElements, ofTypes: [.clip, .assetClip, .compoundClip, .multicamClip, .synchronizedClip]))
			}
			return clips
		}
	}
	
	/// An array of all roles used in the FCPXML document.
	public var fcpxRoles: [String] {
		get {
			if self.fcpxRoleAttributeValues == [] {
				self.parseFCPXIDsAndRoles()
			}
			
			return self.fcpxRoleAttributeValues
		}
	}
	
	/// The highest resource ID number used in the FCPXML document.
	public var fcpxLastResourceID: Int {
		get {
			self.parseFCPXIDsAndRoles()
			
			if let last = self.fcpxResourceIDs.last {
				return last
			}
			
			return 0
		}
	}
	
	/// The highest text style ID number used in the FCPXML document.
	public var fcpxLastTextStyleID: Int {
		get {
			self.parseFCPXIDsAndRoles()
			
			if let last = self.fcpxTextStyleIDs.last {
				return last
			}
			
			return 0
		}
	}
	
	// The FCPXML version number is obtained here, not during parsing. This way, the version number can be checked before parsing, which could break depending on the FCPXML version.
	public var fcpxmlVersion: Float? {
		get {
			guard let children = self.children else {
				return nil
			}
			
			for child in children {
				let childElement = child as! XMLElement
				
				if childElement.name == "fcpxml" {
					guard let version = childElement.attribute(forName: "version") else {
						return nil
					}
					
					let versionNumber = Float(version.stringValue!)
					
					return versionNumber
				}
			}
			
			return nil
		}
		
		set (value){
			
			if value != nil {
				let version = XMLNode.attribute(withName: "version", stringValue: String(value!))
				self.rootElement()?.addAttribute(version as! XMLNode)
			} else {
				self.rootElement()?.removeAttribute(forName: "version")
			}
		}
	}
	
	/// The names of all events as a String array.
	public var fcpxEventNames: [String] {
		get {
			var names: [String] = []
			
			for event in self.fcpxEvents {
				guard let name = event.fcpxName else {
					continue
				}
				
				names.append(name)
			}
			
			return names
		}
	}
	
	/// All items from all events as a XMLElement array.
	public var fcpxAllEventItems: [XMLElement] {
		get {
			var allItems: [XMLElement] = []
			
			for event in self.fcpxEvents {
				
				guard let eventItems = event.eventItems else {
					continue
				}
				
				allItems.append(contentsOf: eventItems)
			}
			
			return allItems
		}
	}
	
	/// The names of all items from all events as a XMLElement array.
	public var fcpxAllEventItemNames: [String] {
		get {
			var names: [String] = []
			
			for event in self.fcpxEvents {
				
				guard let clips = event.eventClips else {
					continue
				}
				
				for clip in clips {
					
					guard let name = clip.fcpxName else {
						continue
					}
					
					names.append(name)
					
				}
			}
			
			return names
		}
	}
	
	/// The names of all projects from all events as a XMLElement array.
	public var fcpxAllProjectNames: [String] {
		get {
			var names: [String] = []
			
			for project in self.fcpxAllProjects {
				guard let name = project.fcpxName else {
					continue
				}
				
				names.append(name)
			}
			
			return names
			
		}
	}
	
	// MARK: - Private Variables
	private struct ParsedData {
		static var resourceIDs = "resourceIDs"
		static var textStyleIDs = "textStyleIDs"
		static var roles = "roles"
	}
	
	private var fcpxResourceIDs: [Int] {
		get {
			guard (objc_getAssociatedObject(self, &ParsedData.resourceIDs)) != nil else {
				return []
			}
			
			return objc_getAssociatedObject(self, &ParsedData.resourceIDs) as! [Int]
		}
		set {
			objc_setAssociatedObject(self, &ParsedData.resourceIDs, newValue as [Int], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	private var fcpxTextStyleIDs: [Int] {
		get {
			guard (objc_getAssociatedObject(self, &ParsedData.textStyleIDs)) != nil else {
				return []
			}
			
			return objc_getAssociatedObject(self, &ParsedData.textStyleIDs) as! [Int]
		}
		set {
				objc_setAssociatedObject(self, &ParsedData.textStyleIDs, newValue as [Int], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	private var fcpxRoleAttributeValues: [String] {
		get {
			guard (objc_getAssociatedObject(self, &ParsedData.roles)) != nil else {
				return []
			}
			
			return objc_getAssociatedObject(self, &ParsedData.roles) as! [String]
		}
		set {
			objc_setAssociatedObject(self, &ParsedData.roles, newValue as [String], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	
	// MARK: - Private Methods
	private func xmlElementArrayToStringArray(usingXMLArray XMLArray: [XMLElement]) -> [String] {
		var stringArray: [String] = []
		for XMLElement in XMLArray {
			stringArray.append(XMLElement.xmlString)
		}
		return stringArray
	}
	
	private func stringArrayToXMLElementArray(usingStringArray stringArray: [String]) -> [XMLElement] {
		var XMLElementArray: [XMLElement] = []
		for stringItem in stringArray {
			do {
				XMLElementArray.append(try XMLElement(xmlString: stringItem))
			} catch {
				continue
			}
		}
		return XMLElementArray
	}
	
	
	// MARK: - Initializers
	
	/// Initializes a new XMLDocument using the contents of an existing FCPXML file.
	///
	/// - Parameter URL: The URL to the FCPXML file.
	/// - Throws: An error object that, on return, identifies any parsing errors and warnings or connection problems.
	public convenience init(contentsOfFCPXML URL: Foundation.URL) throws {
		
		do {
			try self.init(contentsOf: URL, options: [XMLNode.Options.nodePrettyPrint, XMLNode.Options.nodeCompactEmptyElement])
		}
	}
	
	
	/// Initializes a new XMLDocument as FCPXML.
	///
	/// - Parameters:
	///   - resources: Resources an array of XMLElement objects
	///   - events: Events as an array of XMLElement objects
	///   - fcpxmlVersion: The FCPXML version of the document to use.
	public convenience init(resources: [XMLElement], events: [XMLElement], fcpxmlVersion: Float) {
		
		self.init()
		self.documentContentKind = XMLDocument.ContentKind.xml
		self.characterEncoding = "UTF-8"
		self.version = "1.0"
		
		self.dtd = XMLDTD()
		self.dtd!.name = "fcpxml"
		self.isStandalone = false
		
		self.setRootElement(XMLElement(name: "fcpxml"))
		self.fcpxmlVersion = 1.6
		
		self.add(resourceElements: resources)
		self.add(events: events)
		
	}

	
	// MARK: - Parsing Functions
	
	/// Parses the resource IDs, text style IDs, and roles, refreshing the fcpxLastResourceID, fcpxLastTextStyleID, and fcpxRoles properties. Call this method when initially loading an FCPXML document and when the IDs or roles change.
	public func parseFCPXIDsAndRoles() {
		print("Parsing IDs and Roles...")
		
		let xmlParser = XMLParser(data: self.xmlData)
		xmlParser.delegate = self
		
		// Parse the attributes using NSXMLParserDelegate
		xmlParser.parse()
		
		self.fcpxResourceIDs = self.fcpxResourceIDs.sorted()
		self.fcpxTextStyleIDs = self.fcpxTextStyleIDs.sorted()
		
		// Filter out duplicate role values
		var roles: [String] = []
		for value in self.fcpxRoleAttributeValues {
			if roles.contains(value) == false {
				roles.append(value)
			}
		}
		self.fcpxRoleAttributeValues = roles
	}
	
	
	/**
	
	*/
	
	/// An NSXMLParserDelegate function that retrieves the last resource ID and text style ID from an FCPXML file.
	///
	/// This method should not be called explicitly. Call the method parseFCPXIDsAndRoles() instead.
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		
		for (key, value) in attributeDict {
			if key == "id" {
				
				if value.substring(to: value.characters.index(value.startIndex, offsetBy: 1)) == "r" { // The first letter of the value is "r" for resource
					let ID = Int(value.substring(from: value.characters.index(value.startIndex, offsetBy: 1)))
					if let ID = ID {
						self.fcpxResourceIDs.append(ID)
					}
				}
				
				if value.substring(to: value.characters.index(value.startIndex, offsetBy: 2)) == "ts" { // The first two letters of the value are "ts" for text style
					let ID = Int(value.substring(from: value.characters.index(value.startIndex, offsetBy: 2)))
					if let ID = ID {
						self.fcpxTextStyleIDs.append(ID)
					}
				}
				
			} else if key == "role" {
				self.fcpxRoleAttributeValues.append(value)
			}
		}
		
	}
	
	
	
	// MARK: - Retrieval Functions
	/**
	Returns the resource that matches the given ID string.
	
	- parameter matchingID: The resource ID as a string in the form of "r1"
	
	- returns: The matching resource NSXMLElement
	*/
	public func resource(matchingID ID: String) -> XMLElement? {
		
		for resource in self.fcpxResources {
			if resource.fcpxID == ID {
				return resource
			}
		}
		
		return nil
	}
	
	
	
	/// Returns asset resources that match the given URL.
	///
	/// - Parameters:
	///   - matchingURL: The URL to match with.
	///   - usingFilenameOnly: True if matching with just the filename, false if matching with the entire URL path.
	///   - omittingExtension: True if matching without the extension in the filename, false if matching with the entire filename.
	///   - caseSensitive: True if the search should be case sensitive, false if it should not.
	/// - Returns: An array of XMLElement objects that are matching asset resources.
	public func assetResources(matchingURL url: URL, usingFilenameOnly: Bool, omittingExtension: Bool, caseSensitive: Bool) -> [XMLElement] {
		
		let matchURL: URL
		
		if omittingExtension == true {
			matchURL = url.deletingPathExtension()
		} else {
			matchURL = url
		}
		
		var matchPath: String
		
		if usingFilenameOnly == true {
			matchPath = matchURL.lastPathComponent
		} else {
			matchPath = matchURL.path
		}
		
		if caseSensitive == false {
			matchPath = matchPath.uppercased()
		}

		var matchingAssets: [XMLElement] = []
		
		for asset in self.fcpxAssetResources {
			
			guard let assetSrc = asset.fcpxSrc else {
				continue
			}
			
			let assetURL: URL
			
			if omittingExtension == true {
				assetURL = assetSrc.deletingPathExtension()
			} else {
				assetURL = assetSrc
			}
			
			var assetPath: String
			
			if usingFilenameOnly == true {
				assetPath = assetURL.lastPathComponent
			} else {
				assetPath = assetURL.path
			}
			
			if caseSensitive == false {
				assetPath = assetPath.uppercased()
			}
			
			// Check for a match
			if assetPath == matchPath {
				matchingAssets.append(asset)
			}
			
		}
		
		return matchingAssets
		
	}

	
	
	// MARK: - Modification Functions
	
	/// Adds a resource XMLElement to the FCPXML document.
	///
	/// - Parameter resourceElement: The XMLElement of the resource to be added.
	public func add(resourceElement: XMLElement) {
		if self.fcpxResourceList == nil {
			self.rootElement()?.insertChild(XMLElement(name: "resources"), at: 0)
		}
		
		self.fcpxResourceList?.addChild(resourceElement)
	}
	
	
	/// Adds an array of resource XMLElements to the FCPXML document.
	///
	/// - Parameter resourceElements: An array of resource XMLElement objects.
	public func add(resourceElements: [XMLElement]) {
		for resource in resourceElements {
			self.add(resourceElement: resource)
		}
	}
	
	
	/// Removes the resource at the specified index.
	/// - Important: This method will remove all associated clips from all events in the FCPXML document. However, it will not remove synchronized clips, compound clips and multicams that contain the resource.
	///
	/// - Parameter index: The index of the resource within the resources element.
	public func remove(resourceAtIndex index: Int) {
		let resource = self.fcpxResourceList?.child(at: index) as! XMLElement
		guard let resourceID = resource.fcpxID else {
			return
		}
		
		// Remove associated clips from all events
		for event in fcpxEvents {
			
			let eventClips: [XMLElement]
			do {
				eventClips = try event.eventClips(forResourceID: resourceID)
			} catch {
				continue
			}
			
			for clip in eventClips {
				event.removeChild(at: clip.index)
			}
		}
		
		self.fcpxResourceList?.removeChild(at: index)
	}
	
	
	/// Removes all resources from the FCPXML document.
	public func removeAllResources() {
		self.fcpxResourceList?.setChildren(nil)
	}
	
	
	/// Adds an event to the library XMLElement of the FCPXML document.
	///
	/// - Parameter event: The XMLElement of the event to be added.
	public func add(event: XMLElement) {
		if self.fcpxLibrary == nil {
			self.rootElement()?.addChild(XMLElement(name: "library"))
		}
		
		if let lastEvent = self.fcpxEvents.last {
			self.fcpxLibrary?.insertChild(event, at: lastEvent.index + 1)
		} else {
			self.fcpxLibrary?.insertChild(event, at: 0)
		}
	}
	
	
	/// Adds an array of event XMLElements to the FCPXML document.
	///
	/// - Parameter events: An array of event XMLElement objects.
	public func add(events: [XMLElement]) {
		for event in events {
			self.add(event: event)
		}
	}
	
	
	/// Removes the event at the specified index.
	///
	/// - Parameter index: The index of the event within the library element.
	public func remove(eventAtIndex index: Int) {
		self.fcpxLibrary?.removeChild(at: index)
	}
	
	
	/// Removes all events from the library.
	public func removeAllEvents() {
		for event in self.fcpxEvents {
			self.fcpxLibrary?.removeChild(at: event.index)
		}
		
	}
	
	
	
	// TODO: Add functions for adding a resource and event clip in one swoop. Also add functions for removing a resource, event clip, and associated clips in a project in one swoop.
	
	// MARK: - DTD Functions
	
	/// Returns the version numbers of the DTD documents included in this framework bundle.
	///
	/// - Returns: An array of String objects.
	public func fcpxmlDTDVersions() -> [String] {
		var versions: [String] = []
		
		var dtdURLs: [URL] = []
		
		for frameworkBundle in Bundle.allFrameworks {
			guard let urls = frameworkBundle.urls(forResourcesWithExtension: "dtd", subdirectory: "DTDs") else {
				continue
			}
			
			dtdURLs.append(contentsOf: urls)
		}
		
		for url in dtdURLs {
			let filename = url.deletingPathExtension().lastPathComponent
			guard filename.hasPrefix("FCPXML_") == true else {
				continue
			}
			
			let versionNumber = String(filename.dropFirst(7))
			
			versions.append(versionNumber)
		}
		
		return versions
	}
	
	/// Validates the XMLDocument against the DTD of the latest FCPXML version included in this framework. The XMLDocument is valid if no error is thrown.
	///
	/// - Throws: An error describing the reason for the XML being invalid or another error, such as not being able to read or set the associated DTD file.
	public func validateFCPXMLAgainstLatestVersion() throws {
		do {
			try self.validateFCPXMLAgainst(version: "1.8")
		} catch {
			throw error
		}
	}
	
	
	/// Validates the XMLDocument against the DTD of the FCPXML version specified. The version number must match a DTD resource included in the bundle. The XMLDocument is valid if no error is thrown.
	///
	/// - Parameter version: A String of the version number.
	/// - Throws: An error describing the reason for the XML being invalid or another error, such as not being able to read or set the associated DTD file.
	public func validateFCPXMLAgainst(version: String) throws {
		do {
			try self.setDTDToFCPXML(version: version)
		} catch {
			print("Error setting the DTD.")
			self.dtd = nil
			throw error
		}
		
		do {
			try self.validate()
		} catch {
			print("The document is invalid.")
			self.dtd = nil
			throw error
		}
		
		print("The document is valid.")
		self.dtd = nil
	}
	
	
	/// Sets the XMLDocument's DTD to the specified FCPXML version number. The version number must match a DTD resource included in the bundle with the filename pattern `FCPXML_Y` where Y is the version number.
	///
	/// - Parameter version: The version number as a String.
	/// - Throws: If the DTD file cannot be read properly, an error is thrown describing the issue.
	private func setDTDToFCPXML(version: String) throws {
		do {
			let resourceName = "FCPXML_" + version
			do {
				try self.setDTDToBundleResource(named: resourceName)
			} catch {
				throw error
			}
		}
	}
	
	
	/// Sets the DTD to a specified bundle resource in this framework.
	///
	/// - Parameter name: The name of the resource as a String. Do not include the extension of the filename. It is assumed to be "dtd".
	/// - Throws: An FCPXMLDocumentError or an error describing why the file cannot be read.
	private func setDTDToBundleResource(named name: String) throws {
		var dtdURL: URL? = nil
		
		for frameworkBundle in Bundle.allFrameworks {
			if let fileURL = frameworkBundle.url(forResource: name, withExtension: "dtd", subdirectory: "DTDs") {
				dtdURL = fileURL
			}
		}
		
		guard let unwrappedURL = dtdURL else {
			print("Couldn't find the DTD file.")
			throw FCPXMLDocumentError.DTDResourceNotFound
		}
		
		do {
			self.dtd? = try XMLDTD(contentsOf: unwrappedURL, options: [XMLNode.Options.nodePrettyPrint, XMLNode.Options.nodeCompactEmptyElement])
		} catch {
			print("Error reading the DTD file.")
			throw error
		}
		
		if self.dtd != nil {
			self.dtd!.name = "fcpxml"
			self.isStandalone = false
			
			print("DTD set successfully.")
			return
			
		} else {
			print("Failed to set the DTD.")
			return
		}
	}
	
	
	
}
