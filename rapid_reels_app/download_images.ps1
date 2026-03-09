# PowerShell Script to Download Onboarding Images
# This script helps download images from Unsplash using their API

$imagesPath = "assets\images"
$baseUrl = "https://images.unsplash.com/photo-"

# Create images directory if it doesn't exist
if (-not (Test-Path $imagesPath)) {
    New-Item -ItemType Directory -Path $imagesPath -Force
}

Write-Host "Downloading onboarding images..." -ForegroundColor Green

# Image 1: Birthday Celebration
Write-Host "`n1. Downloading Birthday Celebration image..." -ForegroundColor Yellow
$birthdayUrl = "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=1080&h=1920&fit=crop&q=80"
$birthdayPath = "$imagesPath\onboarding_birthday.jpg"
try {
    Invoke-WebRequest -Uri $birthdayUrl -OutFile $birthdayPath -ErrorAction Stop
    Write-Host "   ✓ Birthday image downloaded" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to download birthday image: $_" -ForegroundColor Red
    Write-Host "   Please download manually from: https://unsplash.com/s/photos/birthday-party-family-cake" -ForegroundColor Yellow
}

# Image 2: Car Purchase
Write-Host "`n2. Downloading Car Purchase image..." -ForegroundColor Yellow
$carUrl = "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=1080&h=1920&fit=crop&q=80"
$carPath = "$imagesPath\onboarding_car.jpg"
try {
    Invoke-WebRequest -Uri $carUrl -OutFile $carPath -ErrorAction Stop
    Write-Host "   ✓ Car image downloaded" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to download car image: $_" -ForegroundColor Red
    Write-Host "   Please download manually from: https://unsplash.com/s/photos/new-car-purchase-family" -ForegroundColor Yellow
}

# Image 3: Influencer
Write-Host "`n3. Downloading Influencer image..." -ForegroundColor Yellow
$influencerUrl = "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1080&h=1920&fit=crop&q=80"
$influencerPath = "$imagesPath\onboarding_influencer.jpg"
try {
    Invoke-WebRequest -Uri $influencerUrl -OutFile $influencerPath -ErrorAction Stop
    Write-Host "   ✓ Influencer image downloaded" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to download influencer image: $_" -ForegroundColor Red
    Write-Host "   Please download manually from: https://unsplash.com/s/photos/influencer-woman-smartphone" -ForegroundColor Yellow
}

Write-Host "`n✓ Download process completed!" -ForegroundColor Green
Write-Host "`nNote: If downloads failed, please:" -ForegroundColor Yellow
Write-Host "1. Visit the URLs shown above" -ForegroundColor Yellow
Write-Host "2. Download images manually" -ForegroundColor Yellow
Write-Host "3. Save them to: $imagesPath" -ForegroundColor Yellow
Write-Host "4. Rename them to: onboarding_birthday.jpg, onboarding_car.jpg, onboarding_influencer.jpg" -ForegroundColor Yellow

