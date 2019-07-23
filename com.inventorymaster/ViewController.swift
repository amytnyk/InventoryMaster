//
//  ViewController.swift
//  InventoryMaster
//
//  Created by Alex Mytnyk on 7/20/19.
//  Copyright © 2019 Alex Mytnyk. All rights reserved.
//

import UIKit
import AVFoundation
import SelectionDialog

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}
class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var last_count : Int = 0
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 200
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        last_count = row + 1
    }
    
    
    var video = AVCaptureVideoPreviewLayer()
    
    @IBAction func AddButtonClicked(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        ItemManager.addCurrentItem(1)
    }
    
    @IBAction func AddCountButtonClicked(_ sender: UIButton) {
        // Show dialog here
        let alert = UIAlertController(title: "Choose count".localized, message: "\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        
        let pickerFrame = CGRect(x: 0, y: 50, width: 260, height: 210)
        let picker = UIPickerView(frame: pickerFrame)
        
        picker.delegate = self
        picker.dataSource = self
        
        alert.view.addSubview(picker)
        
        last_count = 1
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: {(action) in
            ItemManager.addCurrentItem(self.last_count)
        }))
        alert.addAction(UIAlertAction(title: "CANCEL".localized, style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func RemoveButtonClicked(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        ItemManager.removeCurrentItem()
    }
    
    func addNonScannableItem(_ index : Int) {
        ItemManager.setCurrentItemByIndex(index)
    }
    
    @IBAction func addNonScannableItemButtonClicked(_ sender: UIButton) {
        let dialog = SelectionDialog(title: "Select item".localized, closeButtonTitle: "Close".localized)
        
        for item in ItemManager.non_scannable_items.enumerated() {
            dialog.addItem(item: "\(item.element.art) - \(item.element.name)", didTapHandler: { () in
                self.addNonScannableItem(item.offset)
                dialog.close()
            })
        }
        
        dialog.show()
    }
    
    @IBOutlet weak var addNonScannableItemButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addCountButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var itemTextView: UITextView!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var MainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("ERROR")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .code39, .code93, .code128, .dataMatrix, .aztec, .itf14, .interleaved2of5, .pdf417, .code39Mod43, .qr]
            metadataOutput.rectOfInterest = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        } else {
            print("ERROR")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        view.bringSubviewToFront(MainView)
        
        captureSession.startRunning()
        setVisibility(false);
        
        ItemManager.viewController = self
    }
    
    func setVisibility(_ visibility : Bool) {
        addButton.isHidden = !visibility
        addCountButton.isHidden = !visibility
        removeButton.isHidden = !visibility
        //itemTextView.isHidden = !visibility
        addNonScannableItemButton.isHidden = !visibility
    }
    
    func setDisplayItem(_ item : Item) {
        setVisibility(true);
        DispatchQueue.main.async {
            self.itemTextView.text = "\n\(item.toString())"
        }
        
        
        if (ItemManager.findByArt(art: item.art, array: ItemManager.cloud_data) == nil) {
            removeButton.isHidden = true
        } else {
            removeButton.isHidden = false
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("Detected")
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.ean13 {
                    let previous = ItemManager.current_item
                    
                    ItemManager.setCurrentItemByBar(bar: object.stringValue!)
                    print("Detected item with barcode: \(object.stringValue!)")
                    if ItemManager.current_item == nil {
                        print("ERROR2")
                    } else {
                        if previous == nil || previous?.bar != object.stringValue {
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                        setDisplayItem(ItemManager.current_item!)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
