<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "🧪 SafeGuardian Backend Tests\n";
echo "==============================\n\n";

// Test 1: Database Connection
echo "1️⃣ Testing Database Connection...\n";
require 'config/Database.php';
try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    if ($conn) {
        echo "✅ Database connection successful\n";
    } else {
        echo "❌ Database connection failed\n";
    }
} catch (Exception $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
}

echo "\n";

// Test 2: Validator Class
echo "2️⃣ Testing Validator Class...\n";
require 'utils/Validator.php';

$tests = [
    'Valid Email' => Validator::validateEmail('test@example.com'),
    'Invalid Email' => Validator::validateEmail('invalid'),
    'Valid Password' => Validator::validatePassword('Test123!'),
    'Short Password' => Validator::validatePassword('test'),
    'Valid Phone' => Validator::validatePhone('+33612345678'),
    'Valid Name' => Validator::validateName('John Doe'),
    'Valid Coordinates' => Validator::validateCoordinates(48.8566, 2.3522),
    'Valid Message' => Validator::validateMessage('This is a test'),
    'Valid Priority' => Validator::validatePriority(3),
    'Valid Status' => Validator::validateStatus('active'),
];

foreach ($tests as $name => $result) {
    $status = $result['valid'] ? '✅' : '❌';
    echo $status . " $name\n";
}

echo "\n";

// Test 3: AuthMiddleware
echo "3️⃣ Testing AuthMiddleware...\n";
require 'middleware/AuthMiddleware.php';
echo "✅ AuthMiddleware loaded successfully\n";

echo "\n";

// Test 4: Controllers
echo "4️⃣ Testing Controllers...\n";
$controllers = [
    'AuthController' => 'controllers/AuthControllerImpl.php',
    'AlertController' => 'controllers/AlertControllerImpl.php',
    'EmergencyContactController' => 'controllers/EmergencyContactControllerImpl.php',
    'ItemController' => 'controllers/ItemControllerImpl.php',
    'DocumentController' => 'controllers/DocumentControllerImpl.php',
    'LocationController' => 'controllers/LocationControllerImpl.php',
];

foreach ($controllers as $name => $file) {
    if (file_exists($file)) {
        require_once $file;
        if (class_exists($name)) {
            echo "✅ $name loaded\n";
        } else {
            echo "❌ $name class not found\n";
        }
    } else {
        echo "❌ $file not found\n";
    }
}

echo "\n";

// Test 5: Database Tables
echo "5️⃣ Checking Database Tables...\n";
try {
    require_once 'config/env.php';
    $dbName = Config::get('DB_NAME', 'safeguardian_prod');

    $query = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ?";
    $stmt = $conn->prepare($query);
    $stmt->execute([$dbName]);
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

    echo "✅ Found " . count($tables) . " tables in '$dbName'\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

echo "\n";
echo "✅ Backend Tests Complete!\n";
