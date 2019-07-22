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
        let alert = UIAlertController(title: "Choose count", message: "\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        
        let pickerFrame = CGRect(x: 17, y: 52, width: 270, height: 100)
        let picker = UIPickerView(frame: pickerFrame)
        
        picker.delegate = self
        picker.dataSource = self
        
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
            ItemManager.addCurrentItem(self.last_count)
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: nil))
        
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
        /*let dialog = SelectionDialog(title: "Dialog", closeButtonTitle: "Close")
        
        for item in ItemManager.non_scannable_items.enumerated() {
            dialog.addItem(item: "\(item.element.art) - \(item.element.name)", didTapHandler: { () in
                self.addNonScannableItem(item.offset)
            })
        }
        
        dialog.show()*/
    }
    
    @IBOutlet weak var addNonScannableItemButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addCountButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var itemTextView: UITextView!
    
    @IBOutlet weak var MainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Creating session
        let session = AVCaptureSession()
        
        // Define capture device
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        }
        catch {
            print("ERROR")
        }
        
        let output = AVCaptureMetadataOutput()
        
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeDataMatrixCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeQRCode]
        
        output.rectOfInterest = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        
        view.layer.addSublayer(video)
        self.view.bringSubview(toFront: MainView)
        
        session.startRunning()
        
        setVisibility(false);
    }
    
    func setVisibility(_ visibility : Bool) {
        addButton.isHidden = !visibility
        addCountButton.isHidden = !visibility
        removeButton.isHidden = !visibility
        itemTextView.isHidden = !visibility
        addNonScannableItemButton.isHidden = !visibility
    }
    
    func setDisplayItem(_ item : Item) {
        setVisibility(true);
        itemTextView.text = item.toString()
        
        if (ItemManager.findByArt(art: item.art, array: ItemManager.cloud_data) == nil) {
            removeButton.isHidden = true
        } else {
            removeButton.isHidden = false
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects != nil && metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObjectTypeEAN13Code {
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
