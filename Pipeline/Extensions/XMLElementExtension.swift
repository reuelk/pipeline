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
	
	// MARK: - Creating FCPXML XMLElement Objects
	
	
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
		let element = self.fcpxEvent(name: name)
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
	
	
	
	/// Creates a new FCPXML multicam reference XMLElement object.
	///
	/// - Parameters:
	///   - name: The name of the resource.
	///   - id: The unique reference ID of this resource.
	///   - formatRef: The reference ID of the format that this resource uses.
	///   - tcStart: The starting timecode value of this resource.
	///   - tcFormat: The timecode format as an XMLElement.TimecodeFormat enumeration value.
	///   - renderColorSpace: The color space of this multicam as an XMLElement.TimecodeFormat enumeration value.
	///   - angles: The mc-angle elements to embed in this multicam resource.
	/// - Returns: An XMLElement object of the multicam <media> resource.
	public func fcpxMulticamResource(name: String, id: String, formatRef: String, tcStart: CMTime?, tcFormat: XMLElement.TimecodeFormat, renderColorSpace: XMLElement.RenderColorSpace, angles: [XMLElement]) -> XMLElement {
		
		let element = XMLElement(name: "media")
		
		element.fcpxName = name
		element.fcpxID = id
		
		let multicamElement = XMLElement(name: "multicam")
		
		multicamElement.fcpxFormatRef = formatRef
		multicamElement.fcpxRenderColorSpace = renderColorSpace
		multicamElement.fcpxTCStart = tcStart
		multicamElement.fcpxTCFormat = tcFormat
		
		angles.forEach { (angle) in
			multicamElement.addChild(angle)
		}
		
		element.addChild(multicamElement)
		
		return element
	}
	
	
	/// Creates a new multicam event clip XMLElement object.
	///
	/// - Parameters:
	///   - name: The name of the clip.
	///   - refID: The reference ID.
	///   - offset: The clip’s location in parent time as a CMTime value.
	///   - duration: The duration of the clip as a CMTime value.
	///   - mcSources: An array of mc-source elements to place in this element.
	/// - Returns: An XMLElement object of the multicam <mc-clip> resource.
	public func fcpxMulticamClip(name: String, refID: String, offset: CMTime?, start: CMTime?, duration: CMTime, mcSources: [XMLElement]) -> XMLElement {
		
		let element = XMLElement(name: "mc-clip")
		
		element.fcpxName = name
		element.fcpxRef = refID
		element.fcpxOffset = offset
		element.fcpxStart = start
		element.fcpxDuration = duration
		
		mcSources.forEach { (source) in
			element.addChild(source)
		}
		
		return element
	}
	
	
	
	/// Creates a new secondary storyline XMLElement object.
	///
	/// - Parameters:
	///   - lane: The lane for the secondary storyline as an Int value.
	///   - offset: The clip’s location in parent time as a CMTime value.
	///   - formatRef: The reference ID of the format that this resource uses.
	///   - clips: An array of XMLElement objects of the clips to be placed inside the secondary storyline.
	/// - Returns: An XMLElement object of the secondary storyline <spine> element.
	public func fcpxSecondaryStoryline(lane: Int, offset: CMTime, formatRef: String?, clips: [XMLElement]) -> XMLElement {
		
		let element = XMLElement(name: "spine")
		
		element.fcpxLane = lane
		element.fcpxOffset = offset
		element.fcpxFormatRef = formatRef
		
		clips.forEach { (clip) in
			element.addChild(clip)
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
	public func fcpxTitle(titleName: String, lane: Int?, offset: CMTime, ref: String, duration: CMTime, start: CMTime, role: String?, titleText: String, textStyleID: Int, newTextStyle: Bool, font: String = "Helvetica", fontSize: CGFloat = 62, fontFace: String = "Regular", fontColor: NSColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), strokeColor: NSColor? = nil, strokeWidth: Float = 2.0, shadowColor: NSColor? = nil, shadowDistance: Float = 5.0, shadowAngle: Float = 315.0, shadowBlurRadius: Float = 1.0, alignment: TextAlignment = TextAlignment.Center, xPosition: Float = 0, yPosition: Float = 0) -> XMLElement {
		
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
	

	/// Creates a new caption to be used in a timeline.
	///
	/// - Parameters:
	///   - captionName: The name of the caption clip on the timeline.
	///   - lane: The preferred timeline lane to place the clip into.
	///   - offset: The clip’s location in parent time as a CMTime value.
	///   - duration: The duration of the clip as a CMTime value.
	///   - start: The start time of the clip's local timeline as a CMTime value.
	///   - roleName: The role name assigned to the clip.
	///   - captionFormat: The format of the captions, either ITT or CEA-608, using the CaptionFormat enum.
	///   - language: The language of the caption text as a CaptionLanguage enum value.
	///   - captionText: The text displayed by this caption clip.
	///   - CEA_displayStyle: For CEA-608 captions, the display transition style of the text.
	///   - CEA_rollUpHeight: For CEA-608 captions using the roll-up display style, the number of rows to show concurrently. Valid values are 2 to 4.
	///   - CEA_xPosition: The starting X position of the text for CEA-608 captions. Valid values are 1 to 23.
	///   - CEA_yPosition: The starting Y position of the text for CEA-608 captions. Valid values are 1 to 15.
	///   - CEA_alignment: The alignment of the text for CEA-608 captions.
	///   - ITT_placement: The text placement for ITT captions.
	///   - textStyleID: The ID to assign to a newly generated text style definition or the ID to reference for an existing text style definition.
	///   - newTextStyle: True if this title clip should contain a newly generated text style definition.
	///   - bold: True if the text is styled bold.
	///   - italic: True if the text is styled italic.
	///   - underline: True if the text is styled underline.
	///   - fontColor: The color of the font as an NSColor value.
	///   - bgColor: The background color behind the text as an NSColor value. Includes alpha value for semi-transparent and transparent backgrounds for CEA-608 captions.
	/// - Returns: An XMLElement object of the caption, which will contain the text style definition, if newTextStyle is true.
	public func fcpxCaption(captionName: String, lane: Int?, offset: CMTime, duration: CMTime, start: CMTime, roleName: String, captionFormat: CaptionFormat, language: CaptionLanguage, captionText: String, CEA_displayStyle: CEA608CaptionDisplayStyle?, CEA_rollUpHeight: Int?, CEA_xPosition: Int?, CEA_yPosition: Int?, CEA_alignment: CEA608CaptionAlignment?, ITT_placement: ITTCaptionPlacement?, textStyleID: Int, newTextStyle: Bool, bold: Bool, italic: Bool, underline: Bool, fontColor: NSColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), bgColor: NSColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) -> XMLElement {
		
		let element = XMLElement(name: "caption")
		
		element.fcpxName = captionName
		element.fcpxLane = lane
		element.fcpxOffset = offset
		element.fcpxDuration = duration
		element.fcpxStart = start
		element.fcpxRole = "\(roleName)?captionFormat=\(captionFormat.rawValue).\(language.rawValue)"
		
		let text = XMLElement(name: "text")
		
		if captionFormat == .cea608 {
			text.fcpxCEACaptionDisplayStyle = CEA_displayStyle
			if CEA_displayStyle == CEA608CaptionDisplayStyle.rollUp {
				text.fcpxCEACaptionRollUpHeight = CEA_rollUpHeight
			}
			text.fcpxCEACaptionPositionX = CEA_xPosition
			text.fcpxCEACaptionPositionY = CEA_yPosition
			text.fcpxCEACaptionAlignment = CEA_alignment
		} else {
			text.fcpxITTCaptionPlacement = ITT_placement
		}
		
		let textTextStyle = XMLElement(name: "text-style", stringValue: captionText)
		
		
		// Add the text content and its style
		textTextStyle.fcpxRef = "ts\(textStyleID)"  // Reference the new text style definition reference number
		
		text.addChild(textTextStyle)
		element.addChild(text)
		
		// Text Style Definition
		if newTextStyle == true {  // If a new text style definition hasn't been created yet
			
			let textStyleDef = XMLElement(name: "text-style-def")
			
			textStyleDef.fcpxID = "ts\(textStyleID)"
			
			let textStyleDefTextStyle = XMLElement(name: "text-style")
			
			textStyleDefTextStyle.setElementAttribute("font", value: ".SF NS Text")
			textStyleDefTextStyle.setElementAttribute("fontSize", value: "13")
			
			textStyleDefTextStyle.setElementAttribute("fontColor", value: "\(fontColor.redComponent) \(fontColor.greenComponent) \(fontColor.blueComponent) \(fontColor.alphaComponent)")
			
			if bold == true {
				textStyleDefTextStyle.setElementAttribute("bold", value: "1")
			} else {
				textStyleDefTextStyle.removeAttribute(forName: "italic")
			}
			
			if italic == true {
				textStyleDefTextStyle.setElementAttribute("italic", value: "1")
			} else {
				textStyleDefTextStyle.removeAttribute(forName: "italic")
			}
			
			if underline == true {
				textStyleDefTextStyle.setElementAttribute("underline", value: "1")
			} else {
				textStyleDefTextStyle.removeAttribute(forName: "underline")
			}
			
			textStyleDefTextStyle.setElementAttribute("backgroundColor", value: "\(bgColor.redComponent) \(bgColor.greenComponent) \(bgColor.blueComponent) \(bgColor.alphaComponent)")
			
			textStyleDef.addChild(textStyleDefTextStyle)
			
			element.addChild(textStyleDef)
		}
		
		return element
	}
	
	
	
	// MARK: - Properties for Attribute Nodes
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
		} // TODO: When this is a compound resource or multicam resource, or project, this should be the duration of the sequence element.
		
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
	
	
	/// If this element's fcpxStart property is nil, fcpxStartValue returns a CMTime value of zero. Otherwise, it returns the same value as fcpxStart. This property is used when you want the value of the "start" attribute whether or not it exists. Final Cut Pro X omits the "start" attribute when the element starts at 0.
	public var fcpxStartValue: CMTime {
		get {
			if let start = self.fcpxStart {
				return start
			} else {
				return CMTime().zero()
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
	
	
	/// Returns and sets the "ref" attribute of an element. If the element fcpxType is FCPXMLElementType.clip, this will return or set its video or audio child element's "ref" attribute.
	public var fcpxRef: String? {
		get {
			
			if self.fcpxType == .clip {  // If the element type is "clip" then get the ref from a video or audio sub-element.
				
				let videoElements = self.elements(forName: "video")
				if videoElements.count > 0 {
					return videoElements[0].fcpxRef
				} else {  // Check for audio elements
					let audioElements = self.elements(forName: "audio")
					if audioElements.count > 0 {
						return audioElements[0].fcpxRef
					} else {
						return nil
					}
				}
				
			} else {
			
				if let attributeString = getElementAttribute("ref") {
					return attributeString
				} else {
					return nil
				}
			}
		}
		
		set(value) {
			if let value = value {
				
				if self.fcpxType == .clip {  // If the element type is "clip" then change the ref in a video or audio sub-element.
					
					let videoElements = self.elements(forName: "video")
					if videoElements.count > 0 {
						
						let attribute = XMLNode(kind: XMLNode.Kind.attribute)
						attribute.name = "ref"
						attribute.stringValue = value
						
						videoElements[0].addAttribute(attribute)
						
					} else {  // Check for audio elements
						let audioElements = self.elements(forName: "audio")
						if audioElements.count > 0 {
							
							let attribute = XMLNode(kind: XMLNode.Kind.attribute)
							attribute.name = "ref"
							attribute.stringValue = value
							
							audioElements[0].addAttribute(attribute)
							
						} else {
							setElementAttribute("ref", value: value)
						}
					}
					
				} else {
				
					setElementAttribute("ref", value: value)
				}
				
			} else {
				
				if self.fcpxType == .clip {  // If the element type is "clip" then remove the ref from a video or audio sub-element.
					
					let videoElements = self.elements(forName: "video")
					if videoElements.count > 0 {
						
						videoElements[0].removeAttribute(forName: "ref")
						
					} else {  // Check for audio elements
						let audioElements = self.elements(forName: "audio")
						if audioElements.count > 0 {
							
							audioElements[0].removeAttribute(forName: "ref")
							
						} else {
							self.removeAttribute(forName: "ref")
						}
					}
					
				} else {
					self.removeAttribute(forName: "ref")
				}
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
	
	
	/// This value indicates whether the clip is enabled or disabled. By default, the element attribute is not included in FCPXML exports when the clip is enabled.
	public var fcpxEnabled: Bool {
		get {
			if let attributeString = getElementAttribute("enabled") {
				if attributeString == "0" {
					return false
				} else {
					return true
				}
			} else {
				return true
			}
		}
		
		set(value) {
			if value == false {
				setElementAttribute("enabled", value: "0")
			} else {
				setElementAttribute("enabled", value: "1")
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
	
	public var fcpxAngleID: String? {
		get {
			if let attributeString = getElementAttribute("angleID") {
				return attributeString
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("angleID", value: value)
			} else {
				self.removeAttribute(forName: "angleID")
			}
		}
	}
	
	
	/// The "srcEnable" attribute for "mc-source" multicam clip angles
	public var fcpxSrcEnable: MulticamSourceEnable? {
		get {
			if let attributeString = getElementAttribute("srcEnable") {
				switch attributeString {
				case MulticamSourceEnable.audio.rawValue:
					return MulticamSourceEnable.audio
				case MulticamSourceEnable.video.rawValue:
					return MulticamSourceEnable.video
				case MulticamSourceEnable.all.rawValue:
					return MulticamSourceEnable.all
				case MulticamSourceEnable.none.rawValue:
					return MulticamSourceEnable.none
				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("srcEnable", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "srcEnable")
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
	
	
	// MARK: - Timing Properties
	
	/// The start of this element on its parent timeline. For example, if this is a video clip on the primary storyline, this value would be the in point of the clip on the project timeline. If this is a clip on a secondary storyline, this value would be the in point of the clip on the secondary storyline's timeline.
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
	
	
	/// The end of this element on its parent timeline. For example, if this is a video clip on the primary storyline, this value would be the out point of the clip on the project timeline. If this is a clip on a secondary storyline, this value would be the out point of the clip on the secondary storyline's timeline.
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
	
	/// The start of this element's local timeline. For example, if this is a video clip, this value would be the in point of the clip's source footage.
	public var fcpxLocalInPoint: CMTime {
		get {
			return self.fcpxStartValue
		}
		set(value) {
			self.fcpxStart = value
		}
	}
	
	/// The end of this element's local timeline. For example, if this is a video clip, this value would be the out point of the clip's source footage. If this element has no duration, this property will return nil.
	public var fcpxLocalOutPoint: CMTime? {
		get {
			guard let duration = self.fcpxDuration else {
				return nil
			}
			return CMTimeAdd(self.fcpxStartValue, duration)
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
	
	
	/// The start time of this element on the project timeline.
	public var fcpxTimelineInPoint: CMTime? {
		get {
			
			// If this element does not have an offset, it is not a clip element on the project timeline
			guard self.fcpxOffset != nil else {
				
				return nil
			}
			
			guard let parentElement = self.parentElement else {
				
				return nil
			}
			
			if parentElement.name == "spine" && parentElement.fcpxOffset == nil {  // This is a clip on the primary storyline.
				
				return self.fcpxOffset
				
			} else if parentElement.name == "spine" {  // This is a clip on a secondary storyline.
				
				let clipIn = self.fcpxOffset!
				
				guard let spineOffset = parentElement.fcpxOffset else {
					return nil
				}
				
				let secondaryStorylineIn = CMTimeAdd(clipIn, spineOffset)
				
				guard let primaryStorylineClip = parentElement.parentElement else {
					return nil
				}
				
				let inDifference = CMTimeSubtract(secondaryStorylineIn, primaryStorylineClip.fcpxLocalInPoint)
				
				guard let primaryStorylineClipIn = primaryStorylineClip.fcpxParentInPoint else {
					return nil
				}
				
				return CMTimeAdd(primaryStorylineClipIn, inDifference)
				
			} else {  // This is a connected clip.
				
				let clipIn = self.fcpxOffset!
				
				let startDifference = CMTimeSubtract(clipIn, parentElement.fcpxLocalInPoint)
				
				guard let clipParentStart = parentElement.fcpxParentInPoint else {
					return nil
				}
				
				return CMTimeAdd(clipParentStart, startDifference)
				
			}
		}
	}
	
	/// The end time of this element on the project timeline.
	public var fcpxTimelineOutPoint: CMTime? {
		get {
			
			// If this element does not have an offset, it is not a clip element on the project timeline
			guard self.fcpxOffset != nil else {
				return nil
			}
			
			guard let parentElement = self.parentElement else {
				return nil
			}
			
			if parentElement.name == "spine" && parentElement.fcpxOffset == nil {  // This is a clip on the primary storyline.
				
				return self.fcpxParentOutPoint
				
			} else if parentElement.name == "spine" {  // This is a clip on a secondary storyline.
				
				guard let clipOut = self.fcpxParentOutPoint else {
					return nil
				}
				
				guard let spineOffset = parentElement.fcpxOffset else {
					return nil
				}
				
				let secondaryStorylineOut = CMTimeAdd(clipOut, spineOffset)
				
				guard let primaryStorylineClip = parentElement.parentElement else {
					return nil
				}
				
				guard let primaryStorylineClipLocalOut = primaryStorylineClip.fcpxLocalOutPoint else {
					return nil
				}
				
				let outDifference = CMTimeSubtract(secondaryStorylineOut, primaryStorylineClipLocalOut)
				
				guard let primaryStorylineClipOut = primaryStorylineClip.fcpxParentOutPoint else {
					return nil
				}
				
				return CMTimeAdd(primaryStorylineClipOut, outDifference)
				
			} else {  // This is a connected clip.
				
				guard let clipOut = self.fcpxParentOutPoint else {
					return nil
				}
				
				let startDifference = CMTimeSubtract(clipOut, parentElement.fcpxLocalInPoint)
				
				guard let clipParentStart = fcpxParentInPoint else {
					return nil
				}
				
				return CMTimeAdd(clipParentStart, startDifference)
				
			}
		}
	}
	
	// MARK: - Caption Element Properties
	
	/// The display style for CEA-608 formatted captions.
	public var fcpxCEACaptionDisplayStyle: CEA608CaptionDisplayStyle? {
		get {
			guard self.fcpxType == .text else {
				return nil
			}
			if let attributeString = getElementAttribute("display-style") {
				switch attributeString {
				case CEA608CaptionDisplayStyle.popOn.rawValue:
					return CEA608CaptionDisplayStyle.popOn
				case CEA608CaptionDisplayStyle.paintOn.rawValue:
					return CEA608CaptionDisplayStyle.paintOn
				case CEA608CaptionDisplayStyle.rollUp.rawValue:
					return CEA608CaptionDisplayStyle.rollUp
				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("display-style", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "display-style")
			}
		}
	}
	
	/// The number of rows to show concurrently on the video when the CEA-608 display style is set to roll-up. Valid values are from 2 to 4.
	public var fcpxCEACaptionRollUpHeight: Int? {
		get {
			guard self.fcpxType == .text else {
				return nil
			}
			if let attributeString = getElementAttribute("roll-up-height") {
				return Int(attributeString)
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("roll-up-height", value: String(value))
			} else {
				self.removeAttribute(forName: "roll-up-height")
			}
		}
	}
	
	/// The X position for CEA-608 captions. Valid values are from 1 to 23. Setting this variable will retain the current Y value if it exists. If it does not, the Y value will default to 15.
	public var fcpxCEACaptionPositionX: Int? {
		get {
			guard self.fcpxType == .text else {
				return nil
			}
			if let attributeString = getElementAttribute("position") {
				let coordinates = attributeString.split(separator: " ")
				guard coordinates.count == 2 else {
					return nil
				}
				return Int(coordinates[0])
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				if let currentY = self.fcpxCEACaptionPositionY {
					setElementAttribute("position", value: "\(value) \(currentY)")
				} else {
					setElementAttribute("position", value: "\(value) 15")
				}
			} else {
				self.removeAttribute(forName: "position")
			}
		}
	}
	
	/// The Y position for CEA-608 captions. Valid values are from 1 to 15. Setting this variable will retain the current X value if it exists. If it does not, the X value will default to 1.
	public var fcpxCEACaptionPositionY: Int? {
		get {
			guard self.fcpxType == .text else {
				return nil
			}
			if let attributeString = getElementAttribute("position") {
				let coordinates = attributeString.split(separator: " ")
				guard coordinates.count == 2 else {
					return nil
				}
				return Int(coordinates[1])
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				if let currentX = self.fcpxCEACaptionPositionX {
					setElementAttribute("position", value: "\(currentX) \(value)")
				} else {
					setElementAttribute("position", value: "1 \(value)")
				}
			} else {
				self.removeAttribute(forName: "position")
			}
		}
	}
	
	/// The caption placement for ITT formatted captions.
	public var fcpxITTCaptionPlacement: ITTCaptionPlacement? {
		get {
			guard self.fcpxType == .text else {
				return nil
			}
			if let attributeString = getElementAttribute("placement") {
				switch attributeString {
				case ITTCaptionPlacement.top.rawValue:
					return ITTCaptionPlacement.top
				case ITTCaptionPlacement.bottom.rawValue:
					return ITTCaptionPlacement.bottom
				case ITTCaptionPlacement.left.rawValue:
					return ITTCaptionPlacement.left
				case ITTCaptionPlacement.right.rawValue:
					return ITTCaptionPlacement.right
				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("placement", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "placement")
			}
		}
	}
	
	/// The alignment for CEA-608 formatted captions.
	public var fcpxCEACaptionAlignment: CEA608CaptionAlignment? {
		get {
			guard self.fcpxType == .text else {
				return nil
			}
			if let attributeString = getElementAttribute("alignment") {
				switch attributeString {
				case CEA608CaptionAlignment.left.rawValue:
					return CEA608CaptionAlignment.left
				case CEA608CaptionAlignment.center.rawValue:
					return CEA608CaptionAlignment.center
				case CEA608CaptionAlignment.right.rawValue:
					return CEA608CaptionAlignment.right
				default:
					return nil
				}
			} else {
				return nil
			}
		}
		
		set(value) {
			if let value = value {
				setElementAttribute("alignment", value: value.rawValue)
			} else {
				self.removeAttribute(forName: "alignment")
			}
		}
	}
	
	// MARK: - Element Identification
	
	/// True if this XMLElement is an event.
	public var isFCPXEvent: Bool {
		get {
			if self.name == "event" {
				return true
			} else {
				return false
			}
		}
	}
	
	/// True if this XMLElement is an item in an event, not a resource.
	public var isFCPXEventItem: Bool {
		get {
			if self.fcpxType == .assetClip ||
				self.fcpxType == .clip ||
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
	
	/// True if this XMLElement is an element that can appear on a storyline.
	public var isFCPXStoryElement: Bool {
		get {
			if self.fcpxType == .assetClip ||
				self.fcpxType == .clip ||
				self.fcpxType == .video ||
				self.fcpxType == .audio ||
				self.fcpxType == .multicamClip ||
				self.fcpxType == .compoundClip ||
				self.fcpxType == .synchronizedClip ||
				self.fcpxType == .gap ||
				self.fcpxType == .transition ||
				self.fcpxType == .title ||
				self.fcpxType == .audition
			{
				return true
			} else {
				return false
			}
		}
	}
	
	/// If this XMLElement is a story element or clip in a sequence, this property returns its location in the sequence.
	public var fcpxStoryElementLocation: StoryElementLocation? {
		get {
			
			guard self.isFCPXStoryElement == true else {
				return nil
			}
			
			guard let parent = self.parentElement else {
				return nil
			}
			
			if parent.fcpxType == .spine {
				
				guard let superParent = parent.parentElement else {
					return nil
				}
				
				if superParent.fcpxType == .sequence {
					// The clip is on a primary storyline
					return StoryElementLocation.primaryStoryline
				} else {
					// The clip is on a secondary storyline
					return StoryElementLocation.secondaryStoryline
				}
			} else if parent.fcpxType == .event {
				// The element is not a clip in a sequence.
				return nil
				
			} else {
				// The clip is attached to another clip
				return StoryElementLocation.attachedClip
			}
		}
	}
	
	
	// MARK: - Retrieving Related Elements
	
	/// If this is a project element, this returns its sequence element. Returns nil if there is no sequence element or if this is not a project element.
	public var fcpxProjectSequence: XMLElement? {
		get {
			if self.fcpxType == .project {
				let sequenceElements = self.elements(forName: "sequence")
				
				guard sequenceElements.count > 0 else {
					return nil
				}
				
				return sequenceElements[0]
			} else {
				return nil
			}
		}
	}
	
	/// If this is a project element, this returns the spine of the primary storyline. Returns nil if there is no spine or if this is not a project element.
	public var fcpxProjectSpine: XMLElement? {
		get {
			if self.fcpxType == .project {
				guard let sequence = self.fcpxProjectSequence else {
					return nil
				}
				let spineElements = sequence.elements(forName: "spine")
				
				guard spineElements.count > 0 else {
					return nil
				}
				
				return spineElements[0]
			} else {
				return nil
			}
		}
	}
	
	/// If this is a project element, this returns the clips contained within the project. Returns an empty array if there are no clips or if this is not a valid project element.
	public var fcpxProjectClips: [XMLElement] {
		get {
			if self.fcpxType == .project {
				
				guard let projectSequence = self.fcpxProjectSequence else {
					return []
				}
				
				return projectSequence.fcpxSequenceClips
				
			} else {
				return []
			}
		}
	}
	
	/// If this is a compound clip or compound resource element, this returns its resource's sequence element. Returns nil if there is no sequence element or if this is not a compound clip or resource element.
	public var fcpxCompoundResourceSequence: XMLElement? {
		let resource: XMLElement
		
		switch self.fcpxType {
		case .compoundClip:  // If this is a compound clip in a project timeline
			guard self.fcpxResource != nil else {
				return nil
			}
			resource = self.fcpxResource!
			
		case .compoundResource:  // If this is the resource of a compound clip
			resource = self
			
		default:
			return nil
		}
		
		let sequenceElements = resource.elements(forName: "sequence")
		
		guard sequenceElements.count > 0 else {
			return nil
		}
		
		return sequenceElements[0]
	}
	
	/// If this is a compound clip or compound resource element, this returns the spine of the primary storyline. Returns nil if there is no spine or if this is not a compound clip or resource element.
	public var fcpxCompoundResourceSpine: XMLElement? {
		let resource: XMLElement
		
		switch self.fcpxType {
		case .compoundClip:  // If this is a compound clip in a project timeline
			guard self.fcpxResource != nil else {
				return nil
			}
			resource = self.fcpxResource!
			
		case .compoundResource:  // If this is the resource of a compound clip
			resource = self
			
		default:
			return nil
		}
		
		let sequenceElements = resource.elements(forName: "sequence")
		
		guard sequenceElements.count > 0 else {
			return nil
		}
		
		let spineElements = sequenceElements[0].elements(forName: "spine")
		
		guard spineElements.count > 0 else {
			return nil
		}
		
		return spineElements[0]
	}
	
	
	/// If this is a sequence element, this returns the clips contained within the primary storyline. Returns an empty array if there are no clips or if this is not a valid sequence element.
	public var fcpxSequenceClips: [XMLElement] {
		get {
			
			guard self.name == "sequence" else {
				return []
			}
			
			let spineElements = self.elements(forName: "spine")
			
			guard spineElements.count > 0 else {
				return []
			}
			
			guard let children = spineElements[0].children else {
				return []
			}
			
			var clips: [XMLElement] = []
			for child in children {
				if child.kind == XMLNode.Kind.element {
					let childElement = child as! XMLElement
					
					if childElement.isFCPXStoryElement == true {
						clips.append(childElement)
					}
				}
			}
			return clips
			
		}
	}
	
	/// If this is an event item, the event that contains it. Returns nil if it is not an event item.
	public var fcpxParentEvent: XMLElement? {
		get {
			guard self.isFCPXEventItem == true else { // If this is a clip inside an event
				return nil
			}
			
			guard self.parent != nil else {
				return nil
			}
			
			var parentElement = self.parent as! XMLElement
			
			while parentElement.name != "event" {
				// If the parent is the top of the document, return nil
				guard parentElement.parent != nil else {
					return nil
				}
				
				parentElement = parentElement.parent as! XMLElement
				
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
	
	
	
	/// An array of this element's metadata elements. Returns nil if this element is not a resource or event item.
	public var fcpxMetadata: [XMLElement]? {
		
		guard self.isFCPXResource == true || self.isFCPXEventItem == true else {
			return nil
		}
		
		if self.isFCPXResource == true {
			
			switch self.fcpxType {
			case .multicamResource, .compoundResource:
				
				var subElement = self.elements(forName: "sequence")
				if subElement.count == 0 {
					subElement = self.elements(forName: "multicam")
				}
				
				guard subElement.count > 0 else {
					return nil
				}
				
				let metadataElement = subElement[0].elements(forName: "metadata")
				
				guard metadataElement.count > 0 else {
					return []
				}
				
				return metadataElement[0].elements(forName: "md")
				
			default:
				
				let metadataElement = self.elements(forName: "metadata")
				
				guard metadataElement.count > 0 else {
					return []
				}
				
				return metadataElement[0].elements(forName: "md")
				
			}
			
		} else if self.isFCPXEventItem == true {
			
			let metadataElement = self.elements(forName: "metadata")
			
			guard metadataElement.count > 0 else {
				return []
			}
			
			return metadataElement[0].elements(forName: "md")
			
		} else {  // Not a resource or event item element
			
			return nil
		}
		
	}
	

	
	/// An array of mc-angle elements within a multicam media resource. Returns nil if this element is not a multicam media resource.
	public var fcpxMulticamAngles: [XMLElement]? {
		get {
			guard self.fcpxType == FCPXMLElementType.multicamResource else {
				return nil
			}
			
			let multicamElement = self.elements(forName: "multicam")
			
			guard multicamElement.count > 0 else {
				return nil
			}
			
			let angles = multicamElement[0].elements(forName: "mc-angle")
			
			return angles
			
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
		
		let clips: [XMLElement]
		do {
			clips = try event.eventClips(forResourceID: resourceID)
		} catch {
			return nil
		}
		
		return clips

	}
	
	// MARK: - Methods for FCPX Library Events
	
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
			
			let clips = FCPXMLUtility().filter(fcpxElements: clipElements, ofTypes: [.assetClip, .clip, .compoundClip, .multicamClip, .synchronizedClip])
			
			return clips
		}
	}
	

	/// Returns all clips in an event that match the given resource ID. If this method is called on an XMLElement that is not an event, nil will be returned. If there are no clips that match the resourceID, an empty array will be returned.
	///
	/// - Parameter resourceID: A string of the resourceID value.
	/// - Returns: An array of XMLElement objects that refer to the matching clips. Note that multiple clips in an event can refer to a single resource ID.
	/// - Throws: An error if this element is not an event.
	public func eventClips(forResourceID resourceID: String) throws -> [XMLElement] {
		
		guard self.fcpxType == .event else {
			throw FCPXMLElementError.notAnEvent(element: self)
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
			throw FCPXMLElementError.notAnEvent(element: self)
		}
		
		var matchingItems: [XMLElement] = []
		
		guard let items = self.eventItems else {
			return matchingItems
		}
		
		for item in items {
			
			switch item.fcpxType {
				
			case .assetClip:  // Check for matching regular clips
//				print("Checking an asset clip in the event...")
				
				if item.fcpxRef == resource.fcpxID { // Found regular clip
					matchingItems.append(item)
					
					print("Matching asset clip found: \(item.fcpxName ?? "unnamed element")")
				}
				
			case .clip:  // Check for matching regular clips
//				print("Checking a clip in the event...")
				
				let videoElements = item.elements(forName: "video")
				if videoElements.count > 0 {
					
					let videoElement = videoElements[0]
					if videoElement.fcpxRef == resource.fcpxID {
						matchingItems.append(item)
						
						print("Matching video clip found: \(item.fcpxName ?? "unnamed element")")
					}
					
				} else {
					
					let audioElements = item.elements(forName: "audio")
					if audioElements.count > 0 {
						
						let audioElement = audioElements[0]
						if audioElement.fcpxRef == resource.fcpxID {
							matchingItems.append(item)
							
							print("Matching audio clip found: \(item.fcpxName ?? "unnamed element")")
						}
						
					} else {
						continue
					}
				}
					
					
			case .synchronizedClip:  // Check for matching synchronized clips
//				print("Checking a synchronized clip in the event...")
				
				guard let itemChildren = item.children else {
					continue
				}
				
				for itemChild in itemChildren {
					let itemChildElement = itemChild as! XMLElement
					
					// Find regular synchronized clips
					if itemChildElement.fcpxType == .assetClip || itemChildElement.fcpxType == .clip { // Normal synchronized clip
						
						if itemChildElement.fcpxRef == resource.fcpxID {  // Match found on a primary storyline clip
							print("Matching synchronized clip found: \(item.fcpxName ?? "unnamed element")")
							
							matchingItems.append(item)
							
						} else {  // Check clips attached to this primary storyline clip
						
							guard let syncedClipChildren = itemChildElement.children else {
								continue
							}
							
							for syncedClipChild in syncedClipChildren {
								let syncedClipChildElement = syncedClipChild as! XMLElement
								
								if syncedClipChildElement.fcpxRef == resource.fcpxID {
									
									print("Matching synchronized clip found: \(item.fcpxName ?? "unnamed element")")
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
									
									print("Matching synchronized clip found: \(item.fcpxName ?? "unnamed element")")
									matchingItems.append(item)
								}
							}
							
						}
					}
				}
				
			case .multicamClip:  // Check for matching multicam clips
//				print("Checking a multicam in the event...")
				
				if item.fcpxRef == resource.fcpxID { // The asset ID matches this multicam so add it immediately to the matchingItems array.
					
					print("Matching multicam found: \(item.fcpxName ?? "unnamed element")")
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
								
								guard multicamAngleChildElement.fcpxType == .assetClip || multicamAngleChildElement.fcpxType == .clip else {
									continue
								}
								
								if multicamAngleChildElement.fcpxRef == resource.fcpxID {
									
									print("Matching multicam found: \(item.fcpxName ?? "unnamed element")")
									matchingItems.append(item)
									break
								}
								
							}
							
							
						}
						
					}
				}
				
				
			case .compoundClip:  // Check for matching compound clips
//				print("Checking a compound clip in the event...")
				
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
								print("Matching compound clip found: \(item.fcpxName ?? "unnamed element")")
								matchingItems.append(item)
								
							} else {  // Check clips attached to this primary storyline clip
							
								guard let childClipElementChildren = childClipElement.children else {
									break
								}
								
								for attachedClip in childClipElementChildren {
									let attachedClipElement = attachedClip as! XMLElement
									
									if attachedClipElement.fcpxRef == resource.fcpxID {
										print("Matching compound clip found: \(item.fcpxName ?? "unnamed element")")
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
			throw FCPXMLElementError.notAnEvent(element: self)
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
			throw FCPXMLElementError.notAnEvent(element: self)
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
			throw FCPXMLElementError.notAnEvent(element: self)
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
			throw FCPXMLElementError.notAnEvent(element: self)
		}
		
		for index in itemIndexes.sorted().reversed() {
			self.removeChild(at: index)
		}
	}
	
	
	/// Removes a group of items from this event. If this XMLElement is not an event, an error is thrown.
	///
	/// - Parameter items: An array of event item XMLElement objects.
	/// - Throws: FCPXMLElementError.notAnEvent if the element is not an event.
	public func removeFromEvent(items: [XMLElement]) throws {
		guard self.fcpxType == .event else {
			throw FCPXMLElementError.notAnEvent(element: self)
		}
		
		for item in items {
			self.removeChild(at: item.index)
		}
	}

	// MARK: - Methods for Event Clips
	
	/// Adds an annotation XMLElement to this item, maintaining the proper order of the DTD. Conforms to FCPXML DTD v1.6.
	///
	/// - Parameter annotationElements: The annotations to add as an array of XMLElement objects.
	/// - Throws: Throws an error if an annotation cannot be added to this type of FCPXML element or if the element to add is not an annotation.
	public func addToClip(annotationElements elements: [XMLElement]) throws {
		
		guard self.fcpxType == .project || self.fcpxType == .synchronizedClip || self.fcpxType == .compoundClip || self.fcpxType == .multicamClip || self.fcpxType == .assetClip || self.fcpxType == .clip else {
			throw FCPXMLElementError.notAnAnnotatableItem(element: self)
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
					throw FCPXMLElementError.notAnAnnotation(element: element)
				}
				
				element.detach()
				
				self.insertChild(element, at: insertIndex)
				insertIndex += 1
			}
			
		} else { // No children so just add to the clips.
			for element in elements {
				
				guard element.fcpxType == .note || element.fcpxType == .marker || element.fcpxType == .chapterMarker || element.fcpxType == .rating || element.fcpxType == .keyword || element.fcpxType == .analysisMarker else {
					throw FCPXMLElementError.notAnAnnotation(element: element)
				}
				
				element.detach()
				
				self.addChild(element)
			}
		}
	}
	
	
	// MARK: - Methods for Projects
	
	/// Returns an array of all roles used inside the project.
	///
	/// - Returns: An array of roles as String values.
	public func projectRoles() -> [String] {
		guard self.fcpxType == .project else {
			return []
		}
		
		var projectRoles = self.parseRoles(fromElement: self)
		
		let compoundClips = self.clips(forElementType: .compoundClip)
		
		var compoundClipRoles: [String] = []
		for clip in compoundClips {
			
			guard let resourceElement = clip.fcpxResource else {
				continue
			}
			
			let resourceElementRoles = self.parseRoles(fromElement: resourceElement)
			compoundClipRoles.append(contentsOf: resourceElementRoles)
		}
		
		for role in compoundClipRoles {
			if projectRoles.contains(role) == false {
				projectRoles.append(role)
			}
		}
		
		return projectRoles
		
	}
	
	
	// MARK: - Retrieving Format Information
	
	/// Returns an element's associated format name, ID, frame duration, and frame size.
	///
	/// - Returns: A tuple with a formatID string, formatName string, frameDuration CMTime, and frameSize CGSize.
	public func formatValues() -> (formatID: String, formatName: String, frameDuration: CMTime?, frameSize: CGSize?)? {
		
		// Get the format's ID
		guard let formatID = self.formatID(forElement: self) else {
			print("No format ID in the element.")
			return nil
		}
		
		// Get the format element
		guard let formatElement = self.rootDocument?.resource(matchingID: formatID) else {
			print("No format matching ID \(formatID).")
			return nil
		}
		
		// Get the format values from the element
		guard let values = self.formatValues(fromElement: formatElement) else {
			print("Retrieving format values failed.")
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
		case .assetResource, .assetClip, .clip, .synchronizedClip, .sequence:  // These elements will have the format reference ID in the top level element.
			
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
	

	
	
	/// Takes a format resource XMLElement and returns its ID, name, frame duration, and frame size. When the format is FFVideoFormatRateUndefined, the frameDuration will be nil.
	///
	/// - Parameter element: The XMLElement of the format resource
	/// - Returns: A tuple with formatID string, formatName string, frameDuration CMTime, and frameSize CGSize. Or returns null of the element is not a format resource.
	private func formatValues(fromElement element: XMLElement) -> (formatID: String, formatName: String, frameDuration: CMTime?, frameSize: CGSize?)? {
		
		guard let elementName = element.name,
			elementName == "format" else {
				return nil
		}
		
		var formatID = ""
		var formatName = ""
		var frameDuration: CMTime? = nil
		var frameSize: CGSize? = nil
		
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
	
	
	// MARK: - Comparing Timing Between Clips
	
	/// Tests if this clip's in and out points include the given time value.
	///
	/// - Parameter time: A CMTime value
	/// - Returns: True if the time value is between the in and out points of the clip
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
	
	/// Tests if this clip's timing falls within the given in and out points.
	///
	/// - Parameters:
	///   - inPoint: The in point to test against.
	///   - outPoint: The out point to test against.
	/// - Returns: True if the clip's timing falls within the inPoint and outPoint values.
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
	
	
	
	
	
	/// Returns whether the clip overlaps with a given time range specified by an in and out point.
	///
	/// - Parameters:
	///   - inPoint: The in point as a CMTime value.
	///   - outPoint: The out point as a CMTime value.
	/// - Returns: A tuple containing three boolean values. "Overlaps" indicates whether the clip overlaps at all with the in and out point range. "withClipInPoint" indicates whether the element's in point overlaps with the range. "withClipOutPoint" indicates whether the element's out point overlaps with the range.
	///
	/// - Example:\
	/// The following is a reference for how a clip could overlap. Below each case are resulting values for the "overlaps", "withClipInPoint", and "withClipOutPoint" tuple values.\
	/// `    [  comparisonClip ]         [ comparisonClip ]          [  comparisonClip  ]`\
	/// `[ clip1 ]         [ clip2 ]    [       clip       ]             [   clip   ]`\
	/// `(t,f,t)            (t,t,f)     (true, false, false)          (true, true, true)`\
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
		
		// FIXME: Something isn't working here and isn't identifying the clips. Maybe it's the timing values?
		for element in children {
			
			let overlaps = element.clipRangeOverlapsWith(inPoint, outPoint: outPoint)
			
			if overlaps.overlaps == true {
				print("\(element.fcpxName ?? "unnamed element") \(overlaps.withClipInPoint),\(overlaps.withClipOutPoint)")
				
				elementsInRange.append((XMLElement: element, overlapsInPoint: overlaps.withClipInPoint, overlapsOutPoint: overlaps.withClipOutPoint))
				
			}
			
		}
		
		return elementsInRange
	}
	
	
	
	// MARK: - Miscellaneous
	
	/// The FCPXML document as a properly formatted string.
	public var fcpxmlString: String {
		let xmlDocument = XMLDocument(rootElement: self.copy() as? XMLElement)
//		let formattedData = xmlDocument.xmlData(withOptions: 131076)
		let formattedData = xmlDocument.xmlData(options: [.nodePreserveWhitespace, .nodePrettyPrint, .nodeCompactEmptyElement])
		let formattedString = NSString(data: formattedData, encoding: String.Encoding.utf8.rawValue)
		
		guard formattedString != nil else {
			return ""
		}
		
		return formattedString! as String
	}
	
	
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
			
			let sourceParser = AttributeParserDelegate(element: resource, attribute: "src", inElementsWithName: nil)
			
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
		let refParser = AttributeParserDelegate(element: self, attribute: "ref", inElementsWithName: nil)
		let references = refParser.values
		
		if references.count > 0 {
			return references
		} else {
			return nil
		}
	}
	
	
	/**
	This function goes through the element and all of its sub-elements, finding elements that match the given name. For example, this function can search a sequence and any embedded secondary storylines for matching elements.
	
	- parameter forName: A String of the element name to match with.
	- parameter usingAbsoluteMatch: A boolean value of whether names must match absolutely or whether element names containing the string will yield a match.
	
	- returns: An array of matching elements as XMLElement objects.
	*/
	public func subelements(forName name: String, usingAbsoluteMatch: Bool) -> [XMLElement] {
		
		return self.subelements(forName: name, inElement: self, usingAbsoluteMatch: usingAbsoluteMatch)
	}
	
	
	/**
	A recursive function that goes through an element and all its sub-elements, finding clips that match the given name. This function is used by the clips(forName name:usingAbsoluteMatch:) function and should not be called directly.
	
	- parameter forName: A String of the name to match clips with.
	- parameter inElement: The XMLElement to recursively search. This is usually self.
	- parameter usingAbsoluteMatch: A boolean value of whether names must match absolutely or whether clip names containing the string will yield a match.
	
	- returns: An array of matching clips as XMLElement objects.
	*/
	private func subelements(forName name: String, inElement element: XMLElement, usingAbsoluteMatch: Bool) -> [XMLElement] {
		
		var matchingElements: [XMLElement] = []
		
		if let children = element.children {
			
			for child in children {
				
				guard child.kind == XMLNode.Kind.element else {
					continue
				}
					
				let childElement = child as! XMLElement
				guard let childElementName = childElement.name else {
					continue
				}
				
				if usingAbsoluteMatch == true {
					
					if childElementName.uppercased() == name.uppercased() {
						
						matchingElements.append(childElement)
						
					}
					
				} else { // Lookes for a match within the string
					
					if childElementName.uppercased().contains(name.uppercased()) == true {
						
						matchingElements.append(childElement)
						
					}
				}
				
				
				// Recurse through children
				if childElement.children != nil {
					
					let items = subelements(forName: name, inElement: childElement, usingAbsoluteMatch: usingAbsoluteMatch)
					
					matchingElements.append(contentsOf: items)
				}
				
			}
			
		}
		
		return matchingElements
		
	}
	
	
	/**
	This function returns all clips within an element and its sub-elements.
	- Note: The clips in the resulting array are not ordered by where they appear in the XML document.
	
	- returns: An array of clips as XMLElement objects.
	*/
	public func clips() -> [XMLElement] {
		
		let clipTypes = [FCPXMLElementType.clip, FCPXMLElementType.audio, FCPXMLElementType.video, FCPXMLElementType.gap, FCPXMLElementType.transition, FCPXMLElementType.title, FCPXMLElementType.audition, FCPXMLElementType.multicamClip, FCPXMLElementType.compoundClip, FCPXMLElementType.synchronizedClip, FCPXMLElementType.assetClip]
		
		var matchingClips: [XMLElement] = []
		
		for clipType in clipTypes {
			matchingClips.append(contentsOf: self.clips(forElementType: clipType))
		}
		
		return matchingClips
	}
	
	
	/// This function goes through the element and all its sub-elements, returning all clips that match the given FCPX clip name.
	///
	/// - Parameters:
	///   - fcpxName: A String of the clip name in FCPX to match with.
	///   - usingAbsoluteMatch: A boolean value of whether names must match absolutely or whether clip names containing the string will yield a match.
	/// - Returns: An array of matching clips as XMLElement objects.
	public func clips(forFCPXName fcpxName: String, usingAbsoluteMatch: Bool) -> [XMLElement] {
		
		let allClips = self.clips()
		
		var matchingClips: [XMLElement] = []
		
		for clip in allClips {
			
			guard let clipName = clip.fcpxName else {
				continue
			}
			
			if usingAbsoluteMatch == true {
				
				if clipName.uppercased() == fcpxName.uppercased() {
					matchingClips.append(clip)
				}
				
			} else {
				
				if clipName.uppercased().contains(fcpxName.uppercased()) == true {
					matchingClips.append(clip)
				}
			}
		}
		
		return matchingClips
		
	}
	
	/**
	This function goes through the element and all its sub-elements, finding clips that match the given type.
	
	- parameter elementType: A type of FCPXML element as FCPXMLElementType enumeration.
	
	- returns: An array of matching clips as XMLElement objects.
	*/
	public func clips(forElementType elementType: FCPXMLElementType) -> [XMLElement] {
		return self.clips(forElementType: elementType, inElement: self)
	}
	
	
	/**
	A recursive function that goes through an element and all its sub-elements, finding clips that match the given type. This function is used by the clips(forElementType:) function and should not be called publicly.

	
	- parameter elementType: A type of FCPXML element as FCPXMLElementType enumeration.
	- parameter inElement: The XMLElement to recursively search. This is usually self.
	
	- returns: An array of matching clips as XMLElement objects.
	*/
	private func clips(forElementType elementType: FCPXMLElementType, inElement element: XMLElement) -> [XMLElement] {
		
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
	
	
	
	
	
	// MARK: - XMLElement Helper Properties and Methods
	public func getElementAttribute(_ name: String) -> String? {
		
		if let elementAttribute = self.attribute(forName: name) {
			
			if let attributeString = elementAttribute.stringValue {
				
				return attributeString
			}
		}
		
		return nil
	}
	
	
	public func setElementAttribute(_ name: String, value: String?) {
		
		if value != nil {
			
			let attribute = XMLNode(kind: XMLNode.Kind.attribute)
			
			attribute.name = name
			attribute.stringValue = value
			
			self.addAttribute(attribute)
			
		} else {
			
			self.removeAttribute(forName: name)
			
		}
		
	}

	
	/// Returns the next element in document order.
	///
	/// - Returns: An XMLElement object or nil if there is no other element after the current one.
	public var nextElement: XMLElement? {
		get {
			guard let nextElement = self.nextElement(afterNode: self) else {
				return nil
			}
			
			return nextElement
		}
	}
	
	
	/// Returns the next element in document order after the specified node. Used by the nextElement property.
	///
	/// - Parameter node: The XMLNode to check after.
	/// - Returns: The next XMLElement object, or nil if there is none.
	private func nextElement(afterNode node: XMLNode) -> XMLElement? {
		
		guard let nextNode = node.next else {
			return nil
		}
		
		guard nextNode.kind == .element else {
			if let nextElementUnwrapped = self.nextElement(afterNode: nextNode) {
				return nextElementUnwrapped
			} else {
				return nil
			}
		}
		
		return (nextNode as! XMLElement)
	}
	
	/// Returns all sub-elements of this XMLElement.
	///
	/// - Returns: An array of XMLElement objects.
	public func subElements() -> [XMLElement] {
		guard let children = self.children else {
			return []
		}
		
		var childElements: [XMLElement] = []
		for child in children {
			if child.kind == .element {
				childElements.append(child as! XMLElement)
			}
		}
		
		return childElements
	}
    
    /// Returns the first sub-element with the given element name.
    ///
    /// - Parameter named: A string of the element name to match.
    /// - Returns: An XMLElement object or nil if there was no match.
    public func subElement(named name: String) -> XMLElement? {
        
        let subElements = self.elements(forName: name)
        
        guard subElements.count > 0 else {
            return nil
        }

        return subElements[0]
    }
	
	
	/// Returns the parent XMLElement.
	public var parentElement: XMLElement? {
		get {
			guard let parent = self.parent else {
				return nil
			}
			
			return parent as? XMLElement
		}
	}
	
	
	/// Adds an element as a child to this element, placing it in proper order according to the DTD.
	///
	/// - Parameters:
	///   - element: The child element to insert.
	///   - overrideDTDVersion: A string of the DTD filename to override with. The DTD must be stored in the framework. If nil, the function uses the latest DTD version.
	public func addChildConformingToDTD(element: XMLElement, overrideDTDVersion: String?) {
		// TODO: Add this function
	}
	
	
	/// Converts a whitespace-only text value inside an XMLElement into an XMLNode object and inserts it as a child back into the XMLElement.
	///
	/// When text values consist of only whitespace characters, such as in title clips with adjusted kerning, Final Cut Pro X exports FCPXML files with the whitespace as is, not encoded into a valid XML whitespace character. This results in the XMLNode class ignoring the whitespace character and not initializing that into an XMLNode object.
	///
	/// This method extracts the text value inside an _XML element string_, converts that into a text XMLNode object, and inserts it back into the XMLElement object.
	///
	/// For example, an XMLElement consisting of:
	/// ````
	/// <text-style ref="ts30"> </text-style>
	/// ````
	/// will have its single space character converted into a text XMLNode after being processed through this method.
	///
	/// - Note: If the XMLElement has a child node, the XMLElement will not be modified.
	public func convertWhitespaceText() {
		
		guard self.childCount == 0 else {
			return
		}
		
		guard let textNode = self.textNode(fromXMLString: self.xmlString) else {
			return
		}
		
		// Insert the node back into the element.
		self.addChild(textNode)
		
	}
	
	
	/// Extracts the text node inside an XMLElement from a string representation of the XMLElement.
	///
	/// When text values consist of only whitespace characters, such as in title clips with adjusted kerning, Final Cut Pro X exports FCPXML files with the whitespace as is, not encoded into a valid XML whitespace character. This results in the XMLNode class ignoring the whitespace character and not initializing that into an XMLNode object.
	///
	/// This function will extract the text value inside an _XML element string_ and convert that into a text XMLNode object so that it can be inserted into the XMLElement object.
	///
	/// For example, an XMLElement consisting of:
	/// ````
	/// <text-style ref="ts30"> </text-style>
	/// ````
	/// will return a text node containing a single space character, which would normally be ignored when that XML string is read from a file.
	///
	/// - Parameter xmlString: A string representation of a single XML element.
	/// - Returns: An XMLNode object of the text node inside the XMLElement, or nil if one could not be extracted.
	private func textNode(fromXMLString xmlString: String) -> XMLNode? {
		// Find the text within the single element and convert it to a text node object.
		
		guard let rangeOfEndTag = xmlString.range(of: "</") else {
			return nil
		}
		let beginning = xmlString.prefix(upTo: rangeOfEndTag.lowerBound)
		
		guard let rangeOfBeginningTag = beginning.range(of: ">") else {
			return nil
		}
		let text = beginning.suffix(from: rangeOfBeginningTag.upperBound)
		
		guard text != "" else {
			return nil
		}
		
		let node = XMLNode.text(withStringValue: String(text)) as? XMLNode
		
		return node
	}
	
	
	// MARK: - Parsing Methods
	
	/// Parses roles from the given XMLElement. This would typically be used on a project XMLElement.
	func parseRoles(fromElement element: XMLElement) -> [String]{
		print("Parsing Roles...")
		
		guard let data = element.xmlString.data(using: .utf8) else {
			print("Error converting XML to Data")
			return []
		}
		let xmlParser = XMLParser(data: data)
		let parserDelegate = FCPXMLParserDelegate()
		xmlParser.delegate = parserDelegate
		
		// Parse the attributes using XMLParserDelegate
		xmlParser.parse()
		
		return parserDelegate.roles
		
	}
	
	
	// MARK: - Constants
	enum FCPXMLElementError: Error, CustomStringConvertible {
		case notAnEvent(element: XMLElement)
		case notAnAnnotatableItem(element: XMLElement)
		case notAnAnnotation(element: XMLElement)
		
		var description: String {
			switch self {
			case .notAnEvent(let element):
				return "The \"\(element.name ?? "unnamed")\" element is not an event."
			case .notAnAnnotatableItem(let element):
				return "The \"\(element.name ?? "unnamed")\" element cannot be annotated."
			case .notAnAnnotation(let element):
				return "The \"\(element.name ?? "unnamed")\" element is not an annotation."
			default:
				return "An error has occurred with an FCPXML element."
			}
		}
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
	
	public enum MulticamSourceEnable: String {
		case audio = "audio"
		case video = "video"
		case all = "all"
		case none = "none"
	}
	
	/// The caption format included in caption role attributes.
	public enum CaptionFormat: String {
		case itt = "ITT"
		case cea608 = "CEA608"
	}
	
	/// RFC 5646 language tags for use in caption role attributes. The languages included in this enum are those supported by FCPX.
	public enum CaptionLanguage: String {
		case Afrikaans = "af"
		case Arabic = "ar"
		case Bangla = "bn"
		case Bulgarian = "bg"
		case Catalan = "ca"
		case Chinese_Cantonese = "yue-Hant"
		case Chinese_Simplified = "cmn-Hans"
		case Chinese_Traditional = "cmn-Hant"
		case Croatian = "hr"
		case Czech = "cs"
		case Danish = "da"
		case Dutch = "nl"
		case English = "en"
		case English_Australia = "en-AU"
		case English_Canada = "en-CA"
		case English_UnitedKingdom = "en-GB"
		case English_UnitedStates = "en-US"
		case Estonian = "et"
		case Finnish = "fi"
		case French_Belgium = "fr-BE"
		case French_Canada = "fr-CA"
		case French_France = "fr-FR"
		case French_Switzerland = "fr-CH"
		case German = "de"
		case German_Austria = "de-AT"
		case German_Germany = "de-DE"
		case German_Switzerland = "de-CH"
		case Greek = "el"
		case Greek_Cyprus = "el-CY"
		case Hebrew = "he"
		case Hindi = "hi"
		case Hungarian = "hu"
		case Icelandic = "is"
		case Indonesian = "id"
		case Italian = "it"
		case Japanese = "ja"
		case Kannada = "kn"
		case Kazakh = "kk"
		case Korean = "ko"
		case Lao = "lo"
		case Latvian = "lv"
		case Lithuanian = "lt"
		case Luxembourgish = "lb"
		case Malay = "ms"
		case Malayalam = "ml"
		case Maltese = "mt"
		case Marathi = "mr"
		case Norwegian = "no"
		case Polish = "pl"
		case Portuguese_Brazil = "pt-BR"
		case Portuguese_Portugal = "pt-PT"
		case Punjabi = "pa"
		case Romanian = "ro"
		case Russian = "ru"
		case Slovak = "sk"
		case Slovenian = "sl"
		case Spanish_LatinAmerica = "es-419"
		case Spanish_Mexico = "es-MX"
		case Spanish_Spain = "es-ES"
		case Swedish = "sv"
		case Tagalog = "tl"
		case Tamil = "ta"
		case Telugu = "te"
		case Thai = "th"
		case Turkish = "tr"
		case Ukrainian = "uk"
		case Urdu = "ur"
		case Vietnamese = "vi"
		case Zulu = "zu"
	}
	
	/// Caption display style for CEA-608 captions
	public enum CEA608CaptionDisplayStyle: String {
		case popOn = "pop-on"
		case paintOn = "paint-on"
		case rollUp = "roll-up"
	}
	
	/// Caption placement for ITT captions.
	public enum ITTCaptionPlacement: String {
		case top = "top"
		case bottom = "bottom"
		case left = "left"
		case right = "right"
	}
	
	/// Caption alignment for CEA-608 captions.
	public enum CEA608CaptionAlignment: String {
		case left = "left"
		case center = "center"
		case right = "right"
	}
	
	/// Color values for CEA-608 captions. The raw value is the color expressed as "red green blue alpha" which is the way it is represented in FCPXML text style elements.
	public enum CEA608Color: String {
		case red = "1 0 0 1"
		case yellow = "1 1 0 1"
		case green = "0 1 0 1"
		case cyan = "0 1 1 1"
		case blue = "0 0 1 1"
		case magenta = "1 0 1 1"
		case white = "1 1 1 1"
		case black = "0 0 0 1"
	}
	
	/// The location of a story element within its sequence or timeline.
	///
	/// - primaryStoryline: The story element exists on the primary storyline.
	/// - attachedClip: The story element is attached to another clip that is on the primary storyline.
	/// - secondaryStoryline: The story element is embedded in a secondary storyline.
	public enum StoryElementLocation {
		case primaryStoryline
		case attachedClip
		case secondaryStoryline
	}
	

}


