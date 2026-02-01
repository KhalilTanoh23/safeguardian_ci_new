# 📝 CRÉER UN REPO GITHUB - GUIDE COMPLET

## ÉTAPE 1️⃣ : CRÉER LE REPO SUR GITHUB.COM

### 1.1 Aller sur GitHub

```
URL: https://github.com
```

### 1.2 Cliquer sur "+" (haut à droite)

```
Petite flèche vers le bas à côté de votre avatar
Sélectionnez: "New repository"
```

### 1.3 Remplir les informations

**Repository name:**

```
safeguardian_ci_new
```

**Description (optionnel):**

```
SafeGuardian CI - Flutter + PHP Backend + PostgreSQL + Supabase
```

**Public ou Private:**

```
Recommandé: Public (pour Railway)
Sinon: Private (mais vous devrez ajouter Railway comme collaborateur)
```

**Initialize this repository with:**

```
❌ Ne cochez RIEN (vous avez déjà du code local)
```

### 1.4 Cliquer sur "Create repository"

```
Bouton vert "Create repository"
```

### 1.5 GitHub affiche les commandes

```
Vous verrez:
"Quick setup — if you've done this kind of thing before"

C'est parfait! Continuez à l'étape 2.
```

---

## ÉTAPE 2️⃣ : AJOUTER LE REMOTE ET PUSHER LE CODE

### 2.1 Copier l'URL du repo GitHub

```
Sur la page du repo, bouton bleu "Code"
Sous "HTTPS", copiez l'URL:
https://github.com/[votre-username]/safeguardian_ci_new.git
```

### 2.2 Ajouter le remote local

```powershell
cd c:\Users\Msi\safeguardian_ci_new

git remote add origin https://github.com/[VOTRE-USERNAME]/safeguardian_ci_new.git
```

**⚠️ Remplacez [VOTRE-USERNAME] par votre nom d'utilisateur GitHub**

Exemple:

```powershell
git remote add origin https://github.com/john-doe/safeguardian_ci_new.git
```

### 2.3 Vérifier que le remote est ajouté

```powershell
git remote -v
```

Vous devez voir:

```
origin  https://github.com/[votre-username]/safeguardian_ci_new.git (fetch)
origin  https://github.com/[votre-username]/safeguardian_ci_new.git (push)
```

### 2.4 Renommer la branche en "main" (optionnel mais recommandé)

```powershell
git branch -M main
```

### 2.5 Pusher le code

```powershell
git push -u origin main
```

GitHub vous demandera peut-être de vous authentifier:

- Cliquez le lien fourni
- Ou utilisez un token GitHub

**Note**: Si vous utilisez HTTPS et que Git demande le mot de passe:

1. Allez sur GitHub → Settings → Developer settings → Personal access tokens
2. Créez un token avec scope `repo`
3. Copiez le token
4. Quand Git demande le mot de passe, collez le token

### 2.6 Vérifier que le push est réussi

```powershell
git log --oneline -1
```

Vous verrez quelque chose comme:

```
a4b466f docs: Add detailed step-by-step Railway deployment guide
```

### 2.7 Vérifier sur GitHub

```
Allez sur: https://github.com/[votre-username]/safeguardian_ci_new
Vous devez voir votre code!
```

---

## ✅ VÉRIFICATION

Vous devez voir:

```
✅ Repo visible sur GitHub
✅ Tous les fichiers présents (backend/, lib/, android/, etc.)
✅ Dockerfile visible
✅ railway.toml visible
✅ RAILWAY_STEP_BY_STEP.md visible
```

---

## 🚀 PROCHAINES ÉTAPES

Une fois le repo GitHub créé et le code pushé:

1. Allez sur https://railway.app
2. Cliquez "Deploy from GitHub"
3. Sélectionnez votre repo `safeguardian_ci_new`
4. Railway détectera le Dockerfile automatiquement
5. Continuez avec RAILWAY_STEP_BY_STEP.md

---

## 🆘 DÉPANNAGE

### Erreur: "Permission denied (publickey)"

```
→ Vous devez configurer une clé SSH ou utiliser un token
→ Allez sur: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
```

### Erreur: "Repository already exists"

```
→ Le nom de repo existe déjà
→ Utilisez un autre nom, ex: safeguardian_ci_v2
```

### Le code ne s'affiche pas sur GitHub

```
→ Vérifiez que git push a réussi (pas d'erreur)
→ Rafraîchissez la page GitHub (F5)
→ Vérifiez que vous êtes connecté au bon compte
```

---

## 💡 TIPS

- Rendez le repo **Public** pour que Railway puisse y accéder facilement
- Vous pouvez ajouter un `.gitignore` pour ne pas commiter les fichiers sensibles
- Les secrets (mots de passe) doivent aller dans les variables Railway, pas dans le code
