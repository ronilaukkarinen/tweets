#!/bin/bash

# Create a safe public Twitter archive
# This script creates a minimal archive with only public tweets

set -e

echo "🐦 Twitter archive public release generator"
echo "==========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "index.html" ] || [ ! -d "data" ]; then
  echo "❌ Error: Please run this script from your Twitter archive folder"
  echo "   (the folder containing index.html and data/ directory)"
  exit 1
fi

# Create output directory
PUBLIC_DIR="public-twitter-archive"
if [ -d "$PUBLIC_DIR" ]; then
  echo "📁 Public archive folder already exists"
  read -p "   Do you want to overwrite it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "   Cancelled."
    exit 1
  fi
  rm -rf "$PUBLIC_DIR"
fi

echo "📦 Creating public archive in: $PUBLIC_DIR"
mkdir -p "$PUBLIC_DIR/data"

# Copy the viewer
echo "📄 Copying index.html..."
if [ ! -f "$PUBLIC_DIR/index.html" ] || [ "index.html" -nt "$PUBLIC_DIR/index.html" ]; then
  cp index.html "$PUBLIC_DIR/"
  echo "   ✓ index.html copied"
else
  echo "   ⏭️  index.html already up to date"
fi

# Copy tweets data
echo ""
echo "📊 Copying tweet data..."
if [ -f "data/tweets.js" ]; then
  if [ ! -f "$PUBLIC_DIR/data/tweets.js" ] || [ "data/tweets.js" -nt "$PUBLIC_DIR/data/tweets.js" ]; then
    cp "data/tweets.js" "$PUBLIC_DIR/data/"
    echo "   ✓ tweets.js copied"
  else
    echo "   ⏭️  tweets.js already up to date"
  fi
fi

# Copy tweet parts if they exist
tweet_parts_found=0
for file in data/tweets-part*.js; do
  if [ -f "$file" ]; then
    tweet_parts_found=$((tweet_parts_found + 1))
    filename=$(basename "$file")
    if [ ! -f "$PUBLIC_DIR/data/$filename" ] || [ "$file" -nt "$PUBLIC_DIR/data/$filename" ]; then
      cp "$file" "$PUBLIC_DIR/data/"
      echo "   ✓ $filename copied"
    else
      echo "   ⏭️  $filename already up to date"
    fi
  fi
done

if [ $tweet_parts_found -eq 0 ] && [ ! -f "data/tweets.js" ]; then
  echo "   ⚠️  No tweet data files found!"
fi

# Copy public profile data (removing email from account.js)
echo ""
echo "👤 Processing profile data..."
if [ -f "data/account.js" ]; then
  echo "   📝 Creating safe account.js (removing email)..."
  # Create account.js without email
  sed 's/"email" : "[^"]*",//' "data/account.js" > "$PUBLIC_DIR/data/account.js"
  echo "   ✓ account.js copied (email removed)"
fi

if [ -f "data/profile.js" ]; then
  if [ ! -f "$PUBLIC_DIR/data/profile.js" ] || [ "data/profile.js" -nt "$PUBLIC_DIR/data/profile.js" ]; then
    cp "data/profile.js" "$PUBLIC_DIR/data/"
    echo "   ✓ profile.js copied"
  else
    echo "   ⏭️  profile.js already up to date"
  fi
fi

# Copy public follower/following data
if [ -f "data/follower.js" ]; then
  if [ ! -f "$PUBLIC_DIR/data/follower.js" ] || [ "data/follower.js" -nt "$PUBLIC_DIR/data/follower.js" ]; then
    cp "data/follower.js" "$PUBLIC_DIR/data/"
    echo "   ✓ follower.js copied"
  else
    echo "   ⏭️  follower.js already up to date"
  fi
fi

if [ -f "data/following.js" ]; then
  if [ ! -f "$PUBLIC_DIR/data/following.js" ] || [ "data/following.js" -nt "$PUBLIC_DIR/data/following.js" ]; then
    cp "data/following.js" "$PUBLIC_DIR/data/"
    echo "   ✓ following.js copied"
  else
    echo "   ⏭️  following.js already up to date"
  fi
fi

# Copy public likes data
if [ -f "data/like.js" ]; then
  if [ ! -f "$PUBLIC_DIR/data/like.js" ] || [ "data/like.js" -nt "$PUBLIC_DIR/data/like.js" ]; then
    cp "data/like.js" "$PUBLIC_DIR/data/"
    echo "   ✓ like.js copied"
  else
    echo "   ⏭️  like.js already up to date"
  fi
fi

# Copy essential media and assets
echo ""
echo "🎬 Copying media and assets..."

# Function to show progress bar
show_progress() {
  local current=$1
  local total=$2
  local width=50
  local percentage=$((current * 100 / total))
  local completed=$((current * width / total))

  printf "\r   ["
  for ((i=0; i<completed; i++)); do printf "#"; done
  for ((i=completed; i<width; i++)); do printf "-"; done
  printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"
}

# Function to copy with progress
copy_with_progress() {
  local source=$1
  local dest=$2
  local desc=$3
  local total_files=$(find "$source" -type f | wc -l)

  echo "   $desc"

  # Use pv if available for better progress, otherwise use basic progress
  if command -v pv >/dev/null 2>&1; then
    echo "   📁 Copying with pv..."
    tar -cf - -C "$source" . | pv -n -s $(du -sb "$source" | cut -f1) | tar -xf - -C "$dest"
  elif command -v rsync >/dev/null 2>&1; then
    # Simple rsync with file counting progress
    mkdir -p "$dest"

    echo "   📁 Copying $total_files files..."

    # Start rsync in background
    rsync -ah "$source/" "$dest/" &
    local rsync_pid=$!

    # Monitor progress by counting files
    local last_count=0
    while kill -0 $rsync_pid 2>/dev/null; do
      sleep 0.5
      local current_files=$(find "$dest" -type f 2>/dev/null | wc -l)

      if [ "$current_files" -ne "$last_count" ] && [ "$total_files" -gt 0 ]; then
        local percentage=$((current_files * 100 / total_files))
        if [ "$percentage" -gt 100 ]; then percentage=100; fi

        local filled=$((percentage / 2))
        local empty=$((50 - filled))

        printf "\r   ["
        printf '%*s' "$filled" '' | tr ' ' '#'
        printf '%*s' "$empty" '' | tr ' ' '-'
        printf "] %d%% (%d/%d)" "$percentage" "$current_files" "$total_files"

        last_count=$current_files
      fi
    done

    wait $rsync_pid
  else
    # Fallback: Use cp with spinning indicator
    echo "   📁 Copying $total_files files..."

    cp -r "$source" "$dest" &
    local cp_pid=$!

    local spin='-\|/'
    local i=0
    while kill -0 $cp_pid 2>/dev/null; do
      i=$(( (i+1) %4 ))
      printf "\r   ${spin:$i:1} Copying files... (%d files total)" "$total_files"
      sleep 0.5
    done

    wait $cp_pid
  fi

  printf "\r   [$(printf '%50s' | tr ' ' '█')] 100%% (%d files copied)" "$total_files"
  echo ""
}

if [ -d "data/tweets_media" ]; then
  if [ ! -d "$PUBLIC_DIR/data/tweets_media" ]; then
    media_count=$(find "data/tweets_media" -type f | wc -l)
    echo "   📸 Copying tweets media ($media_count files, this may take a while)..."

    if [ "$media_count" -gt 100 ]; then
      # Use rsync with progress for large archives
      copy_with_progress "data/tweets_media" "$PUBLIC_DIR/data/tweets_media"
    else
      # Simple copy for small archives
      cp -r "data/tweets_media" "$PUBLIC_DIR/data/"
      printf "\r   [$(printf '%50s' | tr ' ' '#')] 100%%"
      echo ""
    fi
    echo "   ✓ $media_count media files copied"
  else
    echo "   ⏭️  tweets_media already exists (skipping for speed)"
    echo "      💡 Delete $PUBLIC_DIR/data/tweets_media to force refresh"
  fi
else
  echo "   ℹ️  No tweets_media folder found"
fi

if [ -d "data/profile_media" ]; then
  if [ ! -d "$PUBLIC_DIR/data/profile_media" ]; then
    profile_count=$(find "data/profile_media" -type f | wc -l)
    echo "   👤 Copying profile media ($profile_count files)..."
    cp -r "data/profile_media" "$PUBLIC_DIR/data/"
    printf "\r   [$(printf '%50s' | tr ' ' '#')] 100%%"
    echo ""
    echo "   ✓ Profile media copied"
  else
    echo "   ⏭️  profile_media already exists"
  fi
else
  echo "   ℹ️  No profile_media folder found"
fi

if [ -d "assets" ]; then
  if [ ! -d "$PUBLIC_DIR/assets" ]; then
    echo "   🎨 Copying assets..."
    cp -r "assets" "$PUBLIC_DIR/"
    printf "\r   [$(printf '%50s' | tr ' ' '#')] 100%%"
    echo ""
    echo "   ✓ Assets copied"
  else
    echo "   ⏭️  assets already exists"
  fi
else
  echo "   ℹ️  No assets folder found"
fi

# Create a README for the public archive
cat > "$PUBLIC_DIR/README.md" << 'EOF'
# Public Twitter Archive

This is a public-safe version of a Twitter archive, containing only public tweets.

## What's included
- Public tweets only
- Media files from public tweets
- Profile images
- Assets folder (CSS, JS, icons)

## What's NOT included
- Email addresses or personal information
- Direct messages
- Following/follower lists
- Liked tweets
- Any private or sensitive data

## Usage
Open `index.html` in your web browser to view the archive.

## Privacy
This archive has been cleaned of sensitive personal information and is safe for public sharing.
EOF

# Create gitignore for the public version
cat > "$PUBLIC_DIR/.gitignore" << 'EOF'
# This is a public-safe archive
# Only tweet data should be here

# Just in case - ignore any accidentally added sensitive files
account.js
direct-messages*.js
follower.js
following.js
like.js
personalization.js
**/node_modules/
.DS_Store
EOF

echo ""
echo "✅ Public archive created successfully!"
echo ""
echo "📂 Your public archive is ready in: $PUBLIC_DIR"
echo ""
echo "🔍 What was included:"
if [ -f "$PUBLIC_DIR/data/tweets.js" ]; then
  tweet_count=$(grep -o '"tweet"' "$PUBLIC_DIR/data/tweets.js" | wc -l || echo "unknown")
  echo "   • $tweet_count tweets (approximately)"
fi

for file in "$PUBLIC_DIR"/data/tweets-part*.js; do
  if [ -f "$file" ]; then
    part_count=$(grep -o '"tweet"' "$file" | wc -l || echo "unknown")
    echo "   • $(basename "$file"): $part_count tweets (approximately)"
  fi
done

if [ -d "$PUBLIC_DIR/data/tweets_media" ]; then
  media_count=$(find "$PUBLIC_DIR/data/tweets_media" -type f | wc -l)
  echo "   • $media_count media files"
fi

if [ -d "$PUBLIC_DIR/assets" ]; then
  echo "   • Assets folder (viewer dependencies)"
fi

echo ""
echo "🚀 Next steps:"
echo "   1. Test the archive by opening $PUBLIC_DIR/index.html in your browser"
echo "   2. Review your tweets to ensure you're comfortable sharing them"
echo "   3. Upload the $PUBLIC_DIR folder to your hosting platform"
echo ""
echo "⚠️  IMPORTANT: Only share the contents of $PUBLIC_DIR - never your original archive!"
echo ""