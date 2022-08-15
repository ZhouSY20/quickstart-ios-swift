import UIKit
import BanubaSdk

class CameraViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var getVideoButton: UIButton!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video)
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sdkManager.input.startCamera()
        _ = sdkManager.loadEffect("TrollGrandma", synchronous: true)
        sdkManager.startEffectPlayer()
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
    
    
    @IBAction func getPhotoButtonPushed(_ sender: UIButton) {
        guard isRecording == false else {return}
        
        let settings = CameraPhotoSettings(useStabilization: true, flashMode: AVCaptureDevice.FlashMode.off )
        sdkManager.makeCameraPhoto(cameraSettings: settings, flipFrontCamera: true, srcImageHandler: nil) { (img) in
            if (img != nil) {
                guard var safeImg = img else {return}
                UIImageWriteToSavedPhotosAlbum(safeImg, nil, nil, nil)
            }
        }
    }
    
    
    @IBAction func getVideoButtonPushed(_ sender: UIButton) {
        self.isRecording = !self.isRecording
                recordVideo(self.isRecording)
                
                self.getVideoButton.setTitle(self.isRecording ? "stopRecording" : "getVideo", for: .normal)
    }
    
    private func saveVideoToGallery(fileURL: String) {
           if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileURL) {
               UISaveVideoAtPathToSavedPhotosAlbum(fileURL, nil, nil, nil)
           }
       }
       
       func recordVideo(_ shouldRecord: Bool){
           let hasSpace =  sdkManager.output?.hasDiskCapacityForRecording() ?? true
           if shouldRecord && hasSpace {
               let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("video.mp4")
               sdkManager.input.startAudioCapturing()
               sdkManager.output?.startVideoCapturing(fileURL:fileURL) { (success, error) in
                   print("Done Writing: \(success)")
                   if let _error = error {
                       print(_error)
                   }
                   self.sdkManager.input.stopAudioCapturing()
                   self.saveVideoToGallery(fileURL: fileURL.relativePath)
               }
           } else {
               sdkManager.output?.stopVideoCapturing(cancel: false)
           }
       }
}
