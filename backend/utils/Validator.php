<?php

class Validator
{
    private static $errors = [];

    // ═══════════════════════════════════════════════════════════════
    // ALIAS STATIC METHODS - Pour compatibilité avec les contrôleurs
    // ═══════════════════════════════════════════════════════════════

    public static function validateEmail($email)
    {
        $valid = filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
        return ['valid' => $valid, 'message' => 'Email invalide'];
    }

    public static function validatePassword($password)
    {
        $valid = strlen($password) >= 8 && preg_match('/[A-Z]/', $password) && preg_match('/[a-z]/', $password) && preg_match('/[0-9]/', $password);
        return ['valid' => $valid, 'message' => 'Password doit avoir 8+ chars, une majuscule, minuscule et chiffre'];
    }

    public static function validatePhone($phone)
    {
        $clean = str_replace([' ', '-', '.', '(', ')'], '', $phone);
        $valid = preg_match('/^\+?[1-9]\d{1,14}$/', $clean);
        return ['valid' => $valid, 'message' => 'Numéro de téléphone invalide'];
    }

    public static function validateName($name, $fieldName = 'Nom')
    {
        $valid = strlen($name) >= 2 && strlen($name) <= 100;
        return ['valid' => $valid, 'message' => $fieldName . ' doit avoir 2-100 caractères'];
    }

    public static function validateCoordinates($lat, $lon)
    {
        $valid = is_numeric($lat) && is_numeric($lon) && $lat >= -90 && $lat <= 90 && $lon >= -180 && $lon <= 180;
        return ['valid' => $valid, 'message' => 'Coordonnées GPS invalides'];
    }

    public static function validateMessage($message)
    {
        $valid = strlen($message) > 0 && strlen($message) <= 5000;
        return ['valid' => $valid, 'message' => 'Message doit avoir 1-5000 caractères'];
    }

    public static function validatePriority($priority)
    {
        $valid = is_numeric($priority) && $priority >= 1 && $priority <= 7;
        return ['valid' => $valid, 'message' => 'Priorité doit être entre 1-7'];
    }

    public static function validateStatus($status)
    {
        $valid = in_array($status, ['active', 'inactive', 'pending', 'blocked', 'lost', 'found']);
        return ['valid' => $valid, 'message' => 'Statut invalide'];
    }

    /**
     * Réinitialiser les erreurs
     */
    public static function reset()
    {
        self::$errors = [];
    }

    /**
     * Valider un email
     * 
     * @param string $email L'email à valider
     * @param string $fieldName Le nom du champ
     * @return bool
     */
    public static function email($email, $fieldName = 'Email')
    {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            self::$errors[] = "$fieldName n'est pas valide";
            return false;
        }
        return true;
    }

    /**
     * Valider que le champ est requis
     * 
     * @param mixed $value La valeur à valider
     * @param string $fieldName Le nom du champ
     * @return bool
     */
    public static function required($value, $fieldName = 'Champ')
    {
        if (empty($value)) {
            self::$errors[] = "$fieldName est requis";
            return false;
        }
        return true;
    }

    /**
     * Valider la longueur minimale
     * 
     * @param string $value La valeur à valider
     * @param int $min La longueur minimale
     * @param string $fieldName Le nom du champ
     * @return bool
     */
    public static function minLength($value, $min, $fieldName = 'Champ')
    {
        if (strlen($value) < $min) {
            self::$errors[] = "$fieldName doit contenir au moins $min caractères";
            return false;
        }
        return true;
    }

    /**
     * Valider la longueur maximale
     * 
     * @param string $value La valeur à valider
     * @param int $max La longueur maximale
     * @param string $fieldName Le nom du champ
     * @return bool
     */
    public static function maxLength($value, $max, $fieldName = 'Champ')
    {
        if (strlen($value) > $max) {
            self::$errors[] = "$fieldName ne doit pas dépasser $max caractères";
            return false;
        }
        return true;
    }

    /**
     * Valider un téléphone
     * 
     * @param string $phone Le téléphone à valider
     * @param string $fieldName Le nom du champ
     * @return bool
     */
    public static function phone($phone, $fieldName = 'Téléphone')
    {
        // Format: +225XXXXXXXXXXX ou 0XXXXXXXXXXX
        if (!preg_match('/^(\+225|0)[0-9]{9,10}$/', preg_replace('/\s+/', '', $phone))) {
            self::$errors[] = "$fieldName n'est pas valide";
            return false;
        }
        return true;
    }

    /**
     * Obtenir les erreurs
     * 
     * @return array
     */
    public static function getErrors()
    {
        return self::$errors;
    }

    /**
     * Vérifier s'il y a des erreurs
     * 
     * @return bool
     */
    public static function hasErrors()
    {
        return !empty(self::$errors);
    }
}
