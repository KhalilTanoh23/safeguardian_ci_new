<?php

/**
 * Script de test de connexion à la base de données
 */

require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $pdo = $db->getConnection();

    echo "✅ Connexion à la base de données réussie!\n";

    // Tester une requête simple
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $result = $stmt->fetch();
    echo "✅ Nombre d'utilisateurs: " . $result['count'] . "\n";

    // Lister les tables
    $stmt = $pdo->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "✅ Tables dans la base de données:\n";
    foreach ($tables as $table) {
        echo "  - $table\n";
    }
} catch (Exception $e) {
    echo "❌ Erreur de connexion: " . $e->getMessage() . "\n";
    exit(1);
}
