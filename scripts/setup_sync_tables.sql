CREATE DATABASE IF NOT EXISTS tsa_activities
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE tsa_activities;

CREATE TABLE IF NOT EXISTS sync_runs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  run_id VARCHAR(64) NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at DATETIME NULL,
  status ENUM('running','success','failed') NOT NULL DEFAULT 'running',
  flows_scope TEXT NULL,
  docs_read BIGINT NOT NULL DEFAULT 0,
  docs_written BIGINT NOT NULL DEFAULT 0,
  docs_failed BIGINT NOT NULL DEFAULT 0,
  error_message TEXT NULL,
  duration_seconds DOUBLE NULL,
  INDEX idx_run_id (run_id),
  INDEX idx_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sync_state (
  flow_name VARCHAR(128) NOT NULL PRIMARY KEY,
  last_synced_at DATETIME NULL,
  last_success_run_id VARCHAR(64) NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
