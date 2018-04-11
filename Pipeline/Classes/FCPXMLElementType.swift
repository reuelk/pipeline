//
//  FCPXMLElementType.swift
//  Pipeline
//
//  Created by Reuel Kim on 1/15/17.
//  Copyright © 2017 Reuel Kim. All rights reserved.
//

import Foundation

// MARK: - Definitions

/// Defines the element types that can exist in FCPXML documents.
public enum FCPXMLElementType: String {
	/// This element is not from an FCPXML document.
	case none
	
	// MARK: - Sections
	/// The `<resources>` element in an FCPXML document.
	case resourceList = "resources"
	/// The `<library>` element in an FCPXML document.
	case library = "library"
	
	// MARK: - Resources
	case assetResource = "asset"
	case formatResource = "format"
	case mediaResource = "media"
	case effectResource = "effect"
	case multicamResource
	case compoundResource
	
	// MARK: - Library-level
	case event = "event"
	case project = "project"
	case multicamClip = "mc-clip"
	case compoundClip = "ref-clip"
	case synchronizedClip = "sync-clip"  // FCPXML v1.6
	case assetClip = "asset-clip"  // FCPXML v1.6
	
	// MARK: - Project-level
	case clip = "clip"
	case audio = "audio"
	case video = "video"
	case gap = "gap"
	case transition = "transition"
	case spine = "spine"
	case audition = "audition"
	case sequence = "sequence"
	case title = "title"
	case param = "param"
	case caption = "caption"  // FCPXML v1.8
	
	// MARK: Text elements
	case text = "text"
	case textStyleDef = "text-style-def"
	case textStyle = "text-style"
	
	// MARK: - Clip annotation
	case marker = "marker"
	case keyword = "keyword"
	case rating = "rating"
	case chapterMarker = "chapter-marker"
	case analysisMarker = "analysis-marker"
	case note = "note"
	
	// MARK: - Collections
	case folder = "collection-folder"
	case keywordCollection = "keyword-collection"
	case smartCollection = "smart-collection"
	
}

