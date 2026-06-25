# Build and deploy APK to Firebase App Distribution

# 1. Build the release APKs using split-per-abi and obfuscation for security
Write-Host "Building Secured Release APKs (split-per-abi & obfuscate)..." -ForegroundColor Green
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter build failed!" -ForegroundColor Red
    exit 1
}

# The main APK for modern testing phones is arm64-v8a (smaller size)
$apkPath = "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
$appId = "1:863689132828:android:859087d9719075151088d9"

# 2. Upload to Firebase
Write-Host "Uploading arm64-v8a APK to Firebase App Distribution..." -ForegroundColor Green
firebase appdistribution:distribute $apkPath --app $appId


if ($LASTEXITCODE -ne 0) {
    Write-Host "Upload failed! Make sure you are logged in using 'firebase login' and have firebase-tools installed." -ForegroundColor Red
    exit 1
}

Write-Host "Successfully uploaded APK!" -ForegroundColor Green
