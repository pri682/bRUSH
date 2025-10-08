# bRUSH!
> Outline a brief description of your project.
> Live demo [_here_](https://www.example.com). <!-- If you have the project hosted somewhere, include the link here. -->
## Table of Contents
* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [Features](#features)
* [Screenshots](#screenshots)
* [Setup](#setup)
* [Usage](#usage)
* [Project Status](#project-status)
* [Room for Improvement](#room-for-improvement)
* [Acknowledgements](#acknowledgements)
* [Contact](#contact)
<!-- * [License](#license) -->


## Description  

**Who are we?**  
Hi! My name is [Meidad Troper](https://github.com/Meidad-T) and together with team members [Vaidic Soni](https://github.com/vaidicsoni), [Kelvin Mathew](https://github.com/KelvinMathew2004), [Priyanka Karki](https://github.com/pri682), and [Jesse Flynn](https://github.com/jeaflynn) we created bRUSH! The new social media app.  

**What are we creating?**  
In short, this is a mobile social media app that aims at connecting everyone to their creative side as well as connect people closer. The app is aimed at anyone ages 12 to 22 though we believe it will be enjoyable even among families, sharing drawings with your parents.  

bRUSH! is a mobile app inspired by BeReal, where all users world wide get a notification at the same time letting them know it is time to skecth! what are they bRUSHing? whatever the random, funny, bizzare, weird promt was generated for that day! every user, world wide - will all be drawing THE SAME THING at the SAME TIME talk about synchronization.... (sorry, bad programmer joke).  

Users will have a pre determined amount of time to complete their daily drawing. before they have to submit it.  

After a user has submitted their drawing, they are presented with all of their friends drawings! Again, same promt... and that is where the fun begin!  

each user is granted medals they can award each day.  
A gold medal can be awarded once per day, to the user's favorite drawing.  
A silver medal can be awarded once per day for the user's second favorite drawing.  
And of course a bronze medal can be awarded once per day for the user's third favorite bRUSH.  

In addition, every user is given an unlimited number of "participation medals" which they can award to all the drawings they hated.... Just kidding... they can be awarded to the drawings the user recognizes as impressive, but simply we'rent in the top 3 that day in the user's opinion.  

Each user grants those medals to their friends or family... but don't forget... the user also has the chance to be awarded medals of their own from their friends or family! resulting in a friendly and fun competition... who can earn the most gold medals?  

**Who are we doing it for?**  
The app is aimed at anyone ages 12 to 22 though we believe it will be enjoyable even among families, sharing drawings with your parents.  

**Why are we doing this?**  
Now, you might be hearing all of this... and wonder- but why? what's the point..? it doesn't really solve any global issue... it doesn't save lives, and it most certainly doesn't leave the world a better place... so what even if the point??  

Well... According to a recent research, About 45% of students world wide report wishing they had more opportunities to express themselves creatively or artistically but can't. It was also found that 80% of people believe unlocking creativity is critical to economic growth. [1]  

Our platform is just the place to do so. People of all ages could take their very own twist at our random bRUSH prompts, and truly express themselves in them. While the app aims to be fun and easy going, it also enables those students craving to express themselves the platform to do so, without being jujged.  

bRUSH! Aims to connect people, unlock creative thinking, and bring more color to the world (literally).  



## Technologies
- Swift UI
- XCode
- Firebase Authentication
- Firebase Cloud Storage
- Gemini API (Google AI)
- Apple Native APIs (Pencil Kit, photos UI, etc...)

## Features

Currently in progress as of October 6, 2025 (Next steps for sprint 2):
- Pick a personal profile page photo
- store drawings locally
- friend requests and leaderboard
- feed view
- medal awarding
- Liquid glass implemntation
- sign up user verification (verification codes)
- Notifications panel

## 🧩 Contributions

This section lists individual contributions for this sprint.  
Each entry includes the JIRA task ID, title, and links to related commits or pull requests.

---

### 👤 Meidad Troper

#### **KAN-13 — Implement User Login**
- Implemented all user login logic including authentication flow and session persistence.  
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/commits/branch/feature%2FKAN-13-user-login)

#### **KAN-53 — Implement User Sign Out**
- Added user sign-out functionality, restoring the app to its deafult, empty state.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/commits/branch/feature%2FKAN-53-log-out)

#### **KAN-14 — Allow User Profile Deletion**
- Implemented the ability for users to permanently delete their profiles and associated data.  
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/commits/branch/feature%2FKAN-14-Delete-Profile)

#### **KAN-61 — Enable User Sign-Up for New Profiles**
- Developed the user registration process and linked it to the backend user store.  
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/commits/branch/feature%2FKAN-61-sign-up-form)

#### **KAN-12 — Update User Profile Information**
- Implemented logic for user to update their profiles, including name and username.  
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/commits/branch/feature%2FKAN-12-edit-profile-options)

#### **Next Steps** 
- Profile Photo selection + saving it on Firebase.
- save profile data locally to limit firebase usage and reduce costs.
- Better Profile UI + Ensuring it scales correctly to different screen sizes.
- Possible: Add requirement for users to verify themselevs when signing up via 2FA

---

### 👤 Kelvin Mathew

#### **KAN-47 — Canvas for Drawings**
- Implemented UI and logic for for the canvas which can generate strokes based on touch input.
🔗 [Bitbucket Branch](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/c0df58b05d29f08666e93cb2700f13fd3aae3691/?at=feature%2FKAN-47-canvas)

#### **KAN-48 — Custom PencilKit API**
- Implemented UI and logic for the customized Swift toolpicker that updates the drawing view.
🔗 [Bitbucket Branch](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/b44f03882c33a1f2e24d68458ca5adaaa8f21dc1/?at=feature%2FKAN-48-as-a-user-i-want-to-choose-brush-)

#### **KAN-49 — Add Undo/Redo for iPhone**
- Implemented UI and logic for being able to undo and redo on iPhone due to the toolpicker not showing one unlike iPad.
🔗 [Bitbucket Branch](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/3dac70e2a6db1c3ccf7be8bfe3b4a3265327abaa/?at=feature%2FKAN-49-as-a-user-i-want-to-undo-redo-act)

#### **KAN-50 — Add Share Sheet and Save Drawing Locally**
- Implemented UI and logic for creating the composite drawing, saving it in the local memory and being able to share it.
🔗 [Bitbucket Branch](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/9658e3941ec9aa0e00aed71f977c344efc23cb37/?at=feature%2FKAN-50-as-a-user-i-want-to-export-the-ca)
🔗 [Bitbucket Pull Request](https://bitbucket.org/cs3398-nemoidians-f25/brush/pull-requests/2)

#### **KAN-65 — Enable Users to Change Canvas Backgrounds**
- Implemented UI and logic for being able to change the color of the canvas or pick from preset assets. Updated the export feature based on this.
🔗 [Bitbucket Branch](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/c8ddfebd88d5af3fdb1cf0d4381a38f29f14f101/?at=feature%2FKAN-65-as-a-user-i-want-to-be-able-to-ch)
🔗 [Bitbucket Pull Request](https://bitbucket.org/cs3398-nemoidians-f25/brush/pull-requests/7)

#### **Next Steps** 
- Improving the preview screen and the exporting logic for backgrounds with wide aspect ratios.
- Adding a custom canvas outline styled timer when start drawing is clicked in the feed. Also add confirmation warning when submitting early.
- Upload the drawing jpeg to the respective area in Firebase.
- Pass the prompt of the day from the feed to the drawing so it can be viewed while drawing as well as when previewing past drawings (along with date).

---

### 👤 Vaidic Soni

#### **KAN-52 — Daily Reminder Functionality**
- Users now get periodic reminders every 2 hours to complete their daily drawing if they haven't done so.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/432d7255bac1e8b46ca891dae935610f734f8296/?at=feature%2FKAN-52-NotificationReminder)

#### **KAN-21 — Fixing notification Scheduling**
- Fixed notifications and made changes to make them better and increase their frequency.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/KAN-21_Fixing_Notifications/)

#### **KAN-23 — Added Streak functionality**
- Designed logic to track daily drawing streaks to motivate users.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/KAN-23-Streak_Feature/)

#### **KAN-45 — Added Notification Bell and History**
- Implemented a dropdown panel that stores and displays all past notifications.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/src/2437e02c6cc9a20d5537e9c8a60e27a40fbd7f72/?at=feature%2FKAN-45-as-a-user-i-want-a-bell-icon-on-t)

#### **Next Steps**
- Let users upload and share their drawings using Firebase Storage.
- Show posts from friends using Firestore for filtered queries.
- Do the prompt logic by using LLM's API's and train them.
---

### 👤 Priyanka Karki

#### **KAN-51 – Welcome Screen with Logo and Design Elements.**
Integrated the new logo into the welcome screen.
Added a “Get Started” button and aligned layout elements.
Ensured consistency and responsiveness across devices.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/%7B57222da5-99b9-44b5-8ae7-38296988f7a4%7D/commits/2be9dcd5d70ad75b5ee7c49470d0fdc44b713405)

#### **KAN-63 – Home Feed Page.**
Built the main feed to display friends’ drawings.
Added navigation tabs for Home, Explore, Create, and Profile.
Structured layout for future backend integration.
🔗 [Bitbucket] (https://bitbucket.org/cs3398-nemoidians-f25/%7B57222da5-99b9-44b5-8ae7-38296988f7a4%7D/branch/feature/KAN-63-as-a-user-i-want-my-home-page-to-)

#### **KAN-64 – Profile Navigation.**
Enabled navigation from feed posts to creator profiles.
Added private profile visibility logic.
Tested smooth page transitions.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/%7B57222da5-99b9-44b5-8ae7-38296988f7a4%7D/commits/19128ac3199010535bd6b2015dcdedc7a956b65b)

#### **KAN-71 – Post Interactions (Likes, Medals, Shares).**
Added interactive like, medal, and share buttons to feed posts.
Managed state updates and interaction animations.
Verified full integration within feed layout.
🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/%7B57222da5-99b9-44b5-8ae7-38296988f7a4%7D/branch/KAN-71-as-a-user-i-want-to-be-able-to-ta)

#### **Next Steps (Sprint 2)**
Design and plan the structure for the backend logic.
Integrate the feed, profile, and interaction features with a reliable database to store and manage user data.
Implement real-time updates for likes and medals to ensure dynamic user feedback.
Optimize feed performance and conduct accessibility testing for a smoother user experience.
---

### 👤 Jesse Flynn

#### **KAN-18 - Friends Tab (View/Search/Request + Add Friend)**
- Implemented friend screen UI
- Added friend requests section with accept/decline functionality (mock)
- Added friends section with searchable list

🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/commits/branch/KAN-18-as-a-user-i-want-to-have-a-friends-tab-to-view-and-compete-with-my-friends)

#### **KAN-19 - Friends Leaderboard (frontend)**
- Added LeaderboardEntry model and LeaderboardService protocol
- Extended Friends VM with state, sorting, and refresh logic
- Added Leaderboard section in Friends page with ranking, points, refresh, and error/empty states
- Added trophy icon to toggle leaderboard visibility

🔗 [Bitbucket](https://bitbucket.org/cs3398-nemoidians-f25/brush/commits/branch/KAN-19-as-a-user-i-want-a-leaderboard-to-compete-with-friends)

*Note: KAN-18 (Friends tab) was accidentally merged into main instead of the sprint1-dev branch. As a result, when I created the KAN-19 branch and 
merged it into sprint1-dev, it also included the KAN-18 commits. These commits were already reviewed and merged to main earlier. KAN-19 contains only the 
leaderboard-related changes, but the history shows both sets because of the branch base. This was not an attempt to duplicate or fake work - just a branch 
merge mistake that I wanted to add here for clarity.*

#### **Next Steps** 
- Friends Backend Integration (Firebase)
	- Connect Add Friend flow to real Firebase users using handles
	- Implement friend request creation, acceptance, and persistence with Firestore
	- Update FriendsViewModel to use live user data instead of mock arrays
- Leaderboard Backend Integration
	- Implement Firebase logic to query friends’ submissions and calculate medal totals
	- Replace stub service with real Firestore queries using filters for friend IDs
	- Ensure leaderboard updates on refresh and matches real medal counts
- Testing and Polish
	- Add unit tests for FriendsViewModel search and leaderboard sorting logic
	- Clean up any UI bugs or state resets between tabs

<!-- ## Setup

### Requirements

### Installation


## Usage
How does one go about using it?
Provide various use cases and code examples here.

`write-your-code-here`
 -->

## Project Status
Project is: _in progress_ 


<!-- ## Room for Improvement
Include areas you believe need improvement / could be improved. Also add TODOs for future development.

Room for improvement:
- Improvement to be done 1
- Improvement to be done 2

To do:
- Feature to be added 1
- Feature to be added 2


## Acknowledgements
Give credit here.
- This project was inspired by...
- This project was based on [this tutorial](https://www.example.com).
- Many thanks to...


## Contact
Created by [@flynerdpl](https://www.flynerd.pl/) - feel free to contact me!


<!-- Optional -->
<!-- ## License -->
<!-- This project is open source and available under the [... License](). -->

<!-- You don't have to include all sections - just the one's relevant to your project --> 