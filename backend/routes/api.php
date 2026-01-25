<?php
/**
 * ════════════════════════════════════════════════════════════════════════════
 * Router des routes API
 * Ce fichier gère le routage de toutes les requêtes API
 * ════════════════════════════════════════════════════════════════════════════
 */

// ────────────────────────────────────────────────────────────────────────────
// SECTION: Initialisation
// ────────────────────────────────────────────────────────────────────────────

// Charger le fichier bootstrap qui initialise les autoloaders et connexions
require_once __DIR__ . '/../bootstrap.php';

// Définir le type de contenu de la réponse comme JSON avec encodage UTF-8
// Cela indique au client que la réponse est au format JSON
header('Content-Type: application/json;charset=utf-8');

// ────────────────────────────────────────────────────────────────────────────
// SECTION: Gestion des erreurs PHP
// ────────────────────────────────────────────────────────────────────────────

// Définir un gestionnaire d'erreur personnalisé pour intercepter toutes les erreurs
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    // Vérifier si on est en mode développement
    if (Config::isDevelopment()) {
        // En développement, afficher le message d'erreur complet
        ResponseHandler::error("Erreur: $errstr", 500);
    } else {
        // En production, afficher une erreur générique pour la sécurité
        ResponseHandler::internalError();
    }
});


// ────────────────────────────────────────────────────────────────────────────
// SECTION: Gestion des exceptions
// ────────────────────────────────────────────────────────────────────────────

// Définir un gestionnaire d'exception personnalisé pour les exceptions non capturées
set_exception_handler(function($exception) {
    // Vérifier si on est en mode développement
    if (Config::isDevelopment()) {
        // En développement, afficher le message d'exception complet
        ResponseHandler::error($exception->getMessage(), 500);
    } else {
        // En production, afficher une erreur générique pour la sécurité
        ResponseHandler::internalError();
    }
});

// ────────────────────────────────────────────────────────────────────────────
// SECTION: Extraction de la méthode HTTP et du chemin
// ────────────────────────────────────────────────────────────────────────────

// Récupérer la méthode HTTP de la requête (GET, POST, PUT, DELETE, etc.)
$method = $_SERVER['REQUEST_METHOD'];

// Récupérer l'URI complète de la requête (chemin + paramètres)
$uri = $_SERVER['REQUEST_URI'];

// Supprimer le préfixe '/api' du chemin pour obtenir uniquement la route
$uri = str_replace('/api', '', $uri);

// Supprimer les paramètres de requête (après le ?) car on utilise JSON pour les données
$uri = explode('?', $uri)[0];

// Diviser le chemin restant en segments pour identifier la ressource et les paramètres
// Exemple: /contacts/123 devient ['contacts', '123']
$uri_parts = explode('/', trim($uri, '/'));


// ═════════════════════════════════════════════════════════════════════════════
// SECTION: Routeur principal
// Diriger les requêtes vers le contrôleur approprié en fonction du type
// ═════════════════════════════════════════════════════════════════════════════

try {
    // Vérifier le premier segment du chemin pour déterminer le type de ressource
    switch ($uri_parts[0]) {
        // ───── Route Authentification
        case 'auth':
            // Créer une instance du contrôleur d'authentification
            $authController = new AuthController();
            // Déléguer au gestionnaire spécialisé des routes d'authentification
            handleAuthRoutes($method, $uri_parts, $authController);
            break;

        // ───── Route Contacts d'urgence
        case 'contacts':
            // Créer une instance du contrôleur de contacts d'urgence
            $contactController = new EmergencyContactController();
            // Déléguer au gestionnaire spécialisé des routes de contacts
            handleContactRoutes($method, $uri_parts, $contactController);
            break;

        // ───── Route Alertes
        case 'alerts':
            // Créer une instance du contrôleur d'alertes
            $alertController = new AlertController();
            // Déléguer au gestionnaire spécialisé des routes d'alertes
            handleAlertRoutes($method, $uri_parts, $alertController);
            break;

        // ───── Route Objets
        case 'items':
            // Créer une instance du contrôleur d'objets
            $itemController = new ItemController();
            // Déléguer au gestionnaire spécialisé des routes d'objets
            handleItemRoutes($method, $uri_parts, $itemController);
            break;

        // ───── Route Documents
        case 'documents':
            // Créer une instance du contrôleur de documents
            $documentController = new DocumentController();
            // Déléguer au gestionnaire spécialisé des routes de documents
            handleDocumentRoutes($method, $uri_parts, $documentController);
            break;

        // ───── Route inexistante
        default:
            // Définir le code HTTP 404 (Non trouvé)
            http_response_code(404);
            // Retourner un message d'erreur en JSON
            echo json_encode(['error' => 'Route non trouvée']);
            break;
    }
} catch (Exception $e) {
    // En cas d'exception non gérée, retourner une erreur 500
    http_response_code(500);
    // Retourner un message d'erreur générique
    echo json_encode(['error' => 'Erreur interne du serveur']);
}


// ═════════════════════════════════════════════════════════════════════════════
// FONCTION: handleAuthRoutes
// Traiter les routes d'authentification (register, login, profile)
// ═════════════════════════════════════════════════════════════════════════════

function handleAuthRoutes($method, $uri_parts, $controller) {
    // Vérifier la méthode HTTP utilisée
    switch ($method) {
        // ───── Cas POST: Requêtes de création
        case 'POST':
            // Lire les données JSON envoyées dans le corps de la requête
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Vérifier quel endpoint POST est demandé
            if ($uri_parts[1] == 'register') {
                // Appeler la méthode d'enregistrement du contrôleur
                $result = $controller->register($data);
            } elseif ($uri_parts[1] == 'login') {
                // Appeler la méthode de connexion du contrôleur
                $result = $controller->login($data);
            } else {
                // L'endpoint POST n'existe pas
                http_response_code(404);
                // Retourner un message d'erreur
                $result = ['error' => 'Route non trouvée'];
            }
            break;

        // ───── Cas GET: Requêtes de lecture
        case 'GET':
            // Vérifier quel endpoint GET est demandé
            if ($uri_parts[1] == 'profile') {
                // Authentifier l'utilisateur à partir du token JWT
                $userId = AuthMiddleware::authenticate();
                // Récupérer le profil de l'utilisateur connecté
                $result = $controller->getProfile($userId);
            } else {
                // L'endpoint GET n'existe pas
                http_response_code(404);
                // Retourner un message d'erreur
                $result = ['error' => 'Route non trouvée'];
            }
            break;

        // ───── Cas par défaut: Méthode HTTP non autorisée
        default:
            // Définir le code HTTP 405 (Méthode non autorisée)
            http_response_code(405);
            // Retourner un message d'erreur
            $result = ['error' => 'Méthode non autorisée'];
            break;
    }
    // Encoder le résultat en JSON et l'envoyer au client
    echo json_encode($result);
}


// ═════════════════════════════════════════════════════════════════════════════
// FONCTION: handleContactRoutes
// Traiter les routes des contacts d'urgence (CRUD)
// ═════════════════════════════════════════════════════════════════════════════

function handleContactRoutes($method, $uri_parts, $controller) {
    // Authentifier l'utilisateur avant toute opération (sécurité)
    $userId = AuthMiddleware::authenticate();

    // Vérifier la méthode HTTP utilisée
    switch ($method) {
        // ───── Cas GET: Récupérer les contacts
        case 'GET':
            // Appeler la méthode pour récupérer tous les contacts de l'utilisateur
            $result = $controller->getContacts($userId);
            break;

        // ───── Cas POST: Créer un nouveau contact
        case 'POST':
            // Lire les données JSON du nouveau contact
            $data = json_decode(file_get_contents('php://input'), true);
            // Appeler la méthode pour ajouter un nouveau contact
            $result = $controller->addContact($userId, $data);
            break;

        // ───── Cas PUT: Mettre à jour un contact existant
        case 'PUT':
            // Vérifier si l'ID du contact à modifier est fourni dans l'URI
            if (isset($uri_parts[1])) {
                // Lire les données mises à jour du contact
                $data = json_decode(file_get_contents('php://input'), true);
                // Appeler la méthode pour mettre à jour le contact
                $result = $controller->updateContact($userId, $uri_parts[1], $data);
            } else {
                // L'ID du contact n'a pas été fourni
                http_response_code(400);
                // Retourner un message d'erreur
                $result = ['error' => 'ID du contact requis'];
            }
            break;

        // ───── Cas DELETE: Supprimer un contact
        case 'DELETE':
            // Vérifier si l'ID du contact à supprimer est fourni
            if (isset($uri_parts[1])) {
                // Appeler la méthode pour supprimer le contact
                $result = $controller->deleteContact($userId, $uri_parts[1]);
            } else {
                // L'ID du contact n'a pas été fourni
                http_response_code(400);
                // Retourner un message d'erreur
                $result = ['error' => 'ID du contact requis'];
            }
            break;

        // ───── Cas par défaut: Méthode HTTP non autorisée
        default:
            // Définir le code HTTP 405
            http_response_code(405);
            // Retourner un message d'erreur
            $result = ['error' => 'Méthode non autorisée'];
            break;
    }
    // Encoder le résultat en JSON et l'envoyer au client
    echo json_encode($result);
}


// ═════════════════════════════════════════════════════════════════════════════
// FONCTION: handleAlertRoutes
// Traiter les routes des alertes (GET, POST, PUT)
// ═════════════════════════════════════════════════════════════════════════════

function handleAlertRoutes($method, $uri_parts, $controller) {
    // Vérifier la méthode HTTP utilisée
    switch ($method) {
        // ───── Cas GET: Récupérer les alertes
        case 'GET':
            // Authentifier l'utilisateur qui demande les alertes
            $userId = AuthMiddleware::authenticate();
            // Appeler la méthode pour récupérer toutes les alertes de l'utilisateur
            $result = $controller->getAlerts($userId);
            break;

        // ───── Cas POST: Créer une nouvelle alerte
        case 'POST':
            // Authentifier l'utilisateur qui crée l'alerte
            $userId = AuthMiddleware::authenticate();
            // Lire les données JSON de la nouvelle alerte
            $data = json_decode(file_get_contents('php://input'), true);
            // Appeler la méthode pour créer une alerte
            $result = $controller->createAlert($userId, $data);
            break;

        // ───── Cas PUT: Mettre à jour le statut d'une alerte
        case 'PUT':
            // Vérifier si l'ID de l'alerte à modifier est fourni
            if (isset($uri_parts[1])) {
                // Authentifier l'utilisateur
                $userId = AuthMiddleware::authenticate();
                // Lire les données mises à jour (le nouveau statut)
                $data = json_decode(file_get_contents('php://input'), true);
                // Appeler la méthode pour mettre à jour le statut de l'alerte
                $result = $controller->updateAlertStatus($userId, $uri_parts[1], $data['status']);
            } else {
                // L'ID de l'alerte n'a pas été fourni
                http_response_code(400);
                // Retourner un message d'erreur
                $result = ['error' => 'ID de l\'alerte requis'];
            }
            break;

        // ───── Cas par défaut: Méthode HTTP non autorisée
        default:
            // Définir le code HTTP 405
            http_response_code(405);
            // Retourner un message d'erreur
            $result = ['error' => 'Méthode non autorisée'];
            break;
    }
    // Encoder le résultat en JSON et l'envoyer au client
    echo json_encode($result);
}


// ═════════════════════════════════════════════════════════════════════════════
// FONCTION: handleItemRoutes
// Traiter les routes des objets (CRUD + marquer comme perdu)
// ═════════════════════════════════════════════════════════════════════════════

function handleItemRoutes($method, $uri_parts, $controller) {
    // Authentifier l'utilisateur avant toute opération
    $userId = AuthMiddleware::authenticate();

    // Vérifier la méthode HTTP utilisée
    switch ($method) {
        // ───── Cas GET: Récupérer les objets de l'utilisateur
        case 'GET':
            // Appeler la méthode pour récupérer tous les objets de l'utilisateur
            $result = $controller->getItems($userId);
            break;

        // ───── Cas POST: Ajouter un nouvel objet
        case 'POST':
            // Lire les données JSON du nouvel objet
            $data = json_decode(file_get_contents('php://input'), true);
            // Appeler la méthode pour ajouter un nouvel objet
            $result = $controller->addItem($userId, $data);
            break;

        // ───── Cas PUT: Mettre à jour ou marquer un objet comme perdu
        case 'PUT':
            // Vérifier si l'ID de l'objet est fourni
            if (isset($uri_parts[1])) {
                // Lire les données mises à jour de l'objet
                $data = json_decode(file_get_contents('php://input'), true);
                
                // Vérifier si la requête cherche à marquer l'objet comme perdu
                if (isset($data['isLost'])) {
                    // Appeler la méthode pour marquer l'objet comme perdu ou retrouvé
                    $result = $controller->markAsLost($userId, $uri_parts[1], $data['isLost']);
                } else {
                    // Appeler la méthode pour mettre à jour les autres propriétés de l'objet
                    $result = $controller->updateItem($userId, $uri_parts[1], $data);
                }
            } else {
                // L'ID de l'objet n'a pas été fourni
                http_response_code(400);
                // Retourner un message d'erreur
                $result = ['error' => 'ID de l\'objet requis'];
            }
            break;

        // ───── Cas DELETE: Supprimer un objet
        case 'DELETE':
            // Vérifier si l'ID de l'objet à supprimer est fourni
            if (isset($uri_parts[1])) {
                // Appeler la méthode pour supprimer l'objet
                $result = $controller->deleteItem($userId, $uri_parts[1]);
            } else {
                // L'ID de l'objet n'a pas été fourni
                http_response_code(400);
                // Retourner un message d'erreur
                $result = ['error' => 'ID de l\'objet requis'];
            }
            break;

        // ───── Cas par défaut: Méthode HTTP non autorisée
        default:
            // Définir le code HTTP 405
            http_response_code(405);
            // Retourner un message d'erreur
            $result = ['error' => 'Méthode non autorisée'];
            break;
    }
    // Encoder le résultat en JSON et l'envoyer au client
    echo json_encode($result);
}


// ═════════════════════════════════════════════════════════════════════════════
// FONCTION: handleDocumentRoutes
// Traiter les routes des documents (GET avec téléchargement, POST, PUT, DELETE)
// ═════════════════════════════════════════════════════════════════════════════

function handleDocumentRoutes($method, $uri_parts, $controller) {
    // Authentifier l'utilisateur avant toute opération
    $userId = AuthMiddleware::authenticate();

    // Vérifier la méthode HTTP utilisée
    switch ($method) {
        // ───── Cas GET: Récupérer les documents ou télécharger un document
        case 'GET':
            // Vérifier si une opération de téléchargement est demandée
            if (isset($uri_parts[1]) && $uri_parts[1] == 'download' && isset($uri_parts[2])) {
                // Appeler la méthode de téléchargement du document
                // L'ID du document se trouve dans $uri_parts[2]
                $controller->downloadDocument($userId, $uri_parts[2]);
                // Arrêter l'exécution ici car le fichier a été envoyé
                return;
            } else {
                // Appeler la méthode pour récupérer tous les documents de l'utilisateur
                $result = $controller->getDocuments($userId);
            }
            break;

        // ───── Cas POST: Ajouter un nouveau document
        case 'POST':
            // Lire les données JSON du nouveau document
            $data = json_decode(file_get_contents('php://input'), true);
            // Appeler la méthode pour ajouter un document
            $result = $controller->addDocument($userId, $data);
            break;

        // ───── Cas PUT: Mettre à jour un document existant
        case 'PUT':
            // Vérifier si l'ID du document à modifier est fourni
            if (isset($uri_parts[1])) {
                // Lire les données mises à jour du document
                $data = json_decode(file_get_contents('php://input'), true);
                // Appeler la méthode pour mettre à jour le document
                $result = $controller->updateDocument($userId, $uri_parts[1], $data);
            } else {
                // L'ID du document n'a pas été fourni
                http_response_code(400);
                // Retourner un message d'erreur
                $result = ['error' => 'ID du document requis'];
            }
            break;

        // ───── Cas DELETE: Supprimer un document
        case 'DELETE':
            // Vérifier si l'ID du document à supprimer est fourni
            if (isset($uri_parts[1])) {
                // Appeler la méthode pour supprimer le document
                $result = $controller->deleteDocument($userId, $uri_parts[1]);
            } else {
                // L'ID du document n'a pas été fourni
                http_response_code(400);
                // Retourner un message d'erreur
                $result = ['error' => 'ID du document requis'];
            }
            break;

        // ───── Cas par défaut: Méthode HTTP non autorisée
        default:
            // Définir le code HTTP 405
            http_response_code(405);
            // Retourner un message d'erreur
            $result = ['error' => 'Méthode non autorisée'];
            break;
    }
    // Encoder le résultat en JSON et l'envoyer au client
    echo json_encode($result);
}
