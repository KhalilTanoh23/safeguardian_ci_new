<?php

class Validator {
    private static $errors = [];

    /**
     * Réinitialiser les erreurs
     */
    public static function reset() {
        self::$errors = [];
    }

    /**
     * Valider un email
     * 
     * @param string $email L'email à valider
     * @param string $fieldName Le nom du champ
     * @return bool
     */
    public static function email($email, $fieldName = 'Email') {
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
    public static function required($value, $fieldName = 'Champ') {
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
    public static function minLength($value, $min, $fieldName = 'Champ') {
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
    public static function maxLength($value, $max, $fieldName = 'Champ') {
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
    public static function phone($phone, $fieldName = 'Téléphone') {
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
    public static function getErrors() {
        return self::$errors;
    }

    /**
     * Vérifier s'il y a des erreurs
     * 
     * @return bool
     */
    public static function hasErrors() {
        return !empty(self::$errors);
    }
}
