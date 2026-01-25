# 🔒 INSTRUCTIONS D'IMPLÉMENTATION IMMÉDIATE

**À faire MAINTENANT pour sécuriser votre application**

---

## ⚡ Actions Rapides (5 minutes)

### 1. Créer le fichier .env

```bash
# Copier le fichier example
cp backend/.env.example backend/.env

# Générer une clé JWT forte
php -r 'echo bin2hex(random_bytes(32));'
```

### Résultat : exemple
```
a3f8c9e2d1b4f7a6c5e8d2b1f9a3c6e5d8f2b5a8e1c4f7a0d3b6c9e2f5a8
```

### Éditer backend/.env
```bash
# Ouvrir backend/.env et mettre à jour:

JWT_SECRET=a3f8c9e2d1b4f7a6c5e8d2b1f9a3c6e5d8f2b5a8e1c4f7a0d3b6c9e2f5a8

DB_USER=safeguardian_user
DB_PASS=MotDePasseFort123!@#

APP_ENV=production
FORCE_HTTPS=true

CORS_ORIGINS=https://app.safeguardian.ci,https://admin.safeguardian.ci
```

### 2. Ajouter .env au .gitignore

```bash
# Ajouter .env
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore

# Vérifier
cat .gitignore
```

### 3. Configurer la Base de Données

```bash
# Créer utilisateur MySQL (PAS root!)
mysql -u root -p -e "
CREATE USER 'safeguardian_user'@'localhost' IDENTIFIED BY 'MotDePasseFort123!@#';
GRANT ALL PRIVILEGES ON safeguardian_ci.* TO 'safeguardian_user'@'localhost';
FLUSH PRIVILEGES;
"
```

---

## ✅ Vérifications (10 minutes)

### 1. Vérifier CORS

```bash
# Tester la requête CORS
curl -X OPTIONS http://localhost:8000/api \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -v
```

**Résultat attendu**:
```
< Access-Control-Allow-Origin: http://localhost:3000
< X-Frame-Options: DENY
< X-Content-Type-Options: nosniff
< Content-Security-Policy: ...
```

### 2. Vérifier JWT Secret

```bash
# Vérifier que le secret est utilisé
grep -n "JWT_SECRET" backend/index.php
```

**Résultat attendu**:
```
JWT Secret chargé depuis .env ✅
```

### 3. Vérifier Rate Limiting

```bash
# Tester le rate limiting
for i in {1..10}; do
  curl -X POST http://localhost:8000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"test"}'
  echo "\n"
done
```

**Attendu**: Après 5 tentatives, erreur 429

### 4. Vérifier Validation

```bash
# Email invalide
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"invalid","password":"Test123!","firstName":"John","lastName":"Doe","phone":"0123456789"}'
```

**Attendu**: Erreur validation

---

## 🧪 Tests de Sécurité (15 minutes)

### Test 1: CORS Attack
```bash
# Tenter depuis une origine non autorisée
curl -X POST http://localhost:8000/api/auth/login \
  -H "Origin: http://malicious.com" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'
```

**Attendu**: Rejeté avec erreur 403

### Test 2: SQL Injection
```bash
# Tenter injection SQL
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin' OR '1'='1\",\"password\":\"test\"}"
```

**Attendu**: Erreur validation (prepared statements protègent)

### Test 3: XSS Attack
```bash
# Tenter injection XSS
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"Test123!","firstName":"<script>alert(1)</script>","lastName":"Doe","phone":"0123456789"}'
```

**Attendu**: Caractères échappés ou rejetés

### Test 4: Weak Password
```bash
# Mot de passe faible
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"weak","firstName":"John","lastName":"Doe","phone":"0123456789"}'
```

**Attendu**: Erreur validation (minimum 8 caractères + majuscule + chiffre + spécial)

---

## 🔧 Configuration Production

### Sur Serveur Production

```bash
# 1. Mettre à jour .env
scp backend/.env user@production:/var/www/safeguardian/backend/

# 2. Configurer HTTPS
# - SSL Certificate (Let's Encrypt)
# - Redirection HTTP → HTTPS

# 3. Forcer HTTPS dans .env
APP_ENV=production
FORCE_HTTPS=true

# 4. Désactiver le debug
APP_DEBUG=false

# 5. Configurer CORS pour production
CORS_ORIGINS=https://app.safeguardian.ci,https://admin.safeguardian.ci

# 6. Vérifier les permissions
chmod 644 backend/.env
chmod 755 backend/
```

---

## 📋 Checklist d'Implémentation

### Phase 1: AUJOURD'HUI ⚡
- [ ] Copier `.env.example` → `.env`
- [ ] Générer JWT_SECRET fort
- [ ] Configurer DB credentials
- [ ] Ajouter .env à .gitignore
- [ ] Tester CORS

### Phase 2: CETTE SEMAINE
- [ ] Tester rate limiting
- [ ] Vérifier validation inputs
- [ ] Configurer HTTPS
- [ ] Tester sécurité

### Phase 3: CE MOIS
- [ ] Implémenter refresh tokens
- [ ] Ajouter logging
- [ ] Tests automatisés
- [ ] Audit externe

---

## 🚨 Points Critiques

### ⚠️ NE PAS OUBLIER

1. **Changer JWT_SECRET**
   - ❌ NE PAS utiliser la clé de démo
   - ✅ Générer une clé cryptographique

2. **Protéger .env**
   - ❌ NE PAS commiter .env
   - ✅ Ajouter à .gitignore

3. **HTTPS en Production**
   - ❌ NE PAS déployer en HTTP
   - ✅ Forcer HTTPS avec certificat

4. **Database Credentials**
   - ❌ NE PAS utiliser root:password
   - ✅ Créer utilisateur dédié

5. **CORS Origin**
   - ❌ NE PAS laisser `*` (wildcard)
   - ✅ Spécifier les domaines exacts

---

## 📞 En Cas de Problème

### CORS n'est pas restreint
```bash
# Vérifier que CORSConfig est chargé
grep -n "CORSConfig" backend/index.php

# Vérifier .env est chargé
php -r "require 'backend/index.php'; echo getenv('APP_ENV');"
```

### JWT Secret n'est pas chargé
```bash
# Vérifier que .env existe
ls -la backend/.env

# Vérifier la lecture
cat backend/.env | grep JWT_SECRET
```

### Rate limiting ne fonctionne pas
```bash
# Vérifier les permissions du temp
ls -la /tmp/ | grep safeguardian

# Nettoyer le cache
rm -rf /tmp/safeguardian_cache/*
```

---

## 📚 Documentation

- **Audit complet**: [SECURITY_AUDIT.md](SECURITY_AUDIT.md)
- **Solutions détaillées**: [SECURITY_FIXES.md](SECURITY_FIXES.md)
- **État d'implémentation**: [SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md)
- **Conventions**: [CODING_STANDARDS.md](CODING_STANDARDS.md)

---

## ✨ Résultat Final

Après avoir suivi ce guide:
- ✅ CORS sécurisé (pas de wildcard)
- ✅ JWT secret fortifié
- ✅ Rate limiting actif
- ✅ Validation stricte
- ✅ Credentials en .env
- ✅ Prêt pour production

---

**Exécutez maintenant et testez! 🚀**
