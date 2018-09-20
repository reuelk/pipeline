//
//  CMTimeExtension.swift
//  Pipeline
//
//  Created by Reuel Kim on 1/15/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia


extension CMTime {
	
	
	/// The CMTime value as an FCPXML time string using the format "[value]/[timescale]s" or "0s" if the value is zero.
	public var fcpxmlString: String {
		get {
			if self.value == 0 {
				return "0s"
			} else {
				return "\(self.value)/\(self.timescale)s"
			}
		}
	}
	
	
	/// Returns a CMTime value with a value of zero and timescale of 1000.
	///
	/// - Returns: A CMTime object.
	public func zero() -> CMTime {
		
		let newCMTime = CMTime(value: 0, timescale: 1000)
		
		return newCMTime
	}
	
	
	/// Returns the CMTime value as a tuple containing components of time as separate values.
	///
	/// - Returns: A tuple with hours, minutes, seconds, and milliseconds as Int, Double, and String values.
	public func timeAsCounter() -> (hours: Int, minutes: Int, seconds: Int, milliseconds: Double, hoursString: String, minutesString: String, secondsString: String, framesString: String, counterString: String) {
		
			let hours = Int((self.seconds / 60.0) / 60.0)
			let minutes = Int((self.seconds / 60).truncatingRemainder(dividingBy: 60))
			let seconds = Int(self.seconds.truncatingRemainder(dividingBy: 60))
			let milliseconds = ((self.seconds.truncatingRemainder(dividingBy: 60.0)).truncatingRemainder(dividingBy: 1))
			
			let formatter = NumberFormatter()
			formatter.paddingCharacter = "0"
			formatter.minimumIntegerDigits = 2
			formatter.maximumIntegerDigits = 2
			
			let msFormatter = NumberFormatter()
			msFormatter.paddingCharacter = "0"
			msFormatter.minimumFractionDigits = 3
			msFormatter.maximumFractionDigits = 3
			msFormatter.decimalSeparator = ""
			
			let hoursString = formatter.string(from: NSNumber(value: hours))!
			let minutesString = formatter.string(from: NSNumber(value: minutes))!
			let secondsString = formatter.string(from: NSNumber(value: seconds))!
			let millisecondsString = msFormatter.string(from: NSNumber(value: milliseconds))!
			
			let counter: String = hoursString + ":" + minutesString + ":" + secondsString + "," + millisecondsString
			
			return (hours, minutes, seconds, milliseconds, hoursString, minutesString, secondsString, millisecondsString, counter)
	}
	
	
	/// Returns the CMTime value as a tuple containing components of SMPTE timecode as separate values.
	///
	/// - Parameter frameDuration: The duration of a single frame as a CMTime value.
	/// - Returns: A tuple with hours, minutes, seconds, and frames as Int and String values.
	public func timeAsTimecode(usingFrameDuration frameDuration: CMTime, dropFrame: Bool) -> (hours: Int, minutes: Int, seconds: Int, frames: Int, hoursString: String, minutesString: String, secondsString: String, framesString: String, timecodeString: String, timecodeInSeconds: Double) {
		
		let framerate: Double
		if frameDuration == CMTime(value: 1001, timescale: 24000) { // If the framerate is 23.976, make the framerate 24 per SMPTE
			framerate = 24.0
		} else {
			framerate = 1 / (frameDuration.seconds)
		}
		
		// This block below provides correct timing readout for 23.98 NDF, 29.97 NDF and 59.98 NDF
		var numberOfFrames: Double
		switch frameDuration {
		case CMTime(value: 1001, timescale: 24000) where dropFrame == false:	// 23.98 NDF
			numberOfFrames = self.seconds / CMTime(value: 100, timescale: 2400).seconds
		case CMTime(value: 1001, timescale: 30000) where dropFrame == false:	// 29.97 NDF
			numberOfFrames = self.seconds / CMTime(value: 100, timescale: 3000).seconds
		case CMTime(value: 1001, timescale: 60000) where dropFrame == false:	// 59.98 NDF
			numberOfFrames = self.seconds / CMTime(value: 100, timescale: 6000).seconds
		default:
			numberOfFrames = self.seconds / frameDuration.seconds
		}
		
		// Round the number of frames so it's at a frame boundary
		numberOfFrames = round(numberOfFrames)
		
		// Calculate time values
		let hours = floor(numberOfFrames / (3600 * framerate))
		let minutes = floor((numberOfFrames / (60 * framerate)).truncatingRemainder(dividingBy: 60))
		let seconds = floor((numberOfFrames / framerate).truncatingRemainder(dividingBy: 60))
		let frames = numberOfFrames.truncatingRemainder(dividingBy: framerate)
		
		// Format strings
		let formatter = NumberFormatter()
		formatter.paddingCharacter = "0"
		formatter.minimumIntegerDigits = 2
		formatter.maximumIntegerDigits = 2
		
		let hoursString = formatter.string(from: NSNumber(value: hours))!
		let minutesString = formatter.string(from: NSNumber(value: minutes))!
		let secondsString = formatter.string(from: NSNumber(value: seconds))!
		let framesString = formatter.string(from: NSNumber(value: frames))!
		
		let counter: String
		if dropFrame == true {
			counter = hoursString + ":" + minutesString + ":" + secondsString + ";" + framesString
		} else {
			counter = hoursString + ":" + minutesString + ":" + secondsString + ":" + framesString
		}
		
		let timecodeInSeconds = (hours * 60 * 60) + (minutes * 60) + seconds + (frames * frameDuration.seconds)
		
		return (Int(hours), Int(minutes), Int(seconds), Int(frames), hoursString, minutesString, secondsString, framesString, counter, timecodeInSeconds)
	}
	
}
