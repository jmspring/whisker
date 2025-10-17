#!/usr/bin/env python3
"""
Generate actual audio files using Google TTS (gTTS)
Extracts scripts from tour passages and creates MP3 files
"""

import json
from pathlib import Path
import re

try:
    from gtts import gTTS
    GTTS_AVAILABLE = True
except ImportError:
    GTTS_AVAILABLE = False

# Audio script templates (concise versions for TTS)
AUDIO_SCRIPTS = {
    'night_watch.mp3': {
        'en': """Welcome to The Night Watch by Rembrandt van Rijn, painted in 1642.

At first glance, you might think this is a nighttime scene, but it's actually daytime! Centuries of varnish darkened the painting until restoration revealed Rembrandt's true intention: a company of civic guards emerging from shadow into brilliant light.

Notice Captain Frans Banninck Cocq in the center, dressed in black with a red sash. His hand casts a shadow on his lieutenant's golden coat - this proves Rembrandt's mastery of light.

Look for the mysterious girl in the golden dress on the left. Scholars still debate whether she's real or symbolic. And see if you can spot the hidden dog at the lower right. Count the figures - there are 34 people total!

Rembrandt was at the height of his career when he created this revolutionary group portrait. Instead of static, posed compositions, he showed the militia in dynamic action, capturing a moment of movement and drama.""",
        'duration': 240
    },
    'milkmaid.mp3': {
        'en': """This is The Milkmaid by Johannes Vermeer, painted around 1660.

Vermeer's masterpiece shows a kitchen maid pouring milk, transforming a simple domestic scene into something monumental and timeless.

Notice how natural light floods in from the window on the left. The way light catches the texture of the bread, the gleam of the brass, the rough wall - this is Vermeer's genius.

Look closely at the bread on the table. Vermeer used tiny dots of paint to create texture. This technique wouldn't be called pointillism until the Impressionists created it 200 years later!

The maid has dignity, focus, and presence. In Vermeer's time, the Netherlands celebrated domestic life and everyday virtues. This painting elevates a working servant to the status usually reserved for nobility.

Vermeer lived his entire life in Delft, producing only about 35 paintings. Today, his intimate scenes of domestic life are considered among the greatest achievements in Western art.""",
        'duration': 180
    },
    'merry_drinker.mp3': {
        'en': """Welcome to The Merry Drinker by Frans Hals, painted around 1628 to 1630.

Frans Hals captures pure joy in this portrait. You can almost hear the man's laughter!

Hals's technique was radical for his time. Notice the loose, visible brushstrokes - especially in the clothing and lace collar. Get close to the painting: it looks almost abstract. Step back: it resolves into incredible realism.

The subject raises his glass, offering you a drink, with a genuine smile. Direct eye contact engages you, the viewer, with confidence and openness.

Frans Hals was Haarlem's greatest portrait painter, known for capturing personality and spontaneity. While Rembrandt explored psychology and drama, Hals captured the spark of life - the moment before the smile breaks into laughter.

His influence reached from Manet to Van Gogh, who studied his brushwork intensely.""",
        'duration': 150
    },
    'self_portrait_paul.mp3': {
        'en': """This is Self-Portrait as the Apostle Paul by Rembrandt van Rijn, painted in 1661.

This self-portrait comes from Rembrandt's final decade, a period of personal tragedy but artistic triumph. By 1661, Rembrandt had faced bankruptcy and lost his beloved wife, yet he painted some of his greatest masterpieces.

Rembrandt depicts himself as Paul the Apostle, holding a manuscript representing Paul's letters. This wasn't vanity - it was identification. Like Paul, Rembrandt had experienced success, suffering, and spiritual depth.

Notice the sword, Paul's attribute as a martyr, and the aging face - Rembrandt was 55, weathered by life, with a penetrating gaze showing wisdom and introspection.

Compare this to The Night Watch, painted 19 years earlier. The brushwork here is looser, more expressive. Rembrandt builds up thick layers of paint, creating depth and luminosity. The face seems to emerge from darkness into light.""",
        'duration': 180
    },
    'jewish_bride.mp3': {
        'en': """This is The Jewish Bride by Rembrandt van Rijn, painted between 1665 and 1669.

Vincent van Gogh said he would give ten years of his life to sit before this painting for two weeks. That's how powerful it is.

Despite the traditional title, we don't actually know if the couple is Jewish, or if it depicts a bride. Theories suggest it could be biblical Isaac and Rebekah, a wealthy Amsterdam couple in costume, or even Rembrandt's son and his bride.

What we do know: This is one of art's greatest depictions of love, tenderness, and intimacy.

Look at their hands. His right hand gently rests on her heart. Her hand tenderly covers his. The intimacy is palpable. This gesture, so simple and human, has moved viewers for 350 years.

By this period, Rembrandt painted with unprecedented freedom. The clothing is built up with thick, almost sculptural paint. The faces glow with inner light. Colors are rich, warm, and golden. Rembrandt has transcended technique - this is pure emotion made visible.""",
        'duration': 180
    },
    'still_life.mp3': {
        'en': """Welcome to Still Life with Flowers and Fruit by Jan van Huysum, painted around 1715.

Jan van Huysum was the most celebrated still life painter of his generation. Look closely - you can see why.

Here's the secret: These flowers could never bloom together. Van Huysum painted them over months, as each species came into season. Tulips in spring, roses in summer, peonies at different times. The painting is a botanical fantasy - nature perfected beyond reality.

During the Dutch Golden Age, the Netherlands dominated world trade in flowers, especially tulips. A painting like this celebrated Dutch botanical expertise and global commerce.

Every element has meaning. Flowers represent beauty and the fragility of life. Insects show the natural cycle and decay. Fruit symbolizes abundance and sensuality. Dewdrops represent purity and freshness.

Dutch viewers read these paintings like books, finding moral lessons and spiritual truths in bouquets.""",
        'duration': 150
    },
    'threatened_swan.mp3': {
        'en': """This is The Threatened Swan by Jan Asselijn, painted around 1650.

This isn't just a swan - it's the Netherlands itself! The swan represents the Dutch statesman Johan de Witt defending the country, represented by the eggs, against enemies, represented by the dog.

Notice the swan's aggressive posture, spread wings, and protective stance over the nest. This painting was political propaganda disguised as a nature scene.

Paintings like this used animal symbolism to comment on politics safely during dangerous times in Dutch history.""",
        'duration': 150
    },
    'winter_landscape.mp3': {
        'en': """This is Winter Landscape with Ice Skaters by Hendrick Avercamp, painted around 1608.

Avercamp specialized in winter scenes, capturing Dutch life during the Little Ice Age when winters were much colder than today. The frozen canals became highways and gathering places.

Find these details: people skating, sledding, playing golf on ice. Notice wealthy and poor mixing together. See the couple in a private moment on the left, children playing in the center, and a man who has fallen in the right foreground.

Avercamp was deaf and mute, which may have sharpened his observational skills. Notice how he captures dozens of tiny narratives in one panoramic scene.

This painting shows us daily life during the Dutch Golden Age, when even winter's harsh weather became an opportunity for community and celebration.""",
        'duration': 180
    },
    'delftware.mp3': {
        'en': """Welcome to the Delftware Collection, featuring pottery from the 17th and 18th centuries.

Delftware, the iconic blue and white pottery, was the Netherlands' answer to Chinese porcelain. When Dutch traders brought back porcelain from Asia via the Dutch East India Company, local potters in Delft began creating their own versions.

What made Delftware special? It's tin-glazed earthenware, not true porcelain. It features hand-painted blue designs mixing Dutch scenes with Asian motifs, and it became wildly popular across Europe.

This collection represents the Dutch Golden Age's global reach - trade routes to Asia, artistic innovation at home, and the wealth that allowed Dutch families to fill their homes with beautiful objects.""",
        'duration': 150
    },
    'battle_waterloo.mp3': {
        'en': """This is The Battle of Waterloo by Jan Willem Pieneman, painted in 1824.

At over 8 meters wide, this is one of the largest paintings in the Rijksmuseum. Pieneman depicts the decisive moment of the Battle of Waterloo on June 18, 1815, when Napoleon's final defeat secured peace in Europe.

You're looking at the battlefield near Brussels at approximately 4 PM. The Duke of Wellington, center on the white horse, has just received word that Prussian reinforcements are arriving. The battle's outcome is about to turn decisively against Napoleon.

Key figures include the Duke of Wellington in the center, William Prince of Orange wounded and being carried - he's the Dutch heir who would become King William II - and Lord Uxbridge, the British cavalry commander, on the right.

Notice how Prince William is prominently featured despite his relatively minor role. Pieneman was painting Dutch patriotism as much as historical accuracy, glorifying Dutch courage in the coalition victory.

Waterloo ended 23 years of nearly continuous warfare that had engulfed Europe since the French Revolution.""",
        'duration': 180
    },
    'warship_model.mp3': {
        'en': """This is a model of the Warship Amsterdam, created around 1750.

During the 17th and 18th centuries, the Netherlands was a global maritime superpower. This exquisitely detailed ship model represents a Dutch warship from the height of Dutch naval dominance.

This isn't a toy - it's a working model built to exact specifications. Shipwrights created these models for design and planning. Scale models allowed naval architects to test designs before construction. Clients like the Admiralty could approve designs, and builders could calculate material costs.

These models also served as prestige objects, demonstrating Dutch craftsmanship and technological superiority. They were displayed in guild halls and given as diplomatic gifts to foreign courts.

At its peak in the mid-1600s, the Dutch Republic possessed the world's largest merchant fleet - more ships than England, France, and Spain combined. The Dutch East India Company maintained its own navy to protect trade routes to Asia.

Dutch wealth during the Golden Age rested on sea power. Ships like this protected trade routes, secured colonies, and projected Dutch influence globally.""",
        'duration': 150
    },
    'dutch_dollhouse.mp3': {
        'en': """This is the Dutch Dollhouse of Petronella Oortman, created between 1686 and 1710.

This isn't a child's toy - it's a wealthy woman's most prized possession. Petronella Oortman, wife of a rich Amsterdam silk merchant, spent a fortune assembling this miniature mansion. Contemporary accounts suggest it cost as much as an actual Amsterdam canal house!

This cabinet dollhouse represents an idealized wealthy Dutch home from around 1700. It has three floors: the top floor shows private chambers including a bedroom with a canopied bed and tiny embroidered linens. The middle floor displays reception rooms for formal entertaining. The ground floor contains working areas, including a kitchen with copper pots and a working fireplace.

Every single object was hand-crafted by master artisans. Real artists created miniature artworks for the walls. Master cabinetmakers built scaled furniture. Goldsmiths created tiny functional silver utensils. Delftware factories made miniature porcelain. Look closely - that's real gold leaf, actual silk damask, and genuine pearls on the miniature costumes.

Remarkably, this 300-plus year-old object survives almost intact. Petronella's dollhouse survived because it was always a display piece, carefully maintained by successive generations. The Rijksmuseum acquired it in 1876, and it has captivated visitors ever since.""",
        'duration': 180
    }
}

def generate_audio_files():
    """Generate all audio files using gTTS."""

    print("🎧 Generating Audio Files with Google TTS")
    print("=" * 80)

    if not GTTS_AVAILABLE:
        print("❌ gTTS not available")
        print("Install with: pip install gtts")
        return

    print("✅ gTTS available - generating audio files")
    print()

    # Create directories
    Path('assets/audio/en').mkdir(parents=True, exist_ok=True)
    Path('assets/audio/nl').mkdir(parents=True, exist_ok=True)

    success_count = 0
    total_duration = 0

    for filename, data in AUDIO_SCRIPTS.items():
        print(f"\n{filename}:")

        # Generate English version
        try:
            en_text = data['en']
            duration = data.get('duration', 180)

            tts_en = gTTS(text=en_text, lang='en', slow=False)
            en_path = f"assets/audio/en/{filename}"
            tts_en.save(en_path)

            file_size = Path(en_path).stat().st_size / 1024
            minutes = duration // 60
            seconds = duration % 60
            print(f"  ✅ EN: {filename} ({file_size:.1f} KB, ~{minutes}:{seconds:02d})")

            success_count += 1
            total_duration += duration

        except Exception as e:
            print(f"  ❌ EN: Error - {e}")

        # Generate Dutch version (using English text for now - would need translation)
        try:
            # Note: For production, scripts should be properly translated
            # Using English with Dutch TTS as placeholder
            tts_nl = gTTS(text=en_text, lang='nl', slow=False)
            nl_path = f"assets/audio/nl/{filename}"
            tts_nl.save(nl_path)

            file_size = Path(nl_path).stat().st_size / 1024
            print(f"  ✅ NL: {filename} ({file_size:.1f} KB, ~{minutes}:{seconds:02d})")

            success_count += 1

        except Exception as e:
            print(f"  ❌ NL: Error - {e}")

    print()
    print("=" * 80)
    print(f"✅ Generated {success_count} audio files!")
    print(f"📁 Location: assets/audio/en/ and assets/audio/nl/")
    print(f"⏱️  Total audio time: ~{total_duration // 60} minutes per language")
    print()
    print("Audio specifications:")
    print("  - Generated with: Google TTS (gTTS)")
    print("  - Format: MP3")
    print("  - Language: English (en) and Dutch (nl)")
    print("  - Quality: Standard TTS")
    print()
    print("⚠️  Notes:")
    print("  - Dutch audio uses English text (needs professional translation)")
    print("  - TTS quality is good but not professional narrator quality")
    print("  - For production, consider:")
    print("    • Professional Dutch translation")
    print("    • Azure Neural TTS or Google Cloud TTS (higher quality)")
    print("    • Professional narrators for best quality")
    print("=" * 80)

if __name__ == '__main__':
    try:
        generate_audio_files()
    except Exception as e:
        print(f"❌ Error: {e}")
        print()
        print("Requirements:")
        print("  pip install gtts")
