//
//  ViewController.swift
//  AvPlayerStereoAudio
//
//  Created by Dim San Cing on 5/24/22.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    private var playerLeft: AVPlayer!
    private var playerRight: AVPlayer!
    
    private var playerItem: AVPlayerItem!
    private var asset: AVAsset!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var leftAudio: UIButton!
    @IBOutlet weak var rightAudio: UIButton!
    
    var audios: [String] = []
    //let url = "https://bsrr00.s3.amazonaws.com/98iN.mp3"
    //let url = "http://192.168.102.110/qa_mc_hls/1/1/5/2_18865ad6ea782a0/hls/master.m3u8"
    let url = "http://192.168.102.110/qa_mc_hls/1/1/5/3_33493445e39597c/hls/master.m3u8" // the chain smoker
    //let url = "http://192.168.102.110/qa_mc_hls/1/1/4/6_fe585342dd70409/hls/master.m3u8" // Irene
    
    let tapInit: MTAudioProcessingTapInitCallback = {
        (tap, clientInfo, tapStorageOut) in
        
        // Make tap storage the same as clientInfo. I guess you might want them to be different.
        tapStorageOut.pointee = clientInfo
    }
    
    let tapProcess: MTAudioProcessingTapProcessCallback = {
        (tap, numberFrames, flags, bufferListInOut, numberFramesOut, flagsOut) in
        print("callback \((tap, numberFrames, flags, bufferListInOut, numberFramesOut, flagsOut))\n")
        
        let status = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut, flagsOut, nil, numberFramesOut)
        print(" status >>>", status)
        if noErr != status {
            print("get audio: \(status)\n")
        }
        
        
        print(" buffer >>>", bufferListInOut)
        
        
        let cookie = Unmanaged<TapCookie>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).takeUnretainedValue()
        guard let cookieContent = cookie.content else {
            print("Tap callback: cookie content was deallocated!")
            return
        }
        print(" buffer 0 >>>", cookieContent)
        print(" buffer 1 >>>", cookieContent.buffers)
        
//                let appDelegateSelf = cookieContent as! AppDelegate
//                print("cookie content \(appDelegateSelf)")
    }
    
    let tapFinalize: MTAudioProcessingTapFinalizeCallback = {
        (tap) in
        print("finalize \(tap)\n")
        
        // release cookie
        Unmanaged<TapCookie>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).release()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerLeft = setupPlayer(with: url)
        playerRight = setupPlayer(with: url)
        //self.selectedAudio(selectedAudio: true)
    }
    
    
    func selectedAudio(selectedAudio: Bool) {
        if playerLeft != nil {
            let secondTrack = playerLeft.currentItem?.tracks.last
            let audioTrack = playerItem.asset.tracks(withMediaType: AVMediaType.audio).last
            
            print(" track >>>", secondTrack)
            print(" track >>>", audioTrack)
            
//            guard let secondTrack2 = playerLeft.currentItem?.asset.tracks(withMediaType: .audio).last else {
//                print(" is mono")
//                return
//            }
            
            let cookie = TapCookie(content: self)
            
//            var callbacks = MTAudioProcessingTapCallbacks(
//                version: kMTAudioProcessingTapCallbacksVersion_0,
//                clientInfo: UnsafeMutableRawPointer(Unmanaged.passRetained(cookie).toOpaque()),
//                init: tapInit,
//                finalize: tapFinalize,
//                prepare: nil,
//                unprepare: nil,
//                process: tapProcess)
            var callbacks = MTAudioProcessingTapCallbacks(version: kMTAudioProcessingTapCallbacksVersion_0, clientInfo: nil)
                    { tap, _, tapStorageOut in
                        // initialize
                    } finalize: { tap in
                        // clean up
                    } prepare: { tap, maxFrames, processingFormat in
                        // allocate memory for sound processing
                    } unprepare: { tap in
                        // deallocate memory for sound processing
                    } process: { tap, numberFrames, flags, bufferListInOut, numberFramesOut, flagsOut in
                        guard noErr == MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut, flagsOut, nil, numberFramesOut) else {
                            return
                        }

                        // retrieve AudioBuffer using UnsafeMutableAudioBufferListPointer
                        for buffer in UnsafeMutableAudioBufferListPointer(bufferListInOut) {
                            print(" Buffer >>>", buffer)
                            // process audio samples here
                            //memset(buffer.mData, 0, Int(buffer.mDataByteSize))
                        }
                    }
            
            print(" callbacks mine >>>>", callbacks)
            var tap: Unmanaged<MTAudioProcessingTap>?
            let err = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &tap)
            assert(noErr == err);
            
            
            //print(" track >>>>", secondTrack2)
            let inputParams = AVMutableAudioMixInputParameters(track: secondTrack?.assetTrack)
            
            inputParams.audioTapProcessor = tap?.takeRetainedValue()
            tap?.release()
            
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = [inputParams]
            print( " inpur Param >>>", inputParams)
            //playerItem.audioMix = audioMix
            playerLeft.currentItem?.audioMix = audioMix
            
        }
    }
    
    @IBAction func btnPlay(_ sender: Any) {
        playerLeft.play()
        //playerRight.play()
        print( "is playing left >>>", playerLeft.rate)
        print( "is playing right >>>", playerRight.rate)
    }
    
    @IBAction func btnPreparePlayer(_ sender: Any) {
        self.selectedAudio(selectedAudio: true)
    }
    
    @IBAction func btnStop(_ sender: Any) {
        playerLeft.pause()
       // playerRight.pause()
        print( "is playing left >>>", playerLeft.rate)
        print( "is playing right >>>", playerRight.rate)
    }
    @IBAction func btnLeft(_ sender: Any) {
        
       // playerLeft.pause()
       // playerRight.play()
        // playerRight.isMuted = true
        //playerLeft.isMuted = false
        playerLeft.volume = 0.0
       // playerRight.volume = 0.8
        print(" after tap >>>>",  playerLeft.currentItem?.audioMix?.inputParameters.last)
        
        print( "is playing left >>>", playerLeft.rate)
        print( "is playing right >>>", playerRight.rate)
        
        print( "is playing left  mute >>>", playerLeft.volume)
        print( "is playing right mute >>>", playerRight.volume)
        
    }
    
    @IBAction func btnRight(_ sender: Any) {
       
        playerRight.pause()
        playerLeft.play()
        //  playerLeft.isMuted = true
        //  playerRight.isMuted = false
        
        playerRight.volume = 0.0
        playerLeft.volume = 0.8
        print( "is playing left >>>", playerLeft.rate)
        print( "is playing right >>>", playerRight.rate)
        
        print( "is playing left  mute >>>", playerLeft.volume)
        print( "is playing right mute >>>", playerRight.volume)
        
    }
    
    class TapCookie {
        weak var content: AnyObject?
        
        init(content: AnyObject) {
            self.content = content
        }
        
        deinit {
            print("TapCookie deinit")    // should appear after finalize
        }
    }
    
    
    func setupPlayer(with url: String) -> AVPlayer {
        
        let videoURL = URL(string: url)
        if (videoURL != nil) {
            asset = AVAsset(url: videoURL!)
            playerItem = AVPlayerItem(asset: asset)
        }
        
        return AVPlayer(playerItem: playerItem)
    }
    
}

