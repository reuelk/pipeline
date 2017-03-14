![Alt text](pipeline.png?raw=true "Pipeline for Final Cut Pro X")

Pipeline is a Swift framework for working with FCPXML files easily.

## About
Pipeline extends the XMLDocument and XMLElement classes in the Foundation framework. It adds properties and methods that simplify the creation and management of FCPXML document structure.

Pipeline also includes supplemental classes and a CMTime extension to help in the processing of FCPXML data. For example, you can easily convert a timing value that looks like "59983924/30000s" in the XML to "00:33:19,464" for easy display in an app.

Pipeline currently works with FCPXML v1.6 files only.

## Key Features
* Access an FCPXML document's resources, events, clips, and projects through simple object properties.
* Create and modify resources, events, clips, and projects with included properties and methods.
* Easily manipulate timing values.
* Output FCPXML files with proper text formatting.
* Validate FCPXML documents with the DTD.

## Documentation
The framework documentation is included in the `Documentation` folder as HTML files.

## Adding the Framework to a Project
To add the framework to your Xcode project:

1. Clone or download the repository.
2. Open the `Pipeline.xcodeproj` file in Xcode.
3. Build the project by pressing Command-B.
4. Right-click on the `Pipeline.framework` framework in the "Products" folder in the Navigator pane. Select "Show in Finder".
5. Drag the selected folder into your Xcode project's Navigator pane.
6. Xcode will prompt you to set some options for adding the folder. Generally, "Copy items if needed", "Create groups" and your application target should be selected.
7. Select your project in the Navigator pane and go to "Build Phases". Under "Copy Files", select "Frameworks" as the destination.
8. Click on the plus sign and add the Pipeline framework.
9. Add `import Pipeline` to the top of all Swift files that need to use the framework.

## Usage Examples

### Open an FCPXML File
Subsequent examples use the `fcpxmlDoc` object declared here.

	let fileURL = URL(fileURLWithPath: "~/Documents/sample.fcpxml")  // Create a new URL object that points to the FCPXML file's path
	let fcpxmlDoc: XMLDocument  // Declare the fcpxmlDoc constant as an XMLDocument object
	
	do {
		fcpxmlDoc = try XMLDocument(contentsOfFCPXML: fileURL)  // Load the FCPXML file using the fileURL object
	} catch {
		print("Error loading FCPXML file.")
		return
	}

### List the Names of All Events

	let eventNames = fcpxmlDoc.fcpxEventNames  // Get the event names in the FCPXML document
	dump(eventNames)  // Neatly display all of the event names
	
### Create and Add a New Event

	let newEvent = XMLElement().fcpxEvent(name: "My New Event")  // Create a new empty event
	fcpxmlDoc.add(event: newEvent)  // Add the new event to the FCPXML document
	
### Get Clips That Match a Resource ID and Delete Them

	let firstEvent = fcpxmlDoc.fcpxEvents[0]  // Get the first event in the FCPXML document
	let matchingClips = try! firstEvent.eventClips(forResourceID: "r1")  // Get any clips that match resource ID "r1".

	// The eventClips(forResourceID:) method throws an error if the XMLElement that calls it is not an event. Since we know that firstEvent is an event, it is safe to use "try!" to override the error handling.
		
	try! firstEvent.removeFromEvent(items: matchingClips)  // Remove the clips that reference resource "r1".
		
	guard let resource = fcpxmlDoc.resource(matchingID: "r1") else {  // Get the "r1" resource
		return
	}
	fcpxmlDoc.remove(resourceAtIndex: resource.index)  // Remove the "r1" resource from the FCPXML document

### Display the Duration of a Clip

	let firstEvent = fcpxmlDoc.fcpxEvents[0]  // Get the first event in the FCPXML document
	
	guard let eventClips = firstEvent.eventClips else {  // Get the event clips while guarding against a potential nil value
		return
	}
		
	if eventClips.count > 0 {  // Make sure there's at least one clip in the event
		let firstClip = eventClips[0]  // Get the first clip in the event
		let duration = firstClip.fcpxDuration  // Get the duration of the clip
		let timeDisplay = duration?.timeAsCounter().counterString  // Convert the duration, which is a CMTime value, to a String formatted as HH:MM:SS,MMM
		print(timeDisplay) 
	}

## Authors
Reuel Kim