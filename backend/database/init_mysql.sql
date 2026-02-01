-- ════════════════════════════════════════════════════════════════════════════
-- Script d'initialisation MySQL - SafeGuardian CI
-- Ce script crée la base de données, l'utilisateur et les tables
-- ════════════════════════════════════════════════════════════════════════════

-- 1. Créer la base de données
CREATE DATABASE IF NOT EXISTS safeguardian_ci 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE safeguardian_ci;

-- 2. Créer l'utilisateur MySQL et lui attribuer les droits
-- IMPORTANT: Remplacer le mot de passe par un mot de passe sécurisé
CREATE USER IF NOT EXISTS 'safeguardian_user'@'localhost' 
IDENTIFIED BY 'silentOps@#';

-- Accorder tous les droits sur la base de données
GRANT ALL PRIVILEGES ON safeguardian_ci.* 
TO 'safeguardian_user'@'localhost';

-- Appliquer les changements de droits
FLUSH PRIVILEGES;

-- ════════════════════════════════════════════════════════════════════════════
-- CRÉATION DES TABLES
-- ════════════════════════════════════════════════════════════════════════════

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    profile_image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active', 'suspended', 'pending', 'blocked') DEFAULT 'active',
    role ENUM('user', 'admin', 'moderator', 'support') DEFAULT 'user',
    INDEX idx_email (email),
    INDEX idx_status (status)
);

-- Table des contacts d'urgence
CREATE TABLE IF NOT EXISTS emergency_contacts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    relationship VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    priority INT NOT NULL CHECK (priority BETWEEN 1 AND 7),
    is_verified BOOLEAN DEFAULT FALSE,
    can_see_live_location BOOLEAN DEFAULT FALSE,
    last_alert TIMESTAMP NULL,
    response_time VARCHAR(50),
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_priority (priority)
);

-- Table des alertes
CREATE TABLE IF NOT EXISTS alerts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    status ENUM('pending', 'confirmed', 'resolved', 'false_alarm', 'cancelled', 'expired') DEFAULT 'pending',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message TEXT,
    community_alert_sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_timestamp (timestamp)
);

-- Table des notifications d'alerte
CREATE TABLE IF NOT EXISTS alert_notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    alert_id INT NOT NULL,
    contact_id INT NOT NULL,
    status ENUM('pending', 'sent', 'responded', 'failed') DEFAULT 'pending',
    notified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    response TEXT,
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES emergency_contacts(id) ON DELETE CASCADE,
    INDEX idx_alert_id (alert_id),
    INDEX idx_contact_id (contact_id),
    INDEX idx_status (status)
);

-- Table des objets
CREATE TABLE IF NOT EXISTS items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    value DECIMAL(10, 2),
    location VARCHAR(255),
    is_lost BOOLEAN DEFAULT FALSE,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_lost (is_lost)
);

-- Table des documents
CREATE TABLE IF NOT EXISTS documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50),
    file_size INT,
    is_encrypted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- Table des partages de documents
CREATE TABLE IF NOT EXISTS document_shares (
    id INT PRIMARY KEY AUTO_INCREMENT,
    document_id INT NOT NULL,
    shared_by_user_id INT NOT NULL,
    shared_with_user_id INT NOT NULL,
    permissions ENUM('view', 'download', 'edit') DEFAULT 'view',
    shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_by_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_with_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_document_id (document_id),
    INDEX idx_shared_with_user_id (shared_with_user_id)
);

-- Table des localisations
CREATE TABLE IF NOT EXISTS locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accuracy FLOAT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    device_id VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp)
);

-- Table des lieux d'intérêt
CREATE TABLE IF NOT EXISTS places (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    category VARCHAR(100),
    is_safe BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_coordinates (latitude, longitude)
);

-- Table des historiques d'activités
CREATE TABLE IF NOT EXISTS activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Table des paramètres utilisateur
CREATE TABLE IF NOT EXISTS user_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    location_sharing_enabled BOOLEAN DEFAULT FALSE,
    emergency_alert_enabled BOOLEAN DEFAULT TRUE,
    push_notifications_enabled BOOLEAN DEFAULT TRUE,
    sms_notifications_enabled BOOLEAN DEFAULT FALSE,
    email_notifications_enabled BOOLEAN DEFAULT TRUE,
    theme VARCHAR(50) DEFAULT 'light',
    language VARCHAR(10) DEFAULT 'en',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- Table des téléchargements de sessions
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    payload LONGTEXT,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity)
);

-- Table des audits de sécurité
CREATE TABLE IF NOT EXISTS security_audits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    event_type VARCHAR(100) NOT NULL,
    status VARCHAR(50),
    ip_address VARCHAR(45),
    user_agent TEXT,
    details JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at)
);

-- ════════════════════════════════════════════════════════════════════════════
-- CONFIRMATIONS
-- ════════════════════════════════════════════════════════════════════════════

-- Afficher les tables créées
SHOW TABLES;

-- Afficher l'utilisateur créé
SELECT user FROM mysql.user WHERE user = 'safeguardian_user';

-- ════════════════════════════════════════════════════════════════════════════
-- DONNÉES DE TEST (Optionnel - Décommenter pour tester)
-- ════════════════════════════════════════════════════════════════════════════

-- INSERT INTO users (email, password, first_name, last_name, phone, status, role) VALUES
-- ('admin@safeguardian.ci', '$2y$10$example_hashed_password', 'Admin', 'User', '+225XXXXXXXXX', 'active', 'admin'),
-- ('user1@safeguardian.ci', '$2y$10$example_hashed_password', 'Jean', 'Dupont', '+225XXXXXXXXX', 'active', 'user');
