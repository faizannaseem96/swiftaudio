//
//  ViewController.swift
//  TestAudio
//
//  Created by Faizan Naseem on 22/01/2019.
//  Copyright © 2019 Faizan Naseem. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {

    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var totalDurationLbl: UILabel!
    
    var ihakPlayer: iHAKAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://cloud59-recording.s3.ap-southeast-1.amazonaws.com/media/1543847296Earl_IBM_P1_Test.mp3") else {
            print("Invalid URL")
            return
        }
        
        playBtn.isEnabled = false
        
        ihakPlayer = iHAKAudioPlayer(url: url)
        ihakPlayer?.onStatusReadyToPlay { (player, item) in
            print("Item ready to play")
            self.playBtn.isEnabled = true
            
            guard let currentItem = item else { return }
            self.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self.timeSlider.minimumValue = 0
            self.currentTimeLbl.text = self.getTimeString(from: currentItem.currentTime())
            self.totalDurationLbl.text = self.getTimeString(from: CMTimeMake(value: Int64(currentItem.duration.seconds * 1000.0), timescale: 1000))
        }
        
        ihakPlayer?.onProgress { (player, item) in
            guard let currentItem = item else { return }
            self.timeSlider.value = Float(currentItem.currentTime().seconds)
            self.currentTimeLbl.text = self.getTimeString(from: currentItem.currentTime())
        }
        
        ihakPlayer?.enableCommandMediaCenter(withArtist: "Artist Name", track: "Audio Track", artwork: UIImage(named: "lockscreen"))
        ihakPlayer?.setup()
        
        ihakPlayer?.onInterruption(block: { (player, item) in
            print("Interruption began")
        })
        
        ihakPlayer?.onInterruptionResume(block: { (player, item, shouldResume) in
            let resume = shouldResume ? "": "not "
            print("Interruptin ended. Should \(resume)resume")
            
            if shouldResume {
                self.ihakPlayer?.playpause()
            }
        })
    }

    @IBAction func playTapped(_ sender: Any) {
        ihakPlayer?.playpause()
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        ihakPlayer?.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return "illegal value" // or do some error handling
        }
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
}

