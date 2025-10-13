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
            <xsl:apply-templates select="//ba:Manifestation" />
            <xsl:apply-templates select="//ba:Exemplar" />
            <xsl:apply-templates select="//ba:Aufbewahrungseinheit" />
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="*">
        <xsl:apply-templates select="*" />
    </xsl:template>

    <!-- Works -->

    <xsl:template match="ba:Filmwerk">
        <xsl:variable name="filmwerk_title" select="ba:IDTitel" />
        <rdf:Description rdf:about="bundesarchiv://resource/work/{@uuid}">
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
                                        <rdf:type rdf:resource="bundesarchiv://ontology/agent/organisation"/>
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
                                        <rdf:type rdf:resource="bundesarchiv://ontology/agent/person"/>
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

            <!-- fiafcore:hasForm -->

            <!-- fiafcore:hasGenre -->

            <xsl:for-each select="ba:Gattung">
                <xsl:variable name="genre1" select="translate(., ' ', '')" />
                <xsl:variable name="genre2" select="translate($genre1, '/', '')" />
                <fiaf:hasGenre rdf:resource="bundesarchiv://vocabulary/genre/{$genre2}" />
            </xsl:for-each>

            <!-- fiafcore:hasIdentifier -->

            <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/work/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
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

    <!-- Manifestations -->

    <xsl:template match="ba:Manifestation">
        <rdf:Description rdf:about="bundesarchiv://resource/manifestation/{@uuid}">
            <rdf:type rdf:resource="bundesarchiv://ontology/manifestation" />

            <!-- fiaf:hasColourCharacteristic -->

            <xsl:for-each select="ba:Farbe">
                <xsl:variable name="colorchar" select="translate(., ' ', '')" />
                <fiaf:hasColourCharacteristic rdf:resource="bundesarchiv://vocabulary/colourcharacteristic/{$colorchar}" />
            </xsl:for-each>

            <!-- fiaf:hasEvent -->

            <!-- fiaf:hasExtent -->

            <xsl:if test="ba:Gesamtlaenge">
                <fiaf:hasExtent>
                    <rdf:Description>
                        <rdf:type rdf:resource="bundesarchiv://ontology/extent/metres"/>
                        <fiaf:hasExtentValue>
                            <xsl:value-of select="ba:Gesamtlaenge"/>
                        </fiaf:hasExtentValue>
                    </rdf:Description>
                </fiaf:hasExtent>
            </xsl:if>

            <!-- fiaf:hasFormat  -->

            <!-- fiaf:hasIdentifier -->

            <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/manifestation/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier>

            <!-- fiaf:hasImageCharacteristic -->

            <!-- fiaf:hasItem -->

            <xsl:for-each select="ba:Exemplar">
                <fiaf:hasItem>
                    <rdf:Description rdf:about="bundesarchiv://resource/item/{@uuid}">
                        <rdf:type rdf:resource="bundesarchiv://ontology/item" />
                    </rdf:Description>
                </fiaf:hasItem>
            </xsl:for-each>

            <!-- fiaf:hasLanguageUsage -->

            <xsl:if test="ba:Sprache">
                <fiaf:hasLanguageUsage>
                    <rdf:Description>
                        <rdf:type rdf:resource="bundesarchiv://vocabulary/languageusage/{ba:Sprache/@sprachgebrauch}"/>
                        <xsl:variable name="lang" select="translate(ba:Sprache/@sprache, ' ', '')"/>
                        <fiaf:hasLanguage rdf:resource="bundesarchiv://vocabulary/language/{$lang}"/>
                    </rdf:Description>
                </fiaf:hasLanguageUsage>
            </xsl:if>

            <!-- fiaf:hasSoundCharacteristic -->

            <!-- fiaf:hasTitle -->

        </rdf:Description>
    </xsl:template>

    <!-- Items -->

    <xsl:template match="ba:Exemplar">
        <rdf:Description rdf:about="bundesarchiv://resource/item/{@uuid}">
            <rdf:type rdf:resource="bundesarchiv://ontology/item" />

            <!-- fiaf:hasBase -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Traeger">
                <xsl:variable name="base" select="translate(ba:Aufbewahrungseinheit/ba:Traeger, ' ', '')"/>
                <fiaf:hasBase rdf:resource="bundesarchiv://vocabulary/base/{$base}"/>
            </xsl:if>

            <!-- fiaf:hasBroadcastStandard  -->

            <xsl:for-each select="ba:SDHDFernsehnorm">
                <xsl:variable name="broadcaststandard" select="translate(., ' ', '')" />
                <fiaf:hasBroadcastStandard rdf:resource="bundesarchiv://vocabulary/broadcaststandard/{$broadcaststandard}" />
            </xsl:for-each>

            <!-- fiaf:hasCarrier -->

            <xsl:for-each select="ba:Aufbewahrungseinheit">
                <fiaf:hasCarrier>
                    <rdf:Description rdf:about="bundesarchiv://resource/carrier/{@uuid}">
                        <rdf:type rdf:resource="bundesarchiv://ontology/carrier" />
                    </rdf:Description>
                </fiaf:hasCarrier>
            </xsl:for-each>

            <!-- fiaf:hasColourCharacteristic  -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Farbe">
                <xsl:variable name="itemcolour" select="translate(ba:Aufbewahrungseinheit/ba:Farbe, ' ', '')"/>
                <fiaf:hasColourCharacteristic rdf:resource="bundesarchiv://vocabulary/colourcharacteristic/{$itemcolour}"/>
            </xsl:if>

            <!-- fiaf:hasEvent  -->

            <!-- fiaf:hasExtent  -->

            <!-- fiaf:hasFormat  -->

            <xsl:if test="ba:Filmbreite">
                <xsl:variable name="format" select="translate(ba:Filmbreite, ' ', '')"/>
                <fiaf:hasFormat rdf:resource="bundesarchiv://vocabulary/filmformat/{$format}"/>
            </xsl:if>
            <xsl:if test="ba:Videoformat">
                <xsl:variable name="format" select="translate(ba:Videoformat, ' ', '')"/>
                <fiaf:hasFormat rdf:resource="bundesarchiv://vocabulary/videoformat/{$format}"/>
            </xsl:if>
            <xsl:if test="ba:Datenformat">
                <xsl:variable name="format" select="translate(ba:Datenformat, ' ', '')"/>
                <fiaf:hasFormat rdf:resource="bundesarchiv://vocabulary/dataformat/{$format}"/>
            </xsl:if>

            <!-- fiaf:hasFrameRate  -->

            <xsl:if test="ba:Bildfrequenz">
                <xsl:variable name="fps" select="translate(ba:Bildfrequenz, ' ', '')"/>
                <fiaf:hasFrameRate rdf:resource="bundesarchiv://ontology/fps/{$fps}"/>
            </xsl:if>

            <!-- fiaf:hasHoldingInstitution  -->

            <fiaf:hasHoldingInstitution rdf:resource="bundesarchiv://ontology/holdinginstitution/bundesarchiv"/>

            <!-- fiaf:hasIdentifier  -->

            <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/item/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier>

            <!-- fiaf:hasImageCharacteristic  -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Bildseitenverhaeltnis">
                <xsl:variable name="imagechar" select="translate(ba:Aufbewahrungseinheit/ba:Bildseitenverhaeltnis, ' ', '')"/>
                <fiaf:hasImageCharacteristic rdf:resource="bundesarchiv://vocabulary/imagecharacteristic/{$imagechar}"/>
            </xsl:if>

            <!-- fiaf:hasLineStandard  -->

            <!-- fiaf:hasResolution  -->

            <!-- fiaf:hasSoundCharacteristic  -->

            <!-- fiaf:hasSourceDevice  -->

            <!-- fiaf:hasSourceSoftware  -->

            <!-- fiaf:hasStatus  -->

            <xsl:if test="ba:ExemplarStatus">
                <xsl:variable name="status" select="translate(ba:ExemplarStatus, ' ', '')"/>
                <fiaf:hasStatus rdf:resource="bundesarchiv://vocabulary/status/{$status}"/>
            </xsl:if>

            <!-- fiaf:hasStock  -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Rohfilmtyp">
                <xsl:variable name="stock" select="translate(ba:Aufbewahrungseinheit/ba:Rohfilmtyp, ' ', '')"/>
                <fiaf:hasStock rdf:resource="bundesarchiv://vocabulary/stock/{$stock}"/>
            </xsl:if>

            <!-- fiaf:hasStream  -->

            <!-- fiaf:hasTitle  -->

            <!-- fiaf:hasTransferSpeed  -->

            <!-- fiaf:isElement  -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Materialart">
                <xsl:variable name="elem" select="translate(ba:Aufbewahrungseinheit/ba:Materialart, ' ', '')"/>
                <fiaf:isElement rdf:resource="bundesarchiv://vocabulary/element/{$elem}"/>
            </xsl:if>

        </rdf:Description>
    </xsl:template>

    <!-- Carriers -->

    <xsl:template match="ba:Aufbewahrungseinheit">
        <rdf:Description rdf:about="bundesarchiv://resource/carrier/{@uuid}">
            <rdf:type rdf:resource="bundesarchiv://ontology/carrier" />

            <!-- fiaf:hasEvent -->

            <!-- fiaf:hasIdentifier -->

            <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/carrier/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier>

        </rdf:Description>
    </xsl:template>

</xsl:stylesheet>