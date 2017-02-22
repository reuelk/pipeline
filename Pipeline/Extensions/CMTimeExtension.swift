//
//  CMTimeExtension.swift
//  Pipeline
//
//  Created by Reuel Kim on 1/15/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia


// MARK: - CMTIME EXTENSION -
extension CMTime {
	public var fcpxmlString: String {
		get {
			if self.value == 0 {
				return "0s"
			} else {
				return "\(self.value)/\(self.timescale)s"
			}
		}
	}
	
	
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
	
	public func timeAsTimecode(usingFrameDuration frameDuration: CMTime) -> (hours: Int, minutes: Int, seconds: Int, frames: Int, hoursString: String, minutesString: String, secondsString: String, framesString: String, timecodeString: String) {
		
		let framerate: Double
		if frameDuration == CMTime(value: 1001, timescale: 24000) { // If the framerate is 23.976, make the framerate 24 per SMPTE
			framerate = 24.0
		} else {
			framerate = 1 / (frameDuration.seconds)
		}
		
		let numberOfFrames = self.seconds / frameDuration.seconds
		
		let hours = floor(numberOfFrames / (3600 * framerate))
		let minutes = floor((numberOfFrames / (60 * framerate)).truncatingRemainder(dividingBy: 60))
		let seconds = floor((numberOfFrames / framerate).truncatingRemainder(dividingBy: 60))
		let frames = numberOfFrames.truncatingRemainder(dividingBy: framerate)
		
		let formatter = NumberFormatter()
		formatter.paddingCharacter = "0"
		formatter.minimumIntegerDigits = 2
		formatter.maximumIntegerDigits = 2
		
		let hoursString = formatter.string(from: NSNumber(value: hours))!
		let minutesString = formatter.string(from: NSNumber(value: minutes))!
		let secondsString = formatter.string(from: NSNumber(value: seconds))!
		let framesString = formatter.string(from: NSNumber(value: frames))!
		
		let counter: String = hoursString + ":" + minutesString + ":" + secondsString + ":" + framesString
		
		return (Int(hours), Int(minutes), Int(seconds), Int(frames), hoursString, minutesString, secondsString, framesString, counter)
	}
}
