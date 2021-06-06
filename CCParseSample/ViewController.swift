//
//  ViewController.swift
//  CCParseSample
//
//  Created by minho on 2021/06/06.
//

import UIKit
import WebKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    var webView: WKWebView! = nil
    let button: UIButton = UIButton()

    let captionOutput = AVPlayerItemLegibleOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        self.view.addSubview(webView)
        webView.frame = self.view.frame
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self

        self.view.addSubview(button)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        button.addTarget(self, action: #selector(onButton), for: UIControl.Event.touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeVisible(notification:)), name: UIWindow.didBecomeVisibleNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(playerItemBecameCurrent(notification:)), name: NSNotification.Name("AVPlayerViewControllerDidChangePlayerControllerNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemBecameCurrent(notification:)), name: NSNotification.Name("SomeClientIsPlayingDidChange"), object: nil)


        NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { (notif) in print(notif.name) }


        captionOutput.setDelegate(self, queue: DispatchQueue.main)
    }

    @objc func onButton() {
        print("onButton")
    }
    @objc func playerItemBecameCurrent(notification:Notification)  {
        var playerItem: AVPlayerItem? = notification.object as? AVPlayerItem
        var playerController: AVPlayerViewController? = notification.object as? AVPlayerViewController
        if playerItem == nil {
            if let avController = notification.object as? AVPlayerViewController {
                playerController = avController
                playerController?.addObserver(self, forKeyPath: #keyPath(AVPlayerViewController.player), options: NSKeyValueObservingOptions.new, context: nil)
                playerItem = avController.player?.currentItem
                avController.player?.currentItem?.add(captionOutput)
            } else {
                return
            }
        }
        // Break down the AVPlayerItem to get to the path
        guard let asset: AVURLAsset = (playerItem?.asset as? AVURLAsset) else { return }
        guard let url: URL? = asset.url else { return }
        let path: String? = url?.absoluteString
        print(path!)

    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("")
        if let player = object as? AVPlayer {
            player.currentItem?.add(self.captionOutput)
            let playerItem = player.currentItem
//            playerItem?.add(self.captionOutput)
            guard let asset: AVURLAsset = (playerItem?.asset as? AVURLAsset) else { return }
            guard let url: URL? = asset.url else { return }
            let path: String? = url?.absoluteString
            print(path!)
        }
    }
    func logPlayerItem(playerItem: AVPlayerItem) {
        // Break down the AVPlayerItem to get to the path
        let asset = playerItem.asset as? AVURLAsset
        let url: URL? = asset?.url
        let path = url?.absoluteString

        print(path!,"video url")
    }

    @objc func windowDidBecomeVisible(notification: NSNotification) {
        for mainWindow in UIApplication.shared.windows {
            for mainWindowSubview in mainWindow.subviews {
                print("\(mainWindowSubview) \(mainWindowSubview.subviews)")
            }
        }
    }
    private func getScript() -> String {
        if let filepath = Bundle.main.path(forResource: "script", ofType: "js") {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                print(error)
            }
        } else {
            print("script.js not found!")
        }
        return ""
    }


extension ViewController: WKNavigationDelegate {

    /** @abstract Decides whether to allow or cancel a navigation.
     @param webView The web view invoking the delegate method.
     @param navigationAction Descriptive information about the action
     triggering the navigation request.
     @param decisionHandler The decision handler to call to allow or cancel the
     navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
     @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor")
    }


    /** @abstract Decides whether to allow or cancel a navigation.
     @param webView The web view invoking the delegate method.
     @param navigationAction Descriptive information about the action
     triggering the navigation request.
     @param preferences The default set of webpage preferences. This may be
     changed by setting defaultWebpagePreferences on WKWebViewConfiguration.
     @param decisionHandler The policy decision handler to call to allow or cancel
     the navigation. The arguments are one of the constants of the enumerated type
     WKNavigationActionPolicy, as well as an instance of WKWebpagePreferences.
     @discussion If you implement this method,
     -webView:decidePolicyForNavigationAction:decisionHandler: will not be called.
     */
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {

//        print("webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {}")
        var action: WKNavigationActionPolicy?

        print(navigationAction.request.url ?? "")
        if navigationAction.request.url?.absoluteString.contains(".vtt") == true {

            decisionHandler(.allow, WKWebpagePreferences.init())
        }

        defer {
            decisionHandler(action ?? .allow, WKWebpagePreferences.init())
        }
    }


    /** @abstract Decides whether to allow or cancel a navigation after its
     response is known.
     @param webView The web view invoking the delegate method.
     @param navigationResponse Descriptive information about the navigation
     response.
     @param decisionHandler The decision handler to call to allow or cancel the
     navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
     @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//        print("webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {}")
        decisionHandler(WKNavigationResponsePolicy.allow)
    }


    /** @abstract Invoked when a main frame navigation starts.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("provisional")
    }


    /** @abstract Invoked when a server redirect is received for the main
     frame.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("redirectforprovisional")
    }


    /** @abstract Invoked when an error occurs while starting to load data for
     the main frame.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     @param error The error that occurred.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("failprovisional")
    }


    /** @abstract Invoked when content starts arriving for the main frame.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit Navigation : \(webView.url?.absoluteURL.absoluteString ?? "")")
    }


    /** @abstract Invoked when a main frame navigation completes.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
    }


    /** @abstract Invoked when an error occurs during a committed main frame
     navigation.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     @param error The error that occurred.
     */
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
    }


    /** @abstract Invoked when the web view needs to respond to an authentication challenge.
     @param webView The web view that received the authentication challenge.
     @param challenge The authentication challenge.
     @param completionHandler The completion handler you must invoke to respond to the challenge. The
     disposition argument is one of the constants of the enumerated type
     NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
     the credential argument is the credential to use, or nil to indicate continuing without a
     credential.
     @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
     */
//    @available(iOS 8.0, *)
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {")
//    }


}


extension ViewController: AVPlayerItemLegibleOutputPushDelegate {
    func legibleOutput(_ output: AVPlayerItemLegibleOutput,
                       didOutputAttributedStrings strings: [NSAttributedString],
                       nativeSampleBuffers nativeSamples: [Any],
                       forItemTime itemTime: CMTime) {
        print(strings)
//        textView.attributedText = strings.first
    }
}
