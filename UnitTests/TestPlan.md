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
*(no tests added yet)*

---

## Priyanka Karki – Unit Tests Plan
*(no tests added yet)*

---

## Jesse Flynn – Unit Tests Plan

### 1. testAwardService_AllowsSingleGoldPerDayPerUser()
This test will focus on the new AwardServiceFirebase.setAward logic and the /awardUsage/{uid_YYYYMMDD} document. It simulates 
a user giving a gold medal to a friend’s drawing once, and then trying to give a second gold medal on the same day. The first 
call should succeed and mark goldUsed = true for that user/day, and the second call should be no extra writes and no double 
award. This matters because our whole “one gold/silver/bronze per day per user” rule depends on this transaction behaving 
exactly right, and it’s easy to accidentally let people spam medals without this guard.

### 2. testFetchAwardCounts_AggregatesAwardsPerPostOwner()
This test targets AwardServiceFirebase.fetchAwardCounts(forPostOwner:). It will create a fake /dailyFeed/{userId}/awards  
subcollection with multiple docs (each representing a different giver) and different combinations of gold/silver/bronze =  
true/false, then verify that the method returns the correct AwardCounts totals. This is important because the feed,  
leaderboard, and eventually profile stats all rely on these aggregated counts; if the aggregation logic is off by even one,  
the UI will show the wrong number of medals for a drawing.

### 3. testHasPending_FiltersBySenderAndReceiver()
This test will check the pending friend request logic in FriendRequestServiceFirebase.hasPending(fromUid:toUid:). It sets up a 
scenario where user A has a pending request to user B, and user C also exists in the system. The test will verify that 
hasPending(fromUid: A, toUid: B) returns true, but hasPending(fromUid: C, toUid: B) returns false even though B does have a 
pending request from someone else. This matters because we previously had a bug where “Pending” would show just because 
someone had requested that user, not necessarily the currently signed-in user. Getting this right prevents confusing UI states 
and duplicate/incorrect friend requests.

