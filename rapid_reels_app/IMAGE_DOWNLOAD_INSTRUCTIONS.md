# Image Download Instructions - Exact Match Required

## Quick Action Steps

### Step 1: Download Images from Free Stock Photo Sites

You need to download 3 images that match your exact design:

#### Image 1: Birthday Celebration
**Save as:** `onboarding_birthday.jpg`
**Location:** `rapid_reels_app/assets/images/onboarding_birthday.jpg`

**What to look for:**
- Family (man, woman, young girl) celebrating birthday
- Birthday cake with candles
- Party decorations (streamers, banners)
- Colorful, joyful atmosphere
- Portrait orientation (9:16 ratio)

**Best Sources:**
1. **Unsplash:** https://unsplash.com/s/photos/birthday-party-family-cake
   - Search: "birthday party family cake celebration"
   - Filter: Portrait orientation
   - Download size: Large (1080x1920 or similar)

2. **Pexels:** https://www.pexels.com/search/birthday%20party%20family/
   - Search: "birthday party family"
   - Download: Free, no attribution required

3. **Pixabay:** https://pixabay.com/images/search/birthday%20party/
   - Search: "birthday party family"
   - Download: Free

#### Image 2: Car Purchase
**Save as:** `onboarding_car.jpg`
**Location:** `rapid_reels_app/assets/images/onboarding_car.jpg`

**What to look for:**
- Family at car dealership
- New car with red bow (if possible)
- People holding car keys
- Congratulations/celebration scene
- Car showroom setting

**Best Sources:**
1. **Unsplash:** https://unsplash.com/s/photos/new-car-purchase-family
   - Search: "new car purchase family dealership"

2. **Pexels:** https://www.pexels.com/search/car%20dealership%20family/
   - Search: "car dealership family"

3. **Pixabay:** https://pixabay.com/images/search/car%20purchase/
   - Search: "car purchase family"

#### Image 3: Influencer
**Save as:** `onboarding_influencer.jpg`
**Location:** `rapid_reels_app/assets/images/onboarding_influencer.jpg`

**What to look for:**
- Young woman holding smartphone
- Video call or content creation scene
- Modern, professional setting
- Social media/influencer aesthetic

**Best Sources:**
1. **Unsplash:** https://unsplash.com/s/photos/influencer-woman-smartphone
   - Search: "influencer woman smartphone"

2. **Pexels:** https://www.pexels.com/search/influencer%20woman%20phone/
   - Search: "influencer woman phone"

3. **Pixabay:** https://pixabay.com/images/search/influencer/
   - Search: "influencer woman"

### Step 2: Image Requirements

- **Format:** JPG (preferred) or PNG
- **Size:** 1080x1920 pixels (portrait, 9:16 ratio)
- **File Size:** Under 2MB each
- **Quality:** High resolution for mobile display
- **Orientation:** Portrait (vertical)

### Step 3: Save Images

1. Download images from the sources above
2. Rename them exactly as:
   - `onboarding_birthday.jpg`
   - `onboarding_car.jpg`
   - `onboarding_influencer.jpg`
3. Save to: `E:\Projects\Rapid_Reels\rapid_reels_app\assets\images\`

### Step 4: Verify Images Are Added

Run this command to check:
```powershell
cd E:\Projects\Rapid_Reels\rapid_reels_app
dir assets\images\onboarding_*.jpg
```

You should see all 3 files:
- onboarding_birthday.jpg
- onboarding_car.jpg
- onboarding_influencer.jpg

### Step 5: Rebuild App

```powershell
cd E:\Projects\Rapid_Reels\rapid_reels_app
flutter clean
flutter pub get
flutter run
```

## Alternative: Use Temporary Placeholder

If you want to test immediately, the code will use `onboarding_1.jpg` as a fallback until you add the specific images.

## Troubleshooting

**Images not showing?**
1. Check file names match exactly (case-sensitive)
2. Verify images are in `assets/images/` folder
3. Run `flutter clean` then `flutter pub get`
4. Restart the app completely

**Wrong images?**
- Make sure images match the descriptions above
- Check image orientation (should be portrait)
- Verify image quality is high enough

## Current Status

✅ Code is ready and configured
✅ Fallback images are set up
⏳ Waiting for you to add the 3 specific images

Once you add the images, they will automatically display in the onboarding screens!

