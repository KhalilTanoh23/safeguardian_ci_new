<?php

/**
 * Script de test de connexion à Supabase
 * Vérifier que la connexion PostgreSQL fonctionne avant le déploiement
 */

require_once __DIR__ . '/config/env.php';

echo "═══════════════════════════════════════════════════════════════\n";
echo "TEST DE CONNEXION À SUPABASE\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

// Vérifier que PDO pgsql est disponible
echo "1️⃣  Vérification de l'extension PDO PostgreSQL...\n";
$drivers = PDO::getAvailableDrivers();
if (in_array('pgsql', $drivers)) {
    echo "✅ PDO PostgreSQL disponible\n\n";
} else {
    echo "❌ ERREUR: PDO PostgreSQL non disponible!\n";
    echo "Drivers disponibles: " . implode(', ', $drivers) . "\n";
    exit(1);
}

// Charger la configuration
echo "2️⃣  Lecture de la configuration d'environnement...\n";
$databaseUrl = Config::get('DATABASE_URL');
if ($databaseUrl) {
    echo "✅ DATABASE_URL trouvée\n";
    echo "   Valeur masquée: " . substr($databaseUrl, 0, 30) . "***\n\n";
} else {
    echo "❌ DATABASE_URL non configurée dans .env\n";
    exit(1);
}

// Parser l'URL
echo "3️⃣  Parsing de la DATABASE_URL...\n";
$parts = parse_url($databaseUrl);
$scheme = $parts['scheme'] ?? null;
$host = $parts['host'] ?? null;
$port = $parts['port'] ?? '5432';
$db = isset($parts['path']) ? ltrim($parts['path'], '/') : null;
$user = $parts['user'] ?? null;
$pass = $parts['pass'] ?? null;

echo "   Schéma: $scheme\n";
echo "   Host: $host\n";
echo "   Port: $port\n";
echo "   Database: $db\n";
echo "   User: $user\n";
echo "   Pass: " . (strlen($pass) ? str_repeat('*', strlen($pass)) : 'vide') . "\n\n";

if (!in_array($scheme, ['postgres', 'postgresql', 'pgsql'])) {
    echo "❌ Schéma non valide: $scheme\n";
    exit(1);
}

// Construire le DSN
$dsn = "pgsql:host=$host;port=$port;dbname=$db";

// Tenter la connexion
echo "4️⃣  Tentative de connexion à Supabase...\n";
try {
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    echo "✅ Connexion réussie!\n\n";
} catch (PDOException $e) {
    echo "❌ ERREUR DE CONNEXION:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
}

// Vérifier les tables
echo "5️⃣  Vérification des tables...\n";
try {
    $stmt = $pdo->query("
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        ORDER BY table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (count($tables) > 0) {
        echo "✅ " . count($tables) . " tables trouvées:\n";
        foreach ($tables as $table) {
            echo "   - $table\n";
        }
        echo "\n";
    } else {
        echo "⚠️  Aucune table trouvée!\n\n";
    }
} catch (PDOException $e) {
    echo "⚠️  Erreur lors de la requête: " . $e->getMessage() . "\n\n";
}

// Tester une requête simple
echo "6️⃣  Test d'une requête simple...\n";
try {
    $stmt = $pdo->query("SELECT 1 as test");
    $result = $stmt->fetch();
    echo "✅ Requête réussie: " . json_encode($result) . "\n\n";
} catch (PDOException $e) {
    echo "❌ ERREUR: " . $e->getMessage() . "\n\n";
    exit(1);
}

// Tester l'accès à la table users
echo "7️⃣  Vérification de la table users...\n";
try {
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $result = $stmt->fetch();
    echo "✅ Nombre d'utilisateurs: " . $result['count'] . "\n\n";
} catch (PDOException $e) {
    echo "⚠️  La table users n'existe pas ou erreur: " . $e->getMessage() . "\n";
    echo "   → Importez le schéma_postgresql.sql dans Supabase SQL Editor\n\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo "✅ TOUS LES TESTS PASSÉS - CONNEXION OK!\n";
echo "═══════════════════════════════════════════════════════════════\n";
