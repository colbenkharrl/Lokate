//
//  WebViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/3/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    var urlString: String = "www.google.com"
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.isHidden = true
        webView.delegate = self
        webView.scrollView.isScrollEnabled = true
        webView.scalesPageToFit = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !(urlString.hasPrefix("http://") || urlString.hasPrefix("https://")) {
            urlString = "http://" + urlString
        }
        let url = URL(string: urlString)
        print(url!.absoluteString)
        let req = URLRequest(url:url!)
        progressIndicator.hidesWhenStopped = true
        progressIndicator.startAnimating()
        webView.loadRequest(req)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request.url!.absoluteString)
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        progressIndicator.stopAnimating()
    }
}
