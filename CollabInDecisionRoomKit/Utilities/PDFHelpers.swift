//
//  PDFHelpers.swift
//
//  Created by Ella Isgar on 12/17/25.
//

import PDFKit
import RealityKit

extension PDFDocument {

    /// Convert the given PDF page into a UI Image to determine the logical size (in points).
    ///
    /// This size is used to get determine PDF page's aspect ratio so a panel can display the page as a material without it getting distorted.
    func getUIImageDimensionsForPage(_ pageNumber: Int) -> CGSize {

        let pdfPage = self.page(at: 0)!

        let uiImage = pdfPage.toUIImage()

        let pdfDimensions = uiImage.size

        return pdfDimensions
    }

}

extension PDFPage {

    /// Converts the PDF page into a UI Image.
    func toUIImage() -> UIImage {

        let pdfDisplayBoxBounds = self.bounds(for: .mediaBox)

        let rendererFormat = UIGraphicsImageRendererFormat()

        rendererFormat.scale = 3  // this line determines the resolution (pixels-per-point) at which the image will be rendered

        let renderer = UIGraphicsImageRenderer(
            size: pdfDisplayBoxBounds.size,
            format: rendererFormat
        )

        let uiImage = renderer.image { context in

            UIColor.white.set()

            context.fill(pdfDisplayBoxBounds)

            context.cgContext.translateBy(
                x: 0,
                y: pdfDisplayBoxBounds.size.height
            )

            context.cgContext.scaleBy(x: 1, y: -1)  //PDF reference frame is top-down

            self.draw(with: .mediaBox, to: context.cgContext)

        }

        return uiImage

    }

}

extension UIImage {

    /// Converts the UI Image into a Texture Resource (e.g. for a Panel).
    func toTextureResource() -> TextureResource? {

        guard let cgImage = self.cgImage else { return nil }

        return try? TextureResource(
            image: cgImage,
            options: TextureResource.CreateOptions.init(semantic: nil)
        )

    }
}

extension TextureResource {

    /// Converts the Texture Resource into a Reality Kit Material (e.g. for a Panel).
    func toRealityKitMaterial() -> RealityKit.Material {
        var material = PhysicallyBasedMaterial()

        material.baseColor = PhysicallyBasedMaterial.BaseColor(
            texture: MaterialParameters.Texture(self)
        )

        material.emissiveColor = .init(
            texture: MaterialParameters.Texture(self)
        )

        material.emissiveIntensity = 1000000.0

        material.blending = .opaque
        
        material.faceCulling = .back

        return material
    }

}
