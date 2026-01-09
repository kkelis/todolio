# Android Signing Setup for Google Play Store

This guide explains how to create and configure Android signing keys for releasing your app to the Google Play Store.

## Step 1: Generate a Signing Key (Keystore)

Run this command in your project root (or any directory you prefer for storing keys):

```bash
keytool -genkey -v -keystore ~/todolio-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias todolio-key
```

**Important prompts you'll see:**
- **Enter keystore password**: Choose a strong password (save this!)
- **Re-enter password**: Confirm it
- **What is your first and last name**: Your name or organization
- **What is the name of your organizational unit**: Optional (press Enter)
- **What is the name of your organization**: Your organization name
- **What is the name of your City or Locality**: Your city
- **What is the name of your State or Province**: Your state
- **What is the two-letter country code**: Your country code (e.g., US, DE, HR)
- **Is this correct?**: Type `yes`
- **Enter key password**: Can be same as keystore password or different (save this too!)

**What this creates:**
- A file: `~/todolio-release-key.jks` (your keystore file)
- With an alias: `todolio-key` (identifier for your key inside the keystore)

**⚠️ CRITICAL: Keep these safe!**
- **Keystore file** (`todolio-release-key.jks`)
- **Keystore password**
- **Key alias** (`todolio-key`)
- **Key password**

If you lose these, you **cannot** update your app on Google Play Store!

---

## Step 2: Create key.properties File (Local Development)

Create `android/key.properties` in your project:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=todolio-key
storeFile=/Users/YOUR_USERNAME/todolio-release-key.jks
```

Replace:
- `YOUR_KEYSTORE_PASSWORD` - The password you used for the keystore
- `YOUR_KEY_PASSWORD` - The password you used for the key
- `/Users/YOUR_USERNAME/` - Path to where you saved the .jks file

**⚠️ This file is already in .gitignore - never commit it!**

---

## Step 3: Set Up GitHub Secrets (For CI/CD)

For the GitHub Actions workflow to sign your app, you need to add secrets:

### 3.1: Convert Keystore to Base64

```bash
base64 -i ~/todolio-release-key.jks | pbcopy
```

This copies the base64-encoded keystore to your clipboard.

### 3.2: Add GitHub Secrets

Go to: **GitHub Repository → Settings → Secrets and variables → Actions**

Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `KEYSTORE_BASE64` | Paste the base64 string from step 3.1 |
| `KEYSTORE_PASSWORD` | Your keystore password |
| `KEY_ALIAS` | `todolio-key` |
| `KEY_PASSWORD` | Your key password |

---

## Step 4: Test Locally

Build a release APK locally to verify signing works:

```bash
flutter build apk --release
```

If successful, you'll see:
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX.XMB)
```

Build an App Bundle (for Play Store):

```bash
flutter build appbundle --release
```

If successful, you'll see:
```
✓ Built build/app/outputs/bundle/release/app-release.aab
```

---

## Step 5: Verify Signing

Check that your APK is properly signed:

```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

You should see your certificate details (name, organization, validity dates).

---

## File Structure After Setup

```
todolio/
├── android/
│   ├── key.properties       ← Local signing config (gitignored)
│   └── app/
│       ├── build.gradle     ← Updated with signing config
│       └── proguard-rules.pro ← Added for code shrinking
└── ~/todolio-release-key.jks  ← Your keystore (keep safe!)
```

---

## Troubleshooting

### "Keystore file not found"
- Check the path in `key.properties`
- Make sure the file exists at that location

### "Invalid keystore format"
- You might have created a JKS file but specified PKCS12
- Recreate the keystore with `-storetype JKS`

### "Cannot recover key"
- Wrong key password
- Check that `keyPassword` in `key.properties` matches what you used during creation

### GitHub Actions fails with signing error
- Verify all 4 GitHub secrets are set correctly
- Check that the base64 encoding was done correctly
- Ensure there are no extra spaces in secret values

---

## Security Best Practices

1. **Never commit**: `key.properties`, `*.jks`, `*.keystore` files
2. **Backup**: Store keystore and passwords in a password manager
3. **Share carefully**: If team members need to sign, share securely (e.g., encrypted)
4. **Rotate carefully**: If you change keys, you'll need to create a new app listing on Play Store

---

## Next Steps

Once set up:
1. Test local builds: `flutter build appbundle --release`
2. Test GitHub workflow: Push to trigger the workflow
3. Upload to Play Store: Use the generated `.aab` file
