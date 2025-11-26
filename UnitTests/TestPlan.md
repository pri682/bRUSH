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
*(no tests added yet)*

---

## Vaidic Soni – Unit Tests Plan
*(no tests added yet)*

---

## Priyanka Karki – Unit Tests Plan
*(no tests added yet)*

---

## Jesse Flynn – Unit Tests Plan
*(no tests added yet)*

