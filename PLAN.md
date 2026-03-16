# AURA — Virtual Health Companion
## Complete Feature Plan (Based on F29SO Group 3 Stage 1 Report)

---

## 📱 SCREENS FROM FIGMA (Appendix 4)
The report confirms these exact screens are required:
1. Register Page
2. Two-step Verification Page
3. User Login Page
4. Healthcare Provider Login Page
5. User Home Page
6. User Profile Page
7. Edit Profile Page
8. Change Password Page
9. Activity Tracker Page
10. Diet Log Page
11. Report and Analytics Page
12. Virtual Companion Page
13. Chat with Virtual Companion Page
14. Input Health Data Page
15. Share Health Data Page
16. Settings Page
17. Notification Page
18. Language Page
19. Feedback Page
20. About Us Page
21. Healthcare Interaction Page
22. Make Appointment Page
23. Chat with Healthcare Provider Page
24. Goals and Achievements Page
25. Track Menstrual Cycle Page
26. Edit Period Page

---

## 👤 USER ROLES
- **Regular User** — main app user tracking their health
- **Healthcare Provider** — logs in with staff ID, uploads reports, chats with patients

---

## 🔐 PHASE 1 — Authentication

### Register (A1.1)
- [ ] Enter username, email, password, confirm password
- [ ] Agree to Terms & Conditions checkbox
- [ ] On success → auto trigger Setup Profile
- [ ] Validation: invalid email, password mismatch
- [ ] Two-step verification page (email OTP)

### Login — User (A1.3)
- [ ] Enter username + password
- [ ] Validate credentials against database
- [ ] Redirect to home page on success
- [ ] Error: invalid username, incorrect password, account not found

### Login — Healthcare Provider (A1.15)
- [ ] Separate login screen for providers
- [ ] Enter staff ID + password
- [ ] Redirect to provider homepage
- [ ] Error: invalid staff ID, incorrect password

### Forgot Password
- [ ] Enter email
- [ ] Send reset link

---

## 🧭 PHASE 2 — Onboarding / Profile Setup (A1.2)

- [ ] Customise avatar + enter username
- [ ] Enter height and weight
- [ ] Enter health conditions (past illnesses, chronic conditions)
- [ ] Validation: inappropriate username, invalid height/weight
- [ ] Saves to database on completion

---

## 🏠 PHASE 3 — Dashboard (Home)

- [ ] Greeting with user name + time of day
- [ ] AURA Virtual Companion banner → tap to open chat
- [ ] Today's summary metric cards:
  - [ ] Heart rate (bpm)
  - [ ] Steps
  - [ ] Calories burned
  - [ ] Water intake
  - [ ] Weight
  - [ ] Sleep hours
- [ ] BMI card (auto-calculated)
- [ ] Blood pressure card
- [ ] Quick actions:
  - [ ] Log Health Data
  - [ ] View Report & Analytics
  - [ ] Make Appointment
  - [ ] Track Goals
- [ ] Notification bell icon
- [ ] Pull to refresh

---

## 📋 PHASE 4 — Input Health Data (A1.4)

- [ ] Accessible from Home page
- [ ] Data entry fields: steps, calories, heart rate, weight, blood pressure, blood glucose, oxygen saturation, sleep hours, water intake, active minutes
- [ ] Save button → validates input format and stores to database
- [ ] Pre-fill if already logged today
- [ ] Errors: invalid input, missing required fields
- [ ] "Updated today" status badge

---

## 📊 PHASE 5 — Report & Analytics (A1.7 + A1.8)

### User side:
- [ ] View list of past and latest health reports
- [ ] Select a report to view data summary
- [ ] Download or share report
- [ ] Week / Month toggle for charts
- [ ] Charts for: heart rate, weight, steps, calories, sleep, water, blood pressure
- [ ] Empty state when no data

### Healthcare Provider side (A1.8):
- [ ] Navigate to patient list
- [ ] Upload health report (PDF format only)
- [ ] Notification sent to patient on upload
- [ ] Error: file not in PDF format

---

## 🏃 PHASE 6 — Activity Tracker

- [ ] Steps progress ring (vs daily goal)
- [ ] Calories burned today
- [ ] Sport type selector: Running, Cycling, Swimming, Weightlifting, Walking, Other
- [ ] Duration input (minutes)
- [ ] Distance input (km, optional)
- [ ] Auto-estimate calories using MET values
- [ ] Add Activity → saves to database
- [ ] Today's activities list with delete
- [ ] Progress bars (steps vs goal, calories vs goal)

---

## 🥗 PHASE 7 — Diet Log

- [ ] Daily calorie progress ring (consumed vs goal)
- [ ] Meal type selector: Breakfast, Lunch, Dinner, Snacks
- [ ] Food name + calories input
- [ ] Log Meal → saves to database
- [ ] Water intake logging
- [ ] Daily meal summary grouped by type
- [ ] Delete individual meal entry

---

## 🤖 PHASE 8 — Virtual Companion / AI Chat (A1.16, A1.17, A1.18)

### Chat Interface:
- [ ] Chat bubbles (user right, AURA left)
- [ ] AURA avatar
- [ ] Pre-defined quick prompt buttons
- [ ] Typing indicator (animated dots)
- [ ] Scroll to latest message
- [ ] Chat history saved to database

### Powered by Claude API:
- [ ] System prompt includes user's profile + today's health data
- [ ] AURA responds with motivation, emotional support, health guidance

### Extension — Exercise Advice (A1.17):
- [ ] User types exercise question
- [ ] System retrieves: current weight, recent activities, fitness goals
- [ ] Returns exercise plan with duration, intensity, estimated calories burned
- [ ] User can request alternative/easier options
- [ ] Saved to chat history

### Extension — Personalised Diet Plan (A1.18):
- [ ] User types diet question
- [ ] System retrieves health data + goals from database
- [ ] Returns customised meal suggestions + calorie recommendations
- [ ] User can request more details (meal options, portion sizes)
- [ ] Saved to chat history

---

## 🏥 PHASE 9 — Appointments (A1.13)

- [ ] Display list of registered healthcare providers
- [ ] User selects a provider
- [ ] Show available dates and time slots
- [ ] User selects preferred date and time
- [ ] Confirm booking
- [ ] Store appointment in database
- [ ] Send confirmation notification to user
- [ ] Notify healthcare provider of new appointment
- [ ] Errors: no provider available, selected slot already booked (reload availability)
- [ ] Upcoming appointments list with status
- [ ] Past appointments list
- [ ] Cancel appointment

---

## 💬 PHASE 10 — Chat with Healthcare Provider (A1.14)

- [ ] Load chat interface with existing messages
- [ ] User sends message to provider
- [ ] AURA delivers message
- [ ] Provider responds, user gets notification
- [ ] Chat history stored in database
- [ ] Errors: provider unavailable, message not delivered

---

## 🎯 PHASE 11 — Goals & Achievements (A1.9)

- [ ] Create health-related goals (steps/day, calories, water, sleep, weight)
- [ ] View goal list
- [ ] Select a goal to view detailed progress
- [ ] Progress calculated from actual health data
- [ ] Milestone feedback messages (50% / 100% completion)
- [ ] Encouragement notifications
- [ ] Goal data stored + updated in database
- [ ] Error: retry if Goal Module fails to retrieve data

---

## 🔔 PHASE 12 — Notifications (A1.11, A1.12)

### Receive Notifications:
- [ ] Health reminders (log your data)
- [ ] Appointment reminders
- [ ] Goal milestone achieved
- [ ] Healthcare provider uploaded a report
- [ ] New message from healthcare provider

### Manage Notifications:
- [ ] List of all notifications
- [ ] Mark as read
- [ ] Mark all as read
- [ ] Delete notification
- [ ] Toggle notification types on/off
- [ ] Unread count badge on bell icon

---

## 🌸 PHASE 13 — Track Menstrual Cycle (A1.10)

- [ ] Track Menstrual Cycle page
- [ ] Edit Period page
- [ ] Log period start/end dates
- [ ] Predict next cycle
- [ ] Cycle length display
- [ ] History view

---

## 👤 PHASE 14 — Profile (A1.6)

- [ ] View profile: avatar, username, email, DOB, age, gender
- [ ] Health stats: height, weight, BMI, goal weight
- [ ] BMI category badge
- [ ] Appointments section (upcoming + past)
- [ ] Quick links: Edit Profile, Health Data, Report, Goals, Settings
- [ ] Sign out

### Edit Profile (A1.6):
- [ ] Update username/nickname
- [ ] Update DOB, gender
- [ ] Update height, weight, goal weight
- [ ] Update health conditions
- [ ] Update blood pressure baseline
- [ ] Customise avatar
- [ ] Change password (A4.8)
- [ ] Save → updates database

---

## 🔗 PHASE 15 — Share Health Data (A1.5)

- [ ] Select data categories to share: Steps, Sleep, Calories, Heart Rate, etc.
- [ ] Choose recipient (healthcare provider, family member, authorized contact)
- [ ] Confirmation prompt before sharing
- [ ] Encrypt + transmit data to recipient
- [ ] Log sharing activity in database
- [ ] Recipient can view or download shared data
- [ ] View sharing history
- [ ] Errors: recipient authorization invalid, data transmission failed

---

## ⚙️ PHASE 16 — Settings

- [ ] **Goals:** daily step goal, calorie goal, water goal
- [ ] **Notifications:** toggle reminder types on/off
- [ ] **Language** — Language Page (A4.18): select app language
- [ ] **Account:** change email, change password, delete account
- [ ] **Privacy:** data sharing preferences
- [ ] **About Us** — About Us Page (A4.20): app version, team info, privacy policy, terms
- [ ] **Feedback** — Feedback Page (A4.19): send feedback form
- [ ] **Data:** clear all health data (with confirmation)

---

## 📍 PHASE 17 — Locate Nearest Hospital (A1.21)

- [ ] Show map with nearby hospitals/clinics
- [ ] Use device location
- [ ] Filter by type (hospital, clinic, pharmacy)
- [ ] Tap to get directions

---

## 🔄 PHASE 18 — Data Synchronization (A1.19)

- [ ] Auto-sync when app opens on any device
- [ ] Check for updates from database/cloud
- [ ] Resolve conflicts: merge by latest timestamp or user prompt
- [ ] Sync history stored (timestamp, device ID)
- [ ] Offline mode: queue changes for when connection restored
- [ ] Retry on database/cloud failure

---

## 🗄️ DATA MODELS (Firestore)

| Collection | Purpose |
|---|---|
| `users/{uid}` | User profile, avatar, health conditions, settings |
| `providers/{uid}` | Healthcare provider profiles |
| `users/{uid}/healthEntries/{date}` | Daily health logs |
| `users/{uid}/meals/{id}` | Meal entries |
| `users/{uid}/activities/{id}` | Activity/sport entries |
| `users/{uid}/appointments/{id}` | Appointments |
| `users/{uid}/goals/{id}` | Health goals + progress |
| `users/{uid}/chatSessions/{id}` | Virtual companion chat history |
| `users/{uid}/notifications/{id}` | Notifications |
| `users/{uid}/sharedData/{id}` | Sharing history |
| `users/{uid}/menstrualCycle/{id}` | Period tracking |
| `chats/{chatId}` | Healthcare provider ↔ patient messages |
| `reports/{id}` | PDF health reports uploaded by providers |

---

## 🔒 SECURITY & NON-FUNCTIONAL

- [ ] Firestore security rules (users read/write own data only)
- [ ] Healthcare providers can only access assigned patients
- [ ] Data encryption for shared health data
- [ ] Two-step verification on register
- [ ] Password hashing (Firebase Auth handles this)
- [ ] Firebase API key restrictions
- [ ] Budget alert ($5 threshold on Firebase)
- [ ] App should load within 3 seconds
- [ ] Offline mode — queue data for sync

---

## 🌐 PLATFORM SUPPORT

- [ ] **Android** — Primary
- [ ] **Web** — Secondary (responsive layout)
- [ ] **iOS** — Future (after Android + Web complete)

---

## 📦 BUILD PHASES

```
Phase 1  ✅  Project setup, Firebase, theme, router, stubs

Phase 2  🔲  Auth — Login, Register, 2-step verification, Forgot password

Phase 3  🔲  Data layer — All models, services, providers

Phase 4  🔲  Onboarding — Profile setup wizard (avatar, height/weight, health conditions)

Phase 5  🔲  Dashboard — Home screen with real data

Phase 6  🔲  Health Data — Input screen (vitals, activity, diet, sleep)

Phase 7  🔲  Report & Analytics — Charts, week/month toggle

Phase 8  🔲  Activity Tracker

Phase 9  🔲  Diet Log / Nutrition

Phase 10 🔲  Virtual Companion — AI chat with Claude API //

Phase 11 🔲  Goals & Achievements

Phase 12 🔲  Appointments — Book, list, cancel

Phase 13 🔲  Notifications

Phase 14 🔲  Profile + Edit Profile

Phase 15 🔲  Menstrual Cycle Tracker //

Phase 16 🔲  Share Health Data // cant share with (share to social media func)

Phase 17 🔲  Chat with Healthcare Provider (separate login) //

Phase 18 🔲  Settings (Language, Feedback, About Us, Goals, Account)

Phase 19 🔲  Locate Nearest Hospital (Maps)

Phase 20 🔲  Data Synchronization

Phase 21 🔲  Web responsive polish + final testing //fix the layout for web
```


-biomarker button with fake data
-check fr again from the report
-change password(2 step verification)
-share health data to social media
-doctor also can check appoinment dates
-patient change to user
-make the medical history more immersive(search existing ilnnesses and put it themselves)
-make the connect with doctor id work now