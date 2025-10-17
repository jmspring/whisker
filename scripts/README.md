# Whisker Scripts

Utility scripts for working with Whisker story files.

---

## whisker_parse.lua

Comprehensive command-line parser tool for Whisker stories.

### Quick Start

```bash
# Validate a story file
lua scripts/whisker_parse.lua validate story.whisker

# Show statistics
lua scripts/whisker_parse.lua stats story.whisker

# Check for broken links
lua scripts/whisker_parse.lua check-links story.whisker

# Convert between formats
lua scripts/whisker_parse.lua convert story_v1.whisker story_v2.whisker
```

### All Commands

| Command | Description | Example |
|---------|-------------|---------|
| `validate <file>` | Validate JSON and Whisker format | `validate story.whisker` |
| `load <file>` | Load and show basic info | `load story.whisker` |
| `convert <in> <out>` | Auto-convert between 1.0 ↔ 2.0 | `convert old.whisker new.whisker` |
| `compact <in> <out>` | Force convert to compact 2.0 | `compact story.whisker compact.whisker` |
| `verbose <in> <out>` | Force convert to verbose 1.0 | `verbose story.whisker verbose.whisker` |
| `stats <file>` | Show detailed statistics | `stats story.whisker` |
| `check-links <file>` | Find broken passage links | `check-links story.whisker` |
| `info <file>` | Show all passages and metadata | `info story.whisker` |

### Examples

**Validate the Rijksmuseum tour:**
```bash
$ lua scripts/whisker_parse.lua validate examples/museum_tours/rijksmuseum/rijksmuseum_tour.whisker

✅ Valid JSON
✅ Valid Whisker format
Format version: 2.0
Story title: Masters of Light: Dutch Golden Age Tour
Passages: 17
```

**Convert to compact format:**
```bash
$ lua scripts/whisker_parse.lua compact verbose.whisker compact.whisker

Input size:  52.3 KB
Output size: 38.1 KB
Savings:     14.2 KB (27%)
✅ Smaller file created!
```

**Check for broken links:**
```bash
$ lua scripts/whisker_parse.lua check-links story.whisker

Total links checked: 52
Broken links found:  0
✅ All links are valid!
```

**Show story statistics:**
```bash
$ lua scripts/whisker_parse.lua stats story.whisker

Story Statistics
------------------------------------------------------------------------
  Passages:    17
  Total words: 3721
  Avg words/passage: 218

Choice Statistics
------------------------------------------------------------------------
  Total choices:     52
  Passages w/choices: 17 (100%)
  Avg choices/passage: 3.1
  Max choices: 13
```

### Exit Codes

- `0` - Success
- `1` - Error (validation failed, broken links found, etc.)

### Documentation

See [WHISKER_PARSERS.md](../docs/WHISKER_PARSERS.md) for complete parser documentation.

---

## Other Scripts

*(Add other scripts here as they are created)*

---

**Version:** 1.0.0
**Last Updated:** 2025-10-15
