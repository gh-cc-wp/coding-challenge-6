CREATE schema IF NOT EXISTS cc_system;

CREATE TABLE IF NOT EXISTS cc_system.sample_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO cc_system.sample_table (name) VALUES ('test_record_1'), ('test_record_2');
