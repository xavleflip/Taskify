# 📑 Taskify: To-Do & Activity Manager

**Taskify** is a modern, pixel-perfect task and activity management mobile application built using **Flutter**. Taskify offers a clean and distraction-free user experience to manage, track, and archive daily routines and responsibilities.

---

## 🛠️ Tech Stack & Architecture

*   **Frontend Framework:** [Flutter](https://flutter.dev/) (SDK >= 3.10.7)
*   **Micro-Framework:** [Nylo MVC Framework](https://nylo.dev/) (v7.x)
*   **Backend & DB Layer:** [Supabase](https://supabase.com/) (PostgreSQL Database, GoTrue Auth API, Row-Level Security)
*   **Data Models & Controllers:** MVC separation mapping models, network services, and optimistic state updating
*   **Typography:** Google Fonts (`Bebas Neue` for bold uppercase headers; `Montserrat` for body text and labels)
*   **Offline Persistence:** `NyStorage` secure local storage caching (providing read-only fallbacks during connection drops)

---

## ✨ Key Features

1.  **Secure Authentication:** Sign in, register new accounts, or log in with Google OAuth. Protected by route security guards (`AuthRouteGuard` & `GuestRouteGuard`) that secure the internal views.
2.  **Dynamic Activity List:** Optimistic state updating separating *Active Tasks* and *History (Completed Tasks)* in a clean, checkbox-triggered list view.
3.  **Calendars & Timers:** Built-in date and time selection dialogs to configure specific, formatted task deadlines.
4.  **Mark as Important:** A switch toggle on task creation that flags high-priority tasks with a red flag indicator on your dashboard.
5.  **Offline read fallback:** Prevents connection crash screens by caching your task list locally and displaying a read-only list whenever network errors are caught.

---

## 🚀 Getting Started

### 1. Prerequisites
Make sure you have Flutter installed and configured on your machine.
```bash
flutter --version
```

### 2. Configuration Setup
Create a `.env` file in your root folder (or update your existing one) with your Supabase keys:
```env
SUPABASE_URL="https://your-project-id.supabase.co"
SUPABASE_ANON_KEY="your-anon-public-key"
```

### 3. Database Table Configuration
Ensure you have created the `tasks` table with the correct fields inside your Supabase SQL editor:
```sql
create table public.tasks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  title text not null,
  description text,
  category text not null default 'General',
  deadline timestamp with time zone,
  is_completed boolean not null default false,
  is_important boolean not null default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security
alter table public.tasks enable row level security;

-- Create Policies
create policy "Users can perform operations on their own tasks only" 
  on public.tasks 
  for all 
  using (auth.uid() = user_id);
```

### 4. Running the App
Restore dependencies and start the debugger:
```bash
flutter pub get
flutter run
```