<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xsd functx an" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:functx="http://www.functx.com" 
    xmlns:an="info:md/dhr/abawd/notices#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <!--==================================================-->
    <!-- ABAWD Notices XSL:FO to PDF                                                         -->
    <!--==================================================-->
    <!-- Creation Date: 2016-09-09                                                                  -->
    <!-- Last Modified Date: 2016-09-09                                                          -->
    <!-- XSLT Developer: Clay Redding                                                          -->
    <!-- XSLT Developer contact: clay.redding@marklogic.com                     -->
    <!--==================================================-->
    <!--                Requirements                                                                         -->
    <!--==================================================-->
    <!--   XSL-FO Engine:    Apache FOP                                                         -->
    <!--==================================================-->
    <!--                Description                                                                              -->
    <!--==================================================-->
    <!-- This script creates a notification based on the                                     -->
    <!-- ABAWD Screener JSON-to-XML file.                                                  -->
    <!--==================================================-->
	
    <xsl:param name="notice-details" as="element(an:abawd-notices)" required="yes"/>
    
    <!--<xsl:variable name="notice-details" as="element(an:abawd-notices)">
        <an:abawd-notices xmlns:an="info:md/dhr/abawd/notices#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <an:notification-core>
                <an:LDSS>Anne Arundel County Department of Social Services</an:LDSS>
                <an:LDSS-Address>80 West Street, Annapolis, MD 21401</an:LDSS-Address>
                <an:notice-date>2016-09-09</an:notice-date>
                <an:clientID>8675309</an:clientID>
                <an:clientLanguagePreferenceCode>es</an:clientLanguagePreferenceCode>
                <an:recipient-name>Jane Doe</an:recipient-name>
                <an:recipient-mailing-address1>45 Hopping Frog Lane, Apt. 2</an:recipient-mailing-address1>
                <an:recipient-mailing-address2>Avenue, MD 20222</an:recipient-mailing-address2>
            </an:notification-core>
            <an:notice xsi:type="AppointmentNotice">
                <an:appointment-dateTime>2016-04-04T14:18:34-04:00</an:appointment-dateTime>
                <!-\-<an:appointment-date>2016-04-04</an:appointment-date> -\->
                <!-\-<an:appointment-time time-zone="eastern">T14:18:34-04:00</an:appointment-time>-\->
                <an:telephone-contact-number>301-867-5309</an:telephone-contact-number>
            </an:notice>
        </an:abawd-notices>
    </xsl:variable>-->

   <xsl:output method="xml" indent="yes"/>

    <xsl:function name="an:createAppointmentDate">
        <xsl:param name="date" required="yes" as="xs:dateTime"/>
        <xsl:param name="lang" required="no" as="xs:string"/>
        <xsl:sequence select="format-dateTime($date, '[M01]/[D01]/[Y0001]', (), (), ())"/>
    </xsl:function>
    
    <xsl:function name="an:createAppointmentTime">
        <xsl:param name="date" required="yes" as="xs:dateTime"/>
        <xsl:param name="lang" required="no" as="xs:string"/>
        <xsl:sequence select="format-dateTime($date, '[h]:[m01] [PN]', (), (), ())"/>
    </xsl:function>
    
    <!-- Set default font family-->
    <xsl:variable name="defaultFontFace">
        <xsl:choose>
            <xsl:when test="$notice-details//an:clientLanguagePreferenceCode/normalize-space() eq 'am' ">
                <xsl:value-of select="'Abyssinica SIL'"/> <!-- Kefa built-in for Mac or Abyssinica SIL for Linux at http://software.sil.org/abyssinica/download/ -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'Arial'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Set default font size -->
    <xsl:variable name="defaultFontSize">11pt</xsl:variable>
    
 <!-- Default template.  The default is not to output anything unless it has been specifically called. -->
    <xsl:template match="*"/>

    <xsl:template match="/">
        <xsl:call-template name="createPDF"/>
    </xsl:template>

    <xsl:template name="createPDF">
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="FirstPage" margin-top=".75in" margin-left=".75in" margin-right=".75in" margin-bottom=".75in">
                    <fo:region-body/>
                    <fo:region-before extent=".1in" display-align="before" region-name="FirstPageHeader"/>
                    <fo:region-after extent=".1in" display-align="after" region-name="FirstPageFooter"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="EvenPage" margin-top=".75in" margin-left=".75in" margin-right=".75in" margin-bottom=".75in">
                    <fo:region-body/>
                    <fo:region-before extent=".1in" display-align="before" region-name="EvenPageHeader"/>
                    <fo:region-after extent=".1in" display-align="after" region-name="EvenPageFooter"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="OddPage" margin-top=".75in" margin-left=".75in" margin-right=".75in" margin-bottom=".75in">
                    <fo:region-body/>
                    <fo:region-before extent=".1in" display-align="before" region-name="OddPageHeader"/>
                    <fo:region-after extent=".1in" display-align="after" region-name="OddPageFooter"/>
                </fo:simple-page-master>
                <fo:page-sequence-master master-name="AllPages">
                    <fo:single-page-master-reference master-reference="FirstPage"/>
                    <fo:repeatable-page-master-alternatives>
                        <fo:conditional-page-master-reference master-reference="EvenPage" odd-or-even="even"/>
                        <fo:conditional-page-master-reference master-reference="OddPage" odd-or-even="odd"/>
                    </fo:repeatable-page-master-alternatives>
                </fo:page-sequence-master>
            </fo:layout-master-set>
            <xsl:call-template name="createATPageSequence"/>
        </fo:root>
    </xsl:template>

    <xsl:template name="createATPageSequence">
        <fo:page-sequence master-reference="AllPages">
            <fo:static-content flow-name="FirstPageHeader">
                <fo:table>
                    <fo:table-column column-width="15%"/>
                    <fo:table-column column-width="85%"/>
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block>
                                    <fo:external-graphic src="dhr_logo_small.png"/>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block color="#990000" margin="10pt" font-size="7pt">
                                    <fo:leader color="#990000" leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
                                    <fo:inline font-style="italic" padding-right=".25in">Department of Human Resources</fo:inline>
                                    <fo:inline>Larry Hogan, </fo:inline>
                                    <fo:inline font-style="italic">Governor</fo:inline>
                                    <fo:inline> | </fo:inline>
                                    <fo:inline>Boyd Rutherford, </fo:inline>
                                    <fo:inline font-style="italic">Lt. Governor</fo:inline>
                                    <fo:inline> | </fo:inline>
                                    <fo:inline>Sam Malhotra, </fo:inline>
                                    <fo:inline font-style="italic">Secretary</fo:inline>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content flow-name="FirstPageFooter">
                <xsl:call-template name="pageFooter"/>
            </fo:static-content>
           
            <!--   <fo:static-content flow-name="EvenPageHeader"></fo:static-content>-->
            <fo:static-content flow-name="OddPageFooter">
                <xsl:call-template name="pageFooter"/>
            </fo:static-content>

         <!--   <fo:static-content flow-name="EvenPageHeader"></fo:static-content>-->
            <fo:static-content flow-name="EvenPageFooter">
                <xsl:call-template name="pageFooter"/>
            </fo:static-content>
            <xsl:call-template name="createPageFlow"/>
        </fo:page-sequence>
    </xsl:template>
    
    <xsl:template name="pageFooter">
        <fo:block>
            <fo:leader leader-pattern="rule" rule-thickness="1pt" leader-length="100%"/>
        </fo:block>
        <fo:block font-size="7pt" font-style="italic" text-align="center">311 West Saratoga Street • Baltimore, Maryland 21201-3500 • General Information 800-322-6347</fo:block>
        <fo:block font-size="7pt" text-align="center" margin-top="1pt">TTY 800-925-4434 • <fo:basic-link external-destination="url('http://www.dhr.maryland.gov')" color="#F48026">www.dhr.maryland.gov</fo:basic-link> • Equal Opportunity Employer</fo:block>
        <fo:block font-size="5pt" text-align="right">Page <fo:page-number/> of <fo:page-number-citation ref-id="eof"/></fo:block>
    </xsl:template>

    <xsl:template name="createPageFlow">
        <fo:flow flow-name="xsl-region-body" font-family="{$defaultFontFace}" font-size="{$defaultFontSize}">
            <xsl:call-template name="createDistrictOfficeSubHeader"/>
            <xsl:call-template name="createDetailSubHeader"/>
            <xsl:call-template name="createAddress"/>
            <xsl:call-template name="createApprovalNoticeSubHeader"/>
            <xsl:call-template name="createBody"/>
            <xsl:call-template name="createReasonableAccommodation"/>
            <fo:block id="eof"/>
        </fo:flow>
    </xsl:template>
    
    <xsl:template name="createDistrictOfficeSubHeader">
        <fo:block margin-top=".85in">
            <fo:block text-align="center">
                <fo:inline font-style="italic" font-weight="bold">
                    <xsl:value-of select="$notice-details//an:LDSS/normalize-space()"/>
                </fo:inline>
            </fo:block>
            <fo:block text-align="center">
                <fo:inline font-style="italic" font-weight="bold">
                    <xsl:value-of select="$notice-details//an:LDSS-Address/normalize-space()"/>
                </fo:inline>
            </fo:block>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createDetailSubHeader">
        <fo:block space-before=".4in">
            <fo:table>
                <fo:table-column column-width="70%"/>
                <fo:table-column column-width="30%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block>
                                <fo:inline font-weight="bold" margin-right=".1in">Date: </fo:inline>
                                <fo:inline text-decoration="underline">
                                    <fo:inline margin-left="12px">&#160;</fo:inline>
                                    <xsl:value-of select="$notice-details//an:notice-date/normalize-space()"/>
                                    <fo:inline margin-right="12px">&#160;</fo:inline>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block>
                                <fo:inline font-weight="bold" margin-right=".1in">Client ID #: </fo:inline>
                                <fo:inline text-decoration="underline" text-align="right">
                                    <fo:inline margin-left="12px">&#160;</fo:inline>
                                    <xsl:value-of select="$notice-details//an:clientID/normalize-space()"/>
                                    <fo:inline margin-right="12px">&#160;</fo:inline>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createAddress">        
        <fo:block space-before=".25in">
            <fo:table>
                <fo:table-column column-width="60%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block space-before="10px" border-bottom="1px solid #000000">
                                <xsl:value-of select="$notice-details//an:recipient-name/normalize-space()"/>
                            </fo:block>
                            <fo:block space-before="10px" border-bottom="1px solid #000000">
                                <xsl:value-of select="$notice-details//an:recipient-mailing-address1/normalize-space()"/>
                            </fo:block>
                            <fo:block space-before="10px" border-bottom="1px solid #000000">
                                <xsl:value-of select="$notice-details//an:recipient-mailing-address2/normalize-space()"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createApprovalNoticeSubHeader">
        <xsl:variable name="thislang" select="$notice-details//an:clientLanguagePreferenceCode/normalize-space()"/>
        <fo:block text-align="center" space-before=".4in" font-weight="bold">
            <xsl:choose>
                <!-- Spanish 'es' -->
                <xsl:when test="$thislang eq 'es' ">
                    <fo:block><fo:inline font-style="italic">Requisitos de Trabajo para el Programa de Suplementos Alimenticios</fo:inline></fo:block>
                </xsl:when>
                <xsl:otherwise> <!-- English 'en' is default -->
                    <fo:block><fo:inline font-style="italic">WARNING NOTICE</fo:inline></fo:block>
                    <fo:block><fo:inline font-style="italic">FOR FOOD SUPPLEMENT BENEFITS</fo:inline></fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createBody">
        <xsl:variable name="thisapptdate" select="$notice-details//an:appointment-dateTime/normalize-space() cast as xs:dateTime"/>
        <xsl:variable name="thisappttime" select="$notice-details//an:appointment-dateTime/normalize-space() cast as xs:dateTime"/>
        <xsl:variable name="thistelephone" select="$notice-details//an:telephone-contact-number/normalize-space()"/>
        <xsl:variable name="thislang" select="$notice-details//an:clientLanguagePreferenceCode/normalize-space()"/>
        <fo:block space-before=".25in" break-after="page">
            <xsl:choose>
                <xsl:when test="$thislang eq 'es' ">
                    <xsl:call-template name="createBody-es">
                        <xsl:with-param name="thisapptdate" select="$thisapptdate"/>
                        <xsl:with-param name="thisappttime" select="$thisappttime"/>
                        <xsl:with-param name="thistelephone" select="$thistelephone"/>
                        <xsl:with-param name="thislang" select="$thislang"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="createBody-en">
                        <xsl:with-param name="thisapptdate" select="$thisapptdate"/>
                        <xsl:with-param name="thisappttime" select="$thisappttime"/>
                        <xsl:with-param name="thistelephone" select="$thistelephone"/>
                        <xsl:with-param name="thislang" select="$thislang"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
  
    <xsl:template name="createBody-en">
        <xsl:param name="thisapptdate" required="yes"/>
        <xsl:param name="thisappttime" required="yes"/>
        <xsl:param name="thistelephone" required="yes"/>
        <xsl:param name="thislang" required="yes"/>
        <fo:block space-before=".15in">Federal rules for the Food Supplement Program have changed, and the changes might affect your benefits.   In order to assess your ability to work or participate in a work program, we need to talk to you about the work requirements.</fo:block>
        <fo:block space-before=".15in">The new rules limit your benefits to three months during the 36-month period of January 2016 to December 2018 unless you are exempt, or working, or participating in certain work activities.</fo:block>
        <fo:block space-before=".15in">We have scheduled an appointment for you on the day and at the time below:</fo:block>
        <fo:block space-before=".15in" space-after=".15in">
            <fo:table>
                <fo:table-column column-width="1in"/>
                <fo:table-column/>
                <fo:table-column column-width="1in"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:table padding-top="10px" text-align="center">
                                <fo:table-column column-width="50%"/>
                                <fo:table-column column-width="50%"/>
                                <fo:table-header>
                                    <fo:table-row font-weight="bold">
                                        <fo:table-cell><fo:block>Appointment Date:</fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block>Appointment Time:</fo:block></fo:table-cell>
                                    </fo:table-row>
                                </fo:table-header>
                                <fo:table-body>
                                    <fo:table-row border="solid 1px black"  height="30px" display-align="center">
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:value-of select="an:createAppointmentDate($thisapptdate, $thislang)"/>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell border-left="solid 1px black">
                                            <fo:block>
                                                <xsl:value-of select="an:createAppointmentTime($thisappttime, $thislang)"/>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </fo:table-body>
                            </fo:table>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
        <fo:block space-before=".15in">If you need to reschedule, please call this number as soon as possible: <fo:inline text-decoration="underline"><fo:inline margin-left="12px">&#160;</fo:inline><xsl:value-of select="$thistelephone"/><fo:inline margin-right="12px">&#160;</fo:inline></fo:inline>.</fo:block>
        <fo:block space-before=".15in">Thank you.</fo:block>
    </xsl:template>

    <xsl:template name="createBody-es">
        <xsl:param name="thisapptdate" required="yes"/>
        <xsl:param name="thisappttime" required="yes"/>
        <xsl:param name="thistelephone" required="yes"/>
        <xsl:param name="thislang" required="yes"/>
        <fo:block space-before=".15in">Se requiere seguir las reglas laborales si usted tiene entre 18 y 50 años de edad y no se encuentra viviendo con un hijo(a) menor de 18 años. Si usted no sigue estas reglas, usted únicamente recibirá los beneficios del Programa de Suplementos Alimenticios durante 3 meses en un periodo de 36 meses. Seguir las reglas significa que:</fo:block>
        <fo:list-block space-before=".15in" space-after=".15in">
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Trabaja a cambio de remuneración por lo menos 20 horas por semana o 30 horas por semana si trabaja por cuenta propia; O</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Participa en un programa laboral por lo menos 20 horas por semana; O</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Participa en un programa de trabajo de servicio público.</fo:block>
                </fo:list-item-body>
            </fo:list-item>
        </fo:list-block>
        <fo:block space-before=".15in">Podemos ayudarle si viene a nuestra oficina en la siguiente fecha y hora:</fo:block>
        <fo:block space-before=".15in" space-after=".15in">
            <fo:table>
                <fo:table-column column-width="1in"/>
                <fo:table-column/>
                <fo:table-column column-width="1in"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:table padding-top="10px" text-align="center">
                                <fo:table-column column-width="50%"/>
                                <fo:table-column column-width="50%"/>
                                <fo:table-header>
                                    <fo:table-row font-weight="bold">
                                        <fo:table-cell><fo:block>Día de la cita</fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block>Hora de la cita</fo:block></fo:table-cell>
                                    </fo:table-row>
                                </fo:table-header>
                                <fo:table-body>
                                    <fo:table-row border="solid 1px black"  height="30px" display-align="center">
                                        <fo:table-cell>
                                            <fo:block>
                                                <xsl:value-of select="an:createAppointmentDate($thisapptdate, $thislang)"/>
                                            </fo:block>
                                        </fo:table-cell>
                                        <fo:table-cell border-left="solid 1px black">
                                            <fo:block>
                                                <xsl:value-of select="an:createAppointmentTime($thisappttime, $thislang)"/>
                                            </fo:block>
                                        </fo:table-cell>
                                    </fo:table-row>
                                </fo:table-body>
                            </fo:table>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
        <fo:block space-before=".15in">Si necesita cambiar la fecha, por favor llame a este número tan pronto como sea posible: <fo:inline text-decoration="underline"><fo:inline margin-left="12px">&#160;</fo:inline><xsl:value-of select="$thistelephone"/><fo:inline margin-right="12px">&#160;</fo:inline></fo:inline>.</fo:block>
    </xsl:template>
    
    <xsl:template name="createReasonableAccommodation">
        <fo:block-container font-family="Arial">
            <xsl:choose>
                <xsl:when test="$notice-details//an:clientLanguagePreferenceCode/normalize-space() eq 'es' ">
                    <!-- Spanish -->
                    <!-- Page break -->
                    <fo:block space-before=".15in" font-weight="bold">Cómo solicitar una adaptación razonable</fo:block>
                    <fo:block space-before=".15in">Si usted tiene una discapacidad, puede que tenga derecho a una adaptación razonable para ayudarle a tener acceso a las actividades, programas y servicios de DHR. Esto aplica aun si usted trabaja para un departamento de servicios sociales locales o un proveedor de servicios para clientes de DHR.</fo:block>
                    <fo:block space-before=".15in">Una adaptación razonable es una modificación o ajuste a una actividad, programa o servicio que ayuda a una persona discapacitada que califique a que tenga acceso significativo a las actividades, programas y servicios de DHR.</fo:block>
                    <fo:block space-before=".15in" font-weight="bold" padding-top="10px">Ejemplos de adaptaciones razonables:</fo:block>
                    <fo:block space-before=".15in"><fo:inline  font-weight="bold">Limitaciones auditivas:</fo:inline> intérprete de lenguaje de señas; proveer aparato de ayuda auditiva</fo:block>
                    <fo:block space-before=".15in"><fo:inline  font-weight="bold">Limitaciones visuales:</fo:inline> proveer un lector calificado al cliente</fo:block>
                    <fo:block space-before=".15in"><fo:inline font-weight="bold">Limitaciones de movilidad:</fo:inline> enviar formularios al cliente; reunirse con el cliente en un lugar más accesible</fo:block>
                    <fo:block space-before=".15in"><fo:inline font-weight="bold">Discapacidades de desarrollo:</fo:inline> Escribir; tomar recesos; programar citas ajustadas a las necesidades médicas de los clientes.</fo:block>
                    <fo:block space-before=".15in">Usted puede solicitar una adaptación razonable al departamento de servicios sociales local o proveedor en cualquier momento.  La solicitud puede ser verbal o por escrito. Puede hacer una solicitud de adaptación razonable en persona, por escrito o por teléfono. No tiene que usar palabras específicas para solicitar una adaptación. Usted mismo u otra persona que le ayude puede presentar la solicitud. Si necesita solicitar una adaptación razonable debido a su discapacidad, debe hablar con el administrador de su caso o supervisor o el Coordinador de Campo de ADA en su departamento de servicios sociales local. Usted puede pedirle al administrador de caso el nombre del Coordinador de ADA en su departamento de servicios sociales local. También puede pedir más información en la recepción.</fo:block>
                    <fo:block space-before=".15in" font-weight="bold" padding-top="10px">Audiencia justa</fo:block>
                    <fo:block space-before=".15in">Usted tiene derecho a solicitar una audiencia justa si no está de acuerdo con nuestra decisión.  Si usted no está de acuerdo con una decisión, puede solicitar una audiencia justa con un Juez de Derecho Administrativo de la Oficina de Audiencias Administrativas, quien evaluará la información y tomará una decisión conforme con la ley.</fo:block>
                    <fo:block space-before=".15in">Usted tiene <fo:inline text-decoration="underline">90 días</fo:inline> a partir de la fecha del aviso de beneficios de Suplementos Alimenticios y 30 días a partir de la fecha del aviso de asistencia en efectivo para solicitar una audiencia justa.</fo:block>
                    <fo:block space-before=".15in">Puede solicitar una audiencia llamando al administrador del caso cuyo nombre aparece en este aviso o llamando a la Oficina de Audiencias Administrativas al <fo:inline font-weight="bold">410-229-4100 or 1-800-388-8805</fo:inline>.   Puede pedirle a alguien que lo represente durante la audiencia o usted puede representarse a sí mismo.</fo:block>
                </xsl:when>
                <xsl:otherwise>
                    <!-- English, default -->
                    <!-- Page break -->
                    <fo:block space-before=".15in" font-weight="bold">Requesting A Reasonable Accommodation</fo:block>
                    <fo:block space-before=".15in">If you are an individual with a disability, you may be entitled to reasonable accommodation to help you access DHR's activities, programs and services. This applies even if you are working with a local department of social services or a vendor who provides services for DHR's customers.</fo:block>
                    <fo:block space-before=".15in">A reasonable accommodation is a modification or adjustment to an activity, program or service which helps a qualified individual with a disability have meaningful access to DHR's activities, programs and services.</fo:block>
                    <fo:block space-before=".15in" font-weight="bold" padding-top="10px">Examples of Reasonable Accommodations:</fo:block>
                    <fo:block space-before=".15in"><fo:inline  font-weight="bold">Hearing Impairment:</fo:inline> sign language interpreter; providing an assistive listening device</fo:block>
                    <fo:block space-before=".15in"><fo:inline  font-weight="bold">Visual Impairment:</fo:inline> having a qualified reader read to a customer</fo:block>
                    <fo:block space-before=".15in"><fo:inline font-weight="bold">Mobility Impairments:</fo:inline> mailing forms to a customer; meeting a customer at a more accessible location</fo:block>
                    <fo:block space-before=".15in"><fo:inline font-weight="bold">Developmental Disabilities:</fo:inline> Having things written down; taking breaks; scheduling appointments around a customer's medical needs</fo:block>
                    <fo:block space-before=".15in">You may request a reasonable accommodation from the local department of social services or a vendor at any time.  Your request may be oral or written. A request for a reasonable accommodation may be made in person, in writing or over the telephone. There are no particular words that you need to use to request an accommodation. A request may be made by you or someone helping you. If you need to request a reasonable accommodation because of your disability, you should speak with the case manager or the supervisor or the ADA Field Coordinator at your local department of social services. You may ask the case manager for the name of the ADA Coordinator at your local department of social services. You may also ask for more information at the front desk.</fo:block>
                    <fo:block space-before=".15in" font-weight="bold" padding-top="10px">Fair Hearing</fo:block>
                    <fo:block space-before=".15in">You have the right to request a fair hearing if you disagree with our decision.  Anytime you disagree with a decision, you can request a fair hearing with an Administrative Law Judge from the Office of Administrative Hearings who will review the information and make a decision on the law.</fo:block>
                    <fo:block space-before=".15in">You have <fo:inline text-decoration="underline">90 days</fo:inline> from the date of the notice for Food Supplement benefits and 30 days from the date of notice for cash assistance to request a fair hearing.</fo:block>
                    <fo:block space-before=".15in">You can request a hearing by calling the case manager on this notice or by calling the Office of Administrative Hearings at <fo:inline font-weight="bold">410-229-4100 or 1-800-388-8805</fo:inline>.   You may have anyone you choose represent you at the hearing or you may represent yourself.</fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block-container>
    </xsl:template>
</xsl:stylesheet>