# MediaMate App Store Submission Guide

## Step 1: Rent a Mac

Any macOS machine with Xcode 16+ installed. (¥10/day remote Mac works.)

## Step 2: Set Up

Open Terminal and run:
```bash
bash ~/Desktop/setup-mac.sh
```

## Step 3: Configure Signing

In Xcode:
1. Xcode → Settings → Accounts → Add your Apple ID
2. Open project (already opened by setup script)
3. Select MediaMate target → Signing & Capabilities
4. Choose your Team
5. Change Bundle Identifier to `com.YOURNAME.mediamate`

## Step 4: Build Archive

```
Xcode → Product → Archive
```
(Wait 10-20 minutes. Fix any warnings.)

## Step 5: Upload to App Store Connect

1. After Archive, the Organizer window opens automatically
2. Click "Distribute App"
3. Select "App Store Connect"
4. Follow the wizard:
   - Upload symbols: ✅
   - Include bitcode: ✅
   - Automatically manage signing: ✅
5. Click "Upload"

## Step 6: Submit for Review

1. Go to https://appstoreconnect.apple.com
2. Find MediaMate in My Apps
3. Fill in:
   - App Name: MediaMate - Video Converter
   - Subtitle: Compress & convert on-device
   - Privacy Policy URL: https://YOURNAME.github.io/MediaMate/PrivacyPolicy.html
   - Category: Utilities
   - Price: $3.99 (one-time)
   - Availability: All countries except China
4. Upload screenshots (see SCREENSHOTS.md)
5. Click "Submit for Review"

## Step 7: Wait

Typical review time: 24-48 hours.

## Troubleshooting

| Error | Solution |
|-------|----------|
| "No signing certificate found" | Xcode → Settings → Accounts → Download Manual Profiles |
| "Failed to create provisioning profile" | Check Bundle ID matches your Apple Developer account |
| "App sandbox not enabled" | Go to Capabilities → Enable App Sandbox |
| "ITMS-90078: Missing push notification entitlement" | Ignore, not needed for this app |
