//
//  ViewController.swift
//  PRESUS-Barcode-Prototype
//
//  Created by 李　思遠 on 2022/03/25.
//

import UIKit
import AVKit
import Vision

final class ViewController: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                
        let barcodeRequest = VNDetectBarcodesRequest { request, error in
            guard let result = request.results as? [VNBarcodeObservation] else { return }
            
            DispatchQueue.main.sync {
                self.label1.text = "バーコードスキャン結果:"
                self.label2.text = result.first?.payloadStringValue?.debugDescription
                self.label3.text = result.first?.symbology.rawValue
            }
            
        }
        barcodeRequest.symbologies = [.qr, .gs1DataBar, .gs1DataBarLimited, .gs1DataBarExpanded, .code128, .ean13]
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([barcodeRequest])
        
    }
}

