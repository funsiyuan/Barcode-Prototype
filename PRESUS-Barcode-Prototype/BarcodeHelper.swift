//
//  BarcodeHelper.swift
//  PRESUS-Barcode-Prototype
//
//  Created by 李　思遠 on 2022/05/23.
//

import Vision
import Foundation

class BarcodeHelper {
    
    public func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
        
        // Fetch desired requests based on switch status.
        let requests = [pdf417BarcodeDetectionRequest, barcodeDetectionRequest]
        // Create a request handler.
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: orientation,
                                                        options: [:])
        
        // Send the requests to the request handler.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    
    lazy var pdf417BarcodeDetectionRequest: VNDetectBarcodesRequest = {
        let barcodeDetectRequest = VNDetectBarcodesRequest(completionHandler: self.handlePDF417DetectedBarcodes)
        barcodeDetectRequest.symbologies = [.microPDF417]
        return barcodeDetectRequest
    }()
    
    lazy var barcodeDetectionRequest: VNDetectBarcodesRequest = {
        let barcodeDetectRequest = VNDetectBarcodesRequest(completionHandler: self.handleDetectedBarcodes)
        barcodeDetectRequest.symbologies = [.aztec, .code39, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum, .code93, .code93i, .code128,
                                            .dataMatrix, .ean8, .ean13, .i2of5, .i2of5Checksum, .itf14, .pdf417, .qr, .upce, .codabar, .gs1DataBar, .gs1DataBarExpanded,
                                            .gs1DataBarLimited, .microPDF417, .microQR]
        return barcodeDetectRequest
    }()
    
    public func createVisionRequests() -> [VNRequest] {
        [pdf417BarcodeDetectionRequest, barcodeDetectionRequest]
    }
    
    fileprivate func handlePDF417DetectedBarcodes(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            let results = request?.results as? [VNBarcodeObservation]
            print("pdf: \(results)")
        }
    }
    
    fileprivate func handleDetectedBarcodes(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            return
        }
        // Perform drawing on the main thread.
        DispatchQueue.main.async {
            let results = request?.results as? [VNBarcodeObservation]
            print("normal: \(results)")
        }
    }
}
