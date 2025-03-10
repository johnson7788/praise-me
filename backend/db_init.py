# db_init.py
import os
import pymysql
from dotenv import load_dotenv
from pymysql.constants import CLIENT

# 更改不同的.env进行不同的初始化数据库
load_dotenv(dotenv_path=".env")


def get_db_config():
    return {
        "host": os.getenv("DB_HOST"),
        "port": int(os.getenv("DB_PORT", 3306)),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
        "db": os.getenv("DB_NAME"),
        "charset": "utf8mb4",
        "client_flag": CLIENT.MULTI_STATEMENTS
    }


SQL_TABLES = """
CREATE DATABASE IF NOT EXISTS `{db}` DEFAULT CHARACTER SET utf8mb4;

USE `{db}`;

CREATE TABLE IF NOT EXISTS praise_records (
    record_id VARCHAR(100) PRIMARY KEY,
    praise_type ENUM('direct', 'achievement', 'photo', 'star', 'animate'),
    content TEXT,
    style VARCHAR(20) DEFAULT 'normal',
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS praise_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES praise_records(record_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_praise_records ON praise_records(record_id, created_at);
CREATE INDEX idx_comments_record ON praise_comments(record_id);
"""

def main():
    config = get_db_config()
    db_name = config.pop("db")

    try:
        # 先连接无数据库的配置创建数据库
        conn = pymysql.connect(**{**config, "db": None})
        with conn.cursor() as cursor:
            # 替换SQL中的数据库名称占位符
            sql = SQL_TABLES.format(db=db_name)
            cursor.execute(sql)
            print(f"成功创建数据库和表：{db_name}")
        conn.commit()
    except pymysql.Error as e:
        print(f"数据库初始化失败: {str(e)}")
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    main()