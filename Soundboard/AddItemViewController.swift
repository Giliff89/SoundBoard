//
//  AddItemViewController.swift
//  Soundboard
//
//  Created by gina iliff on 8/23/17.
//  Copyright © 2017 gina iliff. All rights reserved.
//

import UIKit
import AVFoundation

class AddItemViewController: UIViewController, UINavigationControllerDelegate {
    
    var previousVC = TableViewController()

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var soundNameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create Audio Session
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try? session.overrideOutputAudioPort(.speaker)
        try? session.setActive(true)
        
        // URL to save the audio
        
        if let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let pathComponents = [basePath, "audio.m4a"]
            if let audioURL = NSURL.fileURL(withPathComponents: pathComponents) {
                
                // Create some settings
                self.audioURL = audioURL
                
                var settings : [String : Any] = [:]
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
                settings[AVSampleRateKey] = 44100.0
                settings[AVNumberOfChannelsKey] = 2
        
                // Create the audio recorder
                audioRecorder = try? AVAudioRecorder(url: audioURL, settings: settings)
                audioRecorder?.prepareToRecord()
            }
        }
        
        playButton.isEnabled = false
        soundNameTextField.isEnabled = false
        addButton.isEnabled = false
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        
        if let audioRecorder = self.audioRecorder {
        
            if audioRecorder.isRecording {
                audioRecorder.stop()
                recordButton.setTitle("Record", for: .normal)
                playButton.isEnabled = true
                soundNameTextField.isEnabled = true
                addButton.isEnabled = true
            } else {
                audioRecorder.record()
                recordButton.setTitle("Stop", for: .normal)
                playButton.isEnabled = false
                soundNameTextField.isEnabled = false
                addButton.isEnabled = false
            }
        }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        
        if let audioURL = self.audioURL {
        
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.play()
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let sound = Sound(entity: Sound.entity(), insertInto: context)
            
            sound.name = soundNameTextField.text
            
            if let audioURL = self.audioURL {
                sound.audioData = try? Data(contentsOf: audioURL)
                try? context.save()
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

