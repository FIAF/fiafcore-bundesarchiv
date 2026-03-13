<?xml version="1.0" encoding="UTF-8"?>

<!-- Bundesarchiv XML data to FIAFcore -->
<!-- Paul Duchesne -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:fiaf="https://dev.fiafcore.org/"
    xmlns:ba="http://www.bundesarchiv.de/schemas/de-barch/fw-view-1.0"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" exclude-result-prefixes="oai ba">

    <xsl:output method="xml" indent="yes" />

    <xsl:template match="/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:fiaf="https://dev.fiafcore.org/">
            <xsl:apply-templates select="//ba:Filmwerk" />
            <xsl:apply-templates select="//ba:Manifestation" />
            <xsl:apply-templates select="//ba:Exemplar" />
            <xsl:apply-templates select="//ba:Aufbewahrungseinheit" />
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="*">
        <xsl:apply-templates select="*" />
    </xsl:template>

    <!-- fiafcore:Work -->

    <xsl:template match="ba:Filmwerk">
        <rdf:Description rdf:about="bundesarchiv://resource/work/{@uuid}">

        <xsl:if test="not(ba:Filmart)">
            <rdf:type rdf:resource="https://dev.fiafcore.org/Work" />
        </xsl:if>
        <xsl:if test="ba:Filmart">
            <xsl:variable name="work_type" select="ba:Filmart" />
            <xsl:choose>
                <xsl:when test="$work_type = 'Unbekannt'">
                    <rdf:type rdf:resource="https://dev.fiafcore.org/Work" />
                </xsl:when>
                <xsl:when test="$work_type = 'Documentation'">
                    <rdf:type rdf:resource="https://dev.fiafcore.org/Work" />
                </xsl:when>
                <xsl:when test="$work_type = 'Dokumentarfilm'">
                    <rdf:type rdf:resource="https://dev.fiafcore.org/MonographicWork" />
                </xsl:when>
                <xsl:when test="$work_type = 'Spielfilm'">
                    <rdf:type rdf:resource="https://dev.fiafcore.org/MonographicWork" />
                </xsl:when>
                <xsl:when test="$work_type = 'Film'">
                    <rdf:type rdf:resource="https://dev.fiafcore.org/MonographicWork" />
                </xsl:when>
                <xsl:when test="$work_type = 'Serie / Reihe'">
                    <rdf:type rdf:resource="https://dev.fiafcore.org/SerialWork" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        Error: Unexpected value "<xsl:value-of select="$work_type"/>".
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <!-- fiafcore:hasCountry -->

    <!-- <xsl:for-each select="ba:Ursprungsland">
                <xsl:variable name="country1" select="translate(., ' ', '')" />
                <xsl:variable name="country2" select="translate($country1, '/', '')" />
                <fiaf:hasCountry rdf:resource="bundesarchiv://vocabulary/country/{$country2}" />
            </xsl:for-each> -->

    <!-- fiafcore:hasEvent -->

    <!-- <fiaf:hasEvent>
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
            </fiaf:hasEvent> -->

    <!-- fiafcore:hasForm -->

    <!-- <xsl:for-each select="ba:Gattung">
                <xsl:variable name="form1" select="translate(., ' ', '')" />
                <xsl:variable name="form2" select="translate($form1, '/', '')" />
                <fiaf:hasForm rdf:resource="bundesarchiv://vocabulary/form/{$form2}" />
            </xsl:for-each> -->

    <!-- fiafcore:hasGenre -->

    <xsl:if test="ba:Genre">
        <xsl:for-each select="ba:Genre">
            <xsl:variable name="genre" select="translate(., ' ', '_')" />
            <xsl:choose>
                <xsl:when test="$genre = 'Wochenschau'" />
                <xsl:when test="$genre = 'Wochenschau_(Segment/Sujet/Ausschnitt)'" />
                <xsl:when test="$genre = 'Sach-_und_Ereignisdokument'" />
                <xsl:when test="$genre = 'Trailer'" />
                <xsl:when test="$genre = 'Trickart:_Puppentrick'" />
                <xsl:when test="$genre = 'Reportage'" />
                <xsl:when test="$genre = 'Amateurfilm'" />
                <xsl:when test="$genre = 'Fernsehfilm'" />
                <xsl:when test="$genre = 'Periodika'" />
                <xsl:when test="$genre = 'Trickart:_Legetrick/Flachfigurenfilm'" />
                <xsl:when test="$genre = 'Lustspiel'" />
                <xsl:when test="$genre = 'Spot'" />
                <xsl:when test="$genre = 'Privatfilm'" />
                <xsl:when test="$genre = 'Trickart:_Silhouettentrick'" />
                <xsl:when test="$genre = 'Trickart:_Sach-/Realtrick'" />
                <xsl:when test="$genre = 'Portraitfilm'" />
                <xsl:when test="$genre = 'Personendokument'" />
                <xsl:when test="$genre = 'Monatsschau'" />
                <xsl:when test="$genre = 'Historischer_Film'" />
                <xsl:when test="$genre = 'Land-/Forstwirtschadtsfilm'" />
                <xsl:when test="$genre = 'Wahlfilm'" />
                <xsl:when test="$genre = 'Biografischer_Film'" />
                <xsl:when test="$genre = 'Trickart:_Realaufnahmen_im_Trickfilm'" />
                <xsl:when test="$genre = 'Expeditionsfilm'" />
                <xsl:when test="$genre = 'Länderfilm'" />
                <xsl:when test="$genre = 'Naturfilm'" />
                <xsl:when test="$genre = 'Politisch-geogr._Film'" />
                <xsl:when test="$genre = 'Medizinfilm'" />
                <xsl:when test="$genre = 'Kompilationsfilm'" />
                <xsl:when test="$genre = 'Gegenwartsfilm'" />
                <xsl:when test="$genre = 'Dokumentarischer_Spielfilm'" />
                <xsl:when test="$genre = 'Trickart:_Drahtfigurentrick'" />
                <xsl:when test="$genre = 'Interview'" />
                <xsl:when test="$genre = 'Kunstfilm'" />
                <xsl:when test="$genre = 'Trickart:_Plasteline-/Knettrick/Claymation'" />
                <xsl:when test="$genre = 'Melodram'" />
                <xsl:when test="$genre = 'Szenische_Dokumentation'" />
                <xsl:when test="$genre = 'Jugendfilm'" />
                <xsl:when test="$genre = 'Abenteuerfilm'" />
                <xsl:when test="$genre = 'Tanzfilm'" />
                <xsl:when test="$genre = 'Ethnografischer_Film'" />
                <xsl:when test="$genre = 'Trickart:_Computeranimation'" />
                <xsl:when test="$genre = 'Religionsfilm'" />
                <xsl:when test="$genre = 'Tragödie'" />
                <xsl:when test="$genre = 'Verkehrsfilm'" />
                <xsl:when test="$genre = 'Operettenfilm'" />
                <xsl:when test="$genre = 'Umweltfilm'" />
                <xsl:when test="$genre = 'Zirkusfilm'" />
                <xsl:when test="$genre = 'Heimatfilm'" />
                <xsl:when test="$genre = 'Detektivfilm'" />
                <xsl:when test="$genre = 'Trickart:_Sonstige_Trickarten'" />
                <xsl:when test="$genre = 'Western'" />
                <xsl:when test="$genre = 'Slapstick'" />
                <xsl:when test="$genre = 'Biologischer_Film'" />
                <xsl:when test="$genre = 'Bergfilm'" />
                <xsl:when test="$genre = 'Thriller'" />
                <xsl:when test="$genre = 'Trickart:_Mischtrick'" />
                <xsl:when test="$genre = 'Musicalfilm'" />
                <xsl:when test="$genre = 'Ballettfilm'" />
                <xsl:when test="$genre = 'Feuilleton'" />
                <xsl:when test="$genre = 'Opernfilm'" />
                <xsl:when test="$genre = 'Antikriegsfilm'" />
                <xsl:when test="$genre = 'Fantasyfilm'" />
                <xsl:when test="$genre = 'Trickart:_Fototrick'" />
                <xsl:when test="$genre = 'Frauenfilm'" />
                <xsl:when test="$genre = 'Arztfilm'" />
                <xsl:when test="$genre = 'Experimentalfilm'" />
                <xsl:when test="$genre = 'Forschungsfilm'" />
                <xsl:when test="$genre = 'Trickart:_Reliefanimation/Zeichentrick'" />
                <xsl:when test="$genre = 'Sensationsfilm'" />
                <xsl:when test="$genre = 'Gerichtsfilm'" />
                <xsl:when test="$genre = 'Parodie'" />
                <xsl:when test="$genre = 'Trickart:_Collagentrick'" />
                <xsl:when test="$genre = 'Spionagefilm'" />
                <xsl:when test="$genre = 'Revuefilm'" />
                <xsl:when test="$genre = 'Science_Fiction'" />
                <xsl:when test="$genre = 'Tragikomödie'" />
                <xsl:when test="$genre = 'Horrofilm'" />
                <xsl:when test="$genre = 'Magazin'" />
                <xsl:when test="$genre = 'Erotischer_Film'" />
                <xsl:when test="$genre = 'Trickart:_Pixilation'" />
                <xsl:when test="$genre = 'Fotofilm'" />
                <xsl:when test="$genre = 'Hist._Ausstattungsfilm'" />
                <xsl:when test="$genre = 'Polithriller'" />
                <xsl:when test="$genre = 'Indianerfilm'" />
                <xsl:when test="$genre = 'Phantastischer_Film'" />
                <xsl:when test="$genre = 'Gangsterfilm'" />
                <xsl:when test="$genre = 'Gefilmtes_Theater'" />
                <xsl:when test="$genre = 'Marionettenfilm'" />
                <xsl:when test="$genre = 'Unterrichtsfilm'" />
                <xsl:when test="$genre = 'Trickart:_Sandanimation'" />
                <xsl:when test="$genre = 'Mischfilm_(Kombination_aus_Real-_u._Trickfilm)'" />
                <xsl:when test="$genre = 'Surrealistischer_Film'" />
                <xsl:when test="$genre = 'Trickart:_Scherenschnitt'" />
                <xsl:when test="$genre = 'Actionfilm'" />
                <xsl:when test="$genre = 'Absoluter_Film'" />
                <xsl:when test="$genre = 'Abstrakter_Film'" />
                <xsl:when test="$genre = 'Singspiel'" />
                <xsl:when test="$genre = 'Computerfilm'" />
                <xsl:when test="$genre = 'Discofilm'" />
                <xsl:when test="$genre = 'Trickart:_Nonkameratrick/Direct_Animation'" />
                <xsl:when test="$genre = 'Trickart:_Modelltrick'" />
                <xsl:when test="$genre = 'Revolutionsfilm'" />
                <xsl:when test="$genre = 'Road_Movie'" />
                <xsl:when test="$genre = 'Stabpuppenfilm'" />
                <xsl:when test="$genre = 'Materialfilm'" />
                <xsl:when test="$genre = 'Trickart:_Folienanimation'" />
                <xsl:when test="$genre = 'Expressionistischer_Film'" />
                <xsl:when test="$genre = 'Philosophischer_Film'" />
                <xsl:when test="$genre = 'Fernsehspiel'" />
                <xsl:when test="$genre = 'Partisanenfilm'" />
                <xsl:when test="$genre = 'Trickart:_Zeichentrick'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Animation" />
                </xsl:when>
                <xsl:when test="$genre = 'Kinderfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Childrens" />
                </xsl:when>
                <xsl:when test="$genre = 'Städte-_u._Landschaftsfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/CityAndLandscape" />
                </xsl:when>
                <xsl:when test="$genre = 'Kulturfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Cultural" />
                </xsl:when>
                <xsl:when test="$genre = 'Propagandafilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Propaganda" />
                </xsl:when>
                <xsl:when test="$genre = 'Literaturverfilmung'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/LiteraryAdaptation" />
                </xsl:when>
                <xsl:when test="$genre = 'Komödie'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Comedy" />
                </xsl:when>
                <xsl:when test="$genre = 'Industriefilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Industrial" />
                </xsl:when>
                <xsl:when test="$genre = 'Drama'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Drama" />
                </xsl:when>
                <xsl:when test="$genre = 'Tierfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Animal" />
                </xsl:when>
                <xsl:when test="$genre = 'Satire'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Satire" />
                </xsl:when>
                <xsl:when test="$genre = 'Märchenfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/FairyTale" />
                </xsl:when>
                <xsl:when test="$genre = 'Militärfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Military" />
                </xsl:when>
                <xsl:when test="$genre = 'Kriegsfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/War" />
                </xsl:when>
                <xsl:when test="$genre = 'Populärwissenschaftlicher_Film'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/PopularScience" />
                </xsl:when>
                <xsl:when test="$genre = 'Sportfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Sports" />
                </xsl:when>
                <xsl:when test="$genre = 'Kriminalfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Crime" />
                </xsl:when>
                <xsl:when test="$genre = 'Handpuppenfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/HandPuppet" />
                </xsl:when>
                <xsl:when test="$genre = 'Technikfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Technical" />
                </xsl:when>
                <xsl:when test="$genre = 'Aufklärungsfilm'">
                    <fiaf:hasGenre rdf:resource="https://dev.fiafcore.org/Educational" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        Error: Unexpected value "<xsl:value-of select="$genre"/>".
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:if>

    <!-- fiafcore:hasIdentifier -->

    <!-- <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/work/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier> -->

    <!-- fiafcore:hasLanguageUsage -->

        <!-- fiafcore:hasManifestation -->

        <xsl:for-each select="ba:Manifestation">
            <fiaf:hasManifestation>
                <rdf:Description rdf:about="bundesarchiv://resource/manifestation/{@uuid}" />
            </fiaf:hasManifestation>
        </xsl:for-each>

    <!-- fiafcore:hasSubject -->

    <!-- fiafcore:hasTitle -->

    <!-- <xsl:for-each select="ba:IDTitel">
                <fiaf:hasTitle>
                    <rdf:Description>
                        <rdf:type rdf:resource="https://ontology.fiafcore.org/IdentifiyingTitle" />
                        <fiaf:hasTitleValue>
                            <xsl:value-of select="." />
                        </fiaf:hasTitleValue>
                    </rdf:Description>
                </fiaf:hasTitle>
            </xsl:for-each> -->

    <!-- fiafcore:hasVariant -->

    <!-- fiafcore:hasWork -->

        </rdf:Description>
    </xsl:template>

    <!-- fiafcore:Manifestation -->

    <xsl:template match="ba:Manifestation">
        <rdf:Description rdf:about="bundesarchiv://resource/manifestation/{@uuid}">

            <xsl:if test="not(ba:Manifestationstyp)">
                <rdf:type rdf:resource="https://dev.fiafcore.org/Manifestation" />
            </xsl:if>
            <xsl:if test="ba:Manifestationstyp">
                <xsl:variable name="manifestation_type" select="ba:Manifestationstyp" />
                <xsl:choose>
                    <xsl:when test="$manifestation_type = 'Standardmanifestation'">
                        <rdf:type rdf:resource="https://dev.fiafcore.org/Manifestation" />
                    </xsl:when>
                    <xsl:when test="$manifestation_type = 'Migrationsmanifestation'">
                        <rdf:type rdf:resource="https://dev.fiafcore.org/Manifestation" />
                    </xsl:when>
                    <xsl:when test="$manifestation_type = 'Weitere Manifestation'">
                        <rdf:type rdf:resource="https://dev.fiafcore.org/Manifestation" />
                    </xsl:when>
                    <xsl:when test="$manifestation_type = 'Herstellungsprozess (Pre-Release)'">
                        <rdf:type rdf:resource="https://dev.fiafcore.org/PreReleaseManifestation" />
                    </xsl:when>
                    <xsl:when test="$manifestation_type = 'Kinofassung (Theatrical distribution)'">
                        <rdf:type rdf:resource="https://dev.fiafcore.org/TheatricalManifestation" />
                    </xsl:when>
                    <xsl:when test="$manifestation_type = 'Unidentifizierte Manifestation'">
                        <rdf:type rdf:resource="https://dev.fiafcore.org/Manifestation" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes">
                            Error: Unexpected value "<xsl:value-of select="$manifestation_type"/>".
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <!-- <rdfs:label> -->
                <!-- <xsl:value-of select="'Example Manifestation'"/> -->
            <!-- </rdfs:label> -->

    <!-- fiaf:hasColourCharacteristic -->

    <!-- <xsl:for-each select="ba:Farbe">
                <xsl:variable name="colorchar" select="translate(., ' ', '')" />
                <fiaf:hasColourCharacteristic rdf:resource="bundesarchiv://vocabulary/colourcharacteristic/{$colorchar}" />
            </xsl:for-each> -->

    <!-- fiaf:hasEvent -->

    <!-- fiaf:hasExtent -->

    <!-- <xsl:if test="ba:Gesamtlaenge">
                <fiaf:hasExtent>
                    <rdf:Description>
                        <rdf:type rdf:resource="bundesarchiv://ontology/extent/metres"/>
                        <fiaf:hasExtentValue>
                            <xsl:value-of select="ba:Gesamtlaenge"/>
                        </fiaf:hasExtentValue>
                    </rdf:Description>
                </fiaf:hasExtent>
            </xsl:if> -->

    <!-- fiaf:hasFormat  -->

    <!-- fiaf:hasIdentifier -->

    <!-- <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/manifestation/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier> -->

    <!-- fiaf:hasImageCharacteristic -->

        <!-- fiaf:hasItem -->

        <xsl:for-each select="ba:Exemplar">
            <fiaf:hasItem>
                <rdf:Description rdf:about="bundesarchiv://resource/item/{@uuid}" />
            </fiaf:hasItem>
        </xsl:for-each>

    <!-- fiaf:hasLanguageUsage -->

    <!-- <xsl:if test="ba:Sprache">
                <fiaf:hasLanguageUsage>
                    <rdf:Description>
                        <rdf:type rdf:resource="bundesarchiv://vocabulary/languageusage/{ba:Sprache/@sprachgebrauch}"/>
                        <xsl:variable name="lang" select="translate(ba:Sprache/@sprache, ' ', '')"/>
                        <fiaf:hasLanguage rdf:resource="bundesarchiv://vocabulary/language/{$lang}"/>
                    </rdf:Description>
                </fiaf:hasLanguageUsage>
            </xsl:if> -->

    <!-- fiaf:hasSoundCharacteristic -->

    <!-- fiaf:hasTitle -->

        </rdf:Description>
    </xsl:template>

    <!-- Items -->

    <xsl:template match="ba:Exemplar"> -->
        <rdf:Description rdf:about="bundesarchiv://resource/item/{@uuid}">
            <rdf:type rdf:resource="https://dev.fiafcore.org/Item" />

            <!-- fiaf:hasBase -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Traeger">
                <xsl:variable name="base" select="translate(ba:Aufbewahrungseinheit/ba:Traeger, ' ', '_')"/>
                <xsl:choose>
                    <xsl:when test="$base = 'keiner'" />
                    <xsl:when test="$base = 'Bearbeitungsspeicher'" />
                    <xsl:when test="$base = 'Ozaphan'" />
                    <xsl:when test="$base = 'Polycarbonat'" />
                    <xsl:when test="$base = 'Langzeitspeicher'" />
                    <xsl:when test="$base = 'Triazetatzellulose'">
                        <fiaf:hasBase rdf:resource="https://dev.fiafcore.org/Acetate" />
                    </xsl:when>
                    <xsl:when test="$base = 'Polyethylenterephtalat_(Polyester)'">
                        <fiaf:hasBase rdf:resource="https://dev.fiafcore.org/Polyester" />
                    </xsl:when>
                    <xsl:when test="$base = 'Zellulosenitrat'">
                        <fiaf:hasBase rdf:resource="https://dev.fiafcore.org/Nitrate" />
                    </xsl:when>
                    <xsl:when test="$base = 'Acetatcellulose'">
                        <fiaf:hasBase rdf:resource="https://dev.fiafcore.org/Acetate" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes">
                            Error: Unexpected value "<xsl:value-of select="$base"/>".
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <!-- fiaf:hasBroadcastStandard  -->

            <!-- <xsl:for-each select="ba:SDHDFernsehnorm">
                <xsl:variable name="broadcaststandard" select="translate(., ' ', '')" />
                <fiaf:hasBroadcastStandard rdf:resource="bundesarchiv://vocabulary/broadcaststandard/{$broadcaststandard}" />
            </xsl:for-each> -->

            <!-- fiaf:hasCarrier -->

            <xsl:for-each select="ba:Aufbewahrungseinheit">
                <fiaf:hasCarrier>
                    <rdf:Description rdf:about="bundesarchiv://resource/carrier/{@uuid}" />
                </fiaf:hasCarrier>
            </xsl:for-each>

            <!-- fiaf:hasColourCharacteristic  -->

            <!-- <xsl:if test="ba:Aufbewahrungseinheit/ba:Farbe">
                <xsl:variable name="itemcolour" select="translate(ba:Aufbewahrungseinheit/ba:Farbe, ' ', '')"/>
                <fiaf:hasColourCharacteristic rdf:resource="bundesarchiv://vocabulary/colourcharacteristic/{$itemcolour}"/>
            </xsl:if> -->

            <!-- fiaf:hasEvent  -->

            <!-- fiaf:hasExtent  -->

            <!-- fiaf:hasFormat  -->

            <xsl:if test="ba:Container">
                <xsl:variable name="format" select="translate(ba:Container, ' ', '_')"/>
                  <xsl:choose>
                  <xsl:when test="$format = 'TIFF'" />
                  <xsl:when test="$format = 'WAVE'" />
                  <xsl:when test="$format = 'OHNE_Container'" />
                  <xsl:when test="$format = 'VOB'" />
                  <xsl:when test="$format = 'WebM'" />
                  <xsl:when test="$format = 'MPEG-2'" />
                  <xsl:when test="$format = 'Unbekannt'" />
                  <xsl:when test="$format = 'DCP'" />
                  <xsl:when test="$format = 'Kodak_Cineon_Format'" />
                  <xsl:when test="$format = 'Open_EXR'" />
                  <xsl:when test="$format = 'MP4'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/MP4" />
                  </xsl:when>
                  <xsl:when test="$format = 'MXF_OP-1a'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/MXF" />
                  </xsl:when>
                  <xsl:when test="$format = 'AVI'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/AVI" />
                  </xsl:when>
                  <xsl:when test="$format = 'MXF_OP-Atom'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/MXF" />
                  </xsl:when>
                  <xsl:when test="$format = 'DPX'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/DPX" />
                  </xsl:when>
                  <xsl:when test="$format = 'MOV'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/MOV" />
                  </xsl:when>
                  <xsl:when test="$format = 'MXF'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/MXF" />
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:message terminate="yes">
                          Error: Unexpected value "<xsl:value-of select="$format"/>".
                      </xsl:message>
                  </xsl:otherwise>
              </xsl:choose>
            </xsl:if>

            <xsl:if test="ba:Filmbreite">
                <xsl:variable name="format" select="translate(ba:Filmbreite, ' ', '_')"/>
                  <xsl:choose>
                  <xsl:when test="$format = '6,25_mm'" />
                  <xsl:when test="$format = 'Unbekannt'" />
                  <xsl:when test="$format = '35_+_16_mm'" />
                  <xsl:when test="$format = '35-8_mm'" />
                  <xsl:when test="$format = '42_mm'" />
                  <xsl:when test="$format = 'Nicht_standardisiert'" />
                  <xsl:when test="$format = '35-16_mm'" />
                  <xsl:when test="$format = '35_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/35mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = '16_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/16mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = '16_mm_neue_Norm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/16mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = '16_mm_alte_Norm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/16mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = '8_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/8mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = 'S_16_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/Super16mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = '17,5_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/17.5mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = '9,5_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/9.5mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = '70_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/70mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = 'Normal_8_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/8mmFilm" />
                  </xsl:when>
                  <xsl:when test="$format = 'Super_8_mm'">
                      <fiaf:hasFormat rdf:resource="https://dev.fiafcore.org/Super8mmFilm" />
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:message terminate="yes">
                          Error: Unexpected value "<xsl:value-of select="$format"/>".
                      </xsl:message>
                  </xsl:otherwise>
              </xsl:choose>
            </xsl:if>

            <!-- fiaf:hasFrameRate  -->

            <!-- <xsl:if test="ba:Bildfrequenz">
                <xsl:variable name="fps" select="translate(ba:Bildfrequenz, ' ', '')"/>
                <fiaf:hasFrameRate rdf:resource="bundesarchiv://ontology/fps/{$fps}"/>
            </xsl:if> -->

            <!-- fiaf:hasHoldingInstitution  -->

            <!-- <fiaf:hasHoldingInstitution rdf:resource="bundesarchiv://ontology/holdinginstitution/bundesarchiv"/> -->

            <!-- fiaf:hasIdentifier  -->

            <!-- <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/item/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier> -->

            <!-- fiaf:hasImageCharacteristic  -->

            <!-- <xsl:if test="ba:Aufbewahrungseinheit/ba:Bildseitenverhaeltnis">
                <xsl:variable name="imagechar1" select="translate(ba:Aufbewahrungseinheit/ba:Bildseitenverhaeltnis, ' ', '')"/>
                <xsl:variable name="imagechar2" select="translate($imagechar1, '/', '')" />
                <xsl:variable name="imagechar3" select="translate($imagechar2, '(', '')" />
                <xsl:variable name="imagechar4" select="translate($imagechar3, ')', '')" />
                <xsl:variable name="imagechar5" select="translate($imagechar4, ',', '')" />
                <xsl:variable name="imagechar6" select="translate($imagechar5, ' ', '')" />
                <fiaf:hasImageCharacteristic rdf:resource="bundesarchiv://vocabulary/imagecharacteristic/{$imagechar6}"/>
            </xsl:if> -->

            <!-- fiaf:hasLineStandard  -->

            <!-- fiaf:hasResolution  -->

            <!-- fiaf:hasSoundCharacteristic  -->

            <!-- fiaf:hasSourceDevice  -->

            <!-- fiaf:hasSourceSoftware  -->

            <!-- fiaf:hasStatus  -->

            <xsl:if test="ba:ExemplarStatus">
                <xsl:variable name="status" select="translate(ba:ExemplarStatus, ' ', '_')"/>
                  <xsl:choose>
                  <xsl:when test="$status = 'Unbekannt'" />
                  <xsl:when test="$status = 'Benutzungsstück'">
                      <fiaf:hasStatus rdf:resource="https://dev.fiafcore.org/Access" />
                  </xsl:when>
                  <xsl:when test="$status = 'Sicherungsstück'">
                      <fiaf:hasStatus rdf:resource="https://dev.fiafcore.org/Preservation" />
                  </xsl:when>
                  <xsl:when test="$status = 'Digitales_Sicherungsstück'">
                      <fiaf:hasStatus rdf:resource="https://dev.fiafcore.org/Preservation" />
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:message terminate="yes">
                          Error: Unexpected value "<xsl:value-of select="$status"/>".
                      </xsl:message>
                  </xsl:otherwise>
              </xsl:choose>
            </xsl:if>

            <!-- fiaf:hasStock  -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Rohfilmtyp">
                <xsl:variable name="stock" select="translate(ba:Aufbewahrungseinheit/ba:Rohfilmtyp, ' ', '_')"/>
                <xsl:choose>
                    <xsl:when test="$stock = 'DP_31'" />
                    <xsl:when test="$stock = 'PF2'" />
                    <xsl:when test="$stock = 'DN_21'" />
                    <xsl:when test="$stock = '2374'" />
                    <xsl:when test="$stock = 'PF2_V2'" />
                    <xsl:when test="$stock = 'ST_8'" />
                    <xsl:when test="$stock = 'Keiner'" />
                    <xsl:when test="$stock = 'TF_12d'" />
                    <xsl:when test="$stock = '2234'" />
                    <xsl:when test="$stock = '2366'" />
                    <xsl:when test="$stock = 'CP_30'" />
                    <xsl:when test="$stock = 'Sonstige'" />
                    <xsl:when test="$stock = 'Kodak'">
                        <fiaf:hasStock rdf:resource="https://dev.fiafcore.org/Kodak" />
                    </xsl:when>
                    <xsl:when test="$stock = 'Orwo'">
                        <fiaf:hasStock rdf:resource="https://dev.fiafcore.org/Orwo" />
                    </xsl:when>
                    <xsl:when test="$stock = 'Agfa'">
                        <fiaf:hasStock rdf:resource="https://dev.fiafcore.org/Agfa" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes">
                            Error: Unexpected value "<xsl:value-of select="$stock"/>".
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <!-- fiaf:hasStream  -->

            <!-- fiaf:hasTitle  -->

            <!-- fiaf:hasTransferSpeed  -->

            <!-- fiaf:isElement  -->

            <xsl:if test="ba:Aufbewahrungseinheit/ba:Materialart">
                <xsl:variable name="element" select="translate(ba:Aufbewahrungseinheit/ba:Materialart, ' ', '_')"/>
                <xsl:choose>
                    <xsl:when test="$element = 'Magnetband'" />
                    <xsl:when test="$element = 'Stumme_Kopie'" />
                    <xsl:when test="$element = 'FILE'" />
                    <xsl:when test="$element = 'Verschiedenes'" />
                    <xsl:when test="$element = 'DVD/BA+TC'" />
                    <xsl:when test="$element = 'VHS'" />
                    <xsl:when test="$element = 'VHS/BA_+_TC'" />
                    <xsl:when test="$element = 'DVD'" />
                    <xsl:when test="$element = 'TN_zu_Farbbildnegativ'" />
                    <xsl:when test="$element = 'Betacam_Digital'" />
                    <xsl:when test="$element = 'Internegativ'" />
                    <xsl:when test="$element = '1_Zoll_B'" />
                    <xsl:when test="$element = 'Umatic'" />
                    <xsl:when test="$element = 'Kopie_mit_Tonkasch'" />
                    <xsl:when test="$element = 'Betacam_SP'" />
                    <xsl:when test="$element = 'Stummes_Internegativ'" />
                    <xsl:when test="$element = 'Kopie_mit_Magnetton'" />
                    <xsl:when test="$element = 'DVD/BA'" />
                    <xsl:when test="$element = 'Farbmuster-stumme_Kopie'" />
                    <xsl:when test="$element = 'Stummes_Duplikatpositiv_mit_Tonkasch'" />
                    <xsl:when test="$element = 'Tonpositiv_nur_für_Tonumspielung'" />
                    <xsl:when test="$element = 'VHS/BA'" />
                    <xsl:when test="$element = 'S-VHS'" />
                    <xsl:when test="$element = 'Stummes_Positiv'" />
                    <xsl:when test="$element = 'Original_Reversal_Positive'" />
                    <xsl:when test="$element = 'DVD/TC'" />
                    <xsl:when test="$element = 'Color_Reversal_Intermediate_(Negativ)'" />
                    <xsl:when test="$element = 'Stummes_Duplikatnegativ_mit_Tonkasch'" />
                    <xsl:when test="$element = 'TP_zu_Farbfilm'" />
                    <xsl:when test="$element = 'Stummes_Negativ'" />
                    <xsl:when test="$element = 'Digital_Audio_Tape'" />
                    <xsl:when test="$element = 'Original_Color_Reversal_Positive'" />
                    <xsl:when test="$element = 'AMPEX_DCT'" />
                    <xsl:when test="$element = 'Originaltonnegativ'" />
                    <xsl:when test="$element = 'Reversal_Positive'" />
                    <xsl:when test="$element = 'VCR'" />
                    <xsl:when test="$element = 'VHS/TC'" />
                    <xsl:when test="$element = 'Stummes_Intermediate_Positve'" />
                    <xsl:when test="$element = 'U-matic-HB'" />
                    <xsl:when test="$element = 'Stumme_Kopie_mit_Tonkasch'" />
                    <xsl:when test="$element = '1_Zoll_C'" />
                    <xsl:when test="$element = 'HD_CAM_SR'" />
                    <xsl:when test="$element = 'BETA'" />
                    <xsl:when test="$element = 'Magnetic_Optical_Disc'" />
                    <xsl:when test="$element = 'Color_Reversal_Positive'" />
                    <xsl:when test="$element = 'Stummes_Original_Reversal_Positive'" />
                    <xsl:when test="$element = 'HD_CAM'" />
                    <xsl:when test="$element = 'D_1_oder_2'" />
                    <xsl:when test="$element = 'Ton_-_Dupnegativ'" />
                    <xsl:when test="$element = 'Farbmuster-_kombinierte_Kopie'" />
                    <xsl:when test="$element = '1_Zoll_A'" />
                    <xsl:when test="$element = 'Nullkopie'" />
                    <xsl:when test="$element = 'Nullkopie_kombiniert'" />
                    <xsl:when test="$element = 'Magnetband_zu_Farbe'" />
                    <xsl:when test="$element = 'LTO_5'" />
                    <xsl:when test="$element = 'Stummes_Original_Color_Reversal_Positive'" />
                    <xsl:when test="$element = 'Stummes_Intermediate_Negative'" />
                    <xsl:when test="$element = 'Blu-ray_Disc'" />
                    <xsl:when test="$element = 'Arbeitskopie/Schnittkopie'" />
                    <xsl:when test="$element = 'Korrekturkopie'" />
                    <xsl:when test="$element = 'Mini_DV'" />
                    <xsl:when test="$element = 'S-VHS/BA'" />
                    <xsl:when test="$element = 'XDCAM_PFD_50DLA'" />
                    <xsl:when test="$element = 'Stummes_Color_Reversal_Intermediate'" />
                    <xsl:when test="$element = 'Stummes_Reversal_Positive'" />
                    <xsl:when test="$element = 'LTO_2'" />
                    <xsl:when test="$element = 'Betacam_Digital/BA'" />
                    <xsl:when test="$element = 'S-VHS/BA+TC'" />
                    <xsl:when test="$element = 'LTO_4'" />
                    <xsl:when test="$element = 'Stummes_Internegativ_mit_Tonkasch'" />
                    <xsl:when test="$element = 'Betacam_SP/TC'" />
                    <xsl:when test="$element = 'Stummes_Color_Reversal_Positive'" />
                    <xsl:when test="$element = 'U-matic-LB'" />
                    <xsl:when test="$element = 'HDD'" />
                    <xsl:when test="$element = 'Bildplatte'" />
                    <xsl:when test="$element = 'LTO_3'" />
                    <xsl:when test="$element = 'S-VHS/TC'" />
                    <xsl:when test="$element = 'Stumme_Korrekturkopie'" />
                    <xsl:when test="$element = 'MAZ'" />
                    <xsl:when test="$element = 'U-matic-LB/BA'" />
                    <xsl:when test="$element = 'DA-88'" />
                    <xsl:when test="$element = 'Stumme_Footage_(Positiv_und_Negativ)'" />
                    <xsl:when test="$element = 'U-matic-HB/BA+TC'" />
                    <xsl:when test="$element = 'HDD_mit_USB3'" />
                    <xsl:when test="$element = 'High_8/8mm'" />
                    <xsl:when test="$element = 'U-matic-HB/BA'" />
                    <xsl:when test="$element = 'Betamax'" />
                    <xsl:when test="$element = 'Kombinierte_Footage_(Positiv_und_Negativ)'" />
                    <xsl:when test="$element = 'VIDEO_2000'" />
                    <xsl:when test="$element = 'Kombinierte_Kopie'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/ReleasePrint" />
                    </xsl:when>
                    <xsl:when test="$element = 'Tonnegativ'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/SoundNegative" />
                    </xsl:when>
                    <xsl:when test="$element = 'kombiniertes_Duplikatpositiv'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicatePositive" />
                    </xsl:when>
                    <xsl:when test="$element = 'Bildduplikatnegativ'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicateNegative" />
                    </xsl:when>
                    <xsl:when test="$element = 'Originalbildnegativ'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/OriginalNegative" />
                    </xsl:when>
                    <xsl:when test="$element = 'kombiniertes_Duplikatnegativ'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicateNegative" />
                    </xsl:when>
                    <xsl:when test="$element = 'Bildnegativ'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicateNegative" />
                    </xsl:when>
                    <xsl:when test="$element = 'Stummes_Duplikatnegativ'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicateNegative" />
                    </xsl:when>
                    <xsl:when test="$element = 'Bildduplikatpositiv'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicatePositive" />
                    </xsl:when>
                    <xsl:when test="$element = 'Stummes_Duplikatpositiv'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicatePositive" />
                    </xsl:when>
                    <xsl:when test="$element = 'Bildpositiv'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicatePositive" />
                    </xsl:when>
                    <xsl:when test="$element = 'Tonpositiv'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/SoundPositive" />
                    </xsl:when>
                    <xsl:when test="$element = 'Intermediate_Positive'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicatePositive" />
                    </xsl:when>
                    <xsl:when test="$element = 'Intermediate_Negative'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/DuplicateNegative" />
                    </xsl:when>
                    <xsl:when test="$element = 'Stummes_Originalnegativ'">
                        <fiaf:isElement rdf:resource="https://dev.fiafcore.org/OriginalNegative" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes">
                            Error: Unexpected value "<xsl:value-of select="$element"/>".
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

        </rdf:Description>
    </xsl:template>

    <!-- Carriers -->

    <xsl:template match="ba:Aufbewahrungseinheit"> -->
        <rdf:Description rdf:about="bundesarchiv://resource/carrier/{@uuid}">
            <rdf:type rdf:resource="https://dev.fiafcore.org/Carrier" />

    <!-- fiaf:hasEvent -->

    <!-- fiaf:hasIdentifier -->

    <!-- <fiaf:hasIdentifier>
                <rdf:Description rdf:about="bundesarchiv://identifier/carrier/{@uuid}">
                    <rdf:type rdf:resource="bundesarchiv://ontology/identifier" />
                    <fiaf:hasIdentifierValue>
                        <xsl:value-of select="@uuid" />
                    </fiaf:hasIdentifierValue>
                    <fiaf:hasIdentifierAuthority rdf:resource="bundesarchiv://ontology/authority/bundesarchiv" />
                </rdf:Description>
            </fiaf:hasIdentifier> -->

        </rdf:Description>
    </xsl:template>

</xsl:stylesheet>
