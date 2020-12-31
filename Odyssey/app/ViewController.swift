//
//  ViewController.swift
//  Electra13
//
//  Created by CoolStar on 3/1/20.
//  Copyright © 2020 coolstar. All rights reserved.
//

import UIKit
import MachO.dyld_images

import AVFoundation
import AVKit

enum JailbreakError: Error {
    case tpf0Error
    case electraError
}

class ViewController: UIViewController, ElectraUI {

    var electra: Electra?
    var allProc = UInt64(0)
        
    fileprivate var scrollAnimationClosures: [() -> Void] = []
    private var popClosure: DispatchWorkItem?
        
    var enableTweaksSwitch = PersistentSwitch(key: "enableTweaks", defaultValue: true)
    var restoreRootfsSwitch = PersistentSwitch(key: "restoreRootFS", defaultValue: false)
    var logSwitch = PersistentSwitch(key: "showLog", defaultValue: false)
    var nonceSetter: TextButton!
    
    var rickRollSwitch = PersistentSwitch(key: "rickroll", defaultValue: true)
    
    var actionCard = ActionCard()
    var jailbreakButton = JailbreakButton()
    
    let progressBar = FluxProgressView()
    let progressLabel = UILabel()
    
    let videoView = UIView()
    let rickRollPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "dQw", ofType: "mp4")!))
    
    var used = UserDefaults.standard.bool(forKey: "usedOnce")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This will reset user defaults, used it a lot for testing
        /*
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        */
        
        self.view.layer.insertSublayer(createGradient(), at: 0)
        
        setUpRickAstley()
        setUpCreditButtons()
        setUpStatusViews()
        setUpActionCard()
        
        // nonceSetter.delegate = NonceManager.shared
        
        if #available(iOS 13.5.1, *) {
            jailbreakButton.isEnabled = true
            jailbreakButton.setTitle("Jailbreak", for: .normal)

            if let allProcStr = UIPasteboard.general.string {
                let prefix = "allproc: "
                if allProcStr.hasPrefix(prefix) {
                    let allProcHex = String(allProcStr.dropFirst(prefix.count + 2))
                    if let allProc = UInt64(allProcHex, radix: 16) {
                        self.allProc = allProc
                        jailbreakButton.isEnabled = true
                        jailbreakButton.setTitle("Jailbreak", for: .normal)
                    }
                }
            }
        }
        
        if isJailbroken() {
            jailbreakButton.isEnabled = false
            jailbreakButton.setTitle("Happy New Year!", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.actionCard.isExpanded = false
        DispatchQueue.main.async {
            self.actionCard.isExpanded = true
        }
    }
    
    func setUpRickAstley() {
        let playerLayer = AVPlayerLayer(player: rickRollPlayer)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = self.view.bounds
        videoView.layer.addSublayer(playerLayer)
        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
        videoView.alpha = 0
        
        self.view.addSubview(videoView)
        
        videoView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        videoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        videoView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        videoView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    func setUpCreditButtons() {
        let creditStack = UIStackView()
        creditStack.axis = .horizontal
        creditStack.spacing = 16
        creditStack.distribution = .fillEqually
        creditStack.translatesAutoresizingMaskIntoConstraints = false
        
        let green = UIColor(red: 0.30, green: 0.44, blue: 0.50, alpha: 0.1)
        
        let justinProulx = TwitterButton(handle: "JustinAlexP")
        justinProulx.setTitle("Justin Proulx", for: .normal)
        justinProulx.titleLabel?.font = .boldSystemFont(ofSize: 20)
        justinProulx.tintColor = green
        
        let odyssey = TwitterButton(customAction: true)
        odyssey.setTitle("Odyssey", for: .normal)
        odyssey.titleLabel?.font = .boldSystemFont(ofSize: 20)
        odyssey.tintColor = green
        odyssey.addTarget(self, action: #selector(showOdysseyCredits), for: .touchUpInside)

        creditStack.addArrangedSubview(justinProulx)
        creditStack.addArrangedSubview(odyssey)
        
        self.view.addSubview(creditStack)
        
        creditStack.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        creditStack.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        creditStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -112).isActive = true
    }
    
    @objc func showOdysseyCredits() {
        let creditsVC = CreditsViewController()
        self.present(creditsVC, animated: true, completion: nil)
    }
    
    func setUpStatusViews() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.heightAnchor.constraint(equalToConstant: 16).isActive = true
        progressBar.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        progressLabel.textAlignment = .center
        progressLabel.numberOfLines = 0
        progressLabel.text = "Ready to Jailbreak"
        
        let statusStack = UIStackView()
        statusStack.axis = .vertical
        statusStack.spacing = 16
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        
        statusStack.addArrangedSubview(progressBar)
        statusStack.addArrangedSubview(progressLabel)
        
        self.view.addSubview(statusStack)
        
        statusStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        statusStack.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    func setUpActionCard() {
        // action card itself
        self.actionCard.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.actionCard)
        self.view.bringSubviewToFront(self.actionCard)
                
        // control stack setup
        let controlStack = UIStackView()
        controlStack.axis = .vertical
        controlStack.distribution = .equalSpacing
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        controlStack.alignment = .center
        controlStack.spacing = 64
        
        self.actionCard.addSubview(controlStack)
        
        controlStack.centerXAnchor.constraint(equalTo: self.actionCard.centerXAnchor).isActive = true
        controlStack.centerYAnchor.constraint(equalTo: self.actionCard.centerYAnchor).isActive = true
        
        // add the actual controls
        self.jailbreakButton.addTarget(self, action: #selector(jailbreakButtonActions), for: .touchUpInside)
        controlStack.addArrangedSubview(self.jailbreakButton)
        
        let settingStack = UIStackView()
        settingStack.spacing = 16
        settingStack.axis = .vertical
                
        let enableTweakStack = createSettingPanel(title: "Enable Tweaks", settingSwitch: enableTweaksSwitch)
        let rootFSStack = createSettingPanel(title: "Restore RootFS", settingSwitch: restoreRootfsSwitch)
        let logSwitchStack = createSettingPanel(title: "Show Log Window", settingSwitch: logSwitch)
        let rickRollSwitchStack = createSettingPanel(title: "rickroll", settingSwitch: rickRollSwitch)
        
        let nonceSetter = UIButton(type: .system)
        nonceSetter.setTitle("Set ApNonce Generator", for: .normal)
        nonceSetter.setTitleColor(.white, for: .normal)
        nonceSetter.tintColor = .white
        nonceSetter.addTarget(self, action: #selector(updateNonce), for: .touchUpInside)
        
        settingStack.addArrangedSubview(enableTweakStack)
        settingStack.addArrangedSubview(rootFSStack)
        settingStack.addArrangedSubview(logSwitchStack)
        settingStack.addArrangedSubview(rickRollSwitchStack)
        settingStack.addArrangedSubview(nonceSetter)
        
        controlStack.addArrangedSubview(settingStack)
        
        if !used {
            rickRollSwitchStack.isHidden = true
        }
    }
    
    func createSettingPanel(title: String, settingSwitch: UISwitch) -> UIView {
        let stack = UIStackView()
        stack.spacing = 16
        stack.layer.backgroundColor = UIColor.green.cgColor
        
        let label = UILabel()
        label.text = title
        label.textColor = UIColor(white: 0.4, alpha: 1)
        
        stack.addArrangedSubview(settingSwitch)
        stack.addArrangedSubview(label)
        
        return stack
    }
    
    func createGradient() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(red: 0.47, green: 0.68, blue: 0.77, alpha: 1.0).cgColor, UIColor(red: 0.47, green: 0.77, blue: 0.60, alpha: 1.0).cgColor]
        
        return gradientLayer
    }
    
    @objc func updateNonce() {
        let alert = UIAlertController(title: "Set ApNonce Generator", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.text = NonceManager.shared.currentValue
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned alert] _ in
            let nonce = alert.textFields![0].text ?? ""
            NonceManager.shared.receiveInput(input: nonce)
        }
        
        let reset = UIAlertAction(title: "Reset", style: .default, handler: { _ in
            NonceManager.shared.receiveInput(input: NonceManager.shared.defaultGenerator)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(reset)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func getHSP4(tfp0: inout mach_port_t) -> Bool {
        let host = mach_host_self()
        let ret = host_get_special_port(host, HOST_LOCAL_NODE, 4, &tfp0)
        mach_port_destroy(mach_task_self_, host)
        return ret == KERN_SUCCESS && tfp0 != MACH_PORT_NULL
    }
    
    func showAlert(_ title: String, _ message: String, sync: Bool, callback: (() -> Void)? = nil, yesNo: Bool = false, noButtonText: String? = nil) {
        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: yesNo ? "Yes" : "OK", style: .default) { _ in
                if let callback = callback {
                    callback()
                }
                if sync {
                    sem.signal()
                }
            })
            if yesNo {
                alertController.addAction(UIAlertAction(title: noButtonText ?? "No", style: .default) { _ in
                    if sync {
                        sem.signal()
                    }
                })
            }
            (self.presentedViewController ?? self).present(alertController, animated: true, completion: nil)
        }
        if sync {
            sem.wait()
        }
    }
    
    @objc func jailbreakButtonActions() {
        self.progressLabel.text = "Starting..."
        self.actionCard.isExpanded = false
        
        if rickRollSwitch.isOn {
            UIView.animate(withDuration: 0.5, animations: {
                self.videoView.alpha = 1
            })
            
            do {
               try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch(let error) {
                print(error.localizedDescription)
            }
            rickRollPlayer.play()
        }
        
        used = true
        UserDefaults.standard.set(true, forKey: "usedOnce")
        
        jailbreak()
    }
    
    func jailbreak() {
        jailbreakButton.isEnabled = false
        jailbreakButton.setTitle("Happy New Year", for: .normal)
        
        if self.logSwitch.isOn {
            UIView.animate(withDuration: 0.5) {
                self.performSegue(withIdentifier: "logSegue", sender: self.jailbreakButton)
            }
        } else {
            self.progressBar.setProgress(0.33, animated: true)
        }
        
        let enableTweaks = self.enableTweaksSwitch.isOn
        let restoreRootFs = self.restoreRootfsSwitch.isOn
        let generator = NonceManager.shared.currentValue
        let simulateJailbreak = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            DispatchQueue.global(qos: .userInteractive).async {
                usleep(500 * 1000)
                
                if simulateJailbreak {
                    sleep(1)
                    DispatchQueue.main.async {
                        self.progressBar.setProgress(0.4, animated: true)
                        self.progressLabel.text = "Testing stderr"
                    }
                    var outStream = StandardOutputStream.shared
                    var errStream = StandardErrorOutputStream.shared
                    print("Testing log", to: &outStream)
                    print("Testing stderr", to: &errStream)
                    
                    sleep(2)
                    DispatchQueue.main.async {
                        self.progressBar.setProgress(0.8, animated: true)
                        self.progressLabel.text = "Testing stderr2"
                    }
                    print("Testing log2", to: &outStream)
                    print("Testing stderr2", to: &errStream)
                    
                    sleep(1)
                    DispatchQueue.main.async {
                        self.progressBar.setProgress(1, animated: true)
                        self.progressLabel.text = "Testing stderr3"
                    }
                    print("Testing log3", to: &outStream)
                    print("Testing stderr3", to: &errStream)
                    
                    self.showAlert("Test alert", "Testing an alert message", sync: true)
                    print("Alert done")
                    
                    return
                }
                
                var tfp0 = mach_port_t()
                var any_proc = UInt64(0)
                if self.getHSP4(tfp0: &tfp0) {
                    tfpzero = tfp0
                    any_proc = rk64(self.allProc)
                } else {
                    if #available(iOS 13.5.1, *) {
                        DispatchQueue.main.async {
                            self.progressBar.setProgress(1, animated: true)
                            self.progressLabel.text = "Unable to get tfp0. Happy New Year!"
                            
                            if self.rickRollSwitch.isOn {
                                self.selfPromo()
                            }
                        }
                        return
                        // fatalError("Unable to get tfp0")
                    } else if #available(iOS 13.3.1, *) {
                        DispatchQueue.main.async {
                            self.progressLabel.text = "Selecting tardy0n"
                        }
                        print("Selecting tardy0n for iOS 13.4 -> 13.5 (+ 13.5.5b1)")
                        tardy0n()
                        tfpzero = getTaskPort()
                        tfp0 = tfpzero
                        let our_task = getOurTask()
                        any_proc = rk64(our_task + Offsets.shared.task.bsd_info)
                    } else if #available(iOS 13, *) {
                        DispatchQueue.main.async {
                            self.progressLabel.text = "Selecting time_waste"
                        }
                        print("Selecting time_waste for iOS 13.0 -> 13.3")
                        get_tfp0()
                        tfp0 = tfpzero
                        let our_task = rk64(task_self + Offsets.shared.ipc_port.ip_kobject)
                        any_proc = rk64(our_task + Offsets.shared.task.bsd_info)
                    }
                }
                DispatchQueue.main.async {
                    self.progressBar.setProgress(0.66, animated: true)
                    self.progressLabel.text = "Jailbreaking"
                }
                let electra = Electra(ui: self,
                                      tfp0: tfpzero,
                                      any_proc: any_proc,
                                      enable_tweaks: enableTweaks,
                                      restore_rootfs: restoreRootFs,
                                      nonce: generator)
                
                self.electra = electra
                let err = electra.jailbreak()

                DispatchQueue.main.async {
                    if err == .ERR_NOERR {
                        self.progressBar.setProgress(1, animated: true)
                        self.progressLabel.text = "Done. Happy New Year!"
                    } else {
                        self.progressBar.setProgress(1, animated: true)
                        self.progressLabel.text = "Failed. Happy New Year!"
                        
                        /*self.showAlert("Oh no", "\(String(describing: err))", sync: false, callback: {
                            UIApplication.shared.beginBackgroundTask {
                                print("odd. this should never be called.")
                            }
                        })*/
                    }
                    
                    if self.rickRollSwitch.isOn {
                        self.selfPromo()
                    }
                    
                    return
                }
            }
        }
    }
    
    func selfPromo() {
        let alert = UIAlertController(title: "Happy New Year!", message: "I'm Justin Proulx, and I'm an app and tweak developer. Please consider following me on Twitter for more jailbreak and App Store related content! Also, this meme would not have been possible without the original Odyssey jailbreak, so be sure to check out the Odyssey credits as well!", preferredStyle: .alert)
        
        let twitterAction = UIAlertAction(title: "Follow", style: .default, handler: { _ in
            let normalURL = URL(string: "https://twitter.com/JustinAlexP")
            let twitterURL = URL(string: "twitter://user?screen_name=JustinAlexP")
            
            if UIApplication.shared.canOpenURL(twitterURL!) {
                UIApplication.shared.open(twitterURL!, options:[:], completionHandler: nil)
            } else {
                UIApplication.shared.open(normalURL!, options:[:] , completionHandler: nil)
            }
        })
        let noThanks = UIAlertAction(title: "No Thanks", style: .default, handler: nil)
        
        alert.addAction(twitterAction)
        alert.addAction(noThanks)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController {
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func unbindKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc
    func keyboardWillChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let curFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let targetFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.view.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: duration, delay: 0.00, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

func isJailbroken() -> Bool {
    var flags = UInt32()
    let CS_OPS_STATUS = UInt32(0)
    csops(getpid(), CS_OPS_STATUS, &flags, 0)
    if flags & Consts.shared.CS_PLATFORM_BINARY != 0 {
        return true
    }
    
    let imageCount = _dyld_image_count()
    for i in 0..<imageCount {
        if let cName = _dyld_get_image_name(i) {
            let name = String(cString: cName)
            if name == "/usr/lib/pspawn_payload-stg2.dylib" {
                return true
            }
        }
    }
    return false
}

 
