-- 更新用户资料表结构
-- 添加缺失的列
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS username VARCHAR(20);

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS display_name VARCHAR(50);

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS bio TEXT;

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}';

-- 重命名nickname为display_name（如果需要）
-- ALTER TABLE user_profiles RENAME COLUMN nickname TO display_name;

-- 创建唯一约束（先检查是否存在）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'user_profiles_user_id_unique'
    ) THEN
        ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_user_id_unique UNIQUE (user_id);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'user_profiles_username_unique'
    ) THEN
        ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_username_unique UNIQUE (username);
    END IF;
END $$;

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_username ON user_profiles(username);
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON user_profiles(created_at);

-- 创建更新时间触发器函数（如果不存在）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 删除现有触发器（如果存在）
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;

-- 创建新触发器
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 删除现有的RLS策略
DROP POLICY IF EXISTS "Users can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;

-- 创建新的RLS策略
-- 用户可以查看所有用户的基本信息（用于搜索、显示等）
CREATE POLICY "Users can view all profiles" ON user_profiles
    FOR SELECT USING (true);

-- 用户只能插入自己的资料
CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 用户只能更新自己的资料
CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- 用户只能删除自己的资料
CREATE POLICY "Users can delete own profile" ON user_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- 授予权限
GRANT ALL PRIVILEGES ON user_profiles TO authenticated;
GRANT SELECT ON user_profiles TO anon;