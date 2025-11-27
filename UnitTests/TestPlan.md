# UnitTests – Sprint Assignment 14
This file provides an overview of each member’s plan for unit testing, as part of Sprint Assignment 14.  
It’s just a short summary of what we expect to test and why it matters.

---

## Meidad Troper – Unit Tests Plan

### 1. testCheckSignInStatus_WhenSignedIn()
This test simulates a user signing in and checks if the sign-in status is reported correctly.  
Since the project is a social media style app, getting this right is important for both privacy and overall UX.  
If this fails, users might be signed in without knowing or the app might behave weirdly.

### 2. testCheckSignInStatus_WhenSignedOut()
This one checks that signing out actually works.  
After a user signs out, the logic should report they are *not* signed in anymore.  
If we try to sign out and the app still thinks the user is signed in, the test will fail.  
Passing it means the signout flow is behaving like it should.

### 3. testUsernameValidation_LengthCheck()
Even though the username rules are simple right now, validation bugs can break the user flow fast.  
I’ve had issues before where the text field stayed red for “too short” even when it wasn’t.  
This test makes sure that the length logic is working right, and later we can build on it to check more rules.

---

## Kelvin Mathew – Unit Tests Plan

### 1. testDrawingViewThemeIdentity()
This test checks the theme system that the drawing view uses (like switching between a color background or a texture).  
It makes sure IDs are created in a consistent way so the UI can loop over them without breaking, and that two themes with the same color are actually treated the same.  
If this logic is wrong, the UI might reload wrong themes or just not update like it should.

### 2. testStreakManagerLocalUpdate()
This focuses on the streak system that runs fully on the device using UserDefaults.  
It resets the stored streak, marks a drawing as completed “today,” and checks that the count goes up the right way.  
Also tests that doing it twice doesn’t double-count.  
It matters because the streak is shown to the user directly, and small bugs here can confuse or frustrate people fast.

### 3. testDrawingPreviewViewInitialization()
This just makes sure the preview view can be created with a normal item and not crash.  
It feeds in a mock item and a simple binding, then checks that the view actually builds its body.  
It’s one of those safety tests to make sure the UI won’t blow up when the user taps something.

---

## Vaidic Soni – Unit Tests Plan

### 1. testFriendsFiltering_FullNameAndHandleSearch()
This test ensures the friend search logic works correctly for both full names and handles.  
It covers searching by name, searching by handle, and confirming that an empty search returns the full list.  
If this filtering is incorrect, users may see incomplete or inaccurate search results in the friends list.

### 2. testNotificationHistory_PersistenceAndRetrieval()
This test validates storing and retrieving notification history using an isolated UserDefaults suite.  
It checks that two saved notifications appear in the correct order (newest first) and verifies that cleanup works.  
This matters because the notifications screen depends on consistent, predictable history storage to avoid missing or misordered entries.

### 3. testPromptGenerator_DeterminismAndUniqueness()
This test confirms that generating a prompt from the same seed always returns the same output and that different seeds produce different prompts.  
It also checks that the result is never empty.  
This is important because the prompt generator powers daily content, and inconsistent results could break prompt scheduling or user-facing features.

---

## Priyanka Karki – Unit Tests Plan

### 1. testPointsCalculation_ZeroMedals()
Just a safety check that someone with no medals gets zero points instead of some weird number.  
It's a simple case but worth testing because edge cases like this can expose bugs in the math.

### 2. testPointsCalculation_OnlyGold()
Another edge case—what if someone only has gold medals and nothing else?  
Makes sure the calculation still works when some medal counts are zero.  
Helps confirm the formula doesn't accidentally multiply or add wrong when values are missing.

### 3. testSorting_HigherPointsFirst()
Tests that the leaderboard actually sorts people by their points, highest first.  
If someone has 500 points and another has 100, the 500-point person should be ranked higher.  
Without this working right, the leaderboard would just be random and nobody would trust it.

### 4. testSorting_TieBreakByEarlierDate()
When two people have the exact same points, we break the tie by who submitted earlier.  
This test makes sure that logic works—earlier submission date should rank higher.  
It's a fairness thing so people know there's a consistent rule when scores are tied.

### 5. testLeaderboard_HighScoreAtTop()
This is more of an integration-style test that checks a whole leaderboard with different scores.  
It makes sure that when you sort a real list of entries, the person with the most points ends up at rank 1.  
Kind of ties everything together to confirm the sorting and calculation work as a system.

### 6. testLeaderboard_SameScoreSortedByTime()
Similar to the tie-break test but with multiple users all having the same score.  
Checks that when three people all have 300 points, they get ordered by submission time oldest to newest.  
Ensures the tie-breaking rule works even when there are more than two people tied.

---

## Jesse Flynn – Unit Tests Plan
*(no tests added yet)*

