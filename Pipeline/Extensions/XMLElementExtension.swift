//
//  XMLElementExtension.swift
//  Pipeline
//
//  Created by Reuel Kim on 1/15/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia


// MARK: - XMLELEMENT EXTENSION -
extension XMLElement {
	
	enum FCPXMLElementError: Error {
		case notAnEvent
		case notAnAnnotatableItem
		case notAnAnnotation
	}
	
	public enum TextAlignment: String {
		case Left = "left"
		case Center = "center"
		case Right = "right"
		case Justified = "justified"
	}
	
	public enum TimecodeFormat: String {
		case dropFrame = "DF"
		case nonDropFrame = "NDF"
	}
	
	public enum AudioLayout: String {
		case mono = "mono"
		case stereo = "stereo"
		case surround = "surround"
	}
	
	public enum AudioRate: String {
		case rate32kHz = "32k"
		case rate44_1kHz = "44.1k"
		case rate48kHz = "48k"
		case rate88_2kHz = "88.2k"
		case rate96kHz = "96k"
		case rate176_4kHz = "176.4k"
		case rate192kHz = "192k"
	}
	
	public enum RenderColorSpace: String {
		case rec601NTSC = "Rec. 601 (NTSC)"
		case rec601PAL = "Rec. 601 (PAL)"
		case rec709 = "Rec. 709"
		case rec2020 = "Rec. 2020"
	}
	
	
	// MARK: - Creating FCPXML XMLElement objects
	
	
	/// Creates a new event FCPXML XMLElement object.
	///
	/// - Parameter name: The name of the event in Final Cut Pro X.
	/// - Returns: An XMLElement object of the event.
	public func fcpxEvent(name: String) -> XMLElement {
		let element = XMLElement(name: "event")
		element.fcpxName = name
		return element
	}

	
	/// Creates a new event FCPXML XMLElement object and adds items to it.
	///
	/// - Parameters:
	///   - name: The name of the event in Final Cut Pro X.
	///   - items: Items to add to the event.
	/// - Returns: An XMLElement object of the event.
	public func fcpxEvent(name: String, items: [XMLElement]) -> XMLElement {
		let element = XMLElement(name: "event")
		element.fcpxName = name
		do {
			try element.addToEvent(items: items)
		} catch {
			return element
		}
		return element
	}
	
	
	/// Creates a new project FCPXML XMLElement object and adds clips to it.
	///
	/// - Parameters:
	///   - name: The name of the project in Final Cut Pro X.
	///   - formatRef: The reference ID for the format resource that matches this project.
	///   - duration: The duration of the clip as a CMTime value.
	///   - tcStart: The starting timecode of the project timeline as a CMTime value.
	///   - tcFormat: The TimecodeFormat enum value describing whether the project timecode is drop-frame or non-drop-frame.
	///   - audioLayout: The project audio channel layout as an AudioLayout enum value.
	///   - audioRate: The project audio sampling rate as an AudioRate enum value.
	///   - renderColorSpace: The project render color space as a RenderColorSpace enum value.
	///   - clips: Clip XMLElement objects to add to the timeline of the project.
	/// - Returns: The XMLElement object of the project.
	public func fcpxProject(name: String, formatRef: String, duration: CMTime, tcStart: CMTime, tcFormat: TimecodeFormat, audioLayout: AudioLayout, audioRate: AudioRate, renderColorSpace: RenderColorSpace, clips: [XMLElement]) -> XMLElement {
		
		let element = XMLElement(name: "project")
		element.fcpxName = name
		
		let sequence = XMLElement(name: "sequence")
		sequence.fcpxFormatRef = formatRef
		sequence.fcpxDuration = duration
		sequence.fcpxTCStart = tcStart
		sequence.fcpxTCFormat = tcFormat
		sequence.fcpxAudioLayout = audioLayout
		sequence.fcpxAudioRate = audioRate
		sequence.fcpxRenderColorSpace = renderColorSpace
		
		let spine = XMLElement(name: "spine")
		for clip in clips {
			let clipCopy = clip.copy() as! XMLElement
			spine.addChild(clipCopy)
		}
		
		sequence.addChild(spine)
		element.addChild(sequence)
		
		return element
		
	}
	
	
	/// Creates a new ref-clip FCPXML XMLElement object
	///
	/// - Parameters:
	///   - name: The name of the clip.
	///   - ref: The reference ID for the resource that this clip refers to.
	///   - offset: The clip’s location in parent time as a CMTime value.
	///   - duration: The duration of the clip as a CMTime value.
	///   - start: The start time of the clip's local timeline as a CMTime value.
	///   - useAudioSubroles: A boolean value indicating if the clip's audio subroles are accessible.
	/// - Returns: An XMLElement object of the ref-clip.
	public func fcpxCompoundClip(name: String, ref: String, offset: CMTime?, duration: CMTime, start: CMTime?, useAudioSubroles: Bool) -> XMLElement {
		
		let element = XMLElement(name: "ref-clip")
		
		element.fcpxName = name
		element.fcpxRef = ref
		element.fcpxOffset = offset
		element.fcpxDuration = duration
		element.fcpxStart = start
		
		if useAudioSubroles == true {
			element.setElementAttribute("useAudioSubroles", value: "1")
		} else {
			element.setElementAttribute("useAudioSubroles", value: "0")
		}
		
		return element
	}
	
	
	/// Creates a new gap to be used in a timeline.
	///
	/// - Parameters:
	///   - offset: The clip’s location in parent time as a CMTime value.
	///   - duration: The duration of the clip as a CMTime value.
	///   - start: The start time of the clip's local timeline as a CMTime value.
	/// - Returns: An XMLElement object of the gap.
	public func fcpxGap(offset: CMTime?, duration: CMTime, start: CMTime?) -> XMLElement {
		
		let element = XMLElement(name: "gap")
		
		element.fcpxOffset = offset
		element.fcpxDuration = duration
		element.fcpxStart = start
		
		return element
	}
	
	
	/// Creates a new title to be used in a timeline.
	/// - Note: The font, fontSize, fontFace, fontColor, strokeColor, strokeWidth, shadowColor, shadowDistance, shadowAngle, shadowBlurRadius, and alignment properties affect the text style only if the newTextStyle property is true.
	///
	/// - Parameters:
	///   - titleName: The name of the title clip on the timeline.
	///   - lane: The preferred timeline lane to place the clip into.
	///   - offset: The clip’s location in parent time as a CMTime value.
	///   - ref: The reference ID for the title effect resource that this clip refers to.
	///   - duration: The duration of the clip as a CMTime value.
	///   - start: The start time of the clip's local timeline as a CMTime value.
	///   - role: The role assigned to the clip.
	///   - titleText: The text displayed by this title clip.
	///   - textStyleID: The ID to assign to a newly generated text style definition or the ID to reference for an existing text style definition.
	///   - newTextStyle: True if this title clip should contain a newly generated text style definition.
	///   - font: The font family name to use for the title text.
	///   - fontSize: The font size.
	///   - fontFace: The font face.
	///   - fontColor: The color of the font.
	///   - strokeColor: The color of the stroke used on the title text.
	///   - strokeWidth: The width of the stroke.
	///   - shadowColor: The color of the shadow used underneath the title text.
	///   - shadowDistance: The distance of the shadow from the title text.
	///   - shadowAngle: The angle of the shadow offset.
	///   - shadowBlurRadius: The blur radius of the shadow.
	///   - alignment: The text paragraph alignment.
	///   - xPosition: The X position of the text on the screen.
	///   - yPosition: The Y position of the text on the screen.
	/// - Returns: An XMLElement object of the title, which will contain the text style definition, if specified.
	public func fcpxTitle(titleName: String, lane: Int?, offset: CMTime, ref: String, duration: CMTime, start: CMTime, role: String?, titleText: String, textStyleID: Int, newTextStyle: Bool, font: String = "Helvetica", fontSize: CGFloat = 62, fontFace: String = "Regular", fontColor: NSColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), strokeColor: NSColor? = nil, strokeWidth: Float = 2.0, shadowColor: NSColor? = nil, shadowDistance: Float = 5.0, shadowAngle: Float = 315.0, shadowBlurRadius: Float = 1.0, alignment: TextAlignment = TextAlignment.Center, xPosition: Float = 0, yPosition: Float = -40) -> XMLElement {
		
		let element = XMLElement(name: "title")
		
		element.fcpxName = titleName
		element.fcpxLane = lane
		element.fcpxOffset = offset
		element.fcpxRef = ref
		element.fcpxDuration = duration
		element.fcpxStart = start
		element.fcpxRole = role
		
		let text = XMLElement(name: "text")
		let textTextStyle = XMLElement(name: "text-style", stringValue: titleText)
		
		
		// Add the text content and its style
		textTextStyle.fcpxRef = "ts\(textStyleID)"  // Reference the new text style definition reference number
		
		text.addChild(textTextStyle)
		element.addChild(text)
		
		// Text Style Definition
		if newTextStyle == true {  // If a new text style definition hasn't been created yet
			
			let textStyleDef = XMLElement(name: "text-style-def")
			
			textStyleDef.fcpxID = "ts\(textStyleID)"
			
			let textStyleDefTextStyle = XMLElement(name: "text-style")
			
			textStyleDefTextStyle.setElementAttribute("font", value: font)
			textStyleDefTextStyle.setElementAttribute("fontSize", value: String(describing: fontSize))
			textStyleDefTextStyle.setElementAttribute("fontFace", value: fontFace)
			textStyleDefTextStyle.setElementAttribute("fontColor", value: "\(fontColor.redComponent) \(fontColor.greenComponent) \(fontColor.blueComponent) \(fontColor.alphaComponent)")
			
			if let strokeColor = strokeColor {
				
				textStyleDefTextStyle.setElementAttribute("strokeColor", value: "\(strokeColor.redComponent) \(strokeColor.greenComponent) \(strokeColor.blueComponent) \(strokeColor.alphaComponent)")
				textStyleDefTextStyle.setElementAttribute("strokeWidth", value: String(strokeWidth))
			}
			
			if let shadowColor = shadowColor {
				
				textStyleDefTextStyle.setElementAttribute("shadowColor", value: "\(shadowColor.redComponent) \(shadowColor.greenComponent) \(shadowColor.blueComponent) \(shadowColor.alphaComponent)")
				textStyleDefTextStyle.setElementAttribute("shadowOffset", value: "\(shadowDistance) \(shadowAngle)")
				textStyleDefTextStyle.setElementAttribute("shadowBlurRadius", value: String(shadowBlurRadius))
			}
			
			textStyleDefTextStyle.setElementAttribute("alignment", value: alignment.rawValue)
			
			textStyleDef.addChild(textStyleDefTextStyle)
			
			element.addChild(textStyleDef)
		}
		
		// Add the transform
		let adjustTransform = XMLElement(name: "adjust-transform")
		
		adjustTransform.setElementAttribute("position", value: "\(xPosition) \(yPosition)")
		
		element.addChild(adjustTransform)
		
		return element
	}
	
	
	
	// MARK: - Properties for attribute nodes within element tags
	public var fcpxType: FCPXMLElementType {
		get {
			guard let elementName = self.name else {
				return FCPXMLElementType.none
			}
			
			if let type = FCPXMLElementType(rawValue: elementName) {
				
				// Check to see if this is a multicam resource or compound resource
				if type == FCPXMLElementType.mediaResource {
					
					guard let nextNode = self.next else {
						return FCPXMLElementType.none
					}
					
					let nextElement = nextNode as! XMLElement
					
					guard let nextElementName = nextElement.name else {
						return FCPXMLElementType.none
					}
					
					switch nextElementName {
					case "multicam":
						return FCPXMLElementType.multicamResource
					case "sequence":
						return FCPXMLElementType.compoundResource
					default:
						return FCPXMLElementType.none
					}
					
				} else {
					// Not a multicam resource or compound resource so return the type corresponding to the rawValue
					return type
				}
				
			} else {
				return FCPXMLElementType.none
			}
		}
	}
	
	
	public var fcpxName: String? {
		get {
			if let attributeString = getElementAttribute("name") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("name", value: value)
			} else {
				self.removeAttribute(forName: "name")
			}
		}
	}
	
	public var fcpxDuration: CMTime? {
		get {
			if let attributeString = getElementAttribute("duration") {
				return FCPXMLUtility().CMTime(fromFCPXMLTime: attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				let valueAsString = FCPXMLUtility().fcpxmlTime(fromCMTime: value)
				setElementAttribute("duration", value: valueAsString)
			} else {
				self.removeAttribute(forName: "duration")
			}
		}
	}
	
	public var fcpxTCStart: CMTime? {
		get {
			if let attributeString = getElementAttribute("tcStart") {
				return FCPXMLUtility().CMTime(fromFCPXMLTime: attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				let valueAsString = FCPXMLUtility().fcpxmlTime(fromCMTime: value)
				setElementAttribute("tcStart", value: valueAsString)
			} else {
				self.removeAttribute(forName: "tcStart")
			}
		}
	}
	
	public var fcpxStart: CMTime? {
		get {
			if let attributeString = getElementAttribute("start") {
				return FCPXMLUtility().CMTime(fromFCPXMLTime: attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				let valueAsString = FCPXMLUtility().fcpxmlTime(fromCMTime: value)
				setElementAttribute("start", value: valueAsString)
			} else {
				self.removeAttribute(forName: "start")
			}
		}
	}
	
	public var fcpxOffset: CMTime? {
		get {
			if let attributeString = getElementAttribute("offset") {
				return FCPXMLUtility().CMTime(fromFCPXMLTime: attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				let valueAsString = FCPXMLUtility().fcpxmlTime(fromCMTime: value)
				setElementAttribute("offset", value: valueAsString)
			} else {
				self.removeAttribute(forName: "offset")
			}
		}
	}
	
	public var fcpxTCFormat: TimecodeFormat? {
		get {
			if let attributeString = getElementAttribute("tcFormat") {
				switch attributeString {
				case TimecodeFormat.dropFrame.rawValue:
					return TimecodeFormat.dropFrame
				case TimecodeFormat.nonDropFrame.rawValue:
					return TimecodeFormat.nonDropFrame
				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("tcFormat", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "tcFormat")
			}
		}
	}
	
	public var fcpxFormatRef: String? {
		get {
			if let attributeString = getElementAttribute("format") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("format", value: value)
			} else {
				self.removeAttribute(forName: "format")
			}
		}
	}
	
	public var fcpxRefOrID: String? { // Can be either a ref or an ID. Read-only.
		get {
			if let attributeString = getElementAttribute("ref") {
				return attributeString
			} else if let attributeString = getElementAttribute("id") {
				return attributeString
			} else {
				return nil
			}
		}
	}
	
	public var fcpxRef: String? {
		get {
			if let attributeString = getElementAttribute("ref") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("ref", value: value)
			} else {
				self.removeAttribute(forName: "ref")
			}
		}
	}
	
	public var fcpxID: String? {
		get {
			if let attributeString = getElementAttribute("id") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("id", value: value)
			} else {
				self.removeAttribute(forName: "id")
			}
		}
	}
	
	public var fcpxRole: String? {
		get {
			if let attributeString = getElementAttribute("role") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("role", value: value)
			} else {
				self.removeAttribute(forName: "role")
			}
		}
	}
	
	public var fcpxLane: Int? {
		get {
			if let attributeString = getElementAttribute("lane") {
				return Int(attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("lane", value: String(value))
			} else {
				self.removeAttribute(forName: "lane")
			}
		}
	}
	
	public var fcpxNote: String? {
		get {
			if let attributeString = getElementAttribute("note") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("note", value: value)
			} else {
				self.removeAttribute(forName: "note")
			}
		}
	}
	
	public var fcpxValue: String? {
		get {
			if let attributeString = getElementAttribute("value") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("value", value: value)
			} else {
				self.removeAttribute(forName: "value")
			}
		}
	}
	
	public var fcpxSrc: URL? {
		get {
			if let attributeString = getElementAttribute("src") {
				return URL(string: attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("src", value: value.absoluteString)
			} else {
				self.removeAttribute(forName: "src")
			}
		}
	}
	
	public var fcpxFrameDuration: CMTime? {
		get {
			if let attributeString = getElementAttribute("frameDuration") {
				return FCPXMLUtility().CMTime(fromFCPXMLTime: attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				let valueAsString = FCPXMLUtility().fcpxmlTime(fromCMTime: value)
				setElementAttribute("frameDuration", value: valueAsString)
			} else {
				self.removeAttribute(forName: "frameDuration")
			}
		}
	}
	
	public var fcpxWidth: Int? {
		get {
			if let attributeString = getElementAttribute("width") {
				let attributeInt = Int(attributeString)
				if attributeInt != 0 {
					return Int(attributeString)
				} else {
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("width", value: value.description)
			} else {
				self.removeAttribute(forName: "width")
			}
		}
	}
	
	public var fcpxHeight: Int? {
		get {
			if let attributeString = getElementAttribute("height") {
				let attributeInt = Int(attributeString)
				if attributeInt != 0 {
					return Int(attributeString)
				} else {
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("height", value: value.description)
			} else {
				self.removeAttribute(forName: "height")
			}
		}
	}
	
	public var fcpxAudioLayout: AudioLayout? {
		get {
			if let attributeString = getElementAttribute("audioLayout") {
				switch attributeString {
				case AudioLayout.mono.rawValue:
					return AudioLayout.mono
				case AudioLayout.stereo.rawValue:
					return AudioLayout.stereo
				case AudioLayout.surround.rawValue:
					return AudioLayout.surround
				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("audioLayout", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "audioLayout")
			}
		}
	}
	
	public var fcpxAudioRate: AudioRate? {
		get {
			if let attributeString = getElementAttribute("audioRate") {
				switch attributeString {
				case AudioRate.rate32kHz.rawValue:
					return AudioRate.rate32kHz
				case AudioRate.rate44_1kHz.rawValue:
					return AudioRate.rate44_1kHz
				case AudioRate.rate48kHz.rawValue:
					return AudioRate.rate48kHz
				case AudioRate.rate88_2kHz.rawValue:
					return AudioRate.rate88_2kHz
				case AudioRate.rate96kHz.rawValue:
					return AudioRate.rate96kHz
				case AudioRate.rate176_4kHz.rawValue:
					return AudioRate.rate176_4kHz
				case AudioRate.rate192kHz.rawValue:
					return AudioRate.rate192kHz
				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("audioRate", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "audioRate")
			}
		}
	}
	
	public var fcpxRenderColorSpace: RenderColorSpace? {
		get {
			if let attributeString = getElementAttribute("renderColorSpace") {
				switch attributeString {
				case RenderColorSpace.rec601NTSC.rawValue:
					return RenderColorSpace.rec601NTSC
				case RenderColorSpace.rec601PAL.rawValue:
					return RenderColorSpace.rec601PAL
				case RenderColorSpace.rec709.rawValue:
					return RenderColorSpace.rec709
				case RenderColorSpace.rec2020.rawValue:
					return RenderColorSpace.rec2020

				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("renderColorSpace", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "renderColorSpace")
			}
		}
	}
	
	public var fcpxHasAudio: Bool? {
		get {
			if let attributeString = getElementAttribute("hasAudio") {
				if attributeString == "1" {
					return true
				} else {
					return false
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				if value == true {
					setElementAttribute("hasAudio", value: "1")
				} else {
					setElementAttribute("hasAudio", value: "0")
				}
			} else {
				self.removeAttribute(forName: "hasAudio")
			}
		}
	}
	
	public var fcpxHasVideo: Bool? {
		get {
			if let attributeString = getElementAttribute("hasVideo") {
				if attributeString == "1" {
					return true
				} else {
					return false
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				if value == true {
					setElementAttribute("hasVideo", value: "1")
				} else {
					setElementAttribute("hasVideo", value: "0")
				}
			} else {
				self.removeAttribute(forName: "hasVideo")
			}
		}
	}
	
	public var fcpxUID: String? {
		get {
			if let attributeString = getElementAttribute("uid") {
				return attributeString
			} else {
				return nil
			}
		}
        
        set(value) {
            if let value = value {
                setElementAttribute("uid", value: value)
            } else {
                self.removeAttribute(forName: "uid")
            }
        }
	}
	
	public var fcpxParentInPoint: CMTime? {
		get {
			guard let inPoint = self.fcpxOffset else {
				return nil
			}
			return inPoint
		}
		set(value) {
			if let value = value {
				self.fcpxOffset = value
			} else {
				self.fcpxOffset = nil
			}
		}
	}
	
	public var fcpxParentOutPoint: CMTime? {
		get {
			guard let inPoint = self.fcpxOffset else {
				return nil
			}
			guard let duration = self.fcpxDuration else {
				return nil
			}
			return CMTimeAdd(inPoint, duration)
		}
		
		set(value) {
			if let value = value {
				guard let inPoint = self.fcpxOffset else {
					self.fcpxDuration = nil
					return
				}
				let newDuration = CMTimeSubtract(value, inPoint)
				self.fcpxDuration = newDuration
				
			} else {
				self.fcpxDuration = nil
			}
		}
	}
	
	public var fcpxLocalInPoint: CMTime? {
		get {
			guard let inPoint = self.fcpxStart else {
				return nil
			}
			return inPoint
		}
		set(value) {
			if let value = value {
				self.fcpxStart = value
			} else {
				self.fcpxStart = nil
			}
		}
	}
	
	public var fcpxLocalOutPoint: CMTime? {
		get {
			guard let inPoint = self.fcpxStart else {
				return nil
			}
			guard let duration = self.fcpxDuration else {
				return nil
			}
			return CMTimeAdd(inPoint, duration)
		}
		
		set(value) {
			if let value = value {
				guard let inPoint = self.fcpxStart else {
					self.fcpxDuration = nil
					return
				}
				let newDuration = CMTimeSubtract(value, inPoint)
				self.fcpxDuration = newDuration
				
			} else {
				self.fcpxDuration = nil
			}
		}
	}
	
	
	// MARK: - Other element properties that are beyond the element itself
	
	/// True if this XMLElement is an item in an event, not a resource.
	public var isFCPXEventItem: Bool {
		get {
			if self.fcpxType == .assetClip ||
				self.fcpxType == .multicamClip ||
				self.fcpxType == .compoundClip ||
				self.fcpxType == .synchronizedClip ||
				self.fcpxType == .project
			{
				return true
			} else {
				return false
			}
		}
	}
	
	/// True if this XMLElement is a resource, not an event item.
	public var isFCPXResource: Bool {
		get {
			if self.fcpxType == .assetResource ||
				self.fcpxType == .formatResource ||
				self.fcpxType == .mediaResource ||
				self.fcpxType == .multicamResource ||
				self.fcpxType == .compoundResource ||
				self.fcpxType == .effectResource
			{
				return true
			} else {
				return false
			}
		}
	}
	
	
	/// If this is an event item, the event that contains it. Returns nil if it is not an event item.
	public var fcpxParentEvent: XMLElement? {
		get {
			guard self.isFCPXEventItem == true else { // If this is a clip inside an event
				return nil
			}
			
			var parentElement = self.parent as! XMLElement
			
			while parentElement.name != "event" {
				parentElement = parentElement.parent as! XMLElement
				
				// If the parent is the top of the document, return nil
				if parentElement.name == "fcpxml" {
					return nil
				}
			}
			return parentElement
		}
	}
	
	
	/// If this is an event item, the XMLElement of its corresponding resource.
	public var fcpxResource: XMLElement? {
		get {
			
			guard let referenceID = self.fcpxRef else {
				return nil
			}
			
			if let resource = self.rootDocument?.resource(matchingID: referenceID) {
				return resource
			} else {
				return nil
			}
		}
	}
	
	/// An array of the annotation XMLElements within this event item or resource.
	public var fcpxAnnotations: [XMLElement] {
		get {
				var annotationElements: [XMLElement] = []
				
				guard let subNodes = self.children else {
					return annotationElements
				}
				
				let subElements = subNodes as! [XMLElement]
				
				for subElement in subElements {
					
					if subElement.fcpxType == .keyword ||
						subElement.fcpxType == .rating ||
						subElement.fcpxType == .marker ||
						subElement.fcpxType == .chapterMarker ||
						subElement.fcpxType == .analysisMarker ||
						subElement.fcpxType == .note {
						
						annotationElements.append(subElement)
					}
				}
				
				return annotationElements
		}
	}
	
	
	/// Returns clips from an event that match this resource. If this method is called on an XMLElement that is not a resource, nil will be returned. If there are no matching clips in the event, an empty array will be returned.
	///
	/// - Parameter event: The event XMLElement to search.
	/// - Returns: An optional array of XMLElement objects.
	public func referencingClips(inEvent event: XMLElement) -> [XMLElement]? {
	
		guard let resourceID = self.fcpxID else {
			return nil
		}
		
		return event.eventClips(forResourceID: resourceID)

	}
	
	// MARK: - Methods for events
	
	/// Returns all items contained within this event. If this is not an event, the property will be nil. If the event is empty, the property will be an empty array.
	public var eventItems: [XMLElement]? {
		get {
			guard self.fcpxType == .event else {
				return nil
			}
			
			guard let itemNodes = self.children else {
				return []
			}
			
			let itemElements = itemNodes as! [XMLElement]
			
			return itemElements
		}
	}
	
	
	/// Returns the projects contained within this event. If this is not an event, the property will be nil. If the event has no projects, the property will be an empty array.
	public var eventProjects: [XMLElement]? {
		get {
			guard self.fcpxType == .event else {
				return nil
			}
			
			guard let itemNodes = self.children else {
				return []
			}
			
			let itemElements = itemNodes as! [XMLElement]
			
			let items = FCPXMLUtility().filter(fcpxElements: itemElements, ofTypes: [.project])
			
			return items
		}
	}
	
	
	/// Returns the clips contained within this event, excluding the projects. If this is not an event, the property will be nil. If the event has no clips, the property will be an empty array.
	public var eventClips: [XMLElement]? {
		get {
			guard self.fcpxType == .event else {
				return nil
			}
			
			guard let clipNodes = self.children else {
				return []
			}
			
			let clipElements = clipNodes as! [XMLElement]
			
			let clips = FCPXMLUtility().filter(fcpxElements: clipElements, ofTypes: [.assetClip, .compoundClip, .multicamClip, .synchronizedClip])
			
			return clips
		}
	}
	
	
	/// Returns all clips in an event that match the given resource ID. If this method is called on an XMLElement that is not an event, nil will be returned. If there are no clips that match the resourceID, an empty array will be returned.
	///
	/// - Parameters:
	///   - resourceID: A string of the resourceID value.
	/// - Returns: An array of XMLElement objects that refer to the matching clips. Note that multiple clips in an event can refer to a single resource ID.
	public func eventClips(forResourceID resourceID: String) -> [XMLElement]? {
		
		guard self.fcpxType == .event else {
			return nil
		}
		
		var matchingClips: [XMLElement] = []
		
		// Get the items in the event.
		guard let clipNodes = self.children else {
			return matchingClips
		}
		
		let clips = clipNodes as! [XMLElement]
		
		for clip in clips {
			
			if clip.fcpxRef == resourceID {
				matchingClips.append(clip)
			}
			
		}
		
		return matchingClips
	}
	
	
	/**
	
	
	- parameter containingAsset:
	
	- returns:
	*/
	
	/// Searches for items in an event that match a given asset resource. This method will also search inside synchronized clips, multicams, and compound clips for matches, but not inside projects. If this XMLElement is not an event, the method will return nil. Updated for FCPXML v1.6. ** NOTE: Currently only searches for matching video clips of all clip types.
	///
	/// - Parameter resource: The resource XMLElement to match with.
	/// - Returns: An array of XMLElement objects of the event clip matching the asset.
	public func eventClips(containingResource resource: XMLElement) throws -> [XMLElement] {
		
		guard self.fcpxType == .event else {
			throw FCPXMLElementError.notAnEvent
		}
		
		var matchingItems: [XMLElement] = []
		
		guard let items = self.eventItems else {
			return matchingItems
		}
		
		for item in items {
			
			switch item.fcpxType {
				
			case .assetClip:  // Check for matching regular clips
				print("Checking a regular clip in the event...")
				
				if item.fcpxRef == resource.fcpxID { // Found regular clip
					matchingItems.append(item)
					
					print("Matching regular clip found: \(item.fcpxName)")
				}
				
			case .synchronizedClip:  // Check for matching synchronized clips
				print("Checking a synchronized clip in the event...")
				
				guard let itemChildren = item.children else {
					continue
				}
				
				for itemChild in itemChildren {
					let itemChildElement = itemChild as! XMLElement
					
					// Find regular synchronized clips
					if itemChildElement.fcpxType == .assetClip { // Normal synchronized clip
						
						if itemChildElement.fcpxRef == resource.fcpxID {  // Match found on a primary storyline clip
							print("Matching synchronized clip found: \(item.attribute(forName: "name")?.stringValue)")
							
							matchingItems.append(item)
							
						} else {  // Check clips attached to this primary storyline clip
						
							guard let syncedClipChildren = itemChildElement.children else {
								continue
							}
							
							for syncedClipChild in syncedClipChildren {
								let syncedClipChildElement = syncedClipChild as! XMLElement
								
								if syncedClipChildElement.fcpxRef == resource.fcpxID {
									
									print("Matching synchronized clip found: \(item.attribute(forName: "name")?.stringValue)")
									matchingItems.append(item)
								}
							}
						}
						
					} else if itemChildElement.fcpxType == .spine { // Found a synchronized clip with multiple clips inside
						// FIXME: Need to test this out and see if it works.
						
						guard let spineChildren = itemChildElement.children else {
							continue
						}
						
						for spineChild in spineChildren {
							
							guard let spineClipChildren = spineChild.children else {
								continue
							}
							
							for spineClipChild in spineClipChildren {
								let spineClipChildElement = spineClipChild as! XMLElement
								
								if spineClipChildElement.fcpxRef == resource.fcpxID {
									
									print("Matching synchronized clip found: \(item.attribute(forName: "name")?.stringValue)")
									matchingItems.append(item)
								}
							}
							
						}
					}
				}
				
			case .multicamClip:  // Check for matching multicam clips
				print("Checking a multicam in the event...")
				
				if item.fcpxRef == resource.fcpxID { // The asset ID matches this multicam so add it immediately to the matchingItems array.
					
					print("Matching multicam found: \(item.attribute(forName: "name")?.stringValue)")
					matchingItems.append(item)
					
					continue
					
				} else {  // Search within the multicam for any asset matches
					
					// Scan list of multicams for the multicam asset that matches this event item
					guard let multicamResources = self.rootDocument?.fcpxMulticamResources else {
						break
					}
					
					for multicam in multicamResources {
						
						guard multicam.fcpxID == item.fcpxRef else { // This multicam asset matches the event item
							continue
						}
						
						guard let multicamNode = multicam.next else { // Get the <multicam> node within the <media> node
							continue
						}
						
						let multicamElement = multicamNode as! XMLElement
						let multicamAngles = multicamElement.elements(forName: "mc-angle")
						
						// See if there are any angles that match the asset
						for multicamAngle in multicamAngles {
							
							guard let multicamAngleChildren = multicamAngle.children else {
								continue
							}
							
							for multicamAngleChild in multicamAngleChildren {
								
								let multicamAngleChildElement = multicamAngleChild as! XMLElement
								
								guard multicamAngleChildElement.fcpxType == .assetClip else {
									continue
								}
								
								if multicamAngleChildElement.fcpxRef == resource.fcpxID {
									
									print("Matching multicam found: \(item.attribute(forName: "name")?.stringValue)")
									matchingItems.append(item)
									break
								}
								
							}
							
							
						}
						
					}
				}
				
				
			case .compoundClip:  // Check for matching compound clips
				print("Checking a compound clip in the event...")
				
				// Use the reference to find the matching resource media
				// Check inside the media and see if the video references the matchingAsset
				guard let compoundResources = self.rootDocument?.fcpxCompoundResources else {
					break
				}
				
				for compound in compoundResources {
					if item.fcpxRef == compound.fcpxID {
						
						let sequence = compound.next as! XMLElement
						let spine = sequence.next as! XMLElement
						
						guard let spineChildren = spine.children else {
							continue
						}
						
						for childClip in spineChildren {
							let childClipElement = childClip as! XMLElement
							
							if childClipElement.fcpxRef == resource.fcpxID {  // Check primary storyline clip
								print("Matching compound clip found: \(item.attribute(forName: "name")?.stringValue)")
								matchingItems.append(item)
								
							} else {  // Check clips attached to this primary storyline clip
							
								guard let childClipElementChildren = childClipElement.children else {
									break
								}
								
								for attachedClip in childClipElementChildren {
									let attachedClipElement = attachedClip as! XMLElement
									
									if attachedClipElement.fcpxRef == resource.fcpxID {
										print("Matching compound clip found: \(item.attribute(forName: "name")?.stringValue)")
										matchingItems.append(item)
									}
									
									// FIXME: Doesn't check secondary storylines right now. Need to go a level deeper.
								}
								
							}
							
						}
						
					}
					
				}
				
			default:
				continue
				
			} // End item type cases
			
		} // End item for-loop
		
		return matchingItems
	}
	

	
	/// Adds an item to this event. If this XMLElement is not an event, an error is thrown.
	///
	/// - Parameters:
	///   - item: The item to add as an XMLElement.
	/// - Throws: FCPXMLElementError.notAnEvent if the element is not an event.
	public func addToEvent(item: XMLElement) throws {
		
		guard self.fcpxType == .event else {
			throw FCPXMLElementError.notAnEvent
		}
		
		let itemCopy = item.copy() as! XMLElement
		
		self.addChild(itemCopy)
		
	}
	
	/// Adds multiple items to this event. If this XMLElement is not an event, an error is thrown.
	///
	/// - Parameters:
	///   - items: An array of XMLElement items to add.
	/// - Throws: FCPXMLElementError.notAnEvent if the element is not an event.
	public func addToEvent(items: [XMLElement]) throws {
		
		guard self.fcpxType == .event else {
			throw FCPXMLElementError.notAnEvent
		}
		
		for item in items {
			let itemCopy = item.copy() as! XMLElement
			self.addChild(itemCopy)
		}
	}
	
	
	/// Removes an item from this event. If this XMLElement is not an event, an error is thrown.
	/// - Note: Use XMLElement.index to obtain the index value to use in the itemIndex parameter.
	///
	/// - Parameter itemIndex: The index of the XMLElement to remove.
	/// - Throws: FCPXMLElementError.notAnEvent if the element is not an event.
	public func removeFromEvent(itemIndex: Int) throws {
		guard self.fcpxType == .event else {
			throw FCPXMLElementError.notAnEvent
		}
		
		self.removeChild(at: itemIndex)
	}
	
	/// Removes a group of items from this event. If this XMLElement is not an event, an error is thrown.
	/// - Note: Use XMLElement.index to obtain the index values to use in the itemIndex parameter.
	///
	/// - Parameter itemIndexes: An array of the indexes of the XMLElements to remove.
	/// - Throws: FCPXMLElementError.notAnEvent if the element is not an event.
	public func removeFromEvent(itemIndexes: [Int]) throws {
		guard self.fcpxType == .event else {
			throw FCPXMLElementError.notAnEvent
		}
		
		for index in itemIndexes.sorted().reversed() {
			self.removeChild(at: index)
		}
	}

	// MARK: - Methods for event clips
	
	/// Adds an annotation XMLElement to this item, maintaining the proper order of the DTD. Conforms to FCPXML DTD v1.6.
	///
	/// - Parameter annotationElements: The annotations to add as an array of XMLElement objects.
	/// - Throws: Throws an error if an annotation cannot be added to this type of FCPXML element or if the element to add is not an annotation.
	public func addToClip(annotationElements elements: [XMLElement]) throws {
		
		guard self.fcpxType == .project || self.fcpxType == .synchronizedClip || self.fcpxType == .compoundClip || self.fcpxType == .multicamClip || self.fcpxType == .assetClip else {
			throw FCPXMLElementError.notAnAnnotatableItem
		}
		
		if let children = self.children {  // If there are children, insert the annotations at the appropriate point
			
			var insertIndex = 0
			
			for child in children {
				// These elements should come AFTER annotation elements so if one is encountered, break the loop and use that as the insert point.
				if child.name == "audio-role-source" || child.name == "audio-channel-source" || child.name == "filter-video" || child.name == "filter-video-mask" || child.name == "filter-audio" || child.name == "metadata" || child.name == "sync-source" {
					
					insertIndex = child.index
					break
				}
				
				insertIndex = child.index + 1
			}
			
			for element in elements {
				
				guard element.fcpxType == .note || element.fcpxType == .marker || element.fcpxType == .chapterMarker || element.fcpxType == .rating || element.fcpxType == .keyword || element.fcpxType == .analysisMarker else {
					throw FCPXMLElementError.notAnAnnotation
				}
				
				element.detach()
				
				self.insertChild(element, at: insertIndex)
				insertIndex += 1
			}
			
		} else { // No children so just add to the clips.
			for element in elements {
				
				guard element.fcpxType == .note || element.fcpxType == .marker || element.fcpxType == .chapterMarker || element.fcpxType == .rating || element.fcpxType == .keyword || element.fcpxType == .analysisMarker else {
					throw FCPXMLElementError.notAnAnnotation
				}
				
				element.detach()
				
				self.addChild(element)
			}
		}
	}
	
	
	// MARK: - Retrieving format information
	
	/// Returns an element's associated format name, ID, frame duration, and frame size.
	///
	/// - Returns: A tuple with a formatID string, formatName string, frameDuration CMTime, and frameSize CGSize.
	public func formatValues() -> (formatID: String, formatName: String, frameDuration: CMTime, frameSize: CGSize)? {
		
		// Get the format's ID
		guard let formatID = self.formatID(forElement: self) else {
			print("No format ID in the element.")
			return nil
		}
		
		// Get the format element
		guard let formatElement = self.rootDocument?.resource(matchingID: formatID) else {
			print("No format matching ID \(formatID)")
			return nil
		}
		
		// Get the format values from the element
		guard let values = self.formatValues(fromElement: formatElement) else {
			print("formatValues failed")
			return nil
		}
		
		return values
		
	}
	

	/// Get's an element's corresponding format element ID. This function can obtain the format for resources, event clips, and projects.
	///
	/// - Parameter element: The element to search.
	/// - Returns: The element format's ID as a String, or nil if none is found.
	private func formatID(forElement element: XMLElement) -> String? {
		
		switch element.fcpxType {
		case .assetResource, .assetClip, .synchronizedClip:  // These elements will have the format reference ID in the top level element.
			
			return element.fcpxFormatRef
			
		case .project, .multicamResource, .compoundResource:  // These elements will have the format reference ID in the second level element.

			guard let nextNode = element.next else {
				return nil
			}
			
			let nextElement = nextNode as! XMLElement
			
			return nextElement.fcpxFormatRef
			
		case .compoundClip, .multicamClip:  // These elements will have the format reference ID in their corresponding resource's second level element.

			guard let resource = element.fcpxResource else {
				return nil
			}
			
			// Get the formatID from the resource's second level element by running the resource through this method.
			let resourceFormatID = self.formatID(forElement: resource)
			
			return resourceFormatID
			
		default:
			return nil
			
		}
		
	}
	

	
	
	/// Takes a format resource XMLElement and returns its ID, name, frame duration, and frame size.
	///
	/// - Parameter element: The XMLElement of the format resource
	/// - Returns: A tuple with formatID string, formatName string, frameDuration CMTime, and frameSize CGSize. Or returns null of the element is not a format resource.
	private func formatValues(fromElement element: XMLElement) -> (formatID: String, formatName: String, frameDuration: CMTime, frameSize: CGSize)? {
		
		guard let elementName = element.name,
			elementName == "format" else {
				return nil
		}
		
		var formatID = ""
		var formatName = ""
		var frameDuration = CMTime()
		var frameSize = CGSize()
		
		if element.fcpxID != nil {
			formatID = element.fcpxID!
		}
		
		if element.fcpxName != nil {
			formatName = element.fcpxName!
		}
		
		if element.fcpxFrameDuration != nil {
			frameDuration = element.fcpxFrameDuration!
		}
		
		if element.fcpxHeight != nil && element.fcpxWidth != nil {
			frameSize = CGSize(width: element.fcpxWidth!, height: element.fcpxHeight!)
		}
		
		return (formatID, formatName, frameDuration, frameSize)
	}
	
	
	
	
	// MARK: - Miscellaneous
	

	
	/**
	Retrieves the URLs from the elements contained within this resource.
	
	- returns: An array of NSURLs.
	*/
	public func urls() -> [URL] {
		
		var URLs: [URL] = []
		
		// Get the references
		guard let references = self.allReferenceIDs() else {
			return []
		}
		
		// Get the reference and pull the URL
		for ref in references {
			guard let resource = self.rootDocument?.resource(matchingID: ref) else {
				continue
			}
			
			let sourceParser = AttributeParser(element: resource, attribute: "src", inElementsWithName: nil)
			
			if sourceParser.values.count > 0 {
				for source in sourceParser.values {
					let URL = Foundation.URL(string: source)
					
					if URL != nil {
						URLs.append(URL!)
					}
				}
			}
		}
		
		return URLs
	}
	
	
	/**
	Searches the given element and its sub-elements for references and returns them.
	
	- returns: The references as an array of strings or nil if no reference is found.
	*/
	public func allReferenceIDs() -> [String]? {
		let refParser = AttributeParser(element: self, attribute: "ref", inElementsWithName: nil)
		let references = refParser.values
		
		if references.count > 0 {
			return references
		} else {
			return nil
		}
	}
	
	
	
	
	

	
	
	/**
	A recursive function that goes through an element and all its children, finding clips that match the given name.
	
	- parameter forName: A String of the name to match clips with.
	- parameter inElement: The XMLElement to recursively search. This is usually self.
	- parameter usingAbsoluteMatch: A boolean value of whether names must match absolutely or whether clip names containing the string will yield a match.
	
	- returns: An array of matching clips as XMLElement objects.
	*/
	public func clips(forName name: String, inElement element: XMLElement, usingAbsoluteMatch: Bool) -> [XMLElement] {
		
		var matchingElements: [XMLElement] = []
		
		if let children = element.children {
			
			for child in children {
				
				if child.kind == XMLNode.Kind.element {
					
					let childElement = child as! XMLElement
					let nameAttribute = childElement.attribute(forName: "name")
					
					if let nameAttribute = nameAttribute {
						
						if usingAbsoluteMatch == true {
							
							if nameAttribute.stringValue! == name {
								
								matchingElements.append(childElement)
								
							}
							
						} else { // Lookes for a match within the string
							
							if nameAttribute.stringValue!.contains(name) == true {
								
								matchingElements.append(childElement)
								
							}
						}
						
					}
					
					// Recurse through children
					if childElement.children != nil {
						
						let items = clips(forName: name, inElement: childElement, usingAbsoluteMatch: usingAbsoluteMatch)
						
						matchingElements.append(contentsOf: items)
					}
				}
				
			}
			
		}
		
		return matchingElements
		
	}
	
	
	/**
	A recursive function that goes through an element and all its children, finding clips that match the given type.
	
	- parameter elementType: A type of FCPXML element as FCPXMLElementType enumeration.
	- parameter inElement: The XMLElement to recursively search. This is usually self.
	
	- returns: An array of matching clips as XMLElement objects.
	*/
	public func clips(forElementType elementType: FCPXMLElementType, inElement element: XMLElement) -> [XMLElement] {
		
		var matchingElements: [XMLElement] = []
		
		if let children = element.children {
			
			for child in children {
				
				if child.kind == XMLNode.Kind.element {
					
					let childElement = child as! XMLElement
					
					if let childElementName = childElement.name {
						
						if childElementName == elementType.rawValue {
							
							matchingElements.append(childElement)
						}
						
					}
					
					// Recurse through children
					if childElement.children != nil {
						
						let items = clips(forElementType: elementType, inElement: childElement)
						
						matchingElements.append(contentsOf: items)
					}
				}
				
			}
			
		}
		
		return matchingElements
		
	}
	
	
	
	
	
	// MARK: - Internal functions
	internal func getElementAttribute(_ name: String) -> String? {
		
		if let elementAttribute = self.attribute(forName: name) {
			
			if let attributeString = elementAttribute.stringValue {
				
				return attributeString
			}
		}
		
		return nil
	}
	
	internal func setElementAttribute(_ name: String, value: String) {
		
		let attribute = XMLNode(kind: XMLNode.Kind.attribute)
		
		attribute.name = name
		attribute.stringValue = value
		
		self.addAttribute(attribute)
		
	}

	
	// MARK: - Timing methods
	
	// Return true if the given time is within the in and out points of the clip
	public func clipRangeIncludes(_ time: CMTime) -> Bool {
		
		guard let clipInPoint = self.fcpxParentInPoint else {
			return false
		}
		
		guard let clipOutPoint = self.fcpxParentOutPoint else {
			return false
		}
		
		if clipInPoint.seconds <= time.seconds && time.seconds <= clipOutPoint.seconds {
			
			return true
			
		} else {
			return false
		}
	}
	
	public func clipRangeIsEnclosedBetween(_ inPoint: CMTime, outPoint: CMTime) -> Bool {
		guard let clipInPoint = self.fcpxParentInPoint else {
			return false
		}
		
		guard let clipOutPoint = self.fcpxParentOutPoint else {
			return false
		}
		
		if inPoint.seconds <= clipInPoint.seconds && clipOutPoint.seconds <= outPoint.seconds {
			return true
		} else {
			return false
		}
	}
	
	
	// Reference for how a clip would overlap.
	//
	//     [  referring ]         [ referring ]          [  referring  ]
	// [ title ]   [ title ]    [      title    ]           [ title ]
	// (t,f,t)      (t,t,f)   (true, false, false)     (true, true, true)
	
	/**
	Returns whether the clip overlaps with a given time range specified by an in and out point.
	
	- parameter inPoint: The in point as a CMTime value.
	- parameter outPoint: The out point as a CMTime value.
	
	- returns: A tuple containing three boolean values. "Overlaps" indicates whether the clip overlaps at all with the in and out point range. "withClipInPoint" indicates whether the element's in point overlaps with the range. "withClipOutPoint" indicates whether the element's out point overlaps with the range.
	*/
	public func clipRangeOverlapsWith(_ inPoint: CMTime, outPoint: CMTime) -> (overlaps: Bool, withClipInPoint: Bool, withClipOutPoint: Bool) {
		
		var overlaps: Bool = false
		var withClipInPoint: Bool = false
		var withClipOutPoint: Bool = false
		
		guard let _ = self.fcpxParentInPoint else {
			return (overlaps, withClipInPoint, withClipOutPoint)
		}
		
		guard let _ = self.fcpxParentOutPoint else {
			return (overlaps, withClipInPoint, withClipOutPoint)
		}
		
		
		if self.clipRangeIsEnclosedBetween(inPoint, outPoint: outPoint) {
			
			overlaps = true
			withClipInPoint = true
			withClipOutPoint = true
			
		} else if self.clipRangeIncludes(inPoint) && self.clipRangeIncludes(outPoint) {
			
			overlaps = true
			withClipInPoint = false
			withClipOutPoint = false
			
		} else {
			
			if self.clipRangeIncludes(inPoint) {
				overlaps = true
				withClipOutPoint = true
			}
			
			if self.clipRangeIncludes(outPoint) {
				overlaps = true
				withClipInPoint = true
			}
		}
		
		return (overlaps, withClipInPoint, withClipOutPoint)
	}
	
	
	/**
	Returns child elements that fall within the specified in and out points. The element type can optionally be specified.
	
	- parameter inPoint: The in point as a CMTime value.
	- parameter outPoint: The out point as a CMTime value.
	- parameter elementType: The element type as an FCPXMLElementType enum value. If the value is nil, the method will return all child elements that match the criteria.
	
	- returns: An array of tuples. Each tuple contains the XML Element as an NSXMLElement, a boolean value indicating whether the element's in point overlaps with the range, and a boolean value indicating whether the element's out point overlaps with the range.
	*/
	public func childElementsWithinRangeOf(_ inPoint: CMTime, outPoint: CMTime, elementType: FCPXMLElementType?) -> [(XMLElement: XMLElement, overlapsInPoint: Bool, overlapsOutPoint: Bool)] {
		
		var elementsInRange: [(XMLElement: XMLElement, overlapsInPoint: Bool, overlapsOutPoint: Bool)] = []
		
		var children: [XMLElement] = []
		
		if elementType == nil { // If no type is specified
			
			guard let childNodes = self.children else { // Check for nil value
				return []
			}
			
			children = childNodes as! [XMLElement]
			
		} else { // If a type is specified
			
			children = self.elements(forName: elementType!.rawValue)
		}
		
		for element in children {
			
			let overlaps = element.clipRangeOverlapsWith(inPoint, outPoint: outPoint)
			
			if overlaps.overlaps == true {
				print("\(element.fcpxName) \(overlaps.withClipInPoint),\(overlaps.withClipOutPoint)")
				
				elementsInRange.append((XMLElement: element, overlapsInPoint: overlaps.withClipInPoint, overlapsOutPoint: overlaps.withClipOutPoint))
				
			}
			
		}
		
		return elementsInRange
	}
	
}


