# Onboarding Images Setup Guide

## Required Images

You need to add 3 background images to match the exact onboarding screens:

### 1. Slide 1 - Birthday Celebration
**File:** `assets/images/onboarding_birthday.jpg`
**Description:** 
- Family celebrating birthday (man, woman, young girl)
- Girl wearing party hat with cake in front
- Colorful party decorations in background
- Bright, cheerful atmosphere

**Search Terms:** "birthday party family celebration cake party hat"

### 2. Slide 2 - Car Purchase
**File:** `assets/images/onboarding_car.jpg`
**Description:**
- Family receiving new car at dealership
- Silver car with red bow on hood
- People holding flowers and car keys
- Car showroom setting

**Search Terms:** "new car purchase family dealership congratulations red bow"

### 3. Slide 3 - Influencer
**File:** `assets/images/onboarding_influencer.jpg`
**Description:**
- Young woman holding smartphone
- Appears to be recording or on video call
- Modern, professional setting
- Social media/influencer aesthetic

**Search Terms:** "influencer woman smartphone video call social media"

## How to Add Images

### Step 1: Find Images
1. Visit free stock photo sites:
   - Unsplash.com
   - Pexels.com
   - Pixabay.com
2. Search using the terms above
3. Download high-quality images (at least 1080x1920 for mobile)
4. Save with exact filenames:
   - `onboarding_birthday.jpg`
   - `onboarding_car.jpg`
   - `onboarding_influencer.jpg`

### Step 2: Add to Project
1. Copy the images to: `rapid_reels_app/assets/images/`
2. The images folder should contain:
   ```
   assets/images/
   ├── onboarding_birthday.jpg
   ├── onboarding_car.jpg
   └── onboarding_influencer.jpg
   ```

### Step 3: Verify Assets
The `pubspec.yaml` already includes:
```yaml
flutter:
  assets:
    - assets/images/
```
So your images will be automatically included.

### Step 4: Test
1. Run `flutter pub get` (if needed)
2. Run the app
3. Navigate to onboarding screen
4. Verify all 3 slides display correctly

## Image Specifications

- **Format:** JPG or PNG
- **Recommended Size:** 1080x1920 pixels (9:16 aspect ratio for mobile)
- **File Size:** Keep under 2MB each for optimal performance
- **Quality:** High resolution for crisp display

## Current Implementation

The code is already set up to:
- ✅ Display images as backgrounds
- ✅ Show text overlays at bottom left
- ✅ Display "Get Started" button at bottom
- ✅ Show pagination dots
- ✅ Display congratulations banner on slide 2

## Troubleshooting

If images don't appear:
1. Check file names match exactly (case-sensitive)
2. Verify images are in `assets/images/` folder
3. Run `flutter clean` then `flutter pub get`
4. Restart the app completely

