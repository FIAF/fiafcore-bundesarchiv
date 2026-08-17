
import pandas
import pathlib
import pydash
import rdflib
import requests
import tqdm
import uuid
from lxml import etree

def local_ontology():

    fiafcore_path = pathlib.Path.cwd() / 'fiafcore.ttl'
    if not fiafcore_path.exists():
        r = requests.get('https://raw.githubusercontent.com/FIAF/fiafcore/refs/heads/develop/fiafcore.ttl')
        if r.status_code != 200:
            raise Exception('API call failed.')
        with open(fiafcore_path, 'w') as local_fiafcore:
            local_fiafcore.write(r.text)

def subclasses(parent):

    fiafcore_path = pathlib.Path.cwd() / 'fiafcore.ttl'
    if not fiafcore_path.exists():
        raise Exception('Local ontology file not found.')

    fiafcore = rdflib.Graph().parse(fiafcore_path)
    query = """
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        SELECT ?subClass
        WHERE {
            ?subClass rdfs:subClassOf+ <"""+parent+"""> .
        }
    """
    result = [row.subClass for row in fiafcore.query(query)]
    result.append(rdflib.URIRef(parent))

    return result

def transform(xml):

    data = etree.parse(str(xml))
    xsl_file = etree.parse(str(pathlib.Path.cwd() / "xsl" / "bundesarchiv.xsl"))
    transform = etree.XSLT(xsl_file)
    result = transform(data)

    return rdflib.Graph().parse(data=str(result), format="xml")

def authority(gr, df, types):

    local_ids = list()
    for t in types:
        t = rdflib.URIRef(str(t))
        local_ids += [
            str(s) for s, p, o in gr.triples((None, rdflib.RDF.type, t))
        ]

    authority = dict()
    for x in local_ids:
        match = df.loc[df.local.isin([str(x)])]
        if len(match) > 1:
            raise Exception("This should never happen.")
        elif len(match) < 1:
            minted_id = f"https://dev.fiafcore.org/{str(uuid.uuid4())}"
            authority[x] = minted_id
            df.loc[len(df)] = [(minted_id), (x)]
        else:
            authority[x] = match.iloc[0]["fiafcore"]

    turtle_string = gr.serialize(format="turtle")
    for k, v in authority.items():
        turtle_string = turtle_string.replace(f"<{k}>", f"<{v}>")

    return rdflib.Graph().parse(data=turtle_string, format="turtle")

def validate(gr):

    fiafcore_path = pathlib.Path.cwd() / 'fiafcore.ttl'
    if not fiafcore_path.exists():
        raise Exception('Local ontology file not found.')

    fiafcore = rdflib.Graph().parse(fiafcore_path)
    fiafcore_entities = list()
    for s,p,o in fiafcore:
        fiafcore_entities.append(s)
        if type(o) is type(rdflib.URIRef('')):
            fiafcore_entities.append(o)

    fiafcore_entities = [x for x in pydash.uniq(fiafcore_entities) if 'fiafcore' in str(x)]
    graph_entities = list()
    for s,p,o in gr:
        graph_entities.append(s)
        if type(o) is type(rdflib.URIRef('')):
            graph_entities.append(o)

    graph_entities = [x for x in pydash.uniq(graph_entities) if 'fiafcore' in str(x)]
    for x in graph_entities:
        if len(pathlib.Path(x).name) == 36:
            continue

        if x not in fiafcore_entities:
            raise Exception(f'{x} not found in fiafcore.')

    fiafcore_properties = list()
    fiafcore_properties += [s for s,p,o in fiafcore.triples((None, rdflib.RDF.type, rdflib.OWL.ObjectProperty))]
    fiafcore_properties += [s for s,p,o in fiafcore.triples((None, rdflib.RDF.type, rdflib.OWL.DatatypeProperty))]
    for s,p,o in gr:
        if p in fiafcore_properties:
            continue
        elif p in [
            rdflib.RDF.type,
            rdflib.RDFS.label]:
            continue
        else:
            raise Exception(f'{p} not found in fiafcore.')

    return gr

def labelling(gr):

    work_types = subclasses('https://dev.fiafcore.org/Work')

    works = list()
    for work_type in work_types:
       for s,p,o in gr.triples((None, rdflib.RDF.type, rdflib.URIRef(work_type))):
           works.append(s)

    title_prop1 = rdflib.URIRef('https://dev.fiafcore.org/hasTitle')
    title_prop2 = rdflib.URIRef('https://dev.fiafcore.org/hasTitleValue')
    for work in works:
        titles = list()
        for s,p,o in gr.triples((work, title_prop1, None)):
            for a,b,c in gr.triples((o, title_prop2, None)):
                titles.append(c)

        if not len(titles):
            raise Exception('No titles found.')

        # TODO: Space here to have some more elaborate logic for title selection.

        title = titles[0]
        gr.add((work, rdflib.RDFS.label, rdflib.Literal(f'{title}')))

        events = list()
        event_prop = rdflib.URIRef('https://dev.fiafcore.org/hasEvent')
        for a,b,event in gr.triples((work, event_prop, None)):
            events.append(event)
        for event in events:
            gr.add((event, rdflib.RDFS.label, rdflib.Literal(f'{title} Event')))

        manifestations = list()
        manifestation_prop = rdflib.URIRef('https://dev.fiafcore.org/hasManifestation')
        for a,b,manifestation in gr.triples((work, manifestation_prop, None)):
            manifestations.append(manifestation)
        for manifestation in manifestations:
            gr.add((manifestation, rdflib.RDFS.label, rdflib.Literal(f'{title} Manifestation')))

        items = list()
        item_prop = rdflib.URIRef('https://dev.fiafcore.org/hasItem')
        for manifestation in manifestations:
            for a,b,item in gr.triples((manifestation, item_prop, None)):
                items.append(item)
        for item in items:
            gr.add((item, rdflib.RDFS.label, rdflib.Literal(f'{title} Item')))

        carriers = list()
        carrier_prop = rdflib.URIRef('https://dev.fiafcore.org/hasCarrier')
        for item in items:
            for a,b,carrier in gr.triples((item, carrier_prop, None)):
                carriers.append(carrier)
        for carrier in carriers:
            gr.add((carrier, rdflib.RDFS.label, rdflib.Literal(f'{title} Carrier')))

    return gr


def main():

    auth_path = pathlib.Path.cwd() / "auth.parquet"
    if not auth_path.exists():
        auth_df = pandas.DataFrame(columns=["fiafcore", "local"])
    else:
        auth_df = pandas.read_parquet(auth_path)

    # local instance of ontology.

    local_ontology()

    # gather resource types.

    resource_types = list()
    resource_types += subclasses('https://dev.fiafcore.org/Agent')
    resource_types += subclasses('https://dev.fiafcore.org/Work')
    resource_types += subclasses('https://dev.fiafcore.org/Manifestation')
    resource_types += subclasses('https://dev.fiafcore.org/Item')
    resource_types += subclasses('https://dev.fiafcore.org/Carrier')

    # top level graph.

    graph = rdflib.Graph()
    graph.bind("fiaf", rdflib.Namespace("https://dev.fiafcore.org/"))

    # loop through xml files.

    xml_path = pathlib.Path.cwd() / "xml"
    xml = [x for x in xml_path.iterdir()]
    xml = [x for x in xml if x.suffix == ".xml"]
    # xml = [x for x in xml][:100] # testing restriction for medium sized dataset.
    xml = [x for x in xml if "example" in x.name] # testing restriction.

    for x in tqdm.tqdm(sorted(xml)):

        # transformation of source data.

        g = transform(x)

        # fiafcore authority ids for entities.

        g = authority(g, auth_df, resource_types)

        # validate properties and entities.

        validate(g)

        # postprocessing, pull title and apply cooked labels to all has manifeestations, items carriers and events.

        labelling(g)

        # aggregate output.

        graph += g

    # count of total triples.

    print(len(graph), "triples.")

    # save authority parquet.

    auth_df.to_parquet(auth_path)

    # save graph.

    graph.serialize(
        destination=pathlib.Path.cwd() / "fiafcore_bundesarchiv.ttl",
        format="turtle",
    )

if __name__ == "__main__":
    main()
