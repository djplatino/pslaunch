//
//  ViewController.swift
//  PSLaunch
//
//  Created by Jose Ponce on 9/12/16.
//  Copyright © 2016 http://www.poncesolutions.com All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var webView: UIWebView!
    
    
    //These variables are going to be used for the scanner. The device camera is used to read the code.
    var captureSession:AVCaptureSession?
    var captureDevice:AVCaptureDevice?
    var captureDeviceInput:AVCaptureDeviceInput?
    var captureLayer:AVCaptureVideoPreviewLayer?
    
    
    
    //These are all code types that can be scanned by the application. They can be modified to your specific needs.
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check to see if the url has been stored on the user's default and if found, update the navigation bar title.
        let defaults = NSUserDefaults.standardUserDefaults()
        if let url = defaults.stringForKey("url") {
            navBar.topItem?.title = url
        }
        
        //This function set the view to be shown. On the same controller, we have the buttons' view, the web view.
        setViews(0)
    }
    
 
    //Button function to launch url in the webview.
    @IBAction func launchInWebViewButton(sender: AnyObject) {
        if let urlFromLabel = navBar.topItem?.title {
            //scan url is the text used when there is not a valid url
            if urlFromLabel != "scan url" {
                let url = NSURL (string: urlFromLabel);
                let requestObj = NSURLRequest(URL: url!);
                webView.loadRequest(requestObj)
                setViews(1)
            }
        }
    }
    
    //Button function to launch url in web browser
    @IBAction func launchInBrowserButton(sender: AnyObject) {
        if let urlFromLabel = navBar.topItem?.title {
            if urlFromLabel != "scan url" {
                let url = NSURL (string: urlFromLabel);
                UIApplication.sharedApplication().openURL(url!)
            }
        }

    }
    
    @IBAction func scanURLButton(sender: AnyObject) {
        setViews(2)
        self.captureSession = AVCaptureSession()
        self.setupCaptureSession()
        
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        finishScanning()
    }
    
    //Function to show/hide specific UIViews
    func setViews(flag: Int) {
        buttonsView.hidden = true
        scannerView.hidden = true
        webView.hidden = true
        switch (flag) {
        case 1: //show webView
            webView.hidden = false
        case 2: //show scanner
            scannerView.hidden = false
        default: //show buttons
            buttonsView.hidden = false
        }
    }
    
    //Function to do variable/resources cleanup when the scanner is not active
    func finishScanning() {
        if let cs = captureSession {
            self.captureSession!.stopRunning()
        }
        if self.captureDevice != nil {
            self.captureSession!.removeInput(self.captureDeviceInput)
        }
        if let cs = self.captureSession {
            self.captureSession = nil
        }
        self.captureLayer = nil
        self.captureDevice = nil
        
        if let sublayers = self.view.layer.sublayers {
            for layer in sublayers {
                if layer.description.rangeOfString("AVCaptureVideoPreviewLayer") != nil{
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        setViews(0)
    }
    
    
    //Function to present a message to the user. In this simple application, it is only called once, but as your application grows, you can call any time is needed
    //and passed the necessary parameters.
    func presentSingleButtonAlert(alertTitle: String, msg: String, btn: String) {
        let refreshAlert = UIAlertController(title: alertTitle, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: btn, style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        
    }
    
    
    //Start from here down, the functions are part of the scanning functionality. I just cut from another applicaiton and pasted them here.
    
    //Sets up session.
    private func setupCaptureSession()
    {
        self.captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            self.captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            self.captureSession!.addInput(self.captureDeviceInput)
            self.setupPreviewLayer({
                self.captureSession!.startRunning()
                self.addMetaDataCaptureOutToSession()
            })
        }
        catch {
            
            presentSingleButtonAlert("Camera is not available", msg: "Camera is needed to scan url", btn: "OK")
            finishScanning()
        }
    }
    
    //Sets up the preview layer
    private func setupPreviewLayer(completion:() -> ())
    {
        self.captureLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        if let capLayer = self.captureLayer
        {
            capLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            capLayer.frame = self.scannerView.frame
            self.view.layer.addSublayer(capLayer)
            completion()
        }
    }
    
    //Sets up meta data for the session
    private func addMetaDataCaptureOutToSession()
    {
        let metadata = AVCaptureMetadataOutput()
        self.captureSession!.addOutput(metadata)
        metadata.metadataObjectTypes = supportedBarCodes
        metadata.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    }
    
    //Starts capturing the images. The camera uses video to read codes. Once it has the decoded the image, it will make the data available to use it anywhere
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        for metaData in metadataObjects
        {
            let decodedData:AVMetadataMachineReadableCodeObject = metaData as! AVMetadataMachineReadableCodeObject
            
            if decodedData.stringValue.uppercaseString.rangeOfString("HTTP:") != nil || decodedData.stringValue.uppercaseString.rangeOfString("HTTPS:") != nil{
                navBar.topItem!.title = decodedData.stringValue
            }
            else {
                navBar.topItem!.title = "scan url"
            }
            
            //Store the value in the user's default storage. The values are read when the application starts again.
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(navBar.topItem!.title, forKey: "url")
            
            self.captureSession!.stopRunning()
            finishScanning()
        }
    }
 }