from lxml import etree
import pandas
import pathlib
import rdflib
import tqdm
import uuid


def transform(xml):
    data = etree.parse(str(xml))
    xsl_file = etree.parse(str(pathlib.Path.cwd() / "xsl" / "bundesarchiv.xsl"))
    transform = etree.XSLT(xsl_file)
    result = transform(data)

    return rdflib.Graph().parse(data=str(result), format="xml")


def harmonise(graph):
    turtle_string = graph.serialize(format="turtle")

    for a, b in [
        ("<bundesarchiv://ontology/work>", "<https://ontology.fiafcore.org/Work>"),
        (
            "<bundesarchiv://ontology/manifestation>",
            "<https://ontology.fiafcore.org/Manifestation>",
        ),
        ("<bundesarchiv://ontology/item>", "<https://ontology.fiafcore.org/Item>"),
        (
            "<bundesarchiv://ontology/carrier>",
            "<https://ontology.fiafcore.org/Carrier>",
        ),
        ("<bundesarchiv://ontology/agent>", "<https://ontology.fiafcore.org/Agent>"),
        (
            "<bundesarchiv://ontology/identifier>",
            "<https://ontology.fiafcore.org/Identifier>",
        ),
    ]:
        turtle_string = turtle_string.replace(a, b)

    return rdflib.Graph().parse(data=turtle_string, format="turtle")


def authority(graph, df):
    local_ids = list()
    for entity_type in ["Work", "Manifestation", "Item", "Carrier", "Agent"]:
        type_uri = rdflib.URIRef(f"https://ontology.fiafcore.org/{entity_type}")
        local_ids += [
            str(s) for s, p, o in graph.triples((None, rdflib.RDF.type, type_uri))
        ]

    authority = dict()
    for x in local_ids:
        match = df.loc[df.local.isin([str(x)])]
        if len(match) > 1:
            raise Exception("This should not happen.")
        elif len(match) < 1:
            minted_id = f"https://resource.fiafcore.org/{str(uuid.uuid4())}"
            authority[x] = minted_id
            df.loc[len(df)] = [(minted_id), (x)]
        else:
            authority[x] = match.iloc[0]["fiafcore"]


    # print(authority)

    turtle_string = graph.serialize(format="turtle")
    for k, v in authority.items():
        turtle_string = turtle_string.replace(f"<{k}>", f"<{v}>")

    return rdflib.Graph().parse(data=turtle_string, format="turtle")


def main():
    auth_path = pathlib.Path.cwd() / "auth.parquet"
    if not auth_path.exists():
        auth_df = pandas.DataFrame(columns=["fiafcore", "local"])
    else:
        auth_df = pandas.read_parquet(auth_path)

    # top level graph.

    graph = rdflib.Graph()
    graph.bind("fiaf", rdflib.Namespace("https://ontology.fiafcore.org/"))

    # loop through xml files.

    xml_path = pathlib.Path.cwd() / "xml"
    xml = [x for x in xml_path.iterdir()]
    xml = [x for x in xml if x.suffix == ".xml"]

    # # testing restriction.

    xml = [x for x in xml if "example" in x.name]

    for x in tqdm.tqdm(sorted(xml)):
        # transformation of source data.

        g = transform(x)

        # harmonise vocabulary and ontology terms.

        g = harmonise(g)

        # fiafcore authority ids for entities.

        g = authority(g, auth_df)

        # aggregate output.

        graph += g

    # write resulting rdf.

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
