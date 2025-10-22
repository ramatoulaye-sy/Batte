
# 🔧 Désactiver la Confirmation Email dans Supabase

## Problème

```
❌ Email not confirmed
```

Supabase bloque la connexion tant que l'email n'est pas confirmé.

---

## ✅ Solution : Désactiver la Confirmation Email (Mode Dev)

### Étape 1 : Va sur Supabase Dashboard

Ouvre ce lien : [https://supabase.com/dashboard/project/zhtnqugrcubrtjvpdzty/auth/policies](https://supabase.com/dashboard/project/zhtnqugrcubrtjvpdzty/auth/policies)

### Étape 2 : Trouve "Email Confirmations"

Cherche la section **"Email Confirmations"** ou **"Confirm email"**

### Étape 3 : Désactive le Toggle

**Désactive** l'option **"Enable email confirmations"**

### Étape 4 : Sauvegarde

Clique sur **"Save"** ou **"Update"**

---

## Alternative : Confirme l'Email Manuellement

Si tu veux garder la confirmation active :

1. Va sur [https://supabase.com/dashboard/project/zhtnqugrcubrtjvpdzty/auth/users](https://supabase.com/dashboard/project/zhtnqugrcubrtjvpdzty/auth/users)
2. Trouve l'utilisateur **ramatoulaye@batte.com**
3. Clique sur les **3 points** (...)
4. Clique sur **"Confirm email"**

---

## 🚀 Après Désactivation

Relance l'app et connecte-toi :

```
Email: ramatoulaye@batte.com
Password: batte123
```

✅ **Tu seras connecté immédiatement !**

