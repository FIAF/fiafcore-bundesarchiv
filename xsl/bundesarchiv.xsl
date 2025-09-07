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

    <xsl:output method="xml" indent="yes" />

    <xsl:template match="/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:fiaf="https://ontology.fiafcore.org/">
            <xsl:apply-templates select="//ba:Filmwerk" />
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="*">
        <xsl:apply-templates select="*" />
    </xsl:template>

    <!-- Works -->

    <xsl:template match="ba:Filmwerk">
        <xsl:variable name="filmwerk_title" select="ba:IDTitel" />
        <rdf:Description rdf:about="bundesarchiv://resource/work/{@uuid}">

            <!-- fiafcore:Work -->

            <rdf:type rdf:resource="bundesarchiv://ontology/work" />

            <!-- fiafcore:hasCountry -->

            <xsl:for-each select="ba:Ursprungsland">
                <xsl:variable name="country1" select="translate(., ' ', '')" />
                <xsl:variable name="country2" select="translate($country1, '/', '')" />
                <fiaf:hasCountry rdf:resource="bundesarchiv://vocabulary/country/{$country2}" />
            </xsl:for-each>

            <!-- fiafcore:hasEvent -->

            <fiaf:hasEvent>
                <rdf:Description>
                    <rdf:type rdf:resource="bundesarchiv://ontology/event/production_event"/>
                    <xsl:if test="ba:ProdJahrVon">
                        <fiaf:hasEventDate>
                            <xsl:value-of select="ba:ProdJahrVon"/>
                        </fiaf:hasEventDate>
                    </xsl:if>
                    <xsl:for-each select="ba:Credit/ba:Koerperschaft">
                        <fiaf:hasActivity>
                            <rdf:Description>
                                <xsl:variable name="funk1" select="translate(ba:Funktion/@Funktion, ' ', '')"/>
                                <xsl:variable name="funk2" select="translate($funk1, '/', '')"/>
                                <rdf:type rdf:resource="bundesarchiv://ontology/activity/{$funk2}"/>
                                <fiaf:hasAgent>
                                    <rdf:Description rdf:about="bundesarchiv://resource/agent/{@uuid}">
                                        <rdf:type rdf:resource="bundesarchiv://ontology/agent"/>
                                        <rdfs:label>
                                            <xsl:value-of select="@Koerperschaftsname"/>
                                        </rdfs:label>
                                        <fiaf:hasIdentifier>
                                            <rdf:Description rdf:about="bundesarchiv://identifier/agent/{@uuid}">
                                                <rdf:type rdf:resource="bundesarchiv://ontology/identifier"/>
                                                <fiaf:hasIdentifierValue>
                                                    <xsl:value-of select="@uuid"/>
                                                </fiaf:hasIdentifierValue>
                                                <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv"/>
                                            </rdf:Description>
                                        </fiaf:hasIdentifier>
                                    </rdf:Description>
                                </fiaf:hasAgent>
                            </rdf:Description>
                        </fiaf:hasActivity>
                    </xsl:for-each>
                    <xsl:for-each select="ba:Credit/ba:Person">
                        <fiaf:hasActivity>
                            <rdf:Description>
                                <xsl:variable name="funk1" select="translate(ba:Funktion/@Funktion, ' ', '')"/>
                                <xsl:variable name="funk2" select="translate($funk1, '/', '')"/>
                                <rdf:type rdf:resource="bundesarchiv://ontology/activity/{$funk2}"/>
                                <fiaf:hasAgent>
                                    <rdf:Description rdf:about="bundesarchiv://resource/agent/{@uuid}">
                                        <rdf:type rdf:resource="bundesarchiv://ontology/agent"/>
                                        <rdfs:label>
                                            <xsl:value-of select="concat(@Vorname, ' ', @Nachname)"/>
                                        </rdfs:label>
                                        <fiaf:hasIdentifier>
                                            <rdf:Description rdf:about="bundesarchiv://identifier/agent/{@uuid}">
                                                <rdf:type rdf:resource="bundesarchiv://ontology/identifier"/>
                                                <fiaf:hasIdentifierValue>
                                                    <xsl:value-of select="@uuid"/>
                                                </fiaf:hasIdentifierValue>
                                                <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv"/>
                                            </rdf:Description>
                                        </fiaf:hasIdentifier>
                                    </rdf:Description>
                                </fiaf:hasAgent>
                            </rdf:Description>
                        </fiaf:hasActivity>
                    </xsl:for-each>
                </rdf:Description>
            </fiaf:hasEvent>

            <!-- fiafcore:hasGenre -->

            <xsl:for-each select="ba:Gattung">
                <xsl:variable name="genre1" select="translate(., ' ', '')" />
                <xsl:variable name="genre2" select="translate($genre1, '/', '')" />
                <fiaf:hasGenre rdf:resource="bundesarchiv://vocabulary/genre/{$genre2}" />
            </xsl:for-each>

            <!-- fiafcore:hasForm -->

            <!-- fiafcore:hasIdentifier -->

            <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/work/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority
                        rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier>

            <!-- fiafcore:hasLanguageUsage -->

            <!-- fiafcore:hasManifestation -->

            <xsl:for-each select="ba:Manifestation">
                <fiaf:hasManifestation>
                    <rdf:Description rdf:about="bundesarchiv://resource/manifestation/{@uuid}">
                        <rdf:type rdf:resource="bundesarchiv://ontology/manifestation" />
                    </rdf:Description>
                </fiaf:hasManifestation>
            </xsl:for-each>

            <!-- fiafcore:hasSubject -->

            <!-- fiafcore:hasTitle -->

            <xsl:for-each select="ba:IDTitel">
                <fiaf:hasTitle>
                    <rdf:Description>
                        <rdf:type rdf:resource="https://ontology.fiafcore.org/IdentifiyingTitle" />
                        <fiaf:hasTitleValue>
                            <xsl:value-of select="." />
                        </fiaf:hasTitleValue>
                    </rdf:Description>
                </fiaf:hasTitle>
            </xsl:for-each>

            <!-- fiafcore:hasVariant -->

            <!-- fiafcore:hasWork -->

        </rdf:Description>

    </xsl:template>

</xsl:stylesheet>