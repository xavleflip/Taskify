# 📑 Taskify

**Taskify** is a modern task and activity management mobile application built with **Flutter**. It offers a clean, distraction-free user experience to manage, track, and archive daily routines.

---

## ✨ Features
*   **Authentication:** Secure login, registration, and Google OAuth.
*   **Task Management:** Separate active tasks from completed ones.
*   **Scheduling:** Set deadlines using built-in date and time pickers.
*   **Prioritization:** Flag high-priority tasks.
*   **Offline Support:** Read-only mode for tasks cached locally when offline.
*   **Reminders:** Local push notifications for approaching deadlines.

## 🛠️ Tech Stack
*   **Frontend:** Flutter & Nylo MVC Framework
*   **Backend:** Supabase (PostgreSQL, GoTrue Auth, RLS)
*   **Storage:** NyStorage for offline caching

---

## 🚀 Setup & Run

### 1. Configuration
Create a `.env` file in the root folder with your Supabase keys:
```env
SUPABASE_URL="https://your-project-id.supabase.co"
SUPABASE_ANON_KEY="your-anon-public-key"
```

### 2. Database Schema
Run this in your Supabase SQL editor to create the `tasks` table with Row Level Security:
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

alter table public.tasks enable row level security;
create policy "Users can perform operations on their own tasks only" 
  on public.tasks for all using (auth.uid() = user_id);
```

### 3. Run
```bash
flutter pub get
flutter run
```