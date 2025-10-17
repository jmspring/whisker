#!/usr/bin/env python3
"""
Generate all remaining audio files using Google TTS
Creates both English and Dutch versions
"""

from pathlib import Path
import time

try:
    from gtts import gTTS
    GTTS_AVAILABLE = True
except ImportError:
    GTTS_AVAILABLE = False
    print("❌ gTTS not available. Install with: pip install gtts")
    exit(1)

# Concise audio scripts for all artworks
AUDIO_SCRIPTS = {
    'night_watch.mp3': {
        'en': """Welcome to The Night Watch by Rembrandt van Rijn, painted in 1642. At first glance, you might think this is a nighttime scene, but it's actually daytime! Centuries of varnish darkened the painting until restoration revealed Rembrandt's true intention: a company of civic guards emerging from shadow into brilliant light. Notice Captain Frans Banninck Cocq in the center, dressed in black with a red sash. His hand casts a shadow on his lieutenant's golden coat, proving Rembrandt's mastery of light. Look for the mysterious girl in the golden dress on the left. Scholars still debate whether she's real or symbolic. And see if you can spot the hidden dog at the lower right. Count the figures, there are 34 people total! Rembrandt was at the height of his career when he created this revolutionary group portrait.""",
        'nl': """Welkom bij De Nachtwacht van Rembrandt van Rijn, geschilderd in 1642. Op het eerste gezicht zou je denken dat dit een nachtscène is, maar het is eigenlijk overdag! Eeuwenlang vernis heeft het schilderij verdonkerd totdat restauratie Rembrandts werkelijke bedoeling onthulde: een compagnie schutters die vanuit de schaduw in briljant licht tevoorschijn komen. Let op Kapitein Frans Banninck Cocq in het midden, gekleed in zwart met een rode sjerp. Zijn hand werpt een schaduw op de gouden jas van zijn luitenant, wat Rembrandts meesterschap van licht bewijst. Zoek het mysterieuze meisje in de gouden jurk aan de linkerkant. Geleerden debatteren nog steeds of ze echt of symbolisch is."""
    },
    'milkmaid.mp3': {
        'en': """This is The Milkmaid by Johannes Vermeer, painted around 1660. Vermeer's masterpiece shows a kitchen maid pouring milk, transforming a simple domestic scene into something monumental and timeless. Notice how natural light floods in from the window on the left. The way light catches the texture of the bread, the gleam of the brass, the rough wall, this is Vermeer's genius. Look closely at the bread on the table. Vermeer used tiny dots of paint to create texture. This technique wouldn't be called pointillism until the Impressionists created it 200 years later! The maid has dignity, focus, and presence. In Vermeer's time, the Netherlands celebrated domestic life and everyday virtues. This painting elevates a working servant to the status usually reserved for nobility.""",
        'nl': """Dit is Het Melkmeisje van Johannes Vermeer, geschilderd rond 1660. Vermeers meesterwerk toont een keukenmeid die melk schenkt, waarbij een eenvoudige huishoudelijke scène wordt getransformeerd in iets monumentaals en tijdloos. Let op hoe natuurlijk licht vanaf links door het raam naar binnen stroomt. De manier waarop het licht de textuur van het brood, de glans van het koper, de ruwe muur vangt, dit is Vermeers genialiteit. Kijk goed naar het brood op tafel. Vermeer gebruikte kleine verfstipjes om textuur te creëren. Deze techniek zou pas 200 jaar later pointillisme genoemd worden!"""
    },
    'merry_drinker.mp3': {
        'en': """Welcome to The Merry Drinker by Frans Hals, painted around 1628 to 1630. Frans Hals captures pure joy in this portrait. You can almost hear the man's laughter! Hals's technique was radical for his time. Notice the loose, visible brushstrokes, especially in the clothing and lace collar. Get close to the painting: it looks almost abstract. Step back: it resolves into incredible realism. The subject raises his glass, offering you a drink, with a genuine smile. Direct eye contact engages you, the viewer, with confidence and openness. Frans Hals was Haarlem's greatest portrait painter, known for capturing personality and spontaneity. His influence reached from Manet to Van Gogh, who studied his brushwork intensely.""",
        'nl': """Welkom bij De Vrolijke Drinker van Frans Hals, geschilderd rond 1628 tot 1630. Frans Hals vangt pure vreugde in dit portret. Je kunt bijna het lachen van de man horen! Hals' techniek was radicaal voor zijn tijd. Let op de losse, zichtbare penseelstreken, vooral in de kleding en de kanten kraag. Ga dicht bij het schilderij staan: het ziet er bijna abstract uit. Stap terug: het lost op in ongelooflijk realisme. Het onderwerp heft zijn glas, biedt je een drankje aan, met een oprechte glimlach."""
    },
    'self_portrait_paul.mp3': {
        'en': """This is Self-Portrait as the Apostle Paul by Rembrandt van Rijn, painted in 1661. This self-portrait comes from Rembrandt's final decade, a period of personal tragedy but artistic triumph. By 1661, Rembrandt had faced bankruptcy and lost his beloved wife, yet he painted some of his greatest masterpieces. Rembrandt depicts himself as Paul the Apostle, holding a manuscript representing Paul's letters. This wasn't vanity, it was identification. Like Paul, Rembrandt had experienced success, suffering, and spiritual depth. Notice the sword, Paul's attribute as a martyr, and the aging face, Rembrandt was 55, weathered by life, with a penetrating gaze showing wisdom and introspection.""",
        'nl': """Dit is Zelfportret als de Apostel Paulus van Rembrandt van Rijn, geschilderd in 1661. Dit zelfportret komt uit Rembrandts laatste decennium, een periode van persoonlijke tragedie maar artistieke triomf. In 1661 had Rembrandt faillissement meegemaakt en zijn geliefde vrouw verloren, maar toch schilderde hij enkele van zijn grootste meesterwerken. Rembrandt beeldt zichzelf af als Paulus de Apostel, met een manuscript dat Paulus' brieven vertegenwoordigt."""
    },
    'jewish_bride.mp3': {
        'en': """This is The Jewish Bride by Rembrandt van Rijn, painted between 1665 and 1669. Vincent van Gogh said he would give ten years of his life to sit before this painting for two weeks. That's how powerful it is. Despite the traditional title, we don't actually know if the couple is Jewish, or if it depicts a bride. What we do know: This is one of art's greatest depictions of love, tenderness, and intimacy. Look at their hands. His right hand gently rests on her heart. Her hand tenderly covers his. The intimacy is palpable. This gesture, so simple and human, has moved viewers for 350 years. By this period, Rembrandt painted with unprecedented freedom. The clothing is built up with thick, almost sculptural paint.""",
        'nl': """Dit is Het Joodse Bruidje van Rembrandt van Rijn, geschilderd tussen 1665 en 1669. Vincent van Gogh zei dat hij tien jaar van zijn leven zou geven om twee weken voor dit schilderij te zitten. Zo krachtig is het. Ondanks de traditionele titel weten we eigenlijk niet of het paar Joods is, of dat het een bruid afbeeldt. Wat we wel weten: Dit is een van de grootste uitbeeldingen van liefde, tederheid en intimiteit in de kunst. Kijk naar hun handen. Zijn rechterhand rust zachtjes op haar hart. Haar hand bedekt teder de zijne."""
    },
    'still_life.mp3': {
        'en': """Welcome to Still Life with Flowers and Fruit by Jan van Huysum, painted around 1715. Jan van Huysum was the most celebrated still life painter of his generation. Look closely, you can see why. Here's the secret: These flowers could never bloom together. Van Huysum painted them over months, as each species came into season. Tulips in spring, roses in summer, peonies at different times. The painting is a botanical fantasy, nature perfected beyond reality. During the Dutch Golden Age, the Netherlands dominated world trade in flowers, especially tulips. A painting like this celebrated Dutch botanical expertise and global commerce. Every element has meaning. Flowers represent beauty and the fragility of life.""",
        'nl': """Welkom bij Stilleven met Bloemen en Fruit van Jan van Huysum, geschilderd rond 1715. Jan van Huysum was de meest gevierde stilleven schilder van zijn generatie. Kijk goed, dan zie je waarom. Hier is het geheim: Deze bloemen konden nooit samen bloeien. Van Huysum schilderde ze over maanden, toen elke soort in het seizoen kwam. Tulpen in de lente, rozen in de zomer, pioenrozen op verschillende momenten. Het schilderij is een botanische fantasie, natuur geperfectioneerd voorbij de werkelijkheid."""
    },
    'threatened_swan.mp3': {
        'en': """This is The Threatened Swan by Jan Asselijn, painted around 1650. This isn't just a swan, it's the Netherlands itself! The swan represents the Dutch statesman Johan de Witt defending the country, represented by the eggs, against enemies, represented by the dog. Notice the swan's aggressive posture, spread wings, and protective stance over the nest. This painting was political propaganda disguised as a nature scene. Paintings like this used animal symbolism to comment on politics safely during dangerous times in Dutch history.""",
        'nl': """Dit is De Bedreigde Zwaan van Jan Asselijn, geschilderd rond 1650. Dit is niet zomaar een zwaan, het is Nederland zelf! De zwaan vertegenwoordigt de Nederlandse staatsman Johan de Witt die het land, vertegenwoordigd door de eieren, verdedigt tegen vijanden, vertegenwoordigd door de hond. Let op de agressieve houding van de zwaan, gespreide vleugels, en beschermende houding over het nest. Dit schilderij was politieke propaganda vermomd als natuurtafereel."""
    },
    'winter_landscape.mp3': {
        'en': """This is Winter Landscape with Ice Skaters by Hendrick Avercamp, painted around 1608. Avercamp specialized in winter scenes, capturing Dutch life during the Little Ice Age when winters were much colder than today. The frozen canals became highways and gathering places. Find these details: people skating, sledding, playing golf on ice. Notice wealthy and poor mixing together. See the couple in a private moment on the left, children playing in the center, and a man who has fallen in the right foreground. Avercamp was deaf and mute, which may have sharpened his observational skills. Notice how he captures dozens of tiny narratives in one panoramic scene.""",
        'nl': """Dit is Winterlandschap met IJsschaatsers van Hendrick Avercamp, geschilderd rond 1608. Avercamp was gespecialiseerd in wintertaferelen en legde het Nederlandse leven vast tijdens de Kleine IJstijd, toen de winters veel kouder waren dan vandaag. De bevroren grachten werden snelwegen en ontmoetingsplaatsen. Vind deze details: mensen aan het schaatsen, sleeën, golf spelen op het ijs. Let op hoe rijk en arm door elkaar zijn. Zie het paar in een privémoment aan de linkerkant, kinderen spelend in het midden."""
    },
    'delftware.mp3': {
        'en': """Welcome to the Delftware Collection, featuring pottery from the 17th and 18th centuries. Delftware, the iconic blue and white pottery, was the Netherlands' answer to Chinese porcelain. When Dutch traders brought back porcelain from Asia via the Dutch East India Company, local potters in Delft began creating their own versions. What made Delftware special? It's tin-glazed earthenware, not true porcelain. It features hand-painted blue designs mixing Dutch scenes with Asian motifs, and it became wildly popular across Europe. This collection represents the Dutch Golden Age's global reach, trade routes to Asia, artistic innovation at home, and the wealth that allowed Dutch families to fill their homes with beautiful objects.""",
        'nl': """Welkom bij de Delfts Blauw Collectie, met aardewerk uit de 17e en 18e eeuw. Delfts blauw, het iconische blauw-witte aardewerk, was het Nederlandse antwoord op Chinees porselein. Toen Nederlandse handelaren porselein terugbrachten uit Azië via de Vereenigde Oost-Indische Compagnie, begonnen lokale pottenbakkers in Delft hun eigen versies te maken. Wat maakte Delfts blauw speciaal? Het is tin-geglazuurd aardewerk, geen echt porselein. Het heeft handgeschilderde blauwe ontwerpen die Nederlandse taferelen mengen met Aziatische motieven."""
    },
    'battle_waterloo.mp3': {
        'en': """This is The Battle of Waterloo by Jan Willem Pieneman, painted in 1824. At over 8 meters wide, this is one of the largest paintings in the Rijksmuseum. Pieneman depicts the decisive moment of the Battle of Waterloo on June 18, 1815, when Napoleon's final defeat secured peace in Europe. You're looking at the battlefield near Brussels at approximately 4 PM. The Duke of Wellington, center on the white horse, has just received word that Prussian reinforcements are arriving. Key figures include William Prince of Orange wounded and being carried, the Dutch heir who would become King William II. Notice how Prince William is prominently featured despite his relatively minor role. Pieneman was painting Dutch patriotism as much as historical accuracy.""",
        'nl': """Dit is De Slag bij Waterloo van Jan Willem Pieneman, geschilderd in 1824. Met meer dan 8 meter breed is dit een van de grootste schilderijen in het Rijksmuseum. Pieneman beeldt het beslissende moment van de Slag bij Waterloo af op 18 juni 1815, toen Napoleons definitieve nederlaag vrede in Europa verzekerde. Je kijkt naar het slagveld bij Brussel rond 4 uur 's middags. De Hertog van Wellington, centraal op het witte paard, heeft net bericht ontvangen dat Pruisische versterkingen aankomen."""
    },
    'warship_model.mp3': {
        'en': """This is a model of the Warship Amsterdam, created around 1750. During the 17th and 18th centuries, the Netherlands was a global maritime superpower. This exquisitely detailed ship model represents a Dutch warship from the height of Dutch naval dominance. This isn't a toy, it's a working model built to exact specifications. Shipwrights created these models for design and planning. At its peak in the mid-1600s, the Dutch Republic possessed the world's largest merchant fleet, more ships than England, France, and Spain combined. The Dutch East India Company maintained its own navy to protect trade routes to Asia. Dutch wealth during the Golden Age rested on sea power.""",
        'nl': """Dit is een model van het Oorlogsschip Amsterdam, gemaakt rond 1750. Tijdens de 17e en 18e eeuw was Nederland een wereldwijde maritieme grootmacht. Dit uiterst gedetailleerde scheepsmodel vertegenwoordigt een Nederlands oorlogsschip uit de hoogtijdagen van de Nederlandse zeemacht. Dit is geen speelgoed, het is een werkmodel gebouwd volgens exacte specificaties. Scheepsbouwers maakten deze modellen voor ontwerp en planning. Op zijn hoogtepunt in het midden van de 17e eeuw bezat de Nederlandse Republiek 's werelds grootste handelsvloot."""
    },
    'dutch_dollhouse.mp3': {
        'en': """This is the Dutch Dollhouse of Petronella Oortman, created between 1686 and 1710. This isn't a child's toy, it's a wealthy woman's most prized possession. Petronella Oortman, wife of a rich Amsterdam silk merchant, spent a fortune assembling this miniature mansion. Contemporary accounts suggest it cost as much as an actual Amsterdam canal house! This cabinet dollhouse represents an idealized wealthy Dutch home from around 1700. Every single object was hand-crafted by master artisans. Real artists created miniature artworks for the walls. Master cabinetmakers built scaled furniture. Goldsmiths created tiny functional silver utensils. Look closely, that's real gold leaf, actual silk damask, and genuine pearls on the miniature costumes. Remarkably, this 300-plus year-old object survives almost intact.""",
        'nl': """Dit is het Nederlandse Poppenhuis van Petronella Oortman, gemaakt tussen 1686 en 1710. Dit is geen kinderspeelgoed, het is het meest gewaardeerde bezit van een rijke vrouw. Petronella Oortman, vrouw van een rijke Amsterdamse zijdehandelaar, gaf een fortuin uit aan het samenstellen van dit miniatuurhuis. Hedendaagse verslagen suggereren dat het net zoveel kostte als een echt Amsterdams grachtenhuis! Dit kabinetspoppenhuis vertegenwoordigt een geïdealiseerd rijk Nederlands huis van rond 1700. Elk voorwerp werd met de hand gemaakt door meesterambachtslieden."""
    }
}

def generate_all_audio():
    """Generate all audio files for both languages."""

    print("🎧 Generating All Audio Files with Google TTS")
    print("=" * 80)
    print()

    # Create directories
    Path('assets/audio/en').mkdir(parents=True, exist_ok=True)
    Path('assets/audio/nl').mkdir(parents=True, exist_ok=True)

    total_files = len(AUDIO_SCRIPTS) * 2  # English + Dutch
    generated = 0
    skipped = 0
    errors = 0

    for filename, scripts in AUDIO_SCRIPTS.items():
        print(f"\n{filename}:")

        # Generate English
        en_path = f"assets/audio/en/{filename}"
        if Path(en_path).exists() and Path(en_path).stat().st_size > 10000:
            print(f"  ⏭️  EN: Already exists, skipping")
            skipped += 1
        else:
            try:
                tts_en = gTTS(text=scripts['en'], lang='en', slow=False)
                tts_en.save(en_path)
                size = Path(en_path).stat().st_size / 1024
                print(f"  ✅ EN: Generated ({size:.0f} KB)")
                generated += 1
                time.sleep(0.5)  # Rate limiting
            except Exception as e:
                print(f"  ❌ EN: Error - {e}")
                errors += 1

        # Generate Dutch
        nl_path = f"assets/audio/nl/{filename}"
        if Path(nl_path).exists() and Path(nl_path).stat().st_size > 10000:
            print(f"  ⏭️  NL: Already exists, skipping")
            skipped += 1
        else:
            try:
                tts_nl = gTTS(text=scripts['nl'], lang='nl', slow=False)
                tts_nl.save(nl_path)
                size = Path(nl_path).stat().st_size / 1024
                print(f"  ✅ NL: Generated ({size:.0f} KB)")
                generated += 1
                time.sleep(0.5)  # Rate limiting
            except Exception as e:
                print(f"  ❌ NL: Error - {e}")
                errors += 1

    print()
    print("=" * 80)
    print(f"✅ Generated: {generated} new files")
    print(f"⏭️  Skipped: {skipped} existing files")
    if errors > 0:
        print(f"❌ Errors: {errors} files")
    print(f"📁 Total: {generated + skipped}/{total_files} audio files ready")
    print()
    print("Audio files created:")
    print("  - Format: MP3 (gTTS)")
    print("  - Languages: English (en) and Dutch (nl)")
    print("  - Location: assets/audio/en/ and assets/audio/nl/")
    print()
    print("✅ All audio files complete!")
    print("=" * 80)

if __name__ == '__main__':
    try:
        generate_all_audio()
    except KeyboardInterrupt:
        print("\n\nGeneration interrupted")
    except Exception as e:
        print(f"\n\n❌ Error: {e}")
