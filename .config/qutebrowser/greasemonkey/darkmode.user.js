// ==UserScript==
// @name          Dark Reader (Unofficial)
// @namespace     DarkReader
// @description	  Inverts the brightness of pages to reduce eye strain
// @run-at        document-end
// @grant         none
// @require       https://cdn.jsdelivr.net/npm/darkreader/darkreader.min.js
// @noframes
// @exclude     https://duckduckgo.com/*
// @exclude     https://*.duckduckgo.com/*
// @exclude     https://github.com/*
// @exclude     https://*.github.com/*
// @exclude     https://*.github.io/*
// @exclude     https://sr.ht/*
// @exclude     https://*.sr.ht/*
// @exclude     https://outlook.*
// @exclude     https://*.slack.com/*
// @exclude     https://adigitoleo.*
// @exclude     https://vimcolorschemes.com/*

//
// ==/UserScript==

DarkReader.auto({
	brightness: 100,
	contrast: 90,
	sepia: 10
});
