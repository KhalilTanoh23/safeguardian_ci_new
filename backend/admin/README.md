# Dashboard Admin SafeGuardian - Web

## Vue d'ensemble

Le Dashboard Admin est une interface web complète permettant aux administrateurs de gérer et surveiller en temps réel tous les aspects du système SafeGuardian.

## Accès

### URL d'accès

```
http://localhost/admin/
```

ou si vous utilisez un domaine :

```
http://votre-domaine.com/admin/
```

### Identifiants de connexion

```
Email: test@example.com (ou tout compte avec rôle 'admin')
Mot de passe: (le mot de passe défini pour ce compte)
```

## Fonctionnalités

### 1. **Métriques en Temps Réel**

- 📊 **Utilisateurs Actifs**: Nombre d'utilisateurs et statistiques d'activation
- ⚠️ **Alertes Aujourd'hui**: Nombre d'alertes générées aujourd'hui
- 🛡️ **Incidents Critiques**: Nombre d'incidents critiques de la semaine
- ✓ **Contacts Vérifiés**: Nombre de contacts d'urgence vérifiés

### 2. **Santé du Système**

Surveillance en temps réel de :

- 🗄️ Base de Données (MySQL)
- 📡 API Serveur
- 🔔 Système de Notifications
- 📍 Service de Géolocalisation

Chaque service affiche un pourcentage de disponibilité en temps réel.

### 3. **Activités Récentes**

- Historique des dernières actions du système
- Timestamps précis pour chaque activité
- Types d'activité variés (signups, alertes, documents, etc.)

## Architecture

```
backend/admin/
├── index.php                 # Page principale du dashboard
├── login.php                 # Page de connexion
├── login_process.php         # Traitement de la connexion
├── logout.php                # Déconnexion
├── auth.php                  # Gestion de l'authentification admin
├── api/
│   ├── metrics.php           # API des métriques du dashboard
│   └── profile.php           # API du profil admin
└── README.md                 # Ce fichier
```

## Flux d'Authentification

1. **Accès à `/admin/`** → Redirige vers `/admin/login.php` si non connecté
2. **Formulaire de connexion** → Vérifie email + mot de passe
3. **Vérification du rôle** → Confirme que l'utilisateur est administrateur
4. **Création de session** → Stocke les infos admin en session
5. **Redirection vers le dashboard** → Charge les métriques en temps réel

### Sécurité

- ✅ Vérification du rôle `admin` obligatoire
- ✅ Sessions PHP sécurisées
- ✅ Mots de passe hachés (bcrypt)
- ✅ Protection contre les accès non authentifiés

## API Endpoints

### Récupérer toutes les métriques

```
GET /admin/api/metrics.php?action=all
```

Retourne un JSON avec :

```json
{
  "users": { "total_users": 1245, "active_users": 1100, ... },
  "alerts": { "total_alerts": 150, "today_alerts": 38, ... },
  "incidents": { "critical_incidents": 3 },
  "contacts": { "total_contacts": 892, "verified_contacts": 850, ... },
  "system_health": { "database": {...}, "api": {...}, ... },
  "recent_activity": [...],
  "timestamp": "2026-02-01 14:30:00"
}
```

### Actions disponibles

- `action=all` - Toutes les métriques
- `action=users` - Métriques utilisateurs
- `action=alerts` - Métriques alertes
- `action=incidents` - Métriques incidents
- `action=contacts` - Métriques contacts
- `action=health` - État de santé du système
- `action=activity` - Activités récentes

### Récupérer le profil admin

```
GET /admin/api/profile.php
```

Retourne :

```json
{
  "id": 1,
  "email": "admin@safeguardian.com",
  "name": "Jean Admin"
}
```

## Configuration Requise

- PHP 7.4+
- MySQL 5.7+
- Serveur web (Apache/Nginx)
- XAMPP configuré avec les extensions PDO MySQL

## Rafraîchissement des Données

- Les données se rafraîchissent **automatiquement toutes les 30 secondes**
- Vous pouvez actualiser manuellement la page avec `F5` ou le bouton de rechargement du navigateur

## Personnalisation

### Modifier l'intervalle de rafraîchissement

Ouvrez `backend/admin/index.php` et changez la ligne :

```javascript
// Rafraîchir les données toutes les 30 secondes
setInterval(loadAdminData, 30000); // 30000ms = 30s
```

### Ajouter de nouvelles métriques

1. Ajouter une méthode dans la classe `AdminMetrics` (api/metrics.php)
2. Ajouter l'action dans le switch de metrics.php
3. Ajouter le rendu dans la fonction JavaScript correspondante

## Dépannage

### Je n'accède pas au dashboard

- ✅ Vérifiez que vous êtes connecté avec un compte admin
- ✅ Vérifiez que l'URL est correcte : `http://localhost/admin/`
- ✅ Vérifiez que le rôle de votre compte est bien `admin` dans phpMyAdmin

### Les données ne se chargent pas

- ✅ Vérifiez que MySQL/XAMPP est démarré
- ✅ Vérifiez la console du navigateur (F12) pour les erreurs
- ✅ Vérifiez les logs du serveur Apache

### Erreur "Accès Administrateur Requis"

- Votre compte n'a pas le rôle admin
- Allez dans phpMyAdmin → Table `users`
- Modifiez le champ `role` en `admin` pour votre utilisateur


**Développé pour SafeGuardian v1.0.0**
