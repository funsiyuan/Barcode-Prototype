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
    
    private var currentBarcode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        
        label1.text = "バーコードスキャン結果:"
    }
    
    // MARK: - Setup.
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
            
            // MARK: - Result is here!!
            guard let result = request.results as? [VNBarcodeObservation] else { return }
            if result.isEmpty { return }
            
            if result.first?.payloadStringValue?.debugDescription == self.currentBarcode { return }
            
            self.currentBarcode = result.first?.payloadStringValue?.debugDescription ?? ""
            
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            generator.impactOccurred()
            
            DispatchQueue.main.sync {
                self.appleyBackgroundAnimation()
                self.label2.text = result.first?.payloadStringValue?.debugDescription
                self.label3.text = result.first?.symbology.rawValue
            }
            
        }
        barcodeRequest.symbologies = [.ean13, .code128, .gs1DataBarExpanded, .gs1DataBarLimited, .gs1DataBar, .dataMatrix, .aztec, .codabar, .code39, .ean13, .code39FullASCII, .code93, .code93i, .microQR, .microPDF417]
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([barcodeRequest])
        
    }
    
    private func appleyBackgroundAnimation() {
        self.view.backgroundColor = UIColor(red: 107/255, green: 152/255, blue: 220/255, alpha: 1)
        self.label2.backgroundColor = .green
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.label2.backgroundColor = .systemBackground
            self.view.backgroundColor = .systemBackground
        }
    }
}

