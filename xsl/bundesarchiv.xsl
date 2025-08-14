<?xml version="1.0" encoding="UTF-8"?>

<!-- Bundesarchiv XML data to FIAFcore -->
<!-- Paul Duchesne -->

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

    <!-- Works -->

    <xsl:template match="ba:Filmwerk">
        <xsl:variable name="filmwerk_title" select="ba:IDTitel"/>
        <rdf:Description rdf:about="bundesarchiv://resource/work/{@uuid}">

            <!-- fiafcore:Work -->

            <rdf:type rdf:resource="bundesarchiv://ontology/work"/>

            <!-- fiafcore:hasCountry -->

            <xsl:for-each select="ba:Ursprungsland">
                <xsl:variable name="country1" select="translate(ba:Ursprungsland, ' ', '')"/>
                <xsl:variable name="country2" select="translate($country1, '/', '')"/>
                <fiaf:hasCountry rdf:resource="bundesarchiv://vocabulary/country/{$country2}"/>
            </xsl:for-each>

            <!-- fiafcore:hasEvent -->

            <!-- fiafcore:hasGenre -->

            <!-- fiafcore:hasForm -->

            <!-- fiafcore:hasIdentifier -->

            <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/work/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier"/>
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid"/>
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv"/>
                </rdf:Description>
            </fiaf:hasIdentifier>

            <!-- fiafcore:hasLanguageUsage -->

            <!-- fiafcore:hasManifestation -->

            <!-- fiafcore:hasSubject -->

            <!-- fiafcore:hasTitle -->

            <!-- fiafcore:hasVariant -->

            <!-- fiafcore:hasWork -->

        </rdf:Description>

    </xsl:template>

</xsl:stylesheet>
