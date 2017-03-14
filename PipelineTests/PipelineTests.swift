//
//  PipelineTests.swift
//  PipelineTests
//
//  Created by Reuel Kim on 1/1/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import XCTest
import CoreMedia
@testable import Pipeline

class PipelineTests: XCTestCase {
	
	var xmlDoc: XMLDocument? = nil
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
		
		let testBundle = Bundle(for: type(of: self))
		guard let resourceURL = testBundle.url(forResource: "PCBang_FromGrace_20160202", withExtension: "fcpxml") else {
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
			xmlDoc = try XMLDocument(contentsOfFCPXML: resourceURL)
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
	
	func testNewDoc() {
		let zero = CMTime(value: 0, timescale: 2400)
		let compound = XMLElement().fcpxCompoundClip(name: "compound", ref: "r1", offset: zero, duration: CMTime(value: 60, timescale: 2400) , start: zero, useAudioSubroles: false)
		let project = XMLElement().fcpxProject(name: "new project", formatRef: "r2", duration: zero, tcStart: zero, tcFormat: .nonDropFrame, audioLayout: .stereo, audioRate: .rate48kHz, renderColorSpace: .rec709, clips: [compound])
		let event = XMLElement().fcpxEvent(name: "My event", items: [project])
		
		
		
		let doc = XMLDocument(resources: [compound], events: [event], fcpxmlVersion: 1.6)
		
		print(doc.fcpxmlString)
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
		
		let matchingEventClips: [XMLElement]
		do {
			matchingEventClips = try testDoc.fcpxEvents[0].eventClips(containingResource: testDoc.fcpxResources[2])
		} catch {
			print("Element is not an event.")
			XCTAssert(false)
			return
		}

		print("matchingEventClips: \(matchingEventClips)")
		
		if matchingEventClips.count > 0 {
			for clip in matchingEventClips {
				print("MATCHING CLIP: \(clip.fcpxName!)")
				print(clip)
			}
		}
		
		print(testDoc.fcpxmlDTDVersions())
		
		do {
			try testDoc.validateFCPXMLAgainstLatestVersion()
		} catch {
			print(error.localizedDescription)
		}
		
		print("--- End Results ---")
		
		XCTAssert(matchingEventClips.count > 0)
		
	}
	
	func testTimeValues() {
		guard let testDoc = xmlDoc else {
			XCTFail()
			return
		}
		
		let eventItem = testDoc.fcpxEvents[0].eventItems![0]
		print(eventItem.fcpxDuration)
		
		print(eventItem.fcpxDuration!.timeAsCounter())
		
		dump(testDoc.fcpxEventNames)
		
		let newEvent = XMLElement().fcpxEvent(name: "My New Event")
		testDoc.add(event: newEvent)
		
		dump(testDoc.fcpxEventNames)
		
		let firstEvent = testDoc.fcpxEvents[0]
		
		guard let eventClips = firstEvent.eventClips else {
			return
		}
		
		if eventClips.count > 0 {
			let firstClip = eventClips[0]
			let duration = firstClip.fcpxDuration
			let timeDisplay = duration?.timeAsCounter().counterString
			print(timeDisplay)
		}
		
		let matchingClips = try! firstEvent.eventClips(forResourceID: "r1")
		
		try! firstEvent.removeFromEvent(items: matchingClips)
		
		guard let resource = testDoc.resource(matchingID: "r1") else {
			return
		}
		testDoc.remove(resourceAtIndex: resource.index)
		
		dump(firstEvent.eventClips)
		dump(testDoc.fcpxResources)
		
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
//
//	func testMatchingClips() {
//		
//		guard let testDoc = xmlDoc else {
//			XCTFail()
//			return
//		}
//		
//		let clipResource = testDoc.fcpxResources[4]
//		print(clipResource.fcpxName!)
//		
//		let matchingClips = testDoc.fcpxEvents[0].eventClips(containingAsset: clipResource)
//		
//		print(matchingClips?.count)
//		
//		XCTAssert((matchingClips?.count)! > 1)
//		
//	}
	
	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}
	
}
