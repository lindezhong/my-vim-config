CREATE TABLE demo1 (
    id BIGINT PRIMARY KEY AUTO_INCREMENT, 
    demo_key VARCHAR(255),
    demo_type  enum ('ONE','TWO'),
    original_type  enum ('ONE','TWO'),
    content VARCHAR(255),
    author VARCHAR(255),
    relation_id INT
);

-- 支持id自动递增使用, 用于@GeneratedValue(strategy = GenerationType.AUTO)支持
-- hibernate要求间隔必须为50
CREATE SEQUENCE DEMO1_SEQ START WITH 10050 INCREMENT BY 50;

CREATE TABLE relation (
    id BIGINT PRIMARY KEY AUTO_INCREMENT, 
    remark VARCHAR(255)
);

-- 支持id自动递增使用, 用于@GeneratedValue(strategy = GenerationType.AUTO)支持
-- hibernate要求间隔必须为50
CREATE SEQUENCE RELATION_SEQ START WITH 10050 INCREMENT BY 50;


