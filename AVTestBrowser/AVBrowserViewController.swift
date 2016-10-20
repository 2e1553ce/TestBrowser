//
//  AVBrowserViewController.swift
//  AVTestBrowser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 A.V. All rights reserved.
//

import UIKit
import WebKit

class AVBrowserViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, AVHistoryTableViewControllerDelegate, AVBookmarksTableViewControllerDelegate {
    
    var webView: WKWebView
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
    
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
        
        self.webView.navigationDelegate = self
    }
    
    func loadUrlFromHistory(url: String) {
        
        webView.stopLoading()
        
        saveAndLoadUrl(true, url: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    }
    
    func loadUrlFromBookmarks(url: String) {
        
        webView.stopLoading()
        
        saveAndLoadUrl(false, url: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
        
        view.insertSubview(webView, belowSubview: progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        let url = NSURL(string:"http://www.google.com")
        urlField.text = "http://www.google.com"
        let request = NSURLRequest(URL:url!)
        
        webView.loadRequest(request)
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        historyManager.getHistory()
        bookmarkManager.getBookmarks()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        barView.frame = CGRect(x:0, y: 0, width: size.width, height: 30)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        urlField.resignFirstResponder()
        
        var url = urlField.text!
        url = decodeUrl(url)
        
        saveAndLoadUrl(true, url: url)
        
        return false
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        
        if (keyPath == "loading") {
            
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
        }
        
        if (keyPath == "estimatedProgress") {
            
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    // MARK: Actions
    
    @IBAction func back(sender: UIBarButtonItem) {
        
        webView.goBack()
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        
        webView.goForward()
    }
    
    @IBAction func reload(sender: UIBarButtonItem) {
        
        let request = NSURLRequest(URL:webView.URL!)
        webView.loadRequest(request)
    }
    
    @IBAction func addBookmark(sender: UIBarButtonItem) {
        
        let url = urlField.text!
        
        if !backButton.enabled && !url.isEmpty {
            
            bookmarkManager.addBookmark("google.ru")
            bookmarkManager.saveBookmark("google.ru")
            
            showAlert("Сообщение", message: "Закладка добавлена")
        }
        else if url.isEmpty {
            
            return
        }
        else {
            
            bookmarkManager.addBookmark(url)
            bookmarkManager.saveBookmark(url)
            
            showAlert("Сообщение", message: "Закладка добавлена")
        }
    }
    
    // MARK: WebView methods
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(webView: WKWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == WKNavigationType.LinkActivated {
            
            let url = navigationAction.request.URL
            let shared = UIApplication.sharedApplication()
            
            let urlString = url!.absoluteString
            
            if shared.canOpenURL(url!) {
                
                //urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                
                webView.loadRequest(NSURLRequest(URL:NSURL(string: urlString)!))
                
                urlField.text = urlString
                
                historyManager.addReference(urlString)
                historyManager.saveHistory(urlString)
            }
            
            decisionHandler(WKNavigationActionPolicy.Cancel)
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "historyIdentifier" {
         
            let historyViewController = segue.destinationViewController as! AVHistoryTableViewController
            historyViewController.delegate = self
            
        } else {
            
            let bookmarkViewController = segue.destinationViewController as! AVBookmarksTableViewController
            bookmarkViewController.delegate = self
        }
    }
    
    // MARK: Helpers
    
    func showAlert(title:String, message:String){
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            (result : UIAlertAction) -> Void in print("OK")
        }
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissViewControllerAnimated(true, completion: {
                
            })
        })
    }
    
    func canOpenURL(string: String?) -> Bool {
        
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.sharedApplication().canOpenURL(url) {return false}
        
        //
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluateWithObject(string)
    }
    
    func saveAndLoadUrl(isHistory: Bool, url: String) {
            
        if url.rangeOfString("http") != nil{
            
            //urlField.text = url
            webView.loadRequest(NSURLRequest(URL:NSURL(string: url)!))
            
            historyManager.addReference(url)
            historyManager.saveHistory(url)
        }
        else {
            
            //urlField.text = "http://" + url
            
            webView.loadRequest(NSURLRequest(URL:NSURL(string: "http://" +  url)!))
            
            historyManager.addReference("http://" + url)
            historyManager.saveHistory("http://" + url)
        }
    }
    
    func decodeUrl(url: String) -> (String) {
    
        let punycode = Punycode.official
        
        let str = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlComponents = NSURLComponents(string: str)
        var host = urlComponents?.host
        var path = urlComponents?.path
        path = path!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let separatedHost = host!.componentsSeparatedByString(".")
        
        var domen, zone : String
        
        if separatedHost.count == 2 {
            
            domen = "xn-" + punycode.encode(separatedHost[0])
            zone = "xn-" + punycode.encode(separatedHost[1])
            
        } else {
            
            domen = "xn-" + punycode.encode(separatedHost[1])
            zone = "xn-" + punycode.encode(separatedHost[2])
        }
        
        
        host = domen + "." + zone + path!
        
        return host!
    }
}

