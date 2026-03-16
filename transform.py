
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

def authority(graph, df, types):

    local_ids = list()
    for t in types:
        t = rdflib.URIRef(str(t))
        local_ids += [
            str(s) for s, p, o in graph.triples((None, rdflib.RDF.type, t))
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

    turtle_string = graph.serialize(format="turtle")
    for k, v in authority.items():
        turtle_string = turtle_string.replace(f"<{k}>", f"<{v}>")

    return rdflib.Graph().parse(data=turtle_string, format="turtle")

def validate(g):

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
    for s,p,o in g:
        graph_entities.append(s)
        if type(o) is type(rdflib.URIRef('')):
            graph_entities.append(o)

    graph_entities = [x for x in pydash.uniq(graph_entities) if 'fiafcore' in str(x)]

    for x in graph_entities:
        if len(pathlib.Path(x).name) == 36:
            continue

        if x not in fiafcore_entities:
            raise Exception(f'{x} not found in fiafcore.')

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
    # xml = [x for x in xml if "example" in x.name] # testing restriction.

    for x in tqdm.tqdm(sorted(xml)):

        # transformation of source data.

        g = transform(x)

        # fiafcore authority ids for entities.

        g = authority(g, auth_df, resource_types)

        # validate entities.

        validate(g)

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
