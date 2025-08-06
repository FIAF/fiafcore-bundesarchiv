from lxml import etree
import dotenv
import os
import pathlib
import pymongo
import rdflib
import tqdm
import uuid


def transform(xml_path):
    graph = rdflib.Graph()

    xsl_file = etree.parse(str(pathlib.Path.cwd() / "xsl" / "bundesarchiv.xsl"))
    xml = [x for x in xml_path.iterdir()]
    xml = [x for x in xml if x.suffix == ".xml"]

    for x in sorted(xml):
        data = etree.parse(str(x))
        transform = etree.XSLT(xsl_file)
        result = transform(data)
        graph += rdflib.Graph().parse(data=str(result), format="xml")

    return graph


def harmonise(graph):
    turtle_string = graph.serialize(format="longturtle")

    turtle_string = turtle_string.replace(
        "<bundesarchiv://ontology/work>", "<https://ontology.fiafcore.org/Work>"
    )

    return rdflib.Graph().parse(data=turtle_string, format="turtle")


def authority(graph):
    work_type = rdflib.URIRef("https://ontology.fiafcore.org/Work")
    work_ids = [
        str(s) for s, p, o in graph.triples((None, rdflib.RDF.type, work_type))
    ]

    atlas_user, atlas_pass = os.getenv("ATLAS_USER"), os.getenv("ATLAS_PASS")
    uri = f"mongodb+srv://{atlas_user}:{atlas_pass}@fiafcore.wrscui9.mongodb.net/?retryWrites=true&w=majority&appName=fiafcore"
    client = pymongo.MongoClient(uri)
    database = client.get_database("fiafcore")
    coll = database.get_collection("auth")

    authority = dict()
    for x in tqdm.tqdm(work_ids):
        match = list(coll.find({"local": {"$elemMatch": {"$eq": x}}}))

        if len(match) > 1:
            raise Exception("This should not happen.")
        elif len(match) < 1:
            minted_id = f"https://resource.fiafcore.org/{str(uuid.uuid4())}"
            coll.insert_one({"fiafcore": minted_id, "local": [x]})
            authority[x] = minted_id
        else:
            authority[x] = match[0]["fiafcore"]

    client.close()

    turtle_string = graph.serialize(format="longturtle")
    for k, v in authority.items():
        turtle_string = turtle_string.replace(f"<{k}>", f"<{v}>")

    return rdflib.Graph().parse(data=turtle_string, format="turtle")


def main():
    # load variables.

    dotenv.load_dotenv()

    # transformation of source data.

    g = transform(pathlib.Path.cwd() / "xml")

    # harmonise vocabulary and ontology terms.

    g = harmonise(g)

    # fiafcore authority ids for entities.

    g = authority(g)

    # write resulting rdf.

    g.serialize(
        destination=pathlib.Path.cwd() / "fiafcore_bundesarchiv.ttl",
        format="longturtle",
    )


if __name__ == "__main__":
    main()
