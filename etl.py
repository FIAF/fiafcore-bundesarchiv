
import pathlib
import rdflib
import subprocess

# sync fiaf_lod set via metha.

xml_path = pathlib.Path.cwd() / 'data'
subprocess.call([
    'metha-sync', 
    '-set', 'fiaf_lod', 
    '-format', 'oai_bundesarchiv', 
    '-daily', 
    '-T', '10m', 
    '-base-dir', str(xml_path), 
    'https://apps.bundesarchiv.de/oaiproducer/doGet'
])
