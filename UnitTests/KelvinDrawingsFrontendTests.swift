import XCTest
import SwiftUI
@testable import brush

final class DrawingsFrontendTests: XCTestCase {

    // MARK: - Test 1: DrawingView Theme Logic
    // This tests the CanvasTheme enum logic used by the frontend to switch backgrounds.
    // It ensures that the Identifiable conformance works correctly for UI iteration.
    func testDrawingViewThemeIdentity() {
        // Given
        let colorTheme = DrawingView.CanvasTheme.color(.red)
        let textureTheme = DrawingView.CanvasTheme.texture("notebook")
        
        // When
        let colorId = colorTheme.id
        let textureId = textureTheme.id
        
        // Then
        // Verify IDs are generated consistently for the UI to use in ForEach loops
        XCTAssertTrue(colorId.starts(with: "color-"), "Color theme ID should start with 'color-'")
        XCTAssertTrue(textureId.starts(with: "texture-"), "Texture theme ID should start with 'texture-'")
        
        // Verify equality logic for state updates
        XCTAssertEqual(colorTheme, DrawingView.CanvasTheme.color(.red), "Same colors should be equal themes")
        XCTAssertNotEqual(colorTheme, DrawingView.CanvasTheme.color(.blue), "Different colors should be different themes")
    }

    // MARK: - Test 2: Streak Manager (Local Frontend State)
    // This tests the pure frontend logic of calculating streaks using UserDefaults.
    // It ensures the UI displays the correct streak count without needing a server.
    func testStreakManagerLocalUpdate() {
        // Given
        var streakManager = StreakManager()
        
        // Clear defaults for test isolation to ensure a clean state
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // When
        // Simulate marking a drawing as complete today
        streakManager.markCompletedToday()
        
        // Then
        // The streak should increment to 1 if it was 0
        XCTAssertEqual(streakManager.currentStreak, 1, "Streak should be 1 after first completion")
        
        // When
        // Simulate marking it again on the same day (should not double count)
        streakManager.markCompletedToday()
        
        // Then
        XCTAssertEqual(streakManager.currentStreak, 1, "Streak should remain 1 if completed twice on same day")
    }

    // MARK: - Test 3: DrawingPreviewView Initialization
    // This tests that the Preview View can be initialized with valid data binding.
    // It ensures the view hierarchy can be constructed without crashing given a standard Item.
    func testDrawingPreviewViewInitialization() {
        // Given
        // Create a dummy item mimicking your data model
        let dummyItem = Item(
            imageFileName: "test_uuid.jpg",
            prompt: "Test Prompt",
            date: Date(),
            image: UIImage(systemName: "star") // Using a system image for testing
        )
        
        // Create a binding to pass into the view
        let selectedItemBinding = Binding<Item?>(
            get: { dummyItem },
            set: { _ in }
        )
        
        // When
        // Initialize the view
        let view = DrawingPreviewView(
            namespace: Namespace().wrappedValue,
            item: dummyItem,
            selectedItem: selectedItemBinding
        )
        
        // Then
        // We assert the view body is not nil, implying successful UI construction
        XCTAssertNotNil(view.body, "DrawingPreviewView body should not be nil")
    }
}
