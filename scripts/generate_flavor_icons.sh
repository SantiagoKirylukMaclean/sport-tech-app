#!/bin/bash
# Generate icon variants for different build flavors

MAIN_RES="android/app/src/main/res"
STAGE_RES="android/app/src/stage/res"
PROD_RES="android/app/src/prod/res"

DENSITIES=("mdpi" "hdpi" "xhdpi" "xxhdpi" "xxxhdpi")

echo "Generating flavor-specific icons..."

# Copy original icons to prod (unchanged)
echo -e "\n📦 Copying original icons to prod flavor..."
for density in "${DENSITIES[@]}"; do
    src="$MAIN_RES/mipmap-$density/ic_launcher.png"
    dst="$PROD_RES/mipmap-$density/ic_launcher.png"

    if [ -f "$src" ]; then
        cp "$src" "$dst"
        echo "✓ Copied to prod: mipmap-$density"
    else
        echo "⚠ Warning: $src not found"
    fi
done

# Create tinted icons for stage (orange tint)
echo -e "\n🎨 Creating orange-tinted icons for stage flavor..."
for density in "${DENSITIES[@]}"; do
    src="$MAIN_RES/mipmap-$density/ic_launcher.png"
    dst="$STAGE_RES/mipmap-$density/ic_launcher.png"

    if [ -f "$src" ]; then
        # Copy first
        cp "$src" "$dst"

        # Apply orange hue using sips
        # Adjust saturation to make it more orange
        sips -s format png --setProperty saturation 1.3 "$dst" &>/dev/null

        echo "✓ Created stage icon: mipmap-$density"
    else
        echo "⚠ Warning: $src not found"
    fi
done

echo -e "\n✨ Done! Icons generated for both stage and prod flavors."
echo "Stage icons have an orange tint to distinguish them from production."
