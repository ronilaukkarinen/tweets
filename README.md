# 🐦 tweets - Yet another Twitter archive viewer

[![version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)](#)
[![javascript](https://img.shields.io/badge/javascript-%23F7DF1E.svg?style=for-the-badge&logo=javascript&logoColor=black)](#)
[![html5](https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white)](#)

A modern, responsive interface for viewing your Twitter archive data locally. This tool transforms your downloaded Twitter data into an elegant, Twitter-like interface that you can browse offline - with **minimal** effort!

**The goal: Single index.html file with JS, CSS and HTML - No compiling, no frameworks, no dependencies.**

## [Demo: tweets.rolle.wtf](https://tweets.rolle.wtf)

<img width="1414" height="1078" alt="screenshot" src="https://github.com/user-attachments/assets/463c692a-f032-4a98-a264-ac8c245aa924" />

## Features

- **Modern Twitter-like (2022) interface**, dim theme by default
- **Responsive design** that works on desktop and mobile
- **Advanced filtering and search** with smart defaults
- **Video autoplay** on scroll
- **Infinite scroll** for seamless browsing
- **Hashtag and mention linking** with search integration
- **Date range filtering** and sorting options
- **Individual tweet permalinks** with back navigation

## Quick start

1. **Download your Twitter archive** from Twitter's settings
2. **Extract the archive** to a folder on your computer
3. **Download `index.html`** from this repository
4. **Place `index.html`** in the root of your extracted Twitter archive folder (same level as the `data` folder)
5. **Open `index.html`** in your web browser

## Folder structure

Your Twitter archive should look like this:

```
twitter-archive/
├── index.html <- Add this to the root of your archive
├── data/
│   ├── account.js
│   ├── tweets.js
│   ├── tweets_media/
│   └── profile_media/
└── assets/
    └── ...
```

## Publishing your archive publicly

**⚠️ This tool is intended for PUBLIC Twitter accounts only. If your account was private/locked, do not use this tool for public sharing.**

### Automated public archive creation

Use the included script to safely create a public version:

```bash
# In your Twitter archive folder
./create-public-archive.sh
```

This script will:
- Copy only public data (tweets, profile info, followers/following)
- Remove your email address automatically
- Create a `public-twitter-archive/` folder ready for sharing

### What gets included safely

✅ **Always included:**
- Your public tweets (`tweets.js`)
- Profile information (bio, avatar, banner) - minus email
- Media from your tweets (images, videos)
- Follower/following lists (public data)
- Liked tweets (public data)

❌ **Never included:**
- Email address (automatically removed)
- Direct messages (the only truly private data)
- Any tracking or personalization data

### Publishing your archive

After running the script:

1. **Test locally**: Open `public-twitter-archive/index.html` in your browser
2. **Review content**: Make sure you're comfortable with all visible tweets
3. **Upload to web hosting**:
   - GitHub Pages
   - Netlify
   - Your own web server
   - Any static hosting service

## Disclaimer

This tool is not affiliated with Twitter/X. It's designed to work with Twitter archive data as provided by Twitter's official export feature.
