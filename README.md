# DarkSoulsCompanion

A helper webapp for playing Dark Souls. Written as a test run of AngularJS.

## About

I was playing Dark Souls at the same time as I decided to try out "that AngularJS thing everyone's raving about", here's the result. An attempt to create a useful, all-in-one Dark Souls armor and weapon finder that takes into account the character's inventory, including materials for available upgrades.

## How to use

Grab the "pub" directory, put the contents on any web server and you're good to go. Everything is self-contained and should work out-of-the-box.

A web server is necessary, because DSC loads data files dynamically using AJAX, and that doesn't work with local files. I'm hoping to eventually add a on offline version that you can run from the filesystem like any application, but no ETA.

## Roadmap
There are no ETAs for anything, or any guarantee for progress at all, since this is a free-time, do-as-I-please project. But here's a general outline for what I'd like to eventually do:

### v0.2 Item data
Add all item data in an exportable (JSON, XML, CSV) format.

### v0.2.1 Tweaks and improvements
Add enhancements and minor additional functionality to existing features.

### v0.3 Checklist
A more advanced, more beginner-friendly and less spoiler-y version of http://smcnabb.github.io/dark-souls-cheat-sheet/.

### v0.4 Ascention support for weapon finder
Currently weapon finder only looks at the weapons you have and their available reinforcements. I'd like to also make it possible to see available ascentions.
