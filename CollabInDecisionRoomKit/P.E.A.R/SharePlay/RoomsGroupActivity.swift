//
//  RoomsGroupActivity.swift
//
//  Created by Ella Isgar on 12/18/25.
//

import Foundation
import GroupActivities

/// A GroupActivity to share the opened 3D rooms in this app.
struct RoomsGroupActivity: GroupActivity {

    // "Metadata is used to generate invitation for other participants, so includes user-facing information about your group activity, such as the title of the activity, an image that corresponds to the activity, and a fallback URL for users who don’t have your app."
    // https://medium.com/@xinyichen0321/visionos-shareplay-tutorial-all-you-need-to-know-026f897b8929
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = NSLocalizedString(
            "Rooms",
            comment: "Title of the group activity")
        
        // configures this activity to a *custom* activity (vs a media activity)
        metadata.type = .generic
        
        // metadata.sceneAssociationBehavior = .content("ImmersiveSpace")
        
        return metadata
    }
}
