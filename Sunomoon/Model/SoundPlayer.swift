//
//  SoundPlayer.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/22/21.
//

import Foundation
import AVFoundation

class SoundPlayer {
    var player: AVAudioPlayer!
    func playSound(selectedSound: String){
        // play alarm sound
        let alarmSound = Bundle.main.url(forResource: selectedSound, withExtension: "mp3")
        // to make sound even though user mute
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            
            
            try AVAudioSession.sharedInstance().setActive(true)
            player = try! AVAudioPlayer(contentsOf: alarmSound!)
            player.play()
            } catch {
              print(error)
            }
    }
    
    func stopSound() {
        player.stop()
    }
}
