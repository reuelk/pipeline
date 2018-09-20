//
//  FCPXMLUtility.swift
//  Pipeline
//
//  Created by Reuel Kim on 1/15/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia



/// Contains miscellaneous utility methods for processing FCPXML data.
public struct FCPXMLUtility {
	
	// MARK: - Initializing
	
	/// Initializer
	public init() {
		
	}
	
	// MARK: - Retrieval Methods
	
	/// Returns an array of elements that match specified FCPXML element types.
	///
	/// - Parameters:
	///   - elements: An array of XMLElement objects
	///   - types: An array of FCPXMLElementType enumeration values
	/// - Returns: A filtered array of XMLElement objects
	public func filter(fcpxElements elements: [XMLElement], ofTypes types: [FCPXMLElementType]) -> [XMLElement] {
		
		var filteredElements: [XMLElement] = []
		
		for element in elements {
			
			for type in types {
				
				if element.fcpxType == type {
					filteredElements.append(element)
				}
			}
		}
		
		return filteredElements
	}
	

	
	
	
	// MARK: - Time Conversion Methods
	
	/**
	Creates a CMTime value that represents real time from timecode values.
	
	- parameter timecodeHours: The hours element of the timecode value.
	- parameter timecodeMinutes: The minutes element of the timecode value.
	- parameter timecodeSeconds: The seconds element of the timecode value.
	- parameter timecodeFrames: The frames element of the timecode value.
	- parameter frameDuration: The duration of a single frame as a CMTime value.
	
	- returns: A CMTime value equivalent to the timecode value in real time.
	*/
	public func CMTimeFrom(timecodeHours: Int, timecodeMinutes: Int, timecodeSeconds: Int, timecodeFrames: Int, frameDuration: CMTime) -> CMTime {
		
		let framerate: Double
		if frameDuration == CMTimeMake(value: 1001, timescale: 24000) { // If the framerate is 23.976, make the framerate 24 per SMPTE
			framerate = 24.0
		} else {
			framerate = 1 / (frameDuration.seconds)
		}
		
		let hourFrames = 3600 * framerate * Double(timecodeHours)
		let minuteFrames = 60 * framerate * Double(timecodeMinutes)
		let secondFrames = framerate * Double(timecodeSeconds)
		
		let totalFrames = hourFrames + minuteFrames + secondFrames + Double(timecodeFrames)
		
		let totalSeconds = totalFrames * frameDuration.seconds
		
		let timescale = Int32(framerate * 1000)
		let value = Int64(Double(timescale) * totalSeconds)
		
		let totalSecondsCMTime = CMTimeMake(value: value, timescale: timescale)
		
		return totalSecondsCMTime
	}

	
	/**
	Converts an FCPXML time value to a CMTime value.
	
	- parameter fromFCPXMLTimeString: The FCPXML time value as a string.
	
	- returns: The equivalent CMTime value.
	*/
	public func CMTime(fromFCPXMLTime timeString: String) -> CMTime {
		var timeValues = timeString.components(separatedBy: "/")
		if timeValues.count > 1 {
			timeValues[1] = String(timeValues[1].dropLast())
			let value = Int64(timeValues[0])!
			let timescale = Int32(timeValues[1])!
			
			return CMTimeMake(value: value, timescale: timescale)
		} else {
			timeValues[0] = String(timeValues[0].dropLast())
			let value = Int64(timeValues[0])!
			
			return CMTimeMake(value: value, timescale: 1)
		}
	}
	
	
	/**
	Converts a CMTime value to an FCPXML time value.
	
	- parameter time: A CMTime value to convert.
	
	- returns: The FCPXML time value as a string.
	*/
	public func fcpxmlTime(fromCMTime time: CMTime) -> String {
		
		return time.fcpxmlString
	}
	
	
	/**
	Conforms a given CMTime value to the frameDuration so that the value falls on an edit frame boundary. The function rounds the edit frame down.
	
	- parameter time: A CMTime value to conform.
	- parameter frameDuration: The frame duration to conform to, represented as a CMTime.
	
	- returns: A CMTime of the conformed value.
	*/
	public func conform(time: CMTime, toFrameDuration frameDuration: CMTime) -> CMTime {
		let numberOfFrames = time.seconds / frameDuration.seconds
		let numberOfFramesRounded = floor(Double(numberOfFrames))
		let conformedTime = CMTimeMake(value: Int64(numberOfFramesRounded * Double(frameDuration.value)), timescale: frameDuration.timescale)
		
		return conformedTime
	}
	
	
	/**
	Converts a project counter value to the project's timecode.
	
	- parameter counterValue: The counter value to convert.
	- parameter project: The project to convert against, as an NSXMLElement.
	
	- returns: An optional CMTime value of the timecode value.
	*/
	@available(*, deprecated, message: "Use sequenceTimecode(fromCounterValue:inSequence:) instead.")
	public func projectTimecode(fromCounterValue counterValue: CMTime, inProject project: XMLElement) -> CMTime? {
		
        guard let projectSequence = project.fcpxProjectSequence else {
            return nil
        }
        
		guard let projectSequenceTCStart = projectSequence.fcpxTCStart else {
			return nil
		}
		
		let timecodeValue = CMTimeAdd(projectSequenceTCStart, counterValue)
		
		return timecodeValue
	}
	
	
	/**
	Converts a project timecode value to the project's counter time.
	
	- parameter timecodeValue: The timecode value to convert.
	- parameter project: The project to convert against, as an NSXMLElement.
	
	- returns: An optional CMTime value of the counter time.
	*/
	@available(*, deprecated, message: "Use sequenceCounterTime(fromTimecodeValue:inSequence:) instead.")
	public func projectCounterTime(fromTimecodeValue timecodeValue: CMTime, inProject project: XMLElement) -> CMTime? {
		
        // Convert the timecode values to sequence counter time values
        guard let projectSequence = project.fcpxProjectSequence else {
            return nil
        }
		
		guard let projectSequenceTCStart = projectSequence.fcpxTCStart else {
			return nil
		}
		
		let counterValue = CMTimeSubtract(timecodeValue, projectSequenceTCStart)
		
		return counterValue
		
	}
    
    
    /**
     Converts a sequence counter value to the sequence's timecode.
     
     - parameter counterValue: The counter value to convert.
     - parameter project: The sequence to convert against, as an NSXMLElement.
     
     - returns: An optional CMTime value of the timecode value.
     */
    public func sequenceTimecode(fromCounterValue counterValue: CMTime, inSequence sequence: XMLElement) -> CMTime? {
        
        guard sequence.fcpxType == .sequence else {
            return nil
        }
        
        guard let sequenceTCStart = sequence.fcpxTCStart else {
            return nil
        }
        
        let timecodeValue = CMTimeAdd(sequenceTCStart, counterValue)
        
        return timecodeValue
    }
    
    
    /**
     Converts a sequence timecode value to the sequence counter time.
     
     - parameter timecodeValue: The timecode value to convert.
     - parameter sequence: The sequence to convert against, as an NSXMLElement.
     
     - returns: An optional CMTime value of the counter time.
     */
    public func sequenceCounterTime(fromTimecodeValue timecodeValue: CMTime, inSequence sequence: XMLElement) -> CMTime? {
        
        // Convert the timecode values to sequence counter time values
        guard sequence.fcpxType == .sequence else {
            return nil
        }
        
        guard let sequenceTCStart = sequence.fcpxTCStart else {
            return nil
        }
        
        let counterValue = CMTimeSubtract(timecodeValue, sequenceTCStart)
        
        return counterValue
        
    }
	
	/**
	Converts a local time value to a clip's parent time value. In FCPXML, this would be converting a time value that is in the start value timescale to the offset value timescale.
	
	For example, if a clip on the primary storyline has an attached clip, this will convert the attached clip's offset value to its parent clip's offset value timescale.
	
	- parameter fromLocalTime: The local time value to convert.
	- parameter forClip: The clip to convert against.
	
	- returns: A CMTime value of the resulting parent time value.
	*/
	public func parentTime(fromLocalTime localTimeValue: CMTime, forClip clip: XMLElement) -> CMTime? {
		
		guard let parentInPoint = clip.fcpxParentInPoint else {
			return nil
		}
		
		let localTimeOffset = CMTimeSubtract(localTimeValue, clip.fcpxLocalInPoint)
		
		let localTimeAsParentTime = CMTimeAdd(parentInPoint, localTimeOffset)
		
		return localTimeAsParentTime
	}
	
	
	/**
	Converts a parent time value to a clip's local time value. In FCPXML, this would be converting a time value that is in the offset value timescale to the start value timescale.
	
	For example, if a clip on the primary storyline has an attached clip, this will tell you what the attached clip's offset should be based on where you want it to be placed along the primary storyline.
	
	- parameter fromParentTime: The parent time value to convert.
	- parameter forClip: The clip to convert against.
	
	- returns: A CMTime value of the resulting parent time value.
	*/
	public func localTime(fromParentTime parentTimeValue: CMTime, forClip clip: XMLElement) -> CMTime? {
		
		guard let parentInPoint = clip.fcpxParentInPoint else {
			return nil
		}
		
		let parentTimeOffset = CMTimeSubtract(parentTimeValue, parentInPoint)
		
		let parentTimeAsLocalTime = CMTimeAdd(clip.fcpxLocalInPoint, parentTimeOffset)
		
		return parentTimeAsLocalTime
	}
	
	
	/**
	Provides the start time of the given clip within the project timeline.
	
	- parameter forClip: The clip on the timeline to return the start time value for. The clip can be a clip on the primary storyline, a secondary storyline or it can be a connected clip.
	- parameter inProject: The project that the clip resides in.
	
	- returns: A CMTime value of the resulting project time value.
	*/
	public func projectTime(forClip clip: XMLElement, inProject project: XMLElement) -> CMTime? {
		
		guard let clipElementOffset = clip.fcpxOffset else {
			print("clipElementOffset is nil")
			return nil
		}
		
		var startTime: CMTime
		let clipParentElement = clip.parent as! XMLElement
		if clipParentElement.name == "spine" && clipParentElement.fcpxOffset != nil { // If the clip is in a secondary storyline
			
			guard let spineOffset = clipParentElement.fcpxOffset else {
				print("spineOffset is nil")
				return nil
			}
			
			guard let spineParent = clipParentElement.parent else {
				print("spineParent is nil")
				return nil
			}
			
			let spineParentElement = spineParent as! XMLElement
			
			let newSpineOffset = CMTimeAdd(spineOffset, clipElementOffset)
			
			guard let spineParentOffset = FCPXMLUtility().parentTime(fromLocalTime: newSpineOffset, forClip: spineParentElement) else {
				print("spineParentOffset is nil")
				return nil
			}
			
			startTime = spineParentOffset
			
		} else if clipParentElement.name != "spine" { // If the clip is an attached clip
			
			guard let clipOffset = FCPXMLUtility().parentTime(fromLocalTime: clipElementOffset, forClip: clipParentElement) else {
				return nil
			}
			
			startTime = clipOffset
			
		} else { // If the clip is in the primary storyline or any other case
			
			guard let clipOffset = clip.fcpxOffset else {
				return nil
			}
			
			startTime = clipOffset
			
		}
		
		return startTime
	}
	
	/// Returns the clip's parent's equivalent offset timings for the specified in and out times. This is useful for walking up an XMLElement hierarchy in order to get the time values of the clip on the project timeline.
	///
	/// - Parameters:
	///   - inTime: The in time to convert, given as a CMTime value.
	///   - outTime: The out time to convert, given as a CMTime value.
	///   - clip: The clip that the time values are from. The parent time values will be drawn from this clip's parent.
	/// - Returns: A tuple of the converted in time, the converted out time, and the parent XMLElement of the specified clip.
	public func parentClipTime(forInTime inTime: CMTime, outTime: CMTime, forClip clip: XMLElement) -> (in: CMTime, out: CMTime, parent: XMLElement)? {
		
		guard let parentClip = clip.parentElement else {
			return nil
		}
		
		guard let parentIn = self.parentTime(fromLocalTime: inTime, forClip: parentClip) else {
			return nil
		}
		
		guard let parentOut = self.parentTime(fromLocalTime: outTime, forClip: parentClip) else {
			return nil
		}
		
		return (parentIn, parentOut, parentClip)
	}
	
	
	
	// MARK: - Other Conversion Methods
	
	/// Converts line breaks in attributes to safe XML entities in an XML file, returning an NSXMLDocument.
	///
	/// When text values contain line breaks, such as in markers, Final Cut Pro X exports FCPXML files with the line break as is, not encoded into a valid XML line break character. This function will replace line breaks in _attribute nodes_ in FCPXML files with the &#xA; character entity.
	///
	/// - Parameter URL: A URL object pointing to the XML file to convert.
	/// - Returns: An XMLDocument or nil if there was a file read or conversion error.
	public func convertLineBreaksInAttributes(inXMLDocumentURL URL: Foundation.URL) -> XMLDocument? {
		
		var document: String = ""
		
		do {
			
			document = try String(contentsOf: URL, encoding: String.Encoding.utf8)
			
		} catch {
			return nil
		}
		
		let splitDocument = document.components(separatedBy: "=\"")
		var newSplitDocument: [String] = []
		var skipNextNewLineReplacement = false
		
		for segment in splitDocument {
			
			var newSegment = ""
			var reachedAttributeEnd = false
			
			for (charIndex, char) in segment.enumerated() {
				
				if reachedAttributeEnd == false {
					
					if char == "\n" && skipNextNewLineReplacement == false {
						
						newSegment += "&#xA;"
						print("Found new line character in attribute value")
						
					} else if char == "\"" {
						
						newSegment += String(char)
						reachedAttributeEnd = true
						
					} else {
						
						newSegment += String(char)
						
						if charIndex == segment.count - 1 {
							skipNextNewLineReplacement = true
						}
						
					}
					
				} else {
					
					newSegment += String(char)
					skipNextNewLineReplacement = false
					
				}
				
			}
			
			newSplitDocument.append(newSegment)
			
		}
		
		let newDocument = newSplitDocument.joined(separator: "=\"")
		
		do {
			
			let newXMLDocument = try XMLDocument(xmlString: newDocument, options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement])
			
			return newXMLDocument
			
		} catch {
			
			return nil
		}
		
	}
	
	
	/**
	Returns the FFVideoFormat identifier based on the given parameters. If the parameters don't match a defined identifier according to FCPXML v1.5, the method will return the string "FFVideoFormatRateUndefined".
	
	- parameter fromWidth: The width of the frame as an integer.
	- parameter height: The height of the frame as an integer.
	- parameter frameRate: The frame rate as a float.
	- parameter isInterlaced: A boolean value indicating if the format is interlaced.
	- parameter is16x9: A boolean value indicating if the format has an aspect ratio of 16:9.
	
	- returns: A string of the FFVideoFormat identifier.
	*/
	public func FFVideoFormat(fromWidth width: Int, height: Int, frameRate: Float, isInterlaced: Bool, isSD16x9: Bool) -> String {
		
		var ffVideoFormat = "FFVideoFormat"
		let undefined = "FFVideoFormatRateUndefined"
		
		switch width {
		case 1920:
			if height == 1080 {
				ffVideoFormat += "1080"
			} else {
				return undefined
			}
		case 1280:
			switch height {
			case 1080:
				ffVideoFormat += "1280x1080"
			case 720:
				ffVideoFormat += "720"
			default:
				return undefined
			}
		case 1440:
			if height == 1080 {
				ffVideoFormat += "1440x1080"
			} else {
				return undefined
			}
		case 2048:
			switch height {
			case 1080:
				ffVideoFormat += "2048x1080"
			case 1024:
				ffVideoFormat += "2048x1024"
			case 1152:
				ffVideoFormat += "2048x1152"
			case 1536:
				ffVideoFormat += "2048x1536"
			case 1556:
				ffVideoFormat += "2048x1556"
			default:
				return undefined
			}
		case 3840:
			if height == 2160 {
				ffVideoFormat += "3840x2160"
			} else {
				return undefined
			}
		case 4096:
			switch height {
			case 2048:
				ffVideoFormat += "4096x2048"
			case 2160:
				ffVideoFormat += "4096x2160"
			case 2304:
				ffVideoFormat += "4096x2304"
			case 3112:
				ffVideoFormat += "4096x3112"
			default:
				return undefined
			}
		case 5120:
			switch height {
			case 2160:
				ffVideoFormat += "5120x2160"
			case 2560:
				ffVideoFormat += "5120x2560"
			case 2700:
				ffVideoFormat += "5120x2700"
			default:
				return undefined
			}
		case 640:
			switch height {
			case 360:
				ffVideoFormat += "640x360"
			case 480:
				ffVideoFormat += "640x480"
			default:
				return undefined
			}
		case 720:
			switch height {
			case 480:
				ffVideoFormat += "DV720x480"
			case 486:
				ffVideoFormat += "720x486"
			case 576:
				ffVideoFormat += "720x576"
			default:
				return undefined
			}
		case 960:
			switch height {
			case 540:
				ffVideoFormat += "960x540"
			case 720:
				ffVideoFormat += "960x720"
			default:
				return undefined
			}
		default:
			return undefined
		}
		
		if isInterlaced == false {
			ffVideoFormat += "p"
		} else {
			if frameRate == 59.94 || frameRate == 50 {
				ffVideoFormat += "i"
			} else {
				return undefined
			}
		}
		
		switch frameRate {
		case 23.98:
			ffVideoFormat += "2398"
		case 24:
			ffVideoFormat += "24"
		case 25:
			ffVideoFormat += "25"
		case 29.97:
			ffVideoFormat += "2997"
		case 30:
			ffVideoFormat += "30"
		case 50:
			ffVideoFormat += "50"
		case 59.94:
			ffVideoFormat += "5994"
		case 60:
			ffVideoFormat += "60"
		default:
			return undefined
		}
		
		if isSD16x9 == true && width == 720 {
			if height == 486 || height == 576 || height == 480 {
				ffVideoFormat += "_16x9"
			}
		}
		
		return ffVideoFormat
		
		/*
		
		// 16x9 taggable:
		720x486
		720x576
		720x480
		
		Interlaced formats:
		FFVideoFormat720x486i5994
		FFVideoFormat720x486i5994_16x9
		FFVideoFormat720x576i50
		FFVideoFormat720x576i50_16x9
		FFVideoFormatDV720x480i5994
		FFVideoFormatDV720x480i5994_16x9
		** FFVideoFormatDV720x576i50
		** FFVideoFormatDV720x576i50_16x9
		FFVideoFormat1080i50
		FFVideoFormat1080i5994
		FFVideoFormat1280x1080i50
		FFVideoFormat1280x1080i5994
		FFVideoFormat1440x1080i50
		FFVideoFormat1440x1080i5994
		
		SD Formats:
		FFVideoFormat640x360p2997
		FFVideoFormat640x480p2398
		FFVideoFormat640x480p24
		FFVideoFormat640x480p25
		FFVideoFormat640x480p2997
		FFVideoFormat640x480p30
		FFVideoFormat720p2398
		FFVideoFormat720p24
		FFVideoFormat720p25
		FFVideoFormat720p2997
		FFVideoFormat720p30
		FFVideoFormat720p50
		FFVideoFormat720p5994
		FFVideoFormat720p60
		FFVideoFormat720x486i5994
		FFVideoFormat720x486i5994_16x9
		FFVideoFormat720x486p2398
		FFVideoFormat720x486p2398_16x9
		FFVideoFormat720x486p2997
		FFVideoFormat720x486p2997_16x9
		FFVideoFormat720x576i50
		FFVideoFormat720x576i50_16x9
		FFVideoFormat720x576p25
		FFVideoFormat720x576p25_16x9
		FFVideoFormat960x540p2398
		FFVideoFormat960x540p24
		FFVideoFormat960x540p25
		FFVideoFormat960x540p2997
		FFVideoFormat960x540p30
		FFVideoFormat960x720p2398
		FFVideoFormat960x720p24
		FFVideoFormat960x720p25
		FFVideoFormat960x720p2997
		FFVideoFormat960x720p30
		FFVideoFormat960x720p50
		FFVideoFormat960x720p5994
		FFVideoFormat960x720p60
		FFVideoFormatDV720x480i5994
		FFVideoFormatDV720x480i5994_16x9
		FFVideoFormatDV720x480p2398
		FFVideoFormatDV720x480p2398_16x9
		FFVideoFormatDV720x480p2997
		FFVideoFormatDV720x480p2997_16x9
		** FFVideoFormatDV720x576i50
		** FFVideoFormatDV720x576i50_16x9
		
		HD Formats:
		FFVideoFormatRateUndefined
		FFVideoFormat1080i50
		FFVideoFormat1080i5994
		FFVideoFormat1080p2398
		FFVideoFormat1080p24
		FFVideoFormat1080p25
		FFVideoFormat1080p2997
		FFVideoFormat1080p30
		FFVideoFormat1080p50
		FFVideoFormat1080p5994
		FFVideoFormat1080p60
		FFVideoFormat1280x1080i50
		FFVideoFormat1280x1080i5994
		FFVideoFormat1280x1080p2398
		FFVideoFormat1280x1080p24
		FFVideoFormat1280x1080p25
		FFVideoFormat1280x1080p2997
		FFVideoFormat1280x1080p30
		FFVideoFormat1280x1080p50
		FFVideoFormat1280x1080p5994
		FFVideoFormat1280x1080p60
		FFVideoFormat1440x1080i50
		FFVideoFormat1440x1080i5994
		FFVideoFormat1440x1080p2398
		FFVideoFormat1440x1080p24
		FFVideoFormat1440x1080p25
		FFVideoFormat1440x1080p2997
		FFVideoFormat1440x1080p30
		FFVideoFormat1440x1080p50
		FFVideoFormat1440x1080p5994
		FFVideoFormat1440x1080p60
		FFVideoFormat2048x1024p2398
		FFVideoFormat2048x1024p24
		FFVideoFormat2048x1024p25
		FFVideoFormat2048x1024p2997
		FFVideoFormat2048x1024p30
		FFVideoFormat2048x1024p50
		FFVideoFormat2048x1024p5994
		FFVideoFormat2048x1024p60
		FFVideoFormat2048x1080p2398
		FFVideoFormat2048x1080p24
		FFVideoFormat2048x1080p25
		FFVideoFormat2048x1080p2997
		FFVideoFormat2048x1080p30
		FFVideoFormat2048x1080p50
		FFVideoFormat2048x1080p5994
		FFVideoFormat2048x1080p60
		FFVideoFormat2048x1152p2398
		FFVideoFormat2048x1152p24
		FFVideoFormat2048x1152p25
		FFVideoFormat2048x1152p2997
		FFVideoFormat2048x1152p30
		FFVideoFormat2048x1152p50
		FFVideoFormat2048x1152p5994
		FFVideoFormat2048x1152p60
		FFVideoFormat2048x1536p2398
		FFVideoFormat2048x1536p24
		FFVideoFormat2048x1536p25
		FFVideoFormat2048x1536p2997
		FFVideoFormat2048x1536p30
		FFVideoFormat2048x1536p50
		FFVideoFormat2048x1536p5994
		FFVideoFormat2048x1536p60
		FFVideoFormat2048x1556p2398
		FFVideoFormat2048x1556p24
		FFVideoFormat2048x1556p25
		FFVideoFormat2048x1556p2997
		FFVideoFormat2048x1556p30
		FFVideoFormat2048x1556p50
		FFVideoFormat2048x1556p5994
		FFVideoFormat2048x1556p60
		FFVideoFormat3840x2160p2398
		FFVideoFormat3840x2160p24
		FFVideoFormat3840x2160p25
		FFVideoFormat3840x2160p2997
		FFVideoFormat3840x2160p30
		FFVideoFormat3840x2160p50
		FFVideoFormat3840x2160p5994
		FFVideoFormat3840x2160p60
		FFVideoFormat4096x2048p2398
		FFVideoFormat4096x2048p24
		FFVideoFormat4096x2048p25
		FFVideoFormat4096x2048p2997
		FFVideoFormat4096x2048p30
		FFVideoFormat4096x2048p50
		FFVideoFormat4096x2048p5994
		FFVideoFormat4096x2048p60
		FFVideoFormat4096x2160p2398
		FFVideoFormat4096x2160p24
		FFVideoFormat4096x2160p25
		FFVideoFormat4096x2160p2997
		FFVideoFormat4096x2160p30
		FFVideoFormat4096x2160p50
		FFVideoFormat4096x2160p5994
		FFVideoFormat4096x2160p60
		FFVideoFormat4096x2304p2398
		FFVideoFormat4096x2304p24
		FFVideoFormat4096x2304p25
		FFVideoFormat4096x2304p2997
		FFVideoFormat4096x2304p30
		FFVideoFormat4096x2304p50
		FFVideoFormat4096x2304p5994
		FFVideoFormat4096x2304p60
		FFVideoFormat4096x3112p2398
		FFVideoFormat4096x3112p24
		FFVideoFormat4096x3112p25
		FFVideoFormat4096x3112p2997
		FFVideoFormat4096x3112p30
		FFVideoFormat4096x3112p50
		FFVideoFormat4096x3112p5994
		FFVideoFormat4096x3112p60
		FFVideoFormat5120x2160p2398
		FFVideoFormat5120x2160p24
		FFVideoFormat5120x2160p25
		FFVideoFormat5120x2160p2997
		FFVideoFormat5120x2160p30
		FFVideoFormat5120x2160p50
		FFVideoFormat5120x2160p5994
		FFVideoFormat5120x2160p60
		FFVideoFormat5120x2560p2398
		FFVideoFormat5120x2560p24
		FFVideoFormat5120x2560p25
		FFVideoFormat5120x2560p2997
		FFVideoFormat5120x2560p30
		FFVideoFormat5120x2560p50
		FFVideoFormat5120x2560p5994
		FFVideoFormat5120x2560p60
		FFVideoFormat5120x2700p2398
		FFVideoFormat5120x2700p24
		FFVideoFormat5120x2700p25
		FFVideoFormat5120x2700p2997
		FFVideoFormat5120x2700p30
		FFVideoFormat5120x2700p50
		FFVideoFormat5120x2700p5994
		FFVideoFormat5120x2700p60
		
		
		*/
		
	}
	

	
}

