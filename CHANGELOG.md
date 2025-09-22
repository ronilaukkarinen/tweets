#### 1.0.0: 2025-09-22

* Fix horizontal scrollbar on mobile by using max() in calc() for sidebar positioning
* Prevent negative positioning of fixed sidebars on narrow viewports
* Fix tab bar overflow on viewports under 420px by reducing padding and font sizes
* Add responsive breakpoints for header and tab padding at 420px and 320px
* Fix URLs not showing when they appear at the end of posts with media
* Only hide t.co URLs when they actually point to media, not external sites
* Convert all remaining t.co URLs to clickable links regardless of media presence
* Fix Safari mobile video fullscreen issue by adding playsinline attribute
* Add webkit-playsinline CSS property for video elements
* Improve responsive breakpoints for sidebars positioning
