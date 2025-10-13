# Feed Layout and Animation Research — Sprint 2  

## Title or Name of Research  
**Design and Animation Flow for Instagram-Style Feed (Blur, Medal, Prompt Bar, Canvas Dimensions)**  

---

## Why I Am Doing It  
To study how popular apps like **Instagram**, **TikTok**, and **Planoly** design their feed layout, grid planning, and motion behavior so that our *Brush* feed page feels modern, responsive, and visually cohesive and may be implement some of that features to our brush app.
This research helps us avoid inefficient or laggy UI decisions before coding `FeedView` and related SwiftUI components.  

---

## What I Expect to Learn / Do  
- Understand layout patterns from top visual-feed apps (**Later**, **Planoly**, **Plann**, **Preview**) — how they handle post spacing, grid flow, and blur overlays.  
- Identify best-practice transitions for scroll, blur, and content-unlock animations.  
- Determine performance guidelines (image scaling, caching, prefetching) for smooth scrolling similar to Instagram Reels.  
- Decide which logic should live in `FeedViewModel` vs. UI-only SwiftUI modifiers.  

---

## Code / Modules Affected  
- `FeedView` – core scrolling + layout  
- `PostCardView` – canvas sizing, blur overlay, medal placement  
- `MedalBadgeView` – new SwiftUI view for top-right badges  
- `PromptBarView` – new fixed-top element for static prompts  
- `FeedViewModel` – state handling for active index, prefetching, and blur toggles  

---

## What I Expect to Do With It (Deliverables)  
- Create a and wireframe referencing **Instagram’s home feed** — one post per screen, medal in top-right, blur for locked posts, and a fixed prompt bar at top.  
- Implement an early prototype with:  
  - `struct MedalBadgeView: View` – displays medal icon  
  - `struct BlurOverlayModifier: ViewModifier` – applies dynamic blur  
  - `struct PromptBarView: View` – pinned bar with prompt text  
- Evaluate animation feasibility:  
  - **Blur transition:** `.transition(.opacity.combined(with: .scale))` wrapped in `withAnimation(.easeInOut(duration: 0.2))`  
  - **Vertical reel swiping:** `TabView(.verticalPage)` (iOS 17+) or `DragGesture` + index math  
- Record animation FPS (target = 60 fps) and memory usage in Instruments.  
- Final output: annotated PNG wireframe stored under `research/wireframes/feed-layout.png`.  

---

## Dependencies / Shared Components  
- `FeedView` composes `PostCardView`, `MedalBadgeView`, and `PromptBarView`.  
- `FeedViewModel` tracks post visibility and current index.  
- Assets for medals and blurred placeholders.  

---

## What Task(s) in Jira Represent the Work Dependent on This Research  

- **KAN-97** – Implement fixed prompt container at top of feed.
- **KAN-93** – Apply blur modifier to post image, profile, and other UI elements.
- **KAN-96** – Implement uniform post layout and alignment for consistency.
- **KAN-95** – Verify blur consistency across platforms and devices.
- **KAN-94** – Create Boolean user setting (default = blur on).
- **KAN-92** – Decide which UI elements need blurring (feed posts, medals, etc.).

---

## Inspiration Reference  
Based on *Ruth Stephensen, “Top 5 Free Apps for Curating the Perfect Instagram Feed,”* Creatively Squared (May 27 2025).  

**Key takeaways from those apps:**  
- **Later / Planoly:** emphasize visual scheduling and cohesive grid preview.  
- **Plann:** best example of drag-and-drop + Canva integration → strong layout inspiration.  
- **Preview:** demonstrates fast image caching and in-app cropping — target performance baseline.  
- **Unum:** creative but slower — shows pitfalls of excessive transitions or complex layouts.  

---


