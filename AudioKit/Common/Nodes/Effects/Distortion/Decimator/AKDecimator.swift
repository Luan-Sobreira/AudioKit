//
//  AKDecimator.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's Decimator from the Distortion Audio Unit
///
/// - parameter input: Input node to process
/// - parameter decimation: Decimation (Percent) ranges from 0 to 100 (Default: 50)
/// - parameter rounding: Rounding (Percent) ranges from 0 to 100 (Default: 0)
/// - parameter mix: Mix (Percent) ranges from 0 to 100 (Default: 100)
///
public class AKDecimator: AKNode, AKToggleable {

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_Distortion,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU = AudioUnit()

    /// Required property for AKNode containing the output node
    public var avAudioNode: AVAudioNode

    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    /// Decimation (Percent) ranges from 0 to 100 (Default: 50)
    public var decimation: Double = 50 {
        didSet {
            if decimation < 0 {
                decimation = 0
            }            
            if decimation > 100 {
                decimation = 100
            }
            AudioUnitSetParameter(
                internalAU,
                kDistortionParam_Decimation,
                kAudioUnitScope_Global, 0,
                Float(decimation), 0)
        }
    }

    /// Rounding (Percent) ranges from 0 to 100 (Default: 0)
    public var rounding: Double = 0 {
        didSet {
            if rounding < 0 {
                rounding = 0
            }            
            if rounding > 100 {
                rounding = 100
            }
            AudioUnitSetParameter(
                internalAU,
                kDistortionParam_Rounding,
                kAudioUnitScope_Global, 0,
                Float(rounding), 0)
        }
    }
    
    /// Mix (Percent) ranges from 0 to 100 (Default: 100)
    public var mix: Double = 100 {
        didSet {
            if mix < 0 {
                mix = 0
            }
            if mix > 100 {
                mix = 100
            }
            AudioUnitSetParameter(
                internalAU,
                kDistortionParam_FinalMix,
                kAudioUnitScope_Global, 0,
                Float(mix), 0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the decimator node
    ///
    /// - parameter input: Input node to process
    /// - parameter decimation: Decimation (Percent) ranges from 0 to 100 (Default: 50)
    /// - parameter rounding: Rounding (Percent) ranges from 0 to 100 (Default: 0)
    /// - parameter mix: Mix (Percent) ranges from 0 to 100 (Default: 100)
    ///
    public init(
        var _ input: AKNode,
        decimation: Double = 50,
        rounding: Double = 0,
        mix: Double = 100) {
            
            self.decimation = decimation
            self.rounding = rounding
            self.mix = mix
            
            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            self.avAudioNode = internalEffect
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            internalAU = internalEffect.audioUnit
            
            // Since this is the Decimator, mix it to 100% and use the final mix as the mix parameter
            AudioUnitSetParameter(internalAU, kDistortionParam_DecimationMix, kAudioUnitScope_Global, 0, 100, 0)
            
            AudioUnitSetParameter(internalAU, kDistortionParam_Decimation, kAudioUnitScope_Global, 0, Float(decimation), 0)
            AudioUnitSetParameter(internalAU, kDistortionParam_Rounding, kAudioUnitScope_Global, 0, Float(rounding), 0)
            AudioUnitSetParameter(internalAU, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, Float(mix), 0)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            mix = 100
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            mix = 0
            isStarted = false
        }
    }
}
