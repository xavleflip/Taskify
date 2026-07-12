# Product Requirements Document (PRD)
## Mobile To-Do Application (Activity Management)

---

### 1. Document Information
* **Product Name:** Mobile To-Do Application (Activity Management)
* **Frontend Framework:** Flutter (Nylo Framework)
* **Backend / Database:** Supabase
* **Document Status:** Draft - Brainstorming
* **Language:** English (Translated from Indonesian)

---

### 2. Introduction & Background
This project aims to build a mobile daily task and activity logging application (To-Do App) focused on interface simplicity (simple UI/UX) without compromising core functionality. The app is designed to help users efficiently manage their activities, group them by categories, and store a history of completed tasks to provide transparency regarding daily productivity.

By leveraging the combination of **Flutter (Nylo Framework)** on the frontend and **Supabase** on the backend, the application is expected to deliver responsive performance, clean state management, and instant, real-time data synchronization.

---

### 3. Product Goals
1. **Minimalist & Intuitive:** Provide a clean, easy-to-understand interface for users, minimizing distraction-free elements.
2. **Efficient Activity Management:** Enable users to quickly log, modify, and categorize activities (in a maximum of 3 navigation steps).
3. **History Keeping:** Shift away from the traditional data deletion paradigm. Activities checked off as completed will remain stored as archives/history to track past productivity.
4. **Data Security:** Ensure each user's activity data is securely isolated using Supabase's built-in authentication.

---

### 4. Technical Specifications (Tech Stack & Architecture)
* **Client-Side:**
  * **Framework:** Flutter
  * **Architecture & Micro-framework:** Nylo (utilizing Nylo's built-in features for Routing, Theming, State Management, and Localization if needed).
  * **Design Style (Typography & Aesthetic):** * *Heading / Title:* **Bebas Neue** (giving a bold, modern, and professional impression).
    * *Body Text / Form / Details:* **Montserrat** (ensuring high readability and a clean look).
* **Server-Side & Database:**
  * **Platform:** Supabase (PostgreSQL)
  * **Authentication:** Supabase Auth (Supporting Email/Password and Google Sign-In OAuth integration).
  * **Real-time Database:** For instant data synchronization between the application's local state and the Supabase server.

---

### 5. Interface Structure & User Flow (Frame Blueprint)
The application is designed concisely, centering around only **3 main Frames (Screens)**:

#### 5.1. Frame 1: Login & Authentication Screen
* **Description:** The main gateway to secure user data.
* **UI Components:**
  * Application header using a dominant-sized *Bebas Neue* font.
  * Input fields: Email and Password fields (with a password hide/show icon).
  * Main buttons: "Log In" and "Register New Account".
  * Visual divider: "Or".
  * Quick option button: "Sign in with Google" (Google Sign-In).
* **User Flow:** User enters credentials -> Supabase Auth validation -> If successful, redirect directly to Frame 2 (Main Screen). If failed, display an error message via a snack bar.

#### 5.2. Frame 2: Main Screen (Dashboard & Activity List)
* **Description:** The user's activity hub displaying the list of tasks to be completed.
* **UI Components:**
  * **Header:** Displays a personalized greeting (e.g., "Hello, Abi!") and today's date.
  * **Simple Filter Tab:** Toggle buttons or tabs to switch between:
    * **"Active Tasks":** Displays uncompleted activities.
    * **"History":** Displays completed checked-off activities.
  * **List View (Activity List):** A series of minimalist card components containing:
    * Activity title (Font: Montserrat Bold).
    * Category/Label Tag (e.g., *Organization, Campus, Personal*) with a desaturated (soft) background color.
    * Deadline date.
    * Checkbox on either the left or right side.
  * **Floating Action Button (FAB):** A round button with a "+" icon in the bottom right corner to direct the user to Frame 3.
* **Special Logic:** When the user taps the checkbox in the "Active Tasks" list, the item will animate out of the active list and move directly into the "History" tab. The data status in Supabase changes, but the data is not deleted.

#### 5.3. Frame 3: Add & Edit Activity Item Screen
* **Description:** A form page to input new activities or modify the details of existing ones.
* **UI Components:**
  * Dynamic header: "Add New Activity" or "Edit Activity".
  * Activity Title Input Field (Required, maximum 100 characters).
  * Long Description Input Field (Optional, paragraph text for additional notes).
  * Dropdown or Choice Chips component to select a Category/Label.
  * Date & Time Picker component to set a deadline.
  * Action Buttons: "Save" (primary position) and "Cancel" (secondary position).
* **User Flow:** User fills out the form -> Taps "Save" -> The app processes the data mutation to Supabase -> Returns to Frame 2 -> Nylo State Management updates the UI automatically without reloading the entire page.

---

### 6. Conceptual Data Schema Design (Supabase Table)
To accommodate the functional requirements above, the `tasks` table on Supabase PostgreSQL is designed as follows:

| Column Name | Data Type | Description | RLS (Row Level Security) Rule |
| :--- | :--- | :--- | :--- |
| `id` | UUID (Primary Key) | Unique identifier for each activity row. | Automatic |
| `user_id` | UUID (Foreign Key) | Refers to `auth.users` belonging to Supabase Auth. | Ensures data security between users. |
| `title` | VARCHAR(100) | Short activity title. | Cannot be empty (*NOT NULL*). |
| `description` | TEXT | Detailed explanation of the activity. | Can be empty (*NULL*). |
| `category` | VARCHAR(50) | Activity group label (e.g., Campus, Organization). | Default: 'General'. |
| `deadline` | TIMESTAMPTZ | Time limit for activity completion. | Can be empty (*NULL*). |
| `is_completed` | BOOLEAN | Completion status marker for the activity. | Default: `false`. If `true`, it goes to the history tab. |
| `created_at` | TIMESTAMPTZ | The timestamp when this activity data was first created. | Automatic (*NOW()*). |

---

### 7. Non-Functional Requirements
1. **Data Security (Row Level Security):** The Supabase database schema must enable RLS policies, ensuring that User A cannot read or modify activity data belonging to User B under any circumstances.
2. **Offline Availability (Optional for Next Phase):** The app is recommended to have a basic caching mechanism via Nylo or local plugins so that the loaded activity list remains readable when the internet connection is lost.
3. **Design Consistency:** Use a consistent color scheme with a desaturated approach (not bright/neon) to maintain the app's simple aesthetic.

---

### 8. Special Development Notes (Nylo Context)
* State management during the `is_completed` status transition in Frame 2 must be handled using Nylo's built-in state management (such as `NyState`) to ensure smooth visual data transitions between tabs.
* The folder structure follows standard Nylo framework conventions (`app/models`, `app/controllers`, `resources/views`) to facilitate future scalability if new features are added.