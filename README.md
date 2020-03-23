# Automatic Music Box Transcription

A processing sketch to automatically transcribe MIDI files for [30 note chromatic music boxes](https://www.grand-illusions.com/30-note-music-box-set-c2x21140081).

## Measurements

### 30 Note Chromatic Model

| Measurement           | (mm)                          |
| --------------------- | ----------------------------- |
| Note Spacing          | 1.97                          |
| Roll Width            | 70                            |
| Margin                | 6.45                          |
| Minimum Note Distance | 6.5                           |
| thickness             | 0.3048 (12/1000" or ~300 gsm) |
| note Radius           | 1.1                           |


### Example Ouput

![](AutoMusicBox/data/svg/Une_Comptine_Autre_page_0.svg)

Example files can be found in:

`AutoMusicBox/data/svg`

![](img/laser_cut_timelapse.gif)

***

## TODO

- [ ] Octave adjustment for each MIDI track.
- [ ] MIDI track cherry picking
- [ ] Score Scrolling
- [ ] Automatic diagonal cut for page splicing

## Current Issues

- [ ] Running State not correctly parsed

    Running state in MIDI files isn't currently being picked up correctly. It will work for some of the time, but some transition isn't being detected.

- [ ] Output SVG paging does not match sketch paging

    Going through pages of the sketch suggests there are more than there actually are. Likely something to do with the limits of the page between the SVG and what is drawn in the sketch.

- [ ] Page Overlap

    There is currently an overlap in pages of around `5cm`. this is actually handy for splicing pages together.
