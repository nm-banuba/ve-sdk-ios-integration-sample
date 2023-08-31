
import UIKit
import BanubaVideoEditorSDK

import VideoEditor
import AVFoundation
import AVKit
import Photos
import BSImagePicker
import VEExportSDK
import BanubaAudioBrowserSDK

// Adopting CountdownView to using in BanubaVideoEditorSDK
extension CountdownView: MusicEditorCountdownAnimatableView {}

class VideoEditorModule {
    
    var videoEditorSDK: BanubaVideoEditor?
    
    var isVideoEditorInitialized: Bool { videoEditorSDK != nil }
    
    init(token: String) {
        let config = createConfiguration()
        let externalViewControllerFactory = createExampleExternalViewControllerFactory()
        
        let videoEditorSDK = BanubaVideoEditor(
            token: token,
            configuration: config,
            externalViewControllerFactory: externalViewControllerFactory
        )
        
        self.videoEditorSDK = videoEditorSDK
    }
    
    func presentVideoEditor(with launchConfig: VideoEditorLaunchConfig) {
        guard isVideoEditorInitialized else {
            print("BanubaVideoEditor is not initialized!")
            return
        }
        videoEditorSDK?.presentVideoEditor(
            withLaunchConfiguration: launchConfig,
            completion: nil
        )
    }
    
    func createExportConfiguration(destFile: URL) -> ExportConfiguration {
        let watermarkConfiguration = WatermarkConfiguration(
          watermark: ImageConfiguration(imageName: "Common.Banuba.Watermark"),
          size: CGSize(width: 204, height: 52),
          sharedOffset: 20,
          position: .rightBottom)
        
        let exportConfiguration = ExportVideoConfiguration(
          fileURL: destFile,
          quality: .auto,
          useHEVCCodecIfPossible: true,
          watermarkConfiguration: watermarkConfiguration
        )
        
        let exportConfig = ExportConfiguration(
          videoConfigurations: [exportConfiguration],
          isCoverEnabled: true,
          gifSettings: GifSettings(duration: 0.3)
        )
        
        return exportConfig
    }
    
    func createProgressViewController() -> ProgressViewController {
      let progressViewController = ProgressViewController.makeViewController()
      progressViewController.message = "Exporting"
      return progressViewController
    }
    
    func createConfiguration() -> VideoEditorConfig {
        var config = VideoEditorConfig()
        
        let pink = UIColor(red: 250 / 255, green: 62 / 255, blue: 118 / 255, alpha: 1)
        let skyBlue = UIColor(red: 0.2350233793, green: 0.7372031212, blue: 0.7565478683, alpha: 1)
        config.setupColorsPalette(
            VideoEditorColorsPalette(
                primaryColor: .white,
                secondaryColor: .black,
                accentColor: .white,
                effectButtonColorsPalette: EffectButtonColorsPalette(
                    defaultIconColor: .white,
                    defaultBackgroundColor: .clear,
                    selectedIconColor: .black,
                    selectedBackgroundColor: .white
                ),
                addGalleryItemBackgroundColor: .white,
                addGalleryItemIconColor: .black,
                timelineEffectColorsPalette: TimelineEffectColorsPalette.default
            )
        )
        
        // Set Mubert API KEYS here
        BanubaAudioBrowser.setMubertKeys(
            license: "SET MUBERT API LICENSE",
            token: "SET MUBERT API TOKEN"
        )
        AudioBrowserConfig.shared.musicSource = .allSources
        AudioBrowserConfig.shared.setPrimaryColor(#colorLiteral(red: 0.2350233793, green: 0.7372031212, blue: 0.7565478683, alpha: 1))
        
        var featureConfiguration = config.featureConfiguration
        featureConfiguration.supportsTrimRecordedVideo = true
        featureConfiguration.isMuteCameraAudioEnabled = true
        config.updateFeatureConfiguration(featureConfiguration: featureConfiguration)
        
        config.musicEditorConfiguration.audioTrackLineEditControllerConfig.voiceFilterProvider = ExampleVoiceFilterProvider()
        
        return config
    }
    
    // MARK: - Example view controller factory customization
    func createExampleExternalViewControllerFactory() -> ExternalViewControllerFactory {
        return ExampleViewControllerFactory()
    }
    
    /// Example video editor view controller factory stores custom view factories used for customization BanubaVideoEditor
    class ExampleViewControllerFactory: ExternalViewControllerFactory {
        var musicEditorFactory: MusicEditorExternalViewControllerFactory?
        var countdownTimerViewFactory: CountdownTimerViewFactory?
        var exposureViewFactory: AnimatableViewFactory?
        
        init() {
            countdownTimerViewFactory = CountdownTimerViewControllerFactory()
            exposureViewFactory = DefaultExposureViewFactory()
        }
        
        /// Example countdown timer view factory for Recorder countdown animation
        class CountdownTimerViewControllerFactory: CountdownTimerViewFactory {
            func makeCountdownTimerView() -> CountdownTimerAnimatableView {
                let countdownView = CountdownView()
                countdownView.frame = UIScreen.main.bounds
                countdownView.font = countdownView.font.withSize(102.0)
                countdownView.digitColor = .white
                return countdownView
            }
        }
    }
}

/// Example voice filter provider
struct ExampleVoiceFilterProvider: VoiceFilterProvider {
  private let filters: [VoiceFilter]
  
  // MARK: - VoiceFilterProvider
  
  func provideFilters() -> [VoiceFilter] {
    return filters
  }
  
  init() {
    filters = [
      VoiceFilter(
        type: .elf,
        title: NSLocalizedString("com.banuba.musicEditor.elf", comment: "Elf filter title"),
        image: UIImage(named:"elf")
      ),
      VoiceFilter(
        type: .baritone,
        title: NSLocalizedString("com.banuba.musicEditor.baritone", comment: "Baritone filter title"),
        image: UIImage(named:"baritone")
      ),
      VoiceFilter(
        type: .echo,
        title: NSLocalizedString("com.banuba.musicEditor.echo", comment: "Echo filter title"),
        image: UIImage(named:"echo")
      ),
      VoiceFilter(
        type: .giant,
        title: NSLocalizedString("com.banuba.musicEditor.giant", comment: "Giant filter title"),
        image: UIImage(named:"giant")
      ),
      VoiceFilter(
        type: .robot,
        title: NSLocalizedString("com.banuba.musicEditor.robot", comment: "Robot filter title"),
        image: UIImage(named:"robot")
      ),
      VoiceFilter(
        type: .squirrel,
        title: NSLocalizedString("com.banuba.musicEditor.squirrel", comment: "Squirrel filter title"),
        image: UIImage(named:"squirrel")
      )
    ]
  }
}
