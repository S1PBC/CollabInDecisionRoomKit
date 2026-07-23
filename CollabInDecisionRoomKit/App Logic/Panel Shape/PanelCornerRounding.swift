//
//  PanelCornerRounding.swift
//
//  Created by Ella Isgar on 5/12/26.
//

/// How the corners and edges of a panel are curved.
enum PanelCornerRounding {

    /**
     Allows separate radii for the major and minor curvature.
    
     MAJOR: The radius of each page corner's circular radius (think the corner of a paper)
     MINOR:The radius of each page 'edge''s circular radius (think the edge of a paper)
    
     Minor is capped to 1/2 depth, major is capped to 1/2 min(width, height)
     */
    case majorMinor(radiusMajor: Float, radiusMinor: Float)

    /**
     Uniform corner radius, capped at 1/2 of depth.
     Produces UVs on the edges which provide an unintended but potentially desirable effect of displaying the page "squished" alone the edges
     */
    case uniform(radius: Float = .infinity)

    /**
     Uniform corner radius, capped at 1/2 of depth.
     Produces UVs on the edges which produce desired effect of displaying the PDF page "squished" along the edges.
     Equivilant to .uniform(0)
     */
    case none

    func getRadii(width: Float, height: Float, depth: Float) -> (
        majorCornerRadius: Float, minorCornerRadius: Float
    ) {

        let majorCornerRadius: Float
        let minorCornerRadius: Float

        switch self {
        case .majorMinor(let radiusMajor, let radiusMinor):
            majorCornerRadius = min(radiusMajor, min(width, height) / 2)
            minorCornerRadius = min(radiusMinor, min(width, height, depth) / 2)

        case .uniform(let radius):
            let radius = min(radius, min(width, height, depth) / 2)
            majorCornerRadius = radius
            minorCornerRadius = radius

        case .none:
            majorCornerRadius = 0
            minorCornerRadius = 0
        }

        return (
            majorCornerRadius: majorCornerRadius,
            minorCornerRadius: minorCornerRadius
        )
    }
}
