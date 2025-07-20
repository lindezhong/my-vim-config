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
-- hibernate要求间隔必须为50
create sequence demo1_seq start with 10050 increment by 50 nocache;

CREATE TABLE relation (
    id BIGINT PRIMARY KEY , 
    remark VARCHAR(255)
);

-- 支持id自动递增使用, 用于@GeneratedValue(strategy = GenerationType.AUTO)支持
-- hibernate要求间隔必须为50
create sequence relation_seq start with 10050 increment by 50 nocache;

