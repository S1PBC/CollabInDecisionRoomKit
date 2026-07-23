//
//  PEAR.swift
//
//  Created by Ella Isgar on 12/18/25.
//

import SwiftUI

/// A very very very rudimentary attempt at the Perception Engine Augmented Reality (P.E.A.R.).
@Observable
class PEAR {
    
    let sharePlayManager: SharePlayManager
    
    /// - Parameters:
    ///     - cor: The object (in this case, a ``ControllerOfRooms``) that P.E.A.R. will control the perception of.
    init(_ cor: COR) {
        self.sharePlayManager = SharePlayManager(for: cor)
    }
    
}
