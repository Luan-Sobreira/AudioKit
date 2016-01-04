//
//  AKSawtoothOscillator.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Bandlimited sawtooth oscillator This is a bandlimited sawtooth oscillator
/// ported from the "sawtooth" function from the Faust programming language.
///
/// - parameter frequency: In cycles per second, or Hz.
/// - parameter amplitude: Output Amplitude.
///
public class AKSawtoothOscillator: AKNode, AKToggleable {

    // MARK: - Properties

    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()

    internal var internalAU: AKSawtoothOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?

    /// In cycles per second, or Hz.
    public var frequency: Double = 440 {
        didSet {
            frequencyParameter?.setValue(Float(frequency), originator: token!)
        }
    }
    /// Output Amplitude.
    public var amplitude: Double = 0.5 {
        didSet {
            amplitudeParameter?.setValue(Float(amplitude), originator: token!)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    // MARK: - Initialization

    /// Initialize this sawtooth node
    ///
    /// - parameter frequency: In cycles per second, or Hz.
    /// - parameter amplitude: Output Amplitude.
    ///
    public init(
        frequency: Double = 440,
        amplitude: Double = 0.5) {

        self.frequency = frequency
        self.amplitude = amplitude

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x7361776f /*'sawo'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKSawtoothOscillatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKSawtoothOscillator",
            version: UInt32.max)

        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKSawtoothOscillatorAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree.valueForKey("frequency") as? AUParameter
        amplitudeParameter = tree.valueForKey("amplitude") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        }
        frequencyParameter?.setValue(Float(frequency), originator: token!)
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public func copy() -> AKSawtoothOscillator {
        let copy = AKSawtoothOscillator(frequency: self.frequency, amplitude: self.amplitude)
        return copy
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
