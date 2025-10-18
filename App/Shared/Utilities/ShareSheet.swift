import SwiftUI
import LinkPresentation

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: UIActivityViewController.CompletionWithItemsHandler? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update here.
    }
}

class ImageActivityItemSource: NSObject, UIActivityItemSource {
    private let title: String
    private let image: UIImage
    
    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.iconProvider = NSItemProvider(object: image)
        return metadata
    }
}

class PrintActivity: UIActivity {
    var image: UIImage?

    override var activityTitle: String? { "Print" }
    override var activityImage: UIImage? { UIImage(systemName: "printer") }
    override var activityType: UIActivity.ActivityType? {
        UIActivity.ActivityType("com.yourapp.PrintActivity")
    }
    
    override class var activityCategory: UIActivity.Category { .action }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return activityItems.contains { $0 is UIImage }
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.image = activityItems.first(where: { $0 is UIImage }) as? UIImage
    }
    
    override func perform() {
        guard let image = image else {
            activityDidFinish(false)
            return
        }
        
        print("Printing image...")
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .general
        printInfo.jobName = "Drawing"
        printController.printInfo = printInfo
        printController.printingItem = image
        printController.present(animated: true) { _, completed, error in
            self.activityDidFinish(completed)
        }
    }
}
