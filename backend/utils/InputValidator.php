<?php
/**
 * Validation et Sanitization Avancée des Inputs
 * 
 * Valide et nettoie toutes les données entrantes
 */

class InputValidator {
    private static $errors = [];
    
    /**
     * Réinitialiser les erreurs
     */
    public static function reset() {
        self::$errors = [];
    }

    /**
     * Valider les données d'inscription
     */
    public static function validateRegister($data) {
        self::reset();
        
        // Email
        if (empty($data['email'] ?? null)) {
            self::$errors['email'] = 'Email requis';
        } else {
            $email = self::sanitizeEmail($data['email']);
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                self::$errors['email'] = 'Email invalide';
            } elseif (strlen($email) > 255) {
                self::$errors['email'] = 'Email trop long (max 255 caractères)';
            }
        }
        
        // Mot de passe
        if (empty($data['password'] ?? null)) {
            self::$errors['password'] = 'Mot de passe requis';
        } else {
            $password = $data['password'];
            $minLength = (int)($_ENV['PASSWORD_MIN_LENGTH'] ?? 8);
            
            if (strlen($password) < $minLength) {
                self::$errors['password'] = "Minimum $minLength caractères";
            } elseif (!preg_match('/[A-Z]/', $password)) {
                self::$errors['password'] = 'Au moins 1 majuscule requise';
            } elseif (!preg_match('/[0-9]/', $password)) {
                self::$errors['password'] = 'Au moins 1 chiffre requis';
            } elseif (!preg_match('/[!@#$%^&*\-_=+\[\]{}|;:,.<>?]/', $password)) {
                self::$errors['password'] = 'Au moins 1 caractère spécial requis (!@#$%^&*)';
            }
        }
        
        // Prénom
        if (empty($data['firstName'] ?? null)) {
            self::$errors['firstName'] = 'Prénom requis';
        } else {
            $firstName = self::sanitizeString($data['firstName']);
            if (strlen($firstName) > 50) {
                self::$errors['firstName'] = 'Prénom trop long (max 50 caractères)';
            } elseif (strlen($firstName) < 2) {
                self::$errors['firstName'] = 'Prénom trop court (min 2 caractères)';
            }
        }
        
        // Nom
        if (empty($data['lastName'] ?? null)) {
            self::$errors['lastName'] = 'Nom requis';
        } else {
            $lastName = self::sanitizeString($data['lastName']);
            if (strlen($lastName) > 50) {
                self::$errors['lastName'] = 'Nom trop long (max 50 caractères)';
            } elseif (strlen($lastName) < 2) {
                self::$errors['lastName'] = 'Nom trop court (min 2 caractères)';
            }
        }
        
        // Téléphone
        if (empty($data['phone'] ?? null)) {
            self::$errors['phone'] = 'Téléphone requis';
        } else {
            $phone = self::sanitizePhone($data['phone']);
            // Format CI: +225XXXXXXXXX ou 0XXXXXXXXX
            if (!preg_match('/^(\+225|0)[0-9]{9,10}$/', $phone)) {
                self::$errors['phone'] = 'Format invalide (ex: +225123456789 ou 0123456789)';
            }
        }
        
        return [
            'valid' => empty(self::$errors),
            'errors' => self::$errors
        ];
    }

    /**
     * Valider les données de connexion
     */
    public static function validateLogin($data) {
        self::reset();
        
        if (empty($data['email'] ?? null)) {
            self::$errors['email'] = 'Email requis';
        } else {
            $email = self::sanitizeEmail($data['email']);
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                self::$errors['email'] = 'Email invalide';
            }
        }
        
        if (empty($data['password'] ?? null)) {
            self::$errors['password'] = 'Mot de passe requis';
        } elseif (strlen($data['password']) < 6) {
            self::$errors['password'] = 'Mot de passe invalide';
        }
        
        return [
            'valid' => empty(self::$errors),
            'errors' => self::$errors
        ];
    }

    /**
     * Valider les données d'alerte
     */
    public static function validateAlert($data) {
        self::reset();
        
        // Latitude
        if (empty($data['latitude'] ?? null)) {
            self::$errors['latitude'] = 'Latitude requise';
        } elseif (!is_numeric($data['latitude'])) {
            self::$errors['latitude'] = 'Latitude invalide';
        } elseif ($data['latitude'] < -90 || $data['latitude'] > 90) {
            self::$errors['latitude'] = 'Latitude hors limites (-90 à 90)';
        }
        
        // Longitude
        if (empty($data['longitude'] ?? null)) {
            self::$errors['longitude'] = 'Longitude requise';
        } elseif (!is_numeric($data['longitude'])) {
            self::$errors['longitude'] = 'Longitude invalide';
        } elseif ($data['longitude'] < -180 || $data['longitude'] > 180) {
            self::$errors['longitude'] = 'Longitude hors limites (-180 à 180)';
        }
        
        // Message (optionnel)
        if (!empty($data['message'] ?? null)) {
            $message = self::sanitizeString($data['message']);
            if (strlen($message) > 500) {
                self::$errors['message'] = 'Message trop long (max 500 caractères)';
            }
        }
        
        return [
            'valid' => empty(self::$errors),
            'errors' => self::$errors
        ];
    }

    /**
     * Sanitizer une chaîne
     */
    public static function sanitizeString($string) {
        if (!is_string($string)) {
            return '';
        }
        
        // Supprimer les espaces inutiles
        $string = trim($string);
        
        // Supprimer les caractères de contrôle
        $string = preg_replace('/[\x00-\x1F\x7F]/', '', $string);
        
        // Échapper les caractères HTML
        return htmlspecialchars($string, ENT_QUOTES, 'UTF-8');
    }

    /**
     * Sanitizer un email
     */
    public static function sanitizeEmail($email) {
        if (!is_string($email)) {
            return '';
        }
        
        // Convertir en minuscules et trimp
        $email = strtolower(trim($email));
        
        // Supprimer les caractères dangereux
        $email = filter_var($email, FILTER_SANITIZE_EMAIL);
        
        return $email;
    }

    /**
     * Sanitizer un téléphone
     */
    public static function sanitizePhone($phone) {
        if (!is_string($phone)) {
            return '';
        }
        
        // Supprimer tous les caractères sauf chiffres et +
        $phone = preg_replace('/[^0-9+]/', '', $phone);
        
        return $phone;
    }

    /**
     * Valider une URL
     */
    public static function validateUrl($url) {
        return filter_var($url, FILTER_VALIDATE_URL) !== false;
    }

    /**
     * Valider une adresse IP
     */
    public static function validateIP($ip) {
        return filter_var($ip, FILTER_VALIDATE_IP) !== false;
    }

    /**
     * Obtenir les erreurs
     */
    public static function getErrors() {
        return self::$errors;
    }

    /**
     * Vérifier s'il y a des erreurs
     */
    public static function hasErrors() {
        return !empty(self::$errors);
    }

    /**
     * Valider et nettoyer les données d'une requête
     */
    public static function sanitizeRequest($data) {
        if (!is_array($data)) {
            return [];
        }
        
        $sanitized = [];
        foreach ($data as $key => $value) {
            // Clé
            $key = preg_replace('/[^a-zA-Z0-9_]/', '', $key);
            
            if ($key === '') {
                continue;
            }
            
            // Valeur
            if (is_string($value)) {
                $sanitized[$key] = self::sanitizeString($value);
            } elseif (is_numeric($value)) {
                $sanitized[$key] = $value;
            } elseif (is_array($value)) {
                $sanitized[$key] = self::sanitizeRequest($value);
            } elseif (is_bool($value)) {
                $sanitized[$key] = $value;
            } else {
                // Ignorer les autres types
                continue;
            }
        }
        
        return $sanitized;
    }
}
