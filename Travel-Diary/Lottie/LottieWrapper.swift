//
//  LottieWrapper.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/3.
//

import UIKit
import Lottie

class LottieAnimation {
    
    static let shared = LottieAnimation()
    
    func createLoopAnimation(lottieName: String) -> AnimationView {
        
        let lottieAnimation = AnimationView.init(name: lottieName)
        lottieAnimation.contentMode = .scaleAspectFit
        lottieAnimation.translatesAutoresizingMaskIntoConstraints = false
        lottieAnimation.loopMode = .loop
        lottieAnimation.play(completion: nil)
        
        return lottieAnimation
    }
    
    func createOneTimeAnimation(lottieName: String) -> AnimationView {
        let lottieAnimation = AnimationView.init(name: lottieName)
        lottieAnimation.contentMode = .scaleAspectFit
        lottieAnimation.translatesAutoresizingMaskIntoConstraints = false
        lottieAnimation.loopMode = .playOnce
        
        return lottieAnimation
    }
    
    func stopAnimation(lottieAnimation: AnimationView) {
        
        lottieAnimation.stop()
        lottieAnimation.alpha = 0
        lottieAnimation.isHidden = true
    }
}
