-- Seed data for ExpenseTracker development
-- This file will be executed when running `supabase db reset`

-- Insert default categories for new users
-- Note: In production, these will be created when a user first signs up

-- Sample user profiles (for development only)
-- In production, profiles are created automatically via auth triggers

-- Default expense categories with colors and icons
-- These will be used as templates for new user category creation

INSERT INTO categories (id, name, color, icon, is_default) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Food & Dining', '#FF6B6B', 'fork.knife', true),
  ('550e8400-e29b-41d4-a716-446655440002', 'Transportation', '#4ECDC4', 'car.fill', true),
  ('550e8400-e29b-41d4-a716-446655440003', 'Shopping', '#45B7D1', 'bag.fill', true),
  ('550e8400-e29b-41d4-a716-446655440004', 'Entertainment', '#96CEB4', 'gamecontroller.fill', true),
  ('550e8400-e29b-41d4-a716-446655440005', 'Bills & Utilities', '#FFEAA7', 'house.fill', true),
  ('550e8400-e29b-41d4-a716-446655440006', 'Healthcare', '#DDA0DD', 'cross.case.fill', true),
  ('550e8400-e29b-41d4-a716-446655440007', 'Education', '#F39C12', 'book.fill', true),
  ('550e8400-e29b-41d4-a716-446655440008', 'Travel', '#E17055', 'airplane', true),
  ('550e8400-e29b-41d4-a716-446655440009', 'Personal Care', '#FD79A8', 'person.fill', true),
  ('550e8400-e29b-41d4-a716-446655440010', 'Other', '#95A5A6', 'ellipsis.circle.fill', true);

-- Sample budget data (for development/testing)
-- Note: These are tied to the auth.users table which won't exist in seed
-- Will be created via the app during development

-- Sample expense data (for development/testing)
-- Note: These are tied to actual user IDs which won't exist in seed
-- Will be created via the app during development

-- Development note: 
-- Real user data (profiles, budgets, expenses) will be created through the app
-- This seed file only contains default categories and system-wide defaults