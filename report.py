import pandas
import pathlib
from xml.etree import ElementTree as et

def attribute(property, tier, element, attribute):
    '''
    Function to extract attributes from source data.
    '''

    dataframes = list()

    namespaces = {
        'oai': 'http://www.openarchives.org/OAI/2.0/',
        'ba': 'http://www.bundesarchiv.de/schemas/de-barch/fw-view-1.0'
    }

    xpath = f".//ba:{tier}/ba:{element}"
    ba_xml = pathlib.Path.cwd() / 'xml'
    ba_xml = [x for x in ba_xml.iterdir() if x.suffix == '.xml']
    ba_xml = [x for x in ba_xml if x.name != 'example.xml']
    for x in ba_xml:
        root = et.parse(x).getroot()
        values = root.findall(xpath, namespaces=namespaces)
        dataframes.append(pandas.DataFrame([x.get(attribute) for x in values], columns=['term']))

    df = pandas.concat(dataframes, ignore_index=True)
    df = pandas.DataFrame(df.value_counts(subset='term')).reset_index()

    string = f'## fiafcore:{property}\n\n'
    string += f'`[{tier}] xpath {xpath}`\n\n'
    string += df.to_markdown(index=False)+'\n\n'

    return string

def tag(xpath):
    '''
    Function to extract tags from source data.
    '''

    dataframes = list()

    namespaces = {
        'oai': 'http://www.openarchives.org/OAI/2.0/',
        'ba': 'http://www.bundesarchiv.de/schemas/de-barch/fw-view-1.0'
    }

    ba_xml = pathlib.Path.cwd() / 'xml'
    ba_xml = [x for x in ba_xml.iterdir() if x.suffix == '.xml']
    ba_xml = [x for x in ba_xml if x.name != 'example.xml']
    for x in ba_xml:
        root = et.parse(x).getroot()
        values = root.findall(xpath, namespaces=namespaces)
        dataframes.append(pandas.DataFrame([x.tag for x in values], columns=['term']))

    return pandas.concat(dataframes, ignore_index=True)

def term(property, tier, element):
    '''
    Function to extract terms from source data.
    '''

    dataframes = list()

    namespaces = {
        'oai': 'http://www.openarchives.org/OAI/2.0/',
        'ba': 'http://www.bundesarchiv.de/schemas/de-barch/fw-view-1.0'
    }

    xpath = f".//ba:{tier}/ba:{element}"
    ba_xml = pathlib.Path.cwd() / 'xml'
    ba_xml = [x for x in ba_xml.iterdir() if x.suffix == '.xml']
    ba_xml = [x for x in ba_xml if x.name != 'example.xml']
    for x in ba_xml:
        root = et.parse(x).getroot()
        values = root.findall(xpath, namespaces=namespaces)
        dataframes.append(pandas.DataFrame([x.text for x in values], columns=['term']))

    df = pandas.concat(dataframes, ignore_index=True)
    df = pandas.DataFrame(df.value_counts(subset='term')).reset_index()

    string = f'## fiafcore:{property}\n\n'
    string += f'`[{tier}] xpath {xpath}`\n\n'
    string += df.to_markdown(index=False)+'\n\n'

    return string

m = ''

# fiafcore:Activity

m += attribute('Activity', 'Person', 'Funktion', 'Funktion')
m += attribute('Activity', 'Koerperschaft', 'Funktion', 'Funktion')

# fiafcore:Agent

ba_df = tag(f".//ba:Filmwerk/ba:Credit/*")
ba_df = pandas.DataFrame(ba_df.value_counts(subset='term')).reset_index()
ba_df['term'] = ba_df['term'].str.replace('{http://www.bundesarchiv.de/schemas/de-barch/fw-view-1.0}', '')
string = f'## fiafcore:Agent\n\n'
string += f'`[Filmwerk] xpath .//ba:Filmwerk/ba:Credit/*`\n\n'
string += ba_df.to_markdown(index=False)+'\n\n'
m += string

# fiafcore:Base

m += term('Base', 'Exemplar', 'Traeger')
m += term('Base', 'Aufbewahrungseinheit', 'Traeger')

# fiafcore:BitDepth

m += term('BitDepth', 'Exemplar', 'QuantisierungBild')
m += term('BitDepth', 'Exemplar', 'QuantisierungTon')

# fiafcore:BroadcastStandard

m += term('BroadcastStandard', 'Exemplar', 'SDHDFernsehnorm')

# fiafcore:Codec

m += term('Codec', 'Exemplar', 'CodecBild')
m += term('Codec', 'Exemplar', 'CodecTon')

# fiafcore:ColourCharacteristic

m += term('ColourCharacteristic', 'Manifestation', 'Farbe')
m += term('ColourCharacteristic', 'Aufbewahrungseinheit', 'Farbe')

# fiafcore:ColourStandard

m += term('ColourStandard', 'Aufbewahrungseinheit', 'Schicht')

# fiafcore:Country

m += term('Country', 'Filmwerk', 'Ursprungsland')

# fiafcore:Element

m += term('Element', 'Aufbewahrungseinheit', 'Materialart')

# fiafcore:Extent

m += term('Extent', 'Manifestation', 'Laufzeit')
m += term('Extent', 'Manifestation', 'Gesamtlaenge')
m += term('Extent', 'Exemplar', 'Laenge')
m += term('Extent', 'Exemplar', 'DatenmengeEinheit')
m += term('Extent', 'Aufbewahrungseinheit', 'Laufzeit')

# fiafcore:Form

m += term('Form', 'Filmwerk', 'Gattung')

# fiafcore:Format

m += term('Format', 'Manifestation', 'Medienformat')
m += term('Format', 'Manifestation', 'Filmbreite')
m += term('Format', 'Exemplar', 'Container')
m += term('Format', 'Exemplar', 'Filmbreite')
m += term('Format', 'Exemplar', 'Videoformat')

# fiafcore:FrameRate

m += term('FrameRate', 'Exemplar', 'BildfrequenzVorlage')

# fiafcore:Genre

m += term('Genre', 'Filmwerk', 'Genre')

# fiafcore:Identifier

m += attribute('Identifier', 'Filmwerk', 'ExtIDs', 'Identifikationstyp')
m += attribute('Identifier', 'Manifestation', 'ExtIDs', 'Identifikationstyp')
m += attribute('Identifier', 'Exemplar', 'ExtIDs', 'Identifikationstyp')

# fiafcore:ImageCharacteristic

m += term('ImageCharacteristic', 'Manifestation', 'Bildformat')
m += term('ImageCharacteristic', 'Exemplar', 'Bildseitenver_aktiv')
m += term('ImageCharacteristic', 'Aufbewahrungseinheit', 'Bildseitenverhaeltnis')
m += term('ImageCharacteristic', 'Exemplar', 'Vorfuehrformat')

# fiafcore:Language

m += attribute('Language', 'Manifestation', 'Sprache', 'sprache')
m += attribute('Language', 'Exemplar', 'Sprache', 'sprache')

# fiafcore:LanguageUsage

m += attribute('LanguageUsage', 'Manifestation', 'Sprache', 'sprachgebrauch')
m += attribute('LanguageUsage', 'Exemplar', 'Sprache', 'sprachgebrauch')

# fiafcore:Manifestation

m += term('Manifestation', 'Manifestation', 'Manifestationstyp')

# fiafcore:Resolution

m += term('Resolution', 'Exemplar', 'Farbraum')

# fiafcore:Status

m += term('Status', 'Exemplar', 'ExemplarStatus')

# fiafcore:Stock

m += term('Stock', 'Aufbewahrungseinheit', 'Rohfilmtyp')

# fiafcore:Subject

m += attribute('Subject', 'Manifestation', 'Schlagwort', 'schlagwort')

# fiafcore:Title

m += attribute('Title', 'Manifestation', 'Filmtitel', 'typ')

# fiafcore:Work

m += term('Work', 'Filmwerk', 'Filmart')

# render report to disk.

with open(pathlib.Path.cwd() / 'report.md', 'w') as markdown_export:
    markdown_export.write(m)
