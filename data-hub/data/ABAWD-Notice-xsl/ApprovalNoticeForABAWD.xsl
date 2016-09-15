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
                <an:clientLanguagePreferenceCode>en</an:clientLanguagePreferenceCode>
                <an:recipient-name>Jane Doe</an:recipient-name>
                <an:recipient-mailing-address1>45 Hopping Frog Lane, Apt. 2</an:recipient-mailing-address1>
                <an:recipient-mailing-address2>Avenue, MD 20222</an:recipient-mailing-address2>
            </an:notification-core>
            <an:notice xsi:type="ApprovalNotice">
                <an:approval-date>2016-09-08</an:approval-date>
                <an:receive-begin-amount>52</an:receive-begin-amount>
                <an:receive-end-amount>53</an:receive-end-amount>
                <an:monthYear-begin>2016-11-01</an:monthYear-begin>
                <an:monthYear-end>2017-01-01</an:monthYear-end>
            </an:notice>
        </an:abawd-notices>
    </xsl:variable>-->

   <xsl:output method="xml" indent="yes"/>

    <xsl:function name="an:createPublicationDate">
        <xsl:param name="date" required="yes" as="xs:date"/>
        <xsl:param name="lang" required="no" as="xs:string"/>
        <xsl:param name="mode" required="no" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$mode eq 'YearMonth' ">
                <xsl:choose>
                    <xsl:when test="$lang eq 'am' ">
                        <xsl:sequence select="format-date($date, '[MNn] [Y]', $lang, (), ())"/>
                    </xsl:when>
                    <xsl:when test="$lang eq 'ar' ">
                        <xsl:sequence select="format-date($date, '[MNn] [Y]', $lang, (), ())"/>
                    </xsl:when>
                    <xsl:when test="$lang eq 'es' ">
                        <xsl:sequence select="lower-case(format-date($date, '[MNn] del año [Y]', $lang, (), ()))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="format-date($date, '[MNn] [Y]', $lang, (), ())"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$lang eq 'am' ">
                <xsl:sequence select="format-date($date, '[MNn] [D], [Y]', $lang, (), ())"/>
            </xsl:when>
            <xsl:when test="$lang eq 'ar' ">
                <xsl:sequence select="format-date($date, '[D]', $lang, (), ())"/>
                <xsl:sequence select="format-date($date, '[MNn] [Y]', $lang, (), ())"/>
            </xsl:when>
            <xsl:when test="$lang eq 'es' ">
                <xsl:sequence select="lower-case(format-date($date, '[D] de [MNn] de [Y]', $lang, (), ()))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="format-date($date, '[MNn] [D], [Y]', $lang, (), ())"/>
            </xsl:otherwise>
        </xsl:choose>
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
                <!-- Amharic Ge'ez 'am' -->
                <xsl:when test="$thislang eq 'am' ">
                    <fo:block xml:lang="am"><fo:inline font-style="italic">ለተጨማሪ ምግብ እርዳታዎች</fo:inline></fo:block>
                    <fo:block xml:lang="am"><fo:inline font-style="italic">ተቀባይነት የማግኘት ማሳሰቢያ</fo:inline></fo:block>
                </xsl:when>
                <!-- Arabic 'ar' -->
                <xsl:when test="$thislang eq 'ar' ">
                    <fo:block-container xml:lang="ar" writing-mode="rl-tb">
                        <fo:block xml:lang="ar">إشعار قبول طلب</fo:block>
                        <fo:block xml:lang="ar">للحصول على مستحقات  الغذاء التكميلي</fo:block>
                    </fo:block-container>
                </xsl:when>
                <!-- Spanish 'es' -->
                <xsl:when test="$thislang eq 'es' ">
                    <fo:block><fo:inline font-style="italic">AVISO DE APROBACIÓN DE BENEFICIOS</fo:inline></fo:block>
                    <fo:block><fo:inline font-style="italic">DE SUPLEMENTOS ALIMENTICIOS</fo:inline></fo:block>
                </xsl:when>
                <xsl:otherwise> <!-- English 'en' is default -->
                    <fo:block><fo:inline font-style="italic">NOTICE OF APPROVAL</fo:inline></fo:block>
                    <fo:block><fo:inline font-style="italic">FOR FOOD SUPPLEMENT BENEFITS</fo:inline></fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createBody">
        <xsl:variable name="thisdate" select="$notice-details//an:approval-date/normalize-space() cast as xs:date"/>
        <xsl:variable name="thisbeginamount" select="$notice-details//an:receive-begin-amount/normalize-space()"/>
        <xsl:variable name="thisendamount" select="$notice-details//an:receive-end-amount/normalize-space()"/>
        <xsl:variable name="thisbegin" select="$notice-details//an:monthYear-begin/normalize-space() cast as xs:date"/>
        <xsl:variable name="thisend" select="$notice-details//an:monthYear-end/normalize-space() cast as xs:date"/>
        <xsl:variable name="thislang" select="$notice-details//an:clientLanguagePreferenceCode/normalize-space()"/>
        <fo:block space-before=".25in" break-after="page">
            <xsl:choose>
                <xsl:when test="$thislang eq 'am' ">
                    <xsl:call-template name="createBody-am">
                        <xsl:with-param name="thisdate" select="$thisdate"/>
                        <xsl:with-param name="thisbeginamount" select="$thisbeginamount"/>
                        <xsl:with-param name="thisendamount" select="$thisendamount"/>
                        <xsl:with-param name="thisbegin" select="$thisbegin"/>
                        <xsl:with-param name="thisend" select="$thisend"/>
                        <xsl:with-param name="thislang" select="$thislang"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$thislang eq 'ar' ">
                    <xsl:call-template name="createBody-ar">
                        <xsl:with-param name="thisdate" select="$thisdate"/>
                        <xsl:with-param name="thisbeginamount" select="$thisbeginamount"/>
                        <xsl:with-param name="thisendamount" select="$thisendamount"/>
                        <xsl:with-param name="thisbegin" select="$thisbegin"/>
                        <xsl:with-param name="thisend" select="$thisend"/>
                        <xsl:with-param name="thislang" select="$thislang"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$thislang eq 'es' ">
                    <xsl:call-template name="createBody-es">
                        <xsl:with-param name="thisdate" select="$thisdate"/>
                        <xsl:with-param name="thisbeginamount" select="$thisbeginamount"/>
                        <xsl:with-param name="thisendamount" select="$thisendamount"/>
                        <xsl:with-param name="thisbegin" select="$thisbegin"/>
                        <xsl:with-param name="thisend" select="$thisend"/>
                        <xsl:with-param name="thislang" select="$thislang"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="createBody-en">
                        <xsl:with-param name="thisdate" select="$thisdate"/>
                        <xsl:with-param name="thisbeginamount" select="$thisbeginamount"/>
                        <xsl:with-param name="thisendamount" select="$thisendamount"/>
                        <xsl:with-param name="thisbegin" select="$thisbegin"/>
                        <xsl:with-param name="thisend" select="$thisend"/>
                        <xsl:with-param name="thislang" select="$thislang"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createBody-am">
        <xsl:param name="thisdate" required="yes"/>
        <xsl:param name="thisbeginamount" required="yes"/>
        <xsl:param name="thisendamount" required="yes"/>
        <xsl:param name="thisbegin" required="yes"/>
        <xsl:param name="thisend" required="yes"/>
        <xsl:param name="thislang" required="yes"/>
        <fo:block space-before=".15in" xml:lang="am">የተጨማሪ ምግብ እርዳታዎችን ለማግኘት በቀን<fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisdate, $thislang, '')"/></fo:inline>ያቀረቡት ማመልከቻ ተቀባይነት አግኝቷል።</fo:block>
        <fo:block space-before=".15in" xml:lang="am"><fo:inline font-weight="bold" text-decoration="underline"><fo:inline margin-right="8px">&#160;</fo:inline>$<xsl:value-of select="$thisbeginamount"/><fo:inline margin-left="8px">&#160;</fo:inline></fo:inline> ለወርሃ<fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisbegin, $thislang, 'YearMonth')"/></fo:inline>ይሰጥዎታል። ከዛ በኋላ ደግሞ እስከ <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisend, $thislang, 'YearMonth')"/></fo:inline> ድረስ በወር <fo:inline font-weight="bold" text-decoration="underline"><fo:inline margin-right="8px">&#160;</fo:inline>$<xsl:value-of select="$thisendamount"/><fo:inline margin-left="8px">&#160;</fo:inline></fo:inline> የገንዘብ ድጋፍ ይሰጥዎታል። የተጠቀሰው ግዜ ሲደርስ ማመልከቻዎትን እንደገና ማቅረብ አለብዎት።</fo:block>
        <fo:block space-before=".15in" xml:lang="am">ቢሮአችን ውስጥ ተገኝተው እያሉ የነጻነት ካርድ ሳንሰጥዎት ከቀረን ይህንን ካርድ በደብዳቤ እንልክልዎታለን። ግብይት በሚፈጽሙበት ወቅት የተጨማሪ ምግብ እርዳታዎችዎን ለማግኘት በዚሁ ካርድ ይጠቀሙ።</fo:block>
        <fo:block space-before=".15in" xml:lang="am">የተጨማሪ ምግብ እርዳታዎችን ከሶስት ወራት በላይ ለሆነ ግዜ ለማግኘት ከፈለጉ በሳምንት ቢያንስ ለ20 ሰዓታት ያክል ሥራ መስራት አለብዎት ወይም ተቀባይነት ባገኘ ሥራ ወይም በማኅበራዊ ዋስትና የገንዘብ ድጋፍ ሲያገኙ በሚከናወን የሥራ እንቅስቃሴ ላይ ተሳታፊ የመሆን ግዴታ አለብዎት። በአዲሱ ሕግ መሰረት ሥራ የማይሰሩ ከሆኑ ወይም በሥራ እንቅስቃሴ ውስጥ በመሳተፍ ላይ ካልሆኑ የሚያገኙት የገንዘብ እርዳታ በሶስት ወራት ብቻ የተገደበ ይሆናል።</fo:block>
        <fo:block space-before=".15in" xml:lang="am">በፌደራል ህግ ላይ እንደተገለጸው ሥራ በመስራት ላይ ካልሆኑ በሶስት ዓመት ግዜ ውስጥ፤ ማለትም ከጃንዋሪ 1, 2016 እስከ ዲሴምበር 31, 2018 ድረስ ባለው ግዜ እነዚህን እርዳታዎች ማግኘት የሚችሉት ለሶስት ወራት ያክል ብቻ ይሆናል።</fo:block>
        <fo:block space-before=".15in" xml:lang="am">ተጨማሪ መረጃዎችን ለማግኘት እባክዎ የተሰጠዎትን ወይም የተላከልዎትን የተጨማሪ ምግብ እርዳታ የሥራ መስፈርቶች አጭር መመሪያ ይመልከቱ። በሳምንት ቢያንስ ለ20 ሰዓታት ያክል ሥራ በመስራት ላይ እንደሆኑ ወይም ተቀባይነት ባለው የሥራ እንቅስቃሴ ውስጥ በመሳተፍ ላይ እንደሆኑ ማረጋገጫ ወይም ማስረጃ ማቅረብ አለብዎት። በግል ሥራዎ ላይ ተሰማርተው የሚሰሩ ከሆኑ ደግሞ በሳምንት ቢያንስ ለ30 ሰዓታት ያክል ሥራ የመስራት ግዴታ አለብዎት። የሥራ ሰዓትዎ ከ20 ሰዓታት በታች ሆኖ ከቀነሰ ክስተቱን ለጉዳይ ሥራ አስኪያጅዎ ማሳወቅ አለብዎት። ማንኛውም ጥያቄ ካለዎት እባክዎ ጥያቄዎን ለጉዳይ ሥራ አስኪያጅዎ ያቅርቡ። ይህንን የሥራ መስፈርት በተመለከተ ያሉት ደንቦችና መመሪያዎች በፌደራል ሕግ ቁጥር 7CFR273 ላይ በዝርዝር ተገልጸዋል።</fo:block>
        <fo:block space-before=".15in" xml:lang="am">ምክንያታዊ ማሟያን እና ፍትሐዊ የምርመራ ሂደትን የሚመለከቱ መረጃዎችን በቀጣዩ ገጽ ላይ ያገኛሉ።</fo:block>
    </xsl:template>

    <xsl:template name="createBody-ar">
        <xsl:param name="thisdate" required="yes"/>
        <xsl:param name="thisbeginamount" required="yes"/>
        <xsl:param name="thisendamount" required="yes"/>
        <xsl:param name="thisbegin" required="yes"/>
        <xsl:param name="thisend" required="yes"/>
        <xsl:param name="thislang" required="yes"/>
        <fo:block-container xml:lang="ar" writing-mode="rl-tb">
            <fo:block space-before=".15in" xml:lang="ar">لقد تم قبول طلبك المُقدم بتاريخ <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisdate, $thislang, '')"/></fo:inline> للحصول على مستحقات من الغذاء التكميلي.</fo:block>
            <fo:block space-before=".15in" xml:lang="ar">سوف تتلقى مبلغ $ _______ في شهر __________. وبعد ذلك، سوف تحصل على مبلغ $ _____________ وذلك بصفة شــــــــــــهرية حتى تاريخ _______.  وعندها يتوجب عليك إعادة تقديم طلب جديد في ذلك الحين .</fo:block>
            <fo:block space-before=".15in" xml:lang="ar">سوف يتم إرسال "بطاقة الإســتقلالية" (Independence Card) إليك عن طريق البريد ، إلا إذا كنا قد أصدرنا بطاقة لك أثناء حضورك إلى المكتب . استخدم "بطاقة الإســـتقلالية" للحصول على مستحقات الغذاء التكميلي عند قيامك بالتسوق .</fo:block>
            <fo:block space-before=".15in" xml:lang="ar">يتوجب عليك العمل  بوظيفة ما أو المشاركة في أحد "أنشطة القوى العاملة"  المعتمدة لمدة 20 ساعة على الأقل في الأسبوع إذا ما أردت الإستمرار في الحصول على مستحقات الغذاء التكميلي لمدة تفوق ثلاثة أشهر. هذا هو أحد الشــروط الجديدة  والتي تُحــد مستحقاتك لمدة أقصاها ثلاثة أشهر في حالة ما إذا كنت لا تعمل بوظيفة أو لا تشارك في أحــد "أنشطة القوى العاملة" .</fo:block>
            <fo:block space-before=".15in" xml:lang="ar">ينص القانون الإتحادي على أنك إذا كنت لا تعمل في وظيفة ، فسيكون فقط بإمكانك الحصول على المستحقات لمدة ثلاثة أشهر فقط خلال الفترة البالغ مدتها ثلاثة أشهر ، ويسرى هذا القانون ابتداء من الأول من كانون الثاني (يناير) 2016 إلى 31 كانون الأول (ديسمبر) 2018.</fo:block>
            <fo:block space-before=".15in" xml:lang="ar">للحصول على مزيد من المعلومات، يرجى الرجوع إلى كتيب شروط "أنشطة القوى العاملة" الخاص بالغذاء التكميلي الذي تم إعطاؤه أو أرساله إليك . ينبغي عليك أن تقدم  إثبات ودليل على أنك تعمل لمدة  20 ساعة في الأسبوع  على الأقل أو دليل على أنك مُسجل في أحد "أنشطة القوى العاملة" المُعتمدة . أما إذا كنت تعمل لحسابك الشخصي ، فينبغي عليك أن تعمل لمدة  30 ساعة في الأسبوع على الأقل . وإذا ما نقص عدد ساعات عملك الإسبوعية إلى أقل من 20 ساعة ، فعليك إذن أن تبلغ عن هذا الأمر إلى المدير المشرف على ملفك . إذا كانت لديك أية أسئلة ، الرجاء سؤال المدير المشرف على ملفك. يمكن الإطلاع على الأحكام الخاصة بمتطلب العمل المفصلة و المتعلقة بهذا القانون من الأحكام الإتحادية في 7CFR273.</fo:block>
            <fo:block space-before=".15in" xml:lang="ar">يمكن الإطلاع على المعلومات الخاصة بالمعاملة المعقولة وجلسات الاستماع العادلة {في حالات التظلم} فى الصفحة التالية.</fo:block>
        </fo:block-container>
    </xsl:template>
    
    <xsl:template name="createBody-en">
        <xsl:param name="thisdate" required="yes"/>
        <xsl:param name="thisbeginamount" required="yes"/>
        <xsl:param name="thisendamount" required="yes"/>
        <xsl:param name="thisbegin" required="yes"/>
        <xsl:param name="thisend" required="yes"/>
        <xsl:param name="thislang" required="yes"/>
        <fo:block space-before=".15in">Your application for Food Supplement benefits dated <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisdate, $thislang, '')"/></fo:inline> was approved.  You will receive <fo:inline font-weight="bold" text-decoration="underline"><fo:inline margin-right="8px">&#160;</fo:inline>$<xsl:value-of select="$thisbeginamount"/><fo:inline margin-left="8px">&#160;</fo:inline></fo:inline> for the month of <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisbegin, $thislang, 'YearMonth')"/></fo:inline>.  After that you will receive <fo:inline font-weight="bold" text-decoration="underline"><fo:inline margin-right="8px">&#160;</fo:inline>$<xsl:value-of select="$thisendamount"/><fo:inline margin-left="8px">&#160;</fo:inline></fo:inline> per month until <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisend, $thislang, 'YearMonth')"/></fo:inline>. You must reapply at that time.</fo:block>
        <fo:block space-before=".15in">Your Independence Card will be sent to you in the mail, unless we issued you one when you were in our office.  Use your Independence Card to access your Food Supplement benefits when you shop.</fo:block>
        <fo:block space-before=".15in">You must work or participate in an approved work or workfare activity for at least 20 hours each week if you want to receive Food Supplement benefits for more than three months.  This is a new rule that limits your benefits to three months if you are not working or participating in a work activity.</fo:block>
        <fo:block space-before=".15in">Federal law states that if you are not working, you can receive only three months of benefits within the three-year period, January 1, 2016 through December 31, 2018.</fo:block>
        <fo:block space-before=".15in">For additional information, please refer to the Food Supplement Work Requirements handout you were given or sent. You must provide proof that you are working at least 20 hours per week or are enrolled in an approved work activity.  If you are self-employed, then you must work at least 30 hours per week.  If your work hours decrease to less than 20 hours, you must report that to your case manager.   If you have questions, please ask your case manager. The rules about this work requirement are spelled out in the Code of Federal Regulations at 7CFR273.</fo:block>
        <fo:block space-before=".15in">Information about reasonable accommodation and fair hearings is on the next page.</fo:block>
    </xsl:template>

    <xsl:template name="createBody-es">
        <xsl:param name="thisdate" required="yes"/>
        <xsl:param name="thisbeginamount" required="yes"/>
        <xsl:param name="thisendamount" required="yes"/>
        <xsl:param name="thisbegin" required="yes"/>
        <xsl:param name="thisend" required="yes"/>
        <xsl:param name="thislang" required="yes"/>
        <fo:block space-before=".15in">Su solicitud de beneficios de Suplementos Alimenticios con fecha de <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisdate, $thislang, '')"/></fo:inline> fue aprobada. Usted recibirá <fo:inline font-weight="bold" text-decoration="underline"><fo:inline margin-right="8px">&#160;</fo:inline>$<xsl:value-of select="$thisbeginamount"/><fo:inline margin-left="8px">&#160;</fo:inline></fo:inline> el mes de <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisbegin, $thislang, 'YearMonth')"/></fo:inline>. Después de esa fecha usted recibirá <fo:inline font-weight="bold" text-decoration="underline"><fo:inline margin-right="8px">&#160;</fo:inline>$<xsl:value-of select="$thisendamount"/><fo:inline margin-left="8px">&#160;</fo:inline></fo:inline> mensuales hasta <fo:inline font-weight="bold" text-decoration="underline"><xsl:value-of select="an:createPublicationDate($thisend, $thislang, 'YearMonth')"/></fo:inline>. En ese momento tiene que volver a solicitar.</fo:block>
        <fo:block space-before=".15in">Se le enviará la tarjeta Independence Card por correo, a menos que le hayamos emitido una tarjeta cuando usted estuvo en nuestra oficina. Use su tarjeta Independence Card para tener acceso a sus beneficios de Suplementos Alimenticios cuando haga sus compras.</fo:block>
        <fo:block space-before=".15in">Usted tiene que trabajar o participar en una actividad laboral o de asistencia comunitaria aprobada por lo menos 20 horas semanales si desea recibir beneficios de Suplementos Alimenticios durante más de tres meses. Se trata de una nueva norma que limita sus beneficios a tres meses si no está trabajando o participando en una actividad laboral.</fo:block>
        <fo:block space-before=".15in">Las leyes federales disponen que, si usted no está trabajando, sólo puede recibir tres meses de beneficios en un período de tres años, desde el 1 de enero de 2016 hasta el 31 de diciembre de 2018.</fo:block>
        <fo:block space-before=".15in">Para obtener información adicional, por favor consulte el folleto de Requisitos de Empleo de Suplementos Alimenticios que le entregamos o enviamos. Usted tiene que presentar pruebas de que está trabajando por lo menos 20 horas semanales o está inscrito en una actividad laboral aprobada. Si trabaja por cuenta propia, tiene que trabajar por lo menos 30 horas semanales. Si sus horas de empleo disminuyen a menos de 20 horas, usted tiene que notificárselo al administrador de su caso. Si tiene alguna pregunta, por favor hable con el administrador de su caso. Las normas sobre este requisito de empleo se encuentran en el Código de Reglamentos Federales en 7 CFR 273.</fo:block>
        <fo:block space-before=".15in">En la página siguiente encontrará información sobre las adaptaciones razonables y audiencias justas.</fo:block>
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