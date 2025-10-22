# 📸 PHOTOS DE PROFIL - GUIDE D'IMPLÉMENTATION

## 🎯 OBJECTIF
Permettre aux utilisateurs d'ajouter et de modifier leur photo de profil avec :
- Upload vers Supabase Storage
- Compression automatique
- Crop/Resize
- Affichage dans l'app

---

## 📦 DÉPENDANCES À AJOUTER

Ajoute ces packages dans `pubspec.yaml` :

```yaml
dependencies:
  # ... tes dépendances existantes
  
  # Photos de profil
  image_picker: ^1.0.7        # Sélection photo depuis galerie/caméra
  image_cropper: ^5.0.1       # Crop et rotation
  image: ^4.1.7               # Compression et resize
  cached_network_image: ^3.3.1 # Cache des images
```

---

## 🗂️ CONFIGURATION SUPABASE STORAGE

### Étape 1 : Créer le bucket dans Supabase

Va sur **Supabase → Storage** et crée un nouveau bucket :

```
Nom du bucket : avatars
Public : true (pour permettre l'accès aux images)
File size limit : 2MB
Allowed MIME types : image/jpeg, image/png, image/webp
```

### Étape 2 : Politiques RLS pour le bucket

```sql
-- Politique : Les utilisateurs peuvent uploader leur propre avatar
CREATE POLICY "Users can upload their own avatar"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique : Les utilisateurs peuvent voir tous les avatars
CREATE POLICY "Anyone can view avatars"
ON storage.objects
FOR SELECT
USING (bucket_id = 'avatars');

-- Politique : Les utilisateurs peuvent mettre à jour leur propre avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique : Les utilisateurs peuvent supprimer leur propre avatar
CREATE POLICY "Users can delete their own avatar"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## 📁 FICHIERS À CRÉER

### 1. Service de gestion des avatars

Fichier : `lib/services/avatar_service.dart`

### 2. Widget de sélection de photo

Fichier : `lib/widgets/avatar_picker.dart`

### 3. Widget d'affichage d'avatar

Fichier : `lib/widgets/user_avatar.dart`

---

## 🎨 FONCTIONNALITÉS

### Upload de photo
1. Sélection depuis galerie ou caméra
2. Crop carré (1:1)
3. Resize automatique (512x512)
4. Compression (< 500KB)
5. Upload vers Supabase Storage
6. URL sauvegardée dans la table users

### Affichage
1. Cache local (pas de re-téléchargement)
2. Placeholder pendant le chargement
3. Initiales si pas de photo
4. Bordure colorée selon le niveau

### Gestion
1. Changement de photo
2. Suppression de photo
3. Prévisualisation avant upload
4. Indicateur de progression

---

## 💾 STRUCTURE DES FICHIERS DANS STORAGE

```
avatars/
  ├── {user_id}/
  │   ├── avatar.jpg           (version principale)
  │   └── avatar_thumb.jpg     (miniature 128x128)
```

---

## 🔧 CONFIGURATION ANDROID/iOS

### Android : `android/app/src/main/AndroidManifest.xml`

Ajoute les permissions :

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
```

### iOS : `ios/Runner/Info.plist`

Ajoute les permissions :

```xml
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre caméra pour prendre une photo de profil</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour définir une photo de profil</string>
```

---

## 📝 PROCHAINES ÉTAPES

1. Ajouter les dépendances dans `pubspec.yaml`
2. Exécuter `flutter pub get`
3. Créer le bucket `avatars` dans Supabase
4. Exécuter les politiques RLS
5. Je vais créer les fichiers de code

**Confirme que tu es prêt pour que je crée les fichiers ! 🚀**

