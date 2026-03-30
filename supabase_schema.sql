-- ============================================================
-- SyberHack SL Hub — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- 1. Create the videos table
create table if not exists public.videos (
  id           uuid primary key default gen_random_uuid(),
  platform     text not null check (platform in ('youtube','facebook','tiktok')),
  url          text not null,
  title        text not null default 'Untitled',
  thumb        text,                          -- base64 image or YouTube CDN URL
  custom_thumb boolean not null default false,
  ratings      integer[] not null default '{}',
  user_rating  integer not null default 0,
  created_at   timestamptz not null default now()
);

-- 2. Index for fast platform queries (newest first)
create index if not exists videos_platform_created
  on public.videos (platform, created_at desc);

-- 3. Disable Row Level Security — the Netlify Function uses the
--    SERVICE KEY (server-side only) so RLS is not needed.
--    Public users never touch Supabase directly.
alter table public.videos disable row level security;
