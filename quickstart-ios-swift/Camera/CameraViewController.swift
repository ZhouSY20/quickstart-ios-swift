import UIKit
import AVFoundation
import VideoToolbox
import BanubaSdk
import BanubaEffectPlayer

class CameraViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video)
    private var effectPlayer : BNBOffscreenEffectPlayer?
    
    private let renderWidth: UInt = 1280
    private let renderHeight: UInt = 720
    private var afro: Bool = false
    private var counter: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sdkManager.input.startCamera()
        _ = sdkManager.loadEffect("test_BG", synchronous: true)
        sdkManager.startEffectPlayer()
        
        initBNBOffscreenEffectPlayer(width: renderWidth, height: renderHeight, manualAudio: false)
        effectPlayer?.loadEffect("Makeup")

        sdkManager.output?.startForwardingFrames(handler: { (pixelBuffer) -> Void in
            self.processFrame(pixelBuffer: pixelBuffer)
        })
    }
    
    deinit {
        sdkManager.destroyEffectPlayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        sdkManager.stopEffectPlayer()
        sdkManager.removeRenderTarget()
        coordinator.animateAlongsideTransition(in: effectView, animation: { (UIViewControllerTransitionCoordinatorContext) in
            self.sdkManager.autoRotationEnabled = true
            self.setUpRenderSize()
        }, completion: nil)
    }
    
    private func setUpRenderTarget() {
        sdkManager.setRenderTarget(view: effectView, playerConfiguration: nil)
        sdkManager.startEffectPlayer()
    }
    
    private func setUpRenderSize() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            config.orientation = .deg90
            config.renderSize = CGSize(width: 720, height: 1280)
            sdkManager.autoRotationEnabled = false
            setUpRenderTarget()
        case .portraitUpsideDown:
            config.orientation = .deg270
            config.renderSize = CGSize(width: 720, height: 1280)
            setUpRenderTarget()
        case .landscapeLeft:
            config.orientation = .deg180
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        case .landscapeRight:
            config.orientation = .deg0
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        default:
            setUpRenderTarget()
        }
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func initBNBOffscreenEffectPlayer(width: UInt, height: UInt, manualAudio: Bool) {
        /**
         * This way of configuration of OEP is useful then you want to register Listeners for EP
         */
        let config = BNBEffectPlayerConfiguration.init(fxWidth: Int32(width), fxHeight: Int32(height), nnEnable: .automatically , faceSearch: .good, jsDebuggerEnable: false, manualAudio: manualAudio)
        let ep = BNBEffectPlayer.create(config)

        // Please note that calls like surfaceChanged should be performed via OEP instance
        effectPlayer = BNBOffscreenEffectPlayer.init(effectPlayer: ep!, offscreenWidth: width, offscreenHight: height)

        /** Use this approach of OEP initialization if you care only about image processing with effect application
         *   effectPlayer = BNBOffscreenEffectPlayer.init(
         *       effectWidth: width,
         *       andHeight: height,
         *       manualAudio: manualAudio
         *   )
         */
    }
    
    private func processFrame(pixelBuffer: CVPixelBuffer){
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        
        counter += 1
        if (counter == 30){
            effectPlayer?.unloadEffect();
            effectPlayer?.loadEffect(afro ? "Makeup" : "Afro")
            afro = !afro
            counter = 0
            
            if (!afro) {
                effectPlayer?.evalJs("Makeup.contour('0.3 0.1 0.1 0.2')", resultCallback: nil)
                effectPlayer?.evalJs("Teeth.whitening(1)", resultCallback: nil)
                effectPlayer?.evalJs("Makeup.highlighter('0.75 0.74 0.74 0.4')", resultCallback: nil)
                effectPlayer?.evalJs("Skin.color('0.73 0.39 0.08 0.3')", resultCallback: nil)
                effectPlayer?.evalJs("Skin.softening(1)", resultCallback: nil)
                effectPlayer?.evalJs("Softlight.strength(1)", resultCallback: nil)
                effectPlayer?.evalJs("FaceMorph.eyes(0.6)", resultCallback: nil)
                effectPlayer?.evalJs("FaceMorph.face(0.5)", resultCallback: nil)
                effectPlayer?.evalJs("FaceMorph.nose(1)", resultCallback: nil)
                effectPlayer?.evalJs("FaceMorph.lips(1)", resultCallback: nil)

//                effectPlayer?.evalJs("Eyes.color('0.0 0.0 1.0 1.0')", resultCallback: nil)
//                effectPlayer?.evalJs("Teeth.whitening(0.1)", resultCallback: nil)
//                effectPlayer?.evalJs("Makeup.clear()", resultCallback: nil)
            }
        }
        
        var format = EpImageFormat(
            imageSize: CGSize(width: 720, height: 1280),
            orientation: .angles270,
            resultedImageOrientation: .angles270, // See paintPixelBuffer for details about image's orientation passed to view
            isMirrored: true,
            needAlphaInOutput: false,
            overrideOutputToBGRA: false,
            outputTexture: false
        )
        
        effectPlayer?.processImage(pixelBuffer, with: &format, frameTimestamp: NSNumber(value: Date().timeIntervalSince1970), completion: {(resPixelBuffer, timestamp) in
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            self.paintPixelBuffer(resPixelBuffer)
        })
        
    }
    
    func paintPixelBuffer(_ pixelBuffer: CVPixelBuffer?) {
        if let resultPixelBuffer = pixelBuffer {
            var cgImage: CGImage?

            VTCreateCGImageFromCVPixelBuffer(resultPixelBuffer, options: nil, imageOut: &cgImage)

            guard let cgImageSafe = cgImage else { return }

            let image = UIImage(cgImage: cgImageSafe, scale: 1.0, orientation: .left)
            
            DispatchQueue.main.async {

            }
        }
    }
}
