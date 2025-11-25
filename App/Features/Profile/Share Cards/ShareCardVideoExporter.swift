import SwiftUI
import AVFoundation
import UIKit
import Combine

class ShareCardVideoExporter: ObservableObject {
    static let shared = ShareCardVideoExporter()
    
    @Published var isExporting = false
    @Published var progress: Double = 0
    
    private let width: CGFloat = 1080
    private let height: CGFloat = 1920
    private let fps: Int32 = 30
    private let duration: Double = 12.0 // 2 loops of 6s (3s move + 3s revert)
    
    func exportVideo(
        templateIndex: Int,
        customization: CardCustomization,
        userProfile: UserProfile?,
        selectedDrawing: Item?,
        showUsername: Bool,
        showPrompt: Bool,
        colors: [Color],
        completion: @escaping (URL?) -> Void
    ) {
        guard !isExporting else { return }
        isExporting = true
        progress = 0
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            completion(nil)
            return
        }
        
        let videoOutputURL = documentDirectory.appendingPathComponent("share_card_export.mov")
        
        if fileManager.fileExists(atPath: videoOutputURL.path) {
            try? fileManager.removeItem(at: videoOutputURL)
        }
        
        guard let videoWriter = try? AVAssetWriter(outputURL: videoOutputURL, fileType: .mov) else {
            print("Failed to create AVAssetWriter")
            completion(nil)
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriterInput.expectsMediaDataInRealTime = false
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        } else {
            completion(nil)
            return
        }
        
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        let totalFrames = Int(duration * Double(fps))
        var frameCount = 0
        
        let queue = DispatchQueue(label: "com.brush.videoexport")
        
        // We need to render on Main Actor, but write on background.
        // Since ImageRenderer is MainActor bound, we have to coordinate.
        
        Task { @MainActor in
            for i in 0..<totalFrames {
                let time = Double(i) / Double(fps)
                
                // Calculate animation progress (0.0 to 1.0)
                // Cycle: 0 -> 3s (0->1), 3s -> 6s (1->0)
                // Total loop 6s. We do 2 loops (12s).
                let loopTime = time.truncatingRemainder(dividingBy: 6.0)
                let rawProgress: Double
                if loopTime < 3.0 {
                    rawProgress = loopTime / 3.0
                } else {
                    rawProgress = 1.0 - ((loopTime - 3.0) / 3.0)
                }
                
                // Ease In Out Sine
                let easedProgress = 0.5 * (1 - cos(rawProgress * .pi))
                
                let frameView = VideoExportFrameView(
                    templateIndex: templateIndex,
                    customization: customization,
                    userProfile: userProfile,
                    selectedDrawing: selectedDrawing,
                    showUsername: showUsername,
                    showPrompt: showPrompt,
                    colors: colors,
                    animationProgress: easedProgress,
                    width: width,
                    height: height
                )
                
                let renderer = ImageRenderer(content: frameView)
                renderer.scale = 1.0 // We set explicit frame size
                
                if let uiImage = renderer.uiImage {
                    while !videoWriterInput.isReadyForMoreMediaData {
                        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                    }
                    
                    if let pixelBuffer = buffer(from: uiImage) {
                        let presentationTime = CMTime(value: CMTimeValue(i), timescale: fps)
                        pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    }
                }
                
                self.progress = Double(i) / Double(totalFrames)
                
                // Yield to keep UI responsive
                if i % 5 == 0 {
                    await Task.yield()
                }
            }
            
            videoWriterInput.markAsFinished()
            await videoWriter.finishWriting()
            
            self.isExporting = false
            self.progress = 1.0
            completion(videoOutputURL)
        }
    }
    
    private func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(width),
            Int(height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        context?.translateBy(x: 0, y: height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}

struct VideoExportFrameView: View {
    let templateIndex: Int
    let customization: CardCustomization
    let userProfile: UserProfile?
    let selectedDrawing: Item?
    let showUsername: Bool
    let showPrompt: Bool
    let colors: [Color]
    let animationProgress: Double
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: colors,
                startPoint: UnitPoint(x: 0, y: 1.0 - animationProgress),
                endPoint: UnitPoint(x: 1, y: animationProgress)
            )
            .ignoresSafeArea()
            
            // Card
            let cardHeight = height * 0.65 // Match preview scale roughly
            let cardWidth = cardHeight * (2/3)
            // For Template 5 (Showcase), it might be different ratio?
            // In ShareCardPreviewView:
            // if currentPage == 4 { finalCardHeight = fullScreenHeight * 0.9 ... }
            // Let's check logic.
            
            let isTemplate5 = templateIndex == 4
            let finalCardHeight = isTemplate5 ? height * 0.75 : height * 0.65
            let finalCardWidth = isTemplate5 ? finalCardHeight * (9.0/16.0) : finalCardHeight * (2.0/3.0)
            
            // We need to wrap the card view
            cardView
                .frame(width: finalCardWidth, height: finalCardHeight)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .frame(width: width, height: height)
        .background(Color.black) // Ensure no transparency
    }
    
    @ViewBuilder
    var cardView: some View {
        switch templateIndex {
        case 0:
            CardTemplateOneView(customization: .constant(customization), userProfile: userProfile)
        case 1:
            CardTemplateTwoView(customization: .constant(customization), userProfile: userProfile)
        case 2:
            CardTemplateThreeView(customization: .constant(customization), userProfile: userProfile)
        case 3:
            CardTemplateFourView(customization: .constant(customization), userProfile: userProfile)
        case 4:
            CardTemplateFiveView(
                customization: .constant(customization),
                selectedDrawing: .constant(selectedDrawing),
                showUsername: showUsername,
                showPrompt: showPrompt,
                userProfile: userProfile,
                onTapAddDrawing: {}
            )
        default:
            EmptyView()
        }
    }
}
