CREATE TABLE demo1 (
    id BIGINT PRIMARY KEY , 
    demo_key VARCHAR(255),
    demo_type  enum ('ONE','TWO'),
    original_type  enum ('ONE','TWO'),
    content VARCHAR(255),
    author VARCHAR(255),
    relation_id INT
);

-- 支持id自动递增使用, 用于@GeneratedValue(strategy = GenerationType.AUTO)支持
CREATE TABLE demo1_seq (next_val bigint);
INSERT INTO demo1_seq (next_val) 
-- hibernate要求间隔必须为50
SELECT 10050 
WHERE NOT EXISTS (SELECT 1 FROM demo1_seq);

CREATE TABLE relation (
    id BIGINT PRIMARY KEY , 
    remark VARCHAR(255)
);

-- 支持id自动递增使用, 用于@GeneratedValue(strategy = GenerationType.AUTO)支持
-- hibernate要求间隔必须为50
CREATE TABLE relation_seq (next_val bigint);
INSERT INTO relation_seq (next_val) 
-- hibernate要求间隔必须为50
SELECT 10050 
WHERE NOT EXISTS (SELECT 1 FROM relation_seq);

