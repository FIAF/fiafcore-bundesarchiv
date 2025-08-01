<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:fiaf="https://ontology.fiafcore.org/"
    xmlns:ba="http://www.bundesarchiv.de/schemas/de-barch/fw-view-1.0"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" exclude-result-prefixes="oai ba">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:fiaf="https://ontology.fiafcore.org/">

            <xsl:apply-templates select="//ba:Filmwerk"/>

        </rdf:RDF>
    </xsl:template>


    <xsl:template match="*">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="ba:Filmwerk">

        <rdf:Description rdf:about="bundesarchiv://resource/work/{@uuid}">
            <rdf:type rdf:resource="bundesarchiv://ontology/work"/>
        </rdf:Description>

    </xsl:template>

</xsl:stylesheet>
