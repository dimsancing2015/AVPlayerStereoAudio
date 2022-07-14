//
//  AVPlayerItem.swift
//  AvPlayerStereoAudio
//
//  Created by Dim San Cing on 5/24/22.
//

import AVFoundation

extension AVPlayerItem {
    
    enum TrackType {
        case subtitle
        case audio
        
        /**
         Return valid AVMediaSelectionGroup is item is available.
         */
        fileprivate func characteristic(item:AVPlayerItem) -> AVMediaSelectionGroup?  {
            let str = self == .subtitle ? AVMediaCharacteristic.legible : AVMediaCharacteristic.audible
            if item.asset.availableMediaCharacteristicsWithMediaSelectionOptions.contains(str) {
                return item.asset.mediaSelectionGroup(forMediaCharacteristic: str)
            }
            return nil
        }
    }
    
    func tracks(type:TrackType) -> [String] {
        if let characteristic = type.characteristic(item: self) {
            return characteristic.options.map { $0.displayName }
        }
       
        return [String]()
    }
    
    func selected(type:TrackType) -> String? {
        guard let group = type.characteristic(item: self) else {
            return nil
        }
        let selected = self.selectedMediaOption(in: group)
        print("selected track >>>", selected)
        print("selected track mediaSubType description >>>", selected?.mediaSubTypes)
        print("selected track mediaType>>>", selected?.mediaType)
        print("selected track propertyList >>>", selected?.propertyList())
        let title = selected?.value(forKey: "title")
        return title as? String
        
    }
    
    func select(type:TrackType, name:String) -> Bool {
        guard let group = type.characteristic(item: self) else {
            return false
        }
        guard let matched = group.options.filter({ $0.displayName == name }).first else {
            return false
        }
        print(" matched >>>", matched)
        self.select(matched, in: group)
        return true
    }
}

