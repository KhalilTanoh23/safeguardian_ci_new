-- Base de données SafeGuardian CI - PostgreSQL
-- Version convertie depuis MySQL

-- Créer les extensions utiles (optionnel mais recommandé)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Créer les types ENUM personnalisés
CREATE TYPE user_status AS ENUM ('active', 'suspended', 'pending', 'blocked');
CREATE TYPE user_role AS ENUM ('user', 'admin', 'moderator', 'support');
CREATE TYPE alert_status AS ENUM ('pending', 'confirmed', 'resolved', 'false_alarm', 'cancelled', 'expired');
CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'responded', 'failed');
CREATE TYPE permission_type AS ENUM ('view', 'download', 'edit');
CREATE TYPE device_type AS ENUM ('bracelet', 'watch', 'phone', 'other');

-- Table des utilisateurs
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    profile_image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status user_status DEFAULT 'active',
    role user_role DEFAULT 'user'
);

-- Table des contacts d'urgence
CREATE TABLE emergency_contacts (
    id SERIAL PRIMARY KEY,
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
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des alertes
CREATE TABLE alerts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    status alert_status DEFAULT 'pending',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message TEXT,
    community_alert_sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des notifications d'alerte
CREATE TABLE alert_notifications (
    id SERIAL PRIMARY KEY,
    alert_id INT NOT NULL,
    contact_id INT NOT NULL,
    status notification_status DEFAULT 'pending',
    notified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    response TEXT,
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES emergency_contacts(id) ON DELETE CASCADE
);

-- Table des objets
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    value DECIMAL(10, 2),
    location VARCHAR(255),
    is_lost BOOLEAN DEFAULT FALSE,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des documents
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50),
    file_size INT,
    is_encrypted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des partages de documents
CREATE TABLE document_shares (
    id SERIAL PRIMARY KEY,
    document_id INT NOT NULL,
    shared_by_user_id INT NOT NULL,
    shared_with_user_id INT NOT NULL,
    permissions permission_type DEFAULT 'view',
    shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_by_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_with_user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (document_id, shared_with_user_id)
);

-- Table des paramètres utilisateur
CREATE TABLE user_settings (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    community_alerts_enabled BOOLEAN DEFAULT TRUE,
    community_radius INT DEFAULT 1000,
    language VARCHAR(10) DEFAULT 'fr',
    dark_mode BOOLEAN DEFAULT FALSE,
    biometric_auth BOOLEAN DEFAULT FALSE,
    emergency_timeout INT DEFAULT 3,
    location_sharing BOOLEAN DEFAULT TRUE,
    auto_connect_bracelet BOOLEAN DEFAULT TRUE,
    discreet_mode BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des informations médicales d'urgence
CREATE TABLE emergency_info (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    blood_type VARCHAR(10),
    allergies TEXT,
    medical_conditions TEXT,
    emergency_contact_note TEXT,
    address TEXT,
    workplace VARCHAR(255),
    school VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des appareils IoT
CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    device_type device_type DEFAULT 'bracelet',
    device_name VARCHAR(255),
    mac_address VARCHAR(17),
    is_connected BOOLEAN DEFAULT FALSE,
    last_connected TIMESTAMP NULL,
    battery_level INT,
    firmware_version VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des logs d'activité
CREATE TABLE activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Index pour améliorer les performances
CREATE INDEX idx_emergency_contacts_user_id ON emergency_contacts(user_id);
CREATE INDEX idx_emergency_contacts_priority ON emergency_contacts(priority);
CREATE INDEX idx_alerts_user_id ON alerts(user_id);
CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alert_notifications_alert_id ON alert_notifications(alert_id);
CREATE INDEX idx_alert_notifications_contact_id ON alert_notifications(contact_id);
CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_category ON items(category);
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);

-- Insertion de données de test
INSERT INTO users (email, password, first_name, last_name, phone) VALUES
('test@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jean', 'Dupont', '+2250102030405');

INSERT INTO emergency_contacts (user_id, name, relationship, phone, email, priority, is_verified) VALUES
(1, 'Marie Dupont', 'Conjoint', '+2250607080910', 'marie@example.com', 2, TRUE),
(1, 'Pierre Martin', 'Ami proche', '+2250102030406', 'pierre@example.com', 3, TRUE);

INSERT INTO user_settings (user_id) VALUES (1);
INSERT INTO emergency_info (user_id, blood_type, address) VALUES (1, 'O+', 'Abidjan, Côte d''Ivoire');
