-- AI Study Workflow - Database Schema
-- PostgreSQL tables for chat history and analytics

-- ============================================================================
-- Chat History Table
-- ============================================================================
-- Stores all student-AI conversations

CREATE TABLE IF NOT EXISTS chat_history (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    message_id VARCHAR(255) UNIQUE NOT NULL,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    key_concepts JSONB,
    action_items JSONB,
    tools_used JSONB,
    response_length INTEGER,
    complexity VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for faster queries
    INDEX idx_session_id (session_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_complexity (complexity)
);

-- Add comments for documentation
COMMENT ON TABLE chat_history IS 'Stores all student-AI tutoring conversations';
COMMENT ON COLUMN chat_history.session_id IS 'Unique identifier for conversation session';
COMMENT ON COLUMN chat_history.user_id IS 'User identifier (can be anonymous)';
COMMENT ON COLUMN chat_history.message_id IS 'Unique message identifier';
COMMENT ON COLUMN chat_history.key_concepts IS 'JSON array of key concepts mentioned';
COMMENT ON COLUMN chat_history.action_items IS 'JSON array of suggested actions';
COMMENT ON COLUMN chat_history.tools_used IS 'JSON array of AI tools used in response';
COMMENT ON COLUMN chat_history.complexity IS 'Response complexity: simple, moderate, detailed';

-- ============================================================================
-- User Progress Table
-- ============================================================================
-- Tracks student learning progress

CREATE TABLE IF NOT EXISTS user_progress (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    topic VARCHAR(500) NOT NULL,
    subject VARCHAR(255),
    status VARCHAR(50) DEFAULT 'in_progress',
    quiz_score INTEGER,
    attempts INTEGER DEFAULT 1,
    time_spent_minutes INTEGER,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_progress_user_id (user_id),
    INDEX idx_user_progress_topic (topic),
    INDEX idx_user_progress_status (status),
    INDEX idx_user_progress_subject (subject)
);

COMMENT ON TABLE user_progress IS 'Tracks student learning progress by topic';
COMMENT ON COLUMN user_progress.status IS 'Progress status: in_progress, completed, needs_review';

-- ============================================================================
-- Quiz Results Table
-- ============================================================================
-- Stores quiz attempts and scores

CREATE TABLE IF NOT EXISTS quiz_results (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    session_id VARCHAR(255),
    topic VARCHAR(500) NOT NULL,
    subject VARCHAR(255),
    difficulty VARCHAR(50),
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER NOT NULL,
    score_percentage DECIMAL(5,2),
    time_taken_seconds INTEGER,
    questions JSONB,
    answers JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_quiz_user_id (user_id),
    INDEX idx_quiz_topic (topic),
    INDEX idx_quiz_created_at (created_at)
);

COMMENT ON TABLE quiz_results IS 'Stores quiz attempts and detailed results';
COMMENT ON COLUMN quiz_results.questions IS 'JSON array of quiz questions';
COMMENT ON COLUMN quiz_results.answers IS 'JSON array of user answers with correctness';

-- ============================================================================
-- Research Papers Table
-- ============================================================================
-- Stores fetched research papers from arXiv

CREATE TABLE IF NOT EXISTS research_papers (
    id SERIAL PRIMARY KEY,
    arxiv_id VARCHAR(50) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    authors TEXT[],
    summary TEXT,
    published DATE,
    updated DATE,
    categories TEXT[],
    primary_category VARCHAR(50),
    pdf_link TEXT,
    abs_link TEXT,
    topic_id VARCHAR(100),
    topic_name VARCHAR(255),
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_papers_arxiv_id (arxiv_id),
    INDEX idx_papers_published (published),
    INDEX idx_papers_categories (categories),
    INDEX idx_papers_topic_id (topic_id)
);

COMMENT ON TABLE research_papers IS 'Stores research papers from arXiv API';
COMMENT ON COLUMN research_papers.authors IS 'Array of author names';
COMMENT ON COLUMN research_papers.categories IS 'Array of arXiv categories (e.g., cs.AI, cs.LG)';

-- ============================================================================
-- Study Sessions Table
-- ============================================================================
-- Tracks overall study sessions

CREATE TABLE IF NOT EXISTS study_sessions (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) UNIQUE NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    message_count INTEGER DEFAULT 0,
    topics_covered TEXT[],
    subjects TEXT[],
    tools_used TEXT[],
    avg_complexity VARCHAR(50),
    
    INDEX idx_sessions_user_id (user_id),
    INDEX idx_sessions_started_at (started_at)
);

COMMENT ON TABLE study_sessions IS 'Tracks study session metadata';

-- ============================================================================
-- Analytics Views
-- ============================================================================

-- View: User statistics
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    user_id,
    COUNT(DISTINCT session_id) as total_sessions,
    COUNT(*) as total_messages,
    AVG(response_length) as avg_response_length,
    COUNT(DISTINCT DATE(created_at)) as active_days,
    MIN(created_at) as first_interaction,
    MAX(created_at) as last_interaction
FROM chat_history
GROUP BY user_id;

-- View: Popular topics
CREATE OR REPLACE VIEW popular_topics AS
SELECT 
    topic,
    subject,
    COUNT(*) as study_count,
    AVG(quiz_score) as avg_score,
    COUNT(DISTINCT user_id) as unique_users
FROM user_progress
GROUP BY topic, subject
ORDER BY study_count DESC;

-- View: Daily activity
CREATE OR REPLACE VIEW daily_activity AS
SELECT 
    DATE(created_at) as activity_date,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT session_id) as total_sessions,
    COUNT(*) as total_messages,
    AVG(response_length) as avg_response_length
FROM chat_history
GROUP BY DATE(created_at)
ORDER BY activity_date DESC;

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Function to get user's weak areas
CREATE OR REPLACE FUNCTION get_weak_areas(p_user_id VARCHAR)
RETURNS TABLE (
    topic VARCHAR,
    subject VARCHAR,
    avg_score DECIMAL,
    attempt_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.topic,
        up.subject,
        AVG(up.quiz_score)::DECIMAL as avg_score,
        COUNT(*)::INTEGER as attempt_count
    FROM user_progress up
    WHERE up.user_id = p_user_id
        AND up.quiz_score IS NOT NULL
    GROUP BY up.topic, up.subject
    HAVING AVG(up.quiz_score) < 70
    ORDER BY avg_score ASC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Function to get session summary
CREATE OR REPLACE FUNCTION get_session_summary(p_session_id VARCHAR)
RETURNS TABLE (
    session_id VARCHAR,
    user_id VARCHAR,
    message_count BIGINT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    topics TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ch.session_id,
        ch.user_id,
        COUNT(*) as message_count,
        MIN(ch.created_at) as start_time,
        MAX(ch.created_at) as end_time,
        ARRAY_AGG(DISTINCT 
            CASE 
                WHEN ch.key_concepts IS NOT NULL 
                THEN ch.key_concepts->>0 
            END
        ) FILTER (WHERE ch.key_concepts IS NOT NULL) as topics
    FROM chat_history ch
    WHERE ch.session_id = p_session_id
    GROUP BY ch.session_id, ch.user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Sample Data (Optional - for testing)
-- ============================================================================

-- Uncomment to insert sample data
/*
INSERT INTO chat_history (session_id, user_id, message_id, user_message, ai_response, key_concepts, complexity)
VALUES 
    ('session_test_001', 'user_001', 'msg_001', 'What is photosynthesis?', 
     'Photosynthesis is the process by which plants convert light energy into chemical energy...', 
     '["Photosynthesis", "Chlorophyll", "ATP"]'::jsonb, 'moderate'),
    ('session_test_001', 'user_001', 'msg_002', 'Can you explain it simply?', 
     'Think of it like a plant making its own food using sunlight...', 
     '["Light energy", "Glucose", "Oxygen"]'::jsonb, 'simple');

INSERT INTO user_progress (user_id, topic, subject, status, quiz_score)
VALUES 
    ('user_001', 'Photosynthesis', 'Biology', 'completed', 85),
    ('user_001', 'Cell Division', 'Biology', 'in_progress', NULL);

INSERT INTO quiz_results (user_id, topic, subject, difficulty, total_questions, correct_answers, score_percentage)
VALUES 
    ('user_001', 'Photosynthesis', 'Biology', 'medium', 10, 8, 80.00),
    ('user_001', 'Cell Division', 'Biology', 'easy', 5, 5, 100.00);
*/

-- ============================================================================
-- Indexes for Performance
-- ============================================================================

-- Additional composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_chat_history_session_created ON chat_history(session_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_history_user_created ON chat_history(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_topic ON user_progress(user_id, topic);

-- ============================================================================
-- Cleanup/Maintenance Functions
-- ============================================================================

-- Function to clean up old sessions (older than 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_data(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM chat_history 
    WHERE created_at < CURRENT_TIMESTAMP - (days_to_keep || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Permissions (Optional - for production)
-- ============================================================================

-- Grant permissions to n8n user
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO "n8n-user";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "n8n-user";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO "n8n-user";

-- ============================================================================
-- Success Message
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Database schema created successfully!';
    RAISE NOTICE '📊 Tables created: chat_history, user_progress, quiz_results, research_papers, study_sessions';
    RAISE NOTICE '📈 Views created: user_stats, popular_topics, daily_activity';
    RAISE NOTICE '🔧 Functions created: get_weak_areas, get_session_summary, cleanup_old_data';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Your database is ready for the Study Assistant workflow!';
END $$;
