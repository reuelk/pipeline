//
//  FCPXMLElement.swift
//  Pipeline
//
//  Created by Reuel Kim on 2/8/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Cocoa
import CoreMedia

public struct FCPXMLElement {
	
	public enum TextAlignment: String {
		case Left = "left"
		case Center = "center"
		case Right = "right"
		case Justified = "justified"
	}
	
	let xmlElement = XMLElement()
	
	public init() {
		
	}
	
	public func newRefClip(name: String, ref: String, offset: CMTime?, duration: CMTime, start: CMTime?, useAudioSubroles: Bool) -> XMLElement {
		
		self.xmlElement.name = "ref-clip"
		
		self.xmlElement.fcpxName = name
		self.xmlElement.fcpxRef = ref
		self.xmlElement.fcpxOffset = offset
		self.xmlElement.fcpxDuration = duration
		self.xmlElement.fcpxStart = start
		
		if useAudioSubroles == true {
			xmlElement.setElementAttribute("useAudioSubroles", value: "1")
		} else {
			xmlElement.setElementAttribute("useAudioSubroles", value: "0")
		}
		
		return self.xmlElement
	}
	
	
	public func newGap(offset: CMTime?, duration: CMTime, start: CMTime?) -> XMLElement {
		
		self.xmlElement.name = "gap"
		
		self.xmlElement.fcpxOffset = offset
		self.xmlElement.fcpxDuration = duration
		self.xmlElement.fcpxStart = start
		
		return self.xmlElement
	}

	
	public func newTitle(titleName: String, lane: Int?, offset: CMTime, ref: String, duration: CMTime, start: CMTime, role: String?, titleText: String, textStyleID: Int, newTextStyle: Bool, font: String = "Helvetica", fontSize: CGFloat = 62, fontFace: String = "Regular", fontColor: NSColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), strokeColor: NSColor? = nil, strokeWidth: Float = 2.0, shadowColor: NSColor? = nil, shadowDistance: Float = 5.0, shadowAngle: Float = 315.0, shadowBlurRadius: Float = 1.0, alignment: TextAlignment = TextAlignment.Center, xPosition: Float = 0, yPosition: Float = -40) -> XMLElement {
		
		self.xmlElement.name = "title"
		
		self.xmlElement.fcpxName = titleName
		self.xmlElement.fcpxLane = lane
		self.xmlElement.fcpxOffset = offset
		self.xmlElement.fcpxRef = ref
		self.xmlElement.fcpxDuration = duration
		self.xmlElement.fcpxStart = start
		self.xmlElement.fcpxRole = role
		
		let text = Foundation.XMLElement(name: "text")
		let textTextStyle = Foundation.XMLElement(name: "text-style", stringValue: titleText)
		
		
		// Add the text content and its style
		textTextStyle.fcpxRef = "ts\(textStyleID)"  // Reference the new text style definition reference number
		
		text.addChild(textTextStyle)
		self.xmlElement.addChild(text)
		
		// Text Style Definition
		if newTextStyle == true {  // If a new text style definition hasn't been created yet
			
			let textStyleDef = Foundation.XMLElement(name: "text-style-def")
			
			textStyleDef.setElementAttribute("id", value: "ts\(textStyleID)")
			
			let textStyleDefTextStyle = Foundation.XMLElement(name: "text-style")
			
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
			
			self.xmlElement.addChild(textStyleDef)
		}
		
		// Add the transform
		let adjustTransform = Foundation.XMLElement(name: "adjust-transform")
		
		adjustTransform.setElementAttribute("position", value: "\(xPosition) \(yPosition)")
		
		self.xmlElement.addChild(adjustTransform)
		
		return self.xmlElement
	}

	
}
