from lxml import etree
import dotenv
import os
import pathlib
import rdflib

def transform(xml_path):

    graph = rdflib.Graph()

    xsl_file = etree.parse(str(pathlib.Path.cwd() / 'xsl' / 'bundesarchiv.xsl'))
    xml = [x for x in xml_path.iterdir()]
    xml = [x for x in xml if x.suffix == '.xml']

    for x in sorted(xml):
        data = etree.parse(str(x))
        transform = etree.XSLT(xsl_file)
        result = transform(data)
        graph += rdflib.Graph().parse(data=str(result), format='xml')

    return graph

def harmonise(graph_in):

    turtle_string = graph_in.serialize(format='longturtle')

    turtle_string = turtle_string.replace('<bundesarchiv://ontology/work>', '<https://ontology.fiafcore.org/Work>')
    
    graph_out = rdflib.Graph().parse(data=turtle_string, format='turtle')

    return graph_out

def authority(graph_in):

    work_type = rdflib.URIRef('https://ontology.fiafcore.org/Work')
    work_ids = [str(s) for s,p,o in graph_in.triples((None, rdflib.RDF.type, work_type))]
    
    print(len(work_ids))
    print((work_ids[:3]))

    return graph_in

# load variables.

dotenv.load_dotenv()

# transformation of source data.

g = transform(pathlib.Path.cwd() / 'xml')

# harmonise vocabulary and ontology terms.

g = harmonise(g)

# fiafcore authority ids for entities.

g = authority(g)

# write resulting rdf.

g.serialize(destination=pathlib.Path.cwd() / 'fiafcore_bundesarchiv.ttl', format='longturtle')

