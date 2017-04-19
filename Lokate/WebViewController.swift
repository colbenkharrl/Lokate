//
//  WebViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/3/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

class WebViewController: UIViewController  {
    
    //      MEMBER DEF
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    var messaged = false
    var urlString: String = "www.google.com"
    @IBOutlet weak var webView: UIWebView!
    
    //      VIEW DELEGATE/INITIALIZATION
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !messaged {
            loadPage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initializeDisplay() {
        navigationItem.title = "Web Search"
        progressIndicator.isHidden = true
        webView.delegate = self
        webView.scrollView.isScrollEnabled = true
        webView.scalesPageToFit = true
    }
    
    //      SHARE DEF

    @IBAction func share(_ sender: UIBarButtonItem) {
        if (MFMessageComposeViewController.canSendText()) {
            messaged = true
            let controller = MFMessageComposeViewController()
            controller.body = "Check this place out!\n\n" + (webView.request?.url?.absoluteString)!
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    //      WEBPAGE PROCESSING
    
    func loadPage() {
        if !(urlString.hasPrefix("http://") || urlString.hasPrefix("https://")) {
            urlString = "http://" + urlString
        }
        let url = URL(string: urlString)
        let req = URLRequest(url:url!)
        progressIndicator.hidesWhenStopped = true
        progressIndicator.startAnimating()
        webView.loadRequest(req)
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    
    @IBAction func movePage(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            webView.goBack()
            break
        case 2:
            webView.goForward()
            break
        default:
            break
        }
    }
    

}

extension WebViewController: UIWebViewDelegate, MFMessageComposeViewControllerDelegate {
    
    //      MESSAGEVIEW DEF
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //      WEBVIEW DEF
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        progressIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        progressIndicator.stopAnimating()
    }
}
