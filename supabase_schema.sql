-- Cal-AIM CHW Referral Tracker Database Schema
-- Run this in your Supabase SQL Editor (supabase.com > Your Project > SQL Editor)

-- Create the referrals table
CREATE TABLE referrals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    enrollment_date DATE NOT NULL,
    member_name VARCHAR(255) NOT NULL,
    dob DATE,
    client_id VARCHAR(100),
    phone_number VARCHAR(50),
    health_plan VARCHAR(50) NOT NULL,
    referral_type VARCHAR(50) NOT NULL,
    referred_by VARCHAR(100),
    location VARCHAR(100) NOT NULL,
    primary_pof TEXT NOT NULL,
    secondary_pof TEXT,
    care_plan VARCHAR(50),
    referral_status VARCHAR(50) NOT NULL,
    notes TEXT,
    worker VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create the workers table for authentication/tracking
CREATE TABLE workers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert the workers
INSERT INTO workers (name) VALUES
    ('Sabrina'),
    ('Katrina'),
    ('Deborah'),
    ('Tanyua'),
    ('Delilah');

-- Create indexes for common queries
CREATE INDEX idx_referrals_enrollment_date ON referrals(enrollment_date);
CREATE INDEX idx_referrals_worker ON referrals(worker);
CREATE INDEX idx_referrals_status ON referrals(referral_status);
CREATE INDEX idx_referrals_health_plan ON referrals(health_plan);
CREATE INDEX idx_referrals_location ON referrals(location);

-- Enable Row Level Security (RLS)
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;

-- Create policies to allow all operations (adjust as needed for more security)
CREATE POLICY "Allow all operations on referrals" ON referrals
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow read on workers" ON workers
    FOR SELECT USING (true);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to auto-update updated_at
CREATE TRIGGER update_referrals_updated_at
    BEFORE UPDATE ON referrals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create a view for dashboard statistics
CREATE VIEW referral_stats AS
SELECT
    COUNT(*) as total_referrals,
    COUNT(*) FILTER (WHERE referral_status = 'Active') as active_count,
    COUNT(*) FILTER (WHERE referral_status = 'In Process') as in_process_count,
    COUNT(*) FILTER (WHERE referral_status = 'Discharged') as discharged_count,
    COUNT(*) FILTER (WHERE care_plan = 'Approved') as approved_count
FROM referrals;

-- Grant access to the view
GRANT SELECT ON referral_stats TO anon, authenticated;
