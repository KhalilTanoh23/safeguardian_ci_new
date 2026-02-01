-- Base de données SafeGuardian CI - Version SQLite
-- Créer la base de données (fichier sera créé automatiquement)

-- Table des utilisateurs
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT,
    profile_image TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'pending', 'blocked')),
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator', 'support'))
);

-- Table des contacts d'urgence
CREATE TABLE emergency_contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    relationship TEXT,
    phone TEXT,
    email TEXT,
    priority INTEGER NOT NULL CHECK (priority BETWEEN 1 AND 7),
    is_verified INTEGER DEFAULT 0,
    can_see_live_location INTEGER DEFAULT 0,
    last_alert DATETIME,
    response_time TEXT,
    added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des alertes
CREATE TABLE alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'resolved', 'false_alarm', 'cancelled', 'expired')),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    message TEXT,
    community_alert_sent INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des notifications d'alerte
CREATE TABLE alert_notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alert_id INTEGER NOT NULL,
    contact_id INTEGER NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'responded', 'failed')),
    notified_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    responded_at DATETIME,
    response TEXT,
    FOREIGN KEY (alert_id) REFERENCES alerts(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES emergency_contacts(id) ON DELETE CASCADE
);

-- Table des objets
CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    value REAL,
    location TEXT,
    is_lost INTEGER DEFAULT 0,
    image_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des documents
CREATE TABLE documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    file_path TEXT NOT NULL,
    file_type TEXT,
    file_size INTEGER,
    is_encrypted INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des partages de documents
CREATE TABLE document_shares (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    shared_by_user_id INTEGER NOT NULL,
    shared_with_user_id INTEGER NOT NULL,
    permissions TEXT DEFAULT 'view' CHECK (permissions IN ('view', 'download', 'edit')),
    shared_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    is_active INTEGER DEFAULT 1,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_by_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_with_user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(document_id, shared_with_user_id)
);

-- Table des paramètres utilisateur
CREATE TABLE user_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE NOT NULL,
    notifications_enabled INTEGER DEFAULT 1,
    community_alerts_enabled INTEGER DEFAULT 1,
    community_radius INTEGER DEFAULT 1000,
    language TEXT DEFAULT 'fr',
    dark_mode INTEGER DEFAULT 0,
    biometric_auth INTEGER DEFAULT 0,
    emergency_timeout INTEGER DEFAULT 3,
    location_sharing INTEGER DEFAULT 1,
    auto_connect_bracelet INTEGER DEFAULT 1,
    discreet_mode INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des informations médicales d'urgence
CREATE TABLE emergency_info (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE NOT NULL,
    blood_type TEXT,
    allergies TEXT,
    medical_conditions TEXT,
    emergency_contact_note TEXT,
    address TEXT,
    workplace TEXT,
    school TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des appareils IoT
CREATE TABLE devices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    device_type TEXT DEFAULT 'bracelet' CHECK (device_type IN ('bracelet', 'watch', 'phone', 'other')),
    device_name TEXT,
    mac_address TEXT,
    is_connected INTEGER DEFAULT 0,
    last_connected DATETIME,
    battery_level INTEGER,
    firmware_version TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des logs d'activité
CREATE TABLE activity_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    action TEXT NOT NULL,
    details TEXT,
    ip_address TEXT,
    user_agent TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
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
(1, 'Marie Dupont', 'Conjoint', '+2250607080910', 'marie@example.com', 2, 1),
(1, 'Pierre Martin', 'Ami proche', '+2250102030406', 'pierre@example.com', 3, 1);

INSERT INTO user_settings (user_id) VALUES (1);
INSERT INTO emergency_info (user_id, blood_type, address) VALUES (1, 'O+', 'Abidjan, Côte d''Ivoire');
