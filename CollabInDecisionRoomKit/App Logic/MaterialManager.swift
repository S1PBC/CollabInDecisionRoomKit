//
//  MaterialManager.swift
//
//  Created by Ella Isgar on 12/15/25.
//

import PDFKit
import RealityKit
import SwiftUI

class MaterialManager {

    var (pdfURLString, pdfPageNumber): (String?, Int?)
    var pdfDocument: PDFDocument?
    var pdfPage: PDFPage?

    var simpleColor: UIColor = .white
    var roughness: Float = 0
    var isMetallic: Bool = false

    var material: any RealityKit.Material {
        if let mat = pdfPage?
            .toUIImage()
            .toTextureResource()?
            .toRealityKitMaterial()
        {
            return mat
        } else {
            return SimpleMaterial(
                color: simpleColor,
                roughness: MaterialScalarParameter(floatLiteral: roughness),
                isMetallic: isMetallic
            )
        }
    }
    
    init(
        simpleColor: UIColor,
        roughness: Float,
        isMetallic: Bool,
    ) {
        self.simpleColor = simpleColor
        self.roughness = roughness
        self.isMetallic = isMetallic
    }
    
    init(
        pdfURLString: String,
        pdfPageNumber: Int
    ) {
        self.pdfURLString = pdfURLString
        self.pdfPageNumber = pdfPageNumber

        guard
            let pdfURL = Bundle.main.url(
                forResource: pdfURLString,
                withExtension: "pdf"
            ),
            let pdfDocument = PDFDocument(url: pdfURL),
            let pdfPage = pdfDocument.page(at: pdfPageNumber)
        else {
            return
        }

        self.pdfDocument = pdfDocument
        self.pdfPage = pdfPage
    }
    
}

extension PDFDocument {

    func getUIImageForPage(_ pageNumber: Int) -> CGSize? {

        let pdfPage = self.page(at: 0)!

        let uiImage = pdfPage.toUIImage()
        
        let pdfDimensions = uiImage.size

        return pdfDimensions
    }

}

//init(_ c: DefaultMaterialManagerConfiguration) {
//    self.simpleColor = c.simpleColor
//    self.roughness = c.roughness
//    self.isMetallic = c.isMetallic
//}
//
//init(_ c: PDFMaterialManagerConfiguration) {
//    self.pdfURLString = c.pdfURLString
//    self.pdfPageNumber = c.pdfPageNumber
//
//    guard
//        let pdfURL = Bundle.main.url(
//            forResource: pdfURLString,
//            withExtension: "pdf"
//        ),
//        let pdfDocument = PDFDocument(url: pdfURL),
//        let pdfPage = pdfDocument.page(at: c.pdfPageNumber)
//    else {
//        return
//    }
//
//    self.pdfDocument = pdfDocument
//    self.pdfPage = pdfPage
//}
