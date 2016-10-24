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
    
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)
        
        self.webView.navigationDelegate = self
    }
    
    func loadUrlFromHistory(url: String) {
        
        webView.stopLoading()
        
        saveAndLoadUrl(true, url: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
    }
    
    func loadUrlFromBookmarks(url: String) {
        
        webView.stopLoading()
        
        saveAndLoadUrl(false, url: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
        
        view.insertSubview(webView, belowSubview: progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        let url = URL(string:"http://www.google.com")
        urlField.text = "http://www.google.com"
        let request = URLRequest(url:url!)
        
        webView.load(request)
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
        historyManager.getHistory()
        bookmarkManager.getBookmarks()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        barView.frame = CGRect(x:0, y: 0, width: size.width, height: 30)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        urlField.resignFirstResponder()
        
        var url = urlField.text!
        url = decodeUrl(url)
        
        saveAndLoadUrl(true, url: url)
        
        return false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "loading") {
            
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
        
        if (keyPath == "estimatedProgress") {
            
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    // MARK: Actions
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        
        webView.goBack()
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        
        webView.goForward()
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        
        let request = URLRequest(url:webView.url!)
        webView.load(request)
    }
    
    @IBAction func addBookmark(_ sender: UIBarButtonItem) {
        
        let url = urlField.text!
        
        if !backButton.isEnabled && !url.isEmpty {
            
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
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            
            let url = navigationAction.request.url
            let shared = UIApplication.shared
            
            let urlString = url!.absoluteString
            
            if shared.canOpenURL(url!) {
                
                //urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                
                webView.load(URLRequest(url:URL(string: urlString)!))
                
                urlField.text = urlString
                
                historyManager.addReference(urlString)
                historyManager.saveHistory(urlString)
            }
            
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "historyIdentifier" {
         
            let historyViewController = segue.destination as! AVHistoryTableViewController
            historyViewController.delegate = self
            
        } else {
            
            let bookmarkViewController = segue.destination as! AVBookmarksTableViewController
            bookmarkViewController.delegate = self
        }
    }
    
    // MARK: Helpers
    
    func showAlert(_ title:String, message:String){
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in print("OK")
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            alert.dismiss(animated: true, completion: {
                
            })
        })
    }
    
    func canOpenURL(_ string: String?) -> Bool {
        
        guard let urlString = string else {return false}
        guard let url = URL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url) {return false}
        
        //
        let regEx = "((https|http)://)(([а-яёa-z0-9]|-)+)(([.]|[/])(([а-яёa-z0-9]|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func saveAndLoadUrl(_ isHistory: Bool, url: String) {
            
        if url.range(of: "http") != nil{
            
            //urlField.text = url
            webView.load(URLRequest(url:URL(string: url)!))
            
            historyManager.addReference(url)
            historyManager.saveHistory(url)
        }
        else {
            
            //urlField.text = "http://" + url
            
            webView.load(URLRequest(url:URL(string: "http://" +  url)!))
            
            historyManager.addReference("http://" + url)
            historyManager.saveHistory("http://" + url)
        }
    }
    
    func decodeUrl(_ urlString: String) -> (String) {
        
        var url = urlString

        if !url.hasPrefix("http"){
            
            url = "http://" + url
        }
    
        let punycode = Punycode.official
        
        let str = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlComponents = URLComponents(string: str)
        var host = urlComponents?.host
        var path = urlComponents?.path
        path = path!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let separatedHost = host!.components(separatedBy: ".")
        
        var domen: String = ""
        var zone: String = ""
        
        if separatedHost.count > 1 {
            
            let cyrillic = isCyrillic(separatedHost[1])
            
            if cyrillic {
                
                domen = "xn-"
                zone = "xn-"
            }
        }
        
        if separatedHost.count == 2 {
            
            domen += punycode.encode(separatedHost[0])
            zone += punycode.encode(separatedHost[1])
            
        } else if separatedHost.count > 2{
            
            domen += punycode.encode(separatedHost[1])
            zone += punycode.encode(separatedHost[2])
        }
        
        
        host = domen + "." + zone + path!
        
        return host!
    }
    
    func isCyrillic(_ url: String) -> Bool {
        
        var cyrillic = true
        
        let scalars = url.unicodeScalars
        
        for (_, unicode) in scalars.enumerated() {
            
            if (unicode.value < 1024 || unicode.value > 1279) {
                
                // print("not a cyrillic text")
                // print(unicode.value)
                
                cyrillic = false
                break
            }
        }
        
        return cyrillic
    }
}

