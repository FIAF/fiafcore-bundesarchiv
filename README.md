# Bundesarchiv → FIAFcore
Bundesarchiv data conformed to FIAFcore. 

**Datasets**

Bundesarchiv `fiaf_lod` set.

**Process**

The etl process expects an `.env` file.

```sh
graph_username= # GraphDB username
graph_password= # GraphDB password
```

The etl script should be run from a virtualenv.

```sh
virtualenv venv -p 3.9
source venv/bin/activate
pip install -r requirements.txt
python etl.py
```

**License**

Data is licensed as [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/). Code is MIT.

