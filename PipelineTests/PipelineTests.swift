//
//  PipelineTests.swift
//  PipelineTests
//
//  Created by Reuel Kim on 1/1/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import XCTest
@testable import Pipeline

class PipelineTests: XCTestCase {
	
	var xmlDoc: XMLDocument? = nil
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
		
		let testBundle = Bundle(for: type(of: self))
		guard let resourceURL = testBundle.url(forResource: "JFK_Moon_Demo_START", withExtension: "fcpxml") else {
			// file does not exist
			print("file doesn't exist")
			return
		}
		
		do {
			let _ = try resourceURL.checkResourceIsReachable()
			print("File exists.")
		} catch {
			print("Error reaching URL.")
			return
		}
		
		do {
			try xmlDoc = XMLDocument(contentsOfFCPXML: resourceURL)
			print("File loaded.")
		} catch {
			print("Error loading XML data.")
			return
		}
		
		
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testEventItemsForAsset() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		guard let testDoc = xmlDoc else {
			XCTFail()
			return
		}
		
		print("--- Test Results ---")
		print("FCPXML Version: \(testDoc.fcpxmlVersion!)")
		print("Assets: \(testDoc.fcpxAssetResources.count)")
		print("Resources: \(testDoc.fcpxResources.count)")
		print("Formats: \(testDoc.fcpxFormatResources.count)")
		print("Multicams: \(testDoc.fcpxMulticamResources.count)")
		print("Compound Clips: \(testDoc.fcpxCompoundResources.count)")
		print("Events: \(testDoc.fcpxEvents.count)")
		print("Event Names: \(testDoc.fcpxEventNames)")
		print("Event Items: \(testDoc.fcpxAllEventItems.count)")
		print("Event Item Names: \(testDoc.fcpxAllEventItemNames)")
		print("Projects: \(testDoc.fcpxAllProjects.count)")
		print("Project Names: \(testDoc.fcpxAllProjectNames)")
		print("Roles: \(testDoc.fcpxRoles.count)")
		
		print("Searching for resource: \(testDoc.fcpxResources[4])")
		let matchingEventClips = testDoc.fcpxEvents[0].eventClips(containingAsset: testDoc.fcpxResources[2])
		
		guard let matchingClips = matchingEventClips else {
			print("Element is not an event.")
			XCTFail()
			return
		}
		
		print("matchingClips: \(matchingClips)")
		
		if matchingClips.count > 0 {
			for clip in matchingClips {
				print("MATCHING CLIP: \(clip.element.fcpxName!)")
				print(clip.element)
			}
		}
		
		print(testDoc.fcpxmlDTDVersions())
		
		do {
			try testDoc.validateFCPXMLAgainstLatestVersion()
		} catch {
			print(error.localizedDescription)
		}
		
		print("--- End Results ---")
		
		XCTAssert(matchingClips.count > 0)
		
	}
	
	func testFormatValues() {
		guard let testDoc = xmlDoc else {
			XCTFail()
			return
		}
		
		let assetResource = testDoc.fcpxAllEventItems[9]
		
		guard let assetResourceFormat = assetResource.formatValues() else {
			print("No format.")
			XCTFail()
			return
		}
		
		print(assetResourceFormat.formatName)
		XCTAssert(true)
		
		
	}
	
	func testLastResourceIDs() {
		
		guard let testDoc = xmlDoc else {
			XCTFail()
			return
		}
		
		print("Last TS: \(testDoc.fcpxLastTextStyleID)")
		print("Roles: \(testDoc.fcpxRoles)")
		
		XCTAssert(testDoc.fcpxLastTextStyleID != 0)
	}
	
	func testMatchingClips() {
		
		guard let testDoc = xmlDoc else {
			XCTFail()
			return
		}
		
		let clipResource = testDoc.fcpxResources[4]
		print(clipResource.fcpxName!)
		
		let matchingClips = testDoc.fcpxEvents[0].eventClips(containingAsset: clipResource)
		
		print(matchingClips?.count)
		
		XCTAssert((matchingClips?.count)! > 1)
		
	}
	
	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}
	
}
