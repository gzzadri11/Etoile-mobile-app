-- Sprint 26: Decouple applications from conversations
-- Applications are now a standalone table, not tied to conversations

CREATE TABLE applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    seeker_id UUID NOT NULL,
    recruiter_id UUID NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'withdrawn')),
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(video_id, seeker_id)
);

-- Indexes for frequent queries
CREATE INDEX idx_applications_seeker_id ON applications(seeker_id);
CREATE INDEX idx_applications_recruiter_id ON applications(recruiter_id);
CREATE INDEX idx_applications_video_id ON applications(video_id);

-- RLS
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- Seeker can see their own applications
CREATE POLICY "seeker_select_own_applications"
    ON applications FOR SELECT
    TO authenticated
    USING (auth.uid() = seeker_id);

-- Seeker can insert their own applications
CREATE POLICY "seeker_insert_own_applications"
    ON applications FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = seeker_id);

-- Seeker can update (withdraw) their own applications
CREATE POLICY "seeker_update_own_applications"
    ON applications FOR UPDATE
    TO authenticated
    USING (auth.uid() = seeker_id)
    WITH CHECK (auth.uid() = seeker_id);

-- Recruiter can see applications to their offers
CREATE POLICY "recruiter_select_applications"
    ON applications FOR SELECT
    TO authenticated
    USING (auth.uid() = recruiter_id);

-- Recruiter can update (mark as contacted) applications to their offers
CREATE POLICY "recruiter_update_applications"
    ON applications FOR UPDATE
    TO authenticated
    USING (auth.uid() = recruiter_id)
    WITH CHECK (auth.uid() = recruiter_id);
