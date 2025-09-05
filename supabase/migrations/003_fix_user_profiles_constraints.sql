-- 修复user_profiles表的约束问题
-- 确保id字段有正确的默认值和约束

-- 首先删除可能存在的问题约束
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_pkey CASCADE;

-- 确保id列有正确的默认值
ALTER TABLE user_profiles ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 重新添加主键约束
ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);

-- 确保user_id列不为空且唯一
ALTER TABLE user_profiles ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_user_id_unique;
ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_user_id_unique UNIQUE (user_id);

-- 确保username列不为空且唯一
ALTER TABLE user_profiles ALTER COLUMN username SET NOT NULL;
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_username_unique;
ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_username_unique UNIQUE (username);

-- 确保created_at和updated_at有默认值
ALTER TABLE user_profiles ALTER COLUMN created_at SET DEFAULT NOW();
ALTER TABLE user_profiles ALTER COLUMN updated_at SET DEFAULT NOW();

-- 重新创建外键约束
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_user_id_fkey;
ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- 确保RLS策略正确
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;
CREATE POLICY "Users can delete own profile" ON user_profiles
    FOR DELETE USING (auth.uid() = user_id);

-- 清理可能存在的无效数据
DELETE FROM user_profiles WHERE id IS NULL OR user_id IS NULL OR username IS NULL;

-- 输出修复完成信息
DO $$
BEGIN
    RAISE NOTICE 'user_profiles表约束修复完成';
END $$;