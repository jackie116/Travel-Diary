//
//  LoginController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import GoogleSignIn
import FirebaseCore
import AVFoundation

class LoginController: UIViewController {
    
    let videoLayer = UIView()
    var videoLooper: AVPlayerLooper?
    var player: AVQueuePlayer?
    
    let titleView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "title")
        view.clipsToBounds = true
        return view
    }()
    
    lazy var signInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(pressSignIn), for: .touchUpInside)
        button.layer.cornerRadius = UIScreen.width * 0.3
        return button
    }()
    
    lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        return button
    }()
    
    let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIScreen.height * 0.01
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    lazy var licenseLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.isUserInteractionEnabled = true
        
        let stringValue = "By continuing, you agree to our Privacy Police and Apple EULA"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColor(color: UIColor.customBlue, forText: "Privacy Police")
        attributedString.setColor(color: UIColor.customBlue, forText: "EULA")
        label.attributedText = attributedString
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentingViewController?.viewWillDisappear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.viewWillAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        player = nil
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(videoLayer)
        playVideo()
        createGradientBackgroud()
        
        view.addSubview(titleView)
        buttonStackView.addArrangedSubview(signInButton)
        buttonStackView.addArrangedSubview(googleSignInButton)
        buttonStackView.addArrangedSubview(licenseLabel)
        view.addSubview(buttonStackView)
        configureConstraint()
    }
    
    func configureConstraint() {
        videoLayer.addConstraintsToFillView(view)
        
        titleView.centerX(inView: view)
        titleView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         paddingTop: UIScreen.height * 0.3,
                         width: UIScreen.width * 0.8, height: 100)
        
        signInButton.setDimensions(width: UIScreen.width * 0.7, height: 50)
        googleSignInButton.setDimensions(width: UIScreen.width * 0.7, height: 50)
        buttonStackView.centerX(inView: view)
        buttonStackView.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: UIScreen.height * 0.05)
    }
    
    func playVideo() {
        guard let path = Bundle.main.path(forResource: "intro", ofType: "mp4") else {
            return
        }
        player = AVQueuePlayer()
        let item = AVPlayerItem(url: URL(fileURLWithPath: path))
        videoLooper = AVPlayerLooper(player: player!, templateItem: item)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoLayer.layer.addSublayer(playerLayer)

        player?.play()
    }
    
    func createGradientBackgroud() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        ]
        videoLayer.layer.addSublayer(gradientLayer)
    }
    
    @objc func pressSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])

        controller.delegate = self
        controller.presentationContextProvider = self

        controller.performRequests()
    }
    
    @objc func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
            print("\(error)")
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

          firebaseSignIn(credential: credential)
        }
    }
    
    func firebaseSignIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { _, error in
            guard error == nil else {
                print("\(String(describing: error!.localizedDescription))")
                return
            }
            
            AuthManager.shared.getUserInfo { result in
                switch result {
                case .success:
                    break
                case .failure:
                    AuthManager.shared.initialUserInfo { result in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            print("\(error)")
                        }
                    }
                }
                self.dismiss(animated: true)
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

extension LoginController: ASAuthorizationControllerDelegate {
    /// 授權成功
    /// - Parameters:
    ///   - controller: _
    ///   - authorization: _
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
                
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")
            print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data\n\(appleIDToken.debugDescription)")
                return
            }
            // 產生 Apple ID 登入的 Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // 與 Firebase Auth 進行串接
            firebaseSignIn(credential: credential)
        }
    }
    
    /// 授權失敗
    /// - Parameters:
    ///   - controller: _
    ///   - error: _
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
                
        switch error {
        case ASAuthorizationError.canceled:
            break
        case ASAuthorizationError.failed:
            break
        case ASAuthorizationError.invalidResponse:
            break
        case ASAuthorizationError.notHandled:
            break
        case ASAuthorizationError.unknown:
            break
        default:
            break
        }
                    
        print("didCompleteWithError: \(error.localizedDescription)")
    }

    // MARK: - Target / IBAction
    @objc private func tapLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = licenseLabel.text else { return }
        let privacyRange = (text as NSString).range(of: "Privacy Police")
        let standardRange = (text as NSString).range(of: "EULA")
        
        var webVC: WebViewController

        if gesture.didTapAttributedTextInLabel(label: licenseLabel, inRange: privacyRange) {
            webVC = WebViewController(urlString: "https://www.privacypolicies.com/live/136dc899-901b-4179-9769-808b4b3ce703")
        } else if gesture.didTapAttributedTextInLabel(label: licenseLabel, inRange: standardRange) {
            webVC = WebViewController(urlString: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
        } else {
            return
        }
        self.present(webVC, animated: true, completion: nil)
    }
}

extension LoginController: ASAuthorizationControllerPresentationContextProviding {
    
    /// - Parameter controller: _
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
