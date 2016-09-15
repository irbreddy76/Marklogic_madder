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
                <an:clientLanguagePreferenceCode>ar</an:clientLanguagePreferenceCode>
                <an:recipient-name>Jane Doe</an:recipient-name>
                <an:recipient-mailing-address1>45 Hopping Frog Lane, Apt. 2</an:recipient-mailing-address1>
                <an:recipient-mailing-address2>Avenue, MD 20222</an:recipient-mailing-address2>
            </an:notification-core>
            <an:notice xsi:type="WarningNoticeMonth-1">
                <an:nil/>
            </an:notice>
        </an:abawd-notices>
    </xsl:variable>-->

   <xsl:output method="xml" indent="yes"/>
    
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
                    <fo:block xml:lang="am"><fo:inline font-style="italic">የማስጠንቀቂያ ማሳሰቢያ</fo:inline></fo:block>
                </xsl:when>
                <!-- Arabic 'ar' -->
                <xsl:when test="$thislang eq 'ar' ">
                    <fo:block-container xml:lang="ar" writing-mode="rl-tb">
                        <fo:block xml:lang="ar">إشعار إنذار</fo:block>
                        <fo:block xml:lang="ar">بخصوص المستحقات من الغذاء التكميلي</fo:block>
                    </fo:block-container>
                </xsl:when>
                <!-- Spanish 'es' -->
                <xsl:when test="$thislang eq 'es' ">
                    <fo:block><fo:inline font-style="italic">AVISO SOBRE BENEFICIOS DE SUPLEMENTOS </fo:inline></fo:block>
                    <fo:block><fo:inline font-style="italic">ALIMENTARIOS</fo:inline></fo:block>
                </xsl:when>
                <xsl:otherwise> <!-- English 'en' is default -->
                    <fo:block><fo:inline font-style="italic">WARNING NOTICE</fo:inline></fo:block>
                    <fo:block><fo:inline font-style="italic">FOR FOOD SUPPLEMENT BENEFITS</fo:inline></fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createBody">
        <xsl:variable name="thislang" select="$notice-details//an:clientLanguagePreferenceCode/normalize-space()"/>
        <fo:block space-before=".25in" break-after="page">
            <xsl:choose>
                <xsl:when test="$thislang eq 'am' ">
                    <xsl:call-template name="createBody-am"/>                    
                </xsl:when>
                <xsl:when test="$thislang eq 'ar' ">
                    <xsl:call-template name="createBody-ar"/>                    
                </xsl:when>
                <xsl:when test="$thislang eq 'es' ">
                    <xsl:call-template name="createBody-es"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="createBody-en"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="createBody-am">
        <fo:block space-before=".15in">ይህ ማሳሰቢያ እንዲሰጥዎት የተደረገበት ምክንያት በተጨማሪ የምግብ እርዳታ ፕሮግራም ተጠቃሚ ለመሆን የተቀመጡትን የሥራ መስፈርቶች ማሟላት እንዳለብዎት ለማሳወቅ ነው። የኛ ውሳኔ የተሳሳተ ነው ብለው ካመኑ ጉዳዩን ያሳውቁን። በፌደራል ህግ መሰረት ከዚህ በታች በዝርዝር የተገለጹት ሁኔታዎች እርስዎን የሚመለከቱ ካልሆኑ በስተቀር፤ ከጃንዋሪ 1, 2016 እስከ ዲሴምበር 31, 2018 ድረስ እነዚህን እርዳታዎች የሚያገኙት ለሶስት ወራት ብቻ እንዲሆን የተቀመጠው ገደብ ተፈጻሚ ይሆንብዎታል። እነዚህ ሁኔታዎችም፦</fo:block>
        <fo:list-block space-before=".15in" space-after=".15in">
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>እድሜዎ ከ18 ዓመት በታች ወይም ከ49 ዓመት በላይ ከሆነ፣</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>በአካላዊ ወይም በአእምሮአዊ ሁኔታዎ ሥራ ለመስራት ብቁ ካልሆኑ (በሕክምና ባለሙያ ከተረጋገጠ)፣</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>በአደንዛዥ ዕጽ ወይም በአልኮል ሱሰኝነት ማገገሚያ ፕሮግራም ውስጥ በመሳተፍ ላይ ከሆኑ፣</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>ግዜያዊ የገንዘብ እርዳታ (TCA) ወይም የሥራ አጥነት መድን ዋስትና እርዳታዎችን በመቀበል ላይ ከሆኑ፣</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>የሥራ አጥነት መድን ዋስትና እንዲሰጥዎት ማመልከቻ ካቀረቡ፣</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>በእርስዎ የተጨማሪ ምግብ እርዳታ ጉዳይ ስር ያለ ዕድሜው ከ18 ዓመት በታች የሆነ ህጻን ልጅን በመንከባከብ ላይ ከሆኑ፣</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>ነፍሰ ጡር ከሆኑ፣</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>በሳምንት ቢያንስ ለ20 ሰዓታት ያክል ክፍያ የሚያገኙበትን ሥራ የሚሰሩ ከሆኑ (በግል ሥራዎ ላይ ከተሰማሩ ቢያንስ ለ30 ሰዓታት ያክል ሥራ በመስራት ላይ ከሆኑ)</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>ከግዜዎ ቢያንስ ከፊሉን በት/ቤት፣ በስልጠና ተቋም ወይም በከፍተኛ የትምህርት ተቋም ውስጥ በትምህርት ላይ የሚያሳልፉ ከሆኑ</fo:block>
                </fo:list-item-body>
            </fo:list-item>
        </fo:list-block>
        <fo:block space-before=".15in">ከላይ ከተጠቀሱት ሁኔታዎች አንዱም የማይመለከትዎ ከሆኑየተጨማሪ ምግብ እርዳታዎችን ማግኘትዎን ለመቀጠል በሳምንት ቢያንስ ለ20 ሰዓታት ያክል ክፍያ የሚያገኙበትን ሥራ መስራት አለብዎት ወይም ወይም ተቀባይነት ባለው የሥራ እንቅስቃሴ ውስጥ መሳተፍ አለብዎት። በግል ሥራዎ ላይ ከተሰማሩ በሳምንት ቢያንስ ለ30 ሰዓታት ያክል ሥራ መስራት</fo:block>
        <fo:block space-before=".15in">ማንኛውም ጥያቄ ካለዎት እባክዎ ጥያቄዎን ለጉዳይ ሥራ አስኪያጅዎ ያቅርቡ። ይህንን የሥራ መስፈርት በተመለከተ ያሉት ደንቦችና መመሪያዎች በፌደራል ሕግ ቁጥር 7CFR273 ላይ በዝርዝር ተገልጸዋል። ምክንያታዊ ማሟያን እና ፍትሐዊ የምርመራ ሂደትን የሚመለከቱ መረጃዎችን በቀጣዩ ገጽ ላይ ያገኛሉ።</fo:block>
    </xsl:template>

    <xsl:template name="createBody-ar">
        <fo:block-container xml:lang="ar" writing-mode="rl-tb">
            <fo:block space-before=".15in" xml:lang="ar">أنت تتلقى هذا الإشعار لأنك تخضع لشروط العمل الخاصة بملفك للحصول على مستحقاتك من برنامج الغذاء التكميلي . إذا كنت تعــــتقد أن قرارنا غير صائب ، يتوجب عليك إبلاغنا بذلك . يقصر القانون الإتحادي مدة حصولك على المستحقات لمدة لا تزيد عن ثلاثة (3) أشهر، إلا إذا كنت:</fo:block>
            <fo:list-block space-before=".15in" space-after=".15in">
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">دون سن الثامنة عشر (18) أو فوق سن 49 عاما</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="">غير قادر على العمل من الناحية الجسدية أو العقلية (بموجب شهادة من مهني طبي محترف)</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">تشارك في برنامج علاج الإدمان  من المخدرات أو الكحول</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">	تتلقى مساعدات نقدية مؤقتة (TCA)، أو مستحقات التأمين على البطالة</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">تتقدم بطلب للحصول على تأمين البطالة</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">تقوم برعاية طفل دون سن 18 يكون مشمولا في ملفك الخاص بالغذاء التكميلي</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">حاملا</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">تعمل لقاء أجر لمدة 20 ساعة في الأسبوع على الأقل ، أو  (30 ساعة في الأسبوع إذا كنت تعمل لحسابك الخاص)</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
                <fo:list-item space-after=".15in">
                    <fo:list-item-label start-indent="1em">
                        <fo:block>
                            <fo:inline>&#x2022;</fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="1.75em">
                        <fo:block xml:lang="ar">مسجل في مدرسة أو برنامج تدريبي أو مؤســــسة تعليم عالي وتداوم على الدراسة بدوام بنصف الوقت على الأقل</fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </fo:list-block>
            <fo:block space-before=".15in" xml:lang="ar">إذا لم تنطبق أي من هذه الشروط عليك ، يتوجب عليك العمل لقاء أجر لمدة 20 ساعة في الأسبوع على الأقل ، أو التسجيل في أحد "أنشطة القوى العاملة"  المعتمدة وذلك حتى تتمكن  من الإستمرار في الحصول على مستحقاتك من برنامج الغذاء التكميلي .  إذا ما كانت أيا من الشروط المذكورة أعلاه  تنطبق عليك ، الرجاء الاتصال بنا فوراً . أما إذا لم تستوفي أيا من الشروط ، فيمكنك تلقي المستحقات مرة أخرى إذا ما أعدت تقديم طلب وتثبت فيه أنك تعمل لمدة  20 ساعة في الأسبوع على الأقل ، أو إذا ما كان لديك دليل على أنك قد سجلت في أحد "أنشطة القوى العاملة" المُعتمد . أما إذا ما كُنت تعمل لحسابك الشخصي ، فعليك أن تعمل 30 ساعة في الأسبوع على الأقل .</fo:block>
            <fo:block space-before=".15in" xml:lang="ar">إذا كانت لديك أي أسئلة، الرجاء سؤال المدير المشرف على ملفك. يمكن الإطلاع على الأحكام الخاصة بمتطلب العمل هذا بالتفصيل في قانون الأحكام الإتحادية في 7CFR273. يمكن الإطلاع على المعلومات الخاصة بالمعاملة المعقولة وجلسات الاستماع العادلة على الصفحة التالية.</fo:block>
        </fo:block-container>
    </xsl:template>
    
    <xsl:template name="createBody-en">
        <fo:block space-before=".15in">You are receiving this notice because you are subject to work requirements for your Food Supplement Program case.  If you think our decision is wrong, you need to let us know.   Federal law limits your benefits to three months between January 1, 2016 and December 31, 2018 unless you are:</fo:block>
        <fo:list-block space-before=".15in" space-after=".15in">
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Under 18 years old or older than 49 years old</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Are physically or mentally unfit for work (according to a medical professional)</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Attending a drug or alcohol treatment program</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Receiving Temporary Cash Assistance (TCA) or Unemployment Insurance benefits</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Applying for Unemployment Insurance</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Caring for a child under age 18 who is in your Food Supplement case</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Pregnant</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Working for pay for at least 20 hours per week (30 hours per week if you are self-employed)</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Enrolled at least half-time in school, training or an institution of higher learning</fo:block>
                </fo:list-item-body>
            </fo:list-item>
        </fo:list-block>
        <fo:block space-before=".15in">If none of the above situations applies to you, then you must work for pay for at least 20 hours per week or enroll in an approved work activity in order to continue your Food Supplement benefits. If you are self-employed, you must work for at least 30 hours per week.</fo:block>
        <fo:block space-before=".15in">If you have questions, please ask your case manager. The rules about this work requirement are spelled out in the Code of Federal Regulations at 7CFR273.   Reasonable accommodation and fair hearing information are printed on the next page.</fo:block>
    </xsl:template>

    <xsl:template name="createBody-es">
        <fo:block space-before=".15in">Usted está recibiendo este aviso porque usted está sujeto a los requisitos de empleo de su caso del Programa de Suplementos Alimenticios. Si usted piensa que nuestra decisión es incorrecta, usted tiene que notificárnoslo. Las leyes federales limitan sus beneficios a tres meses entre el 1 de enero de 2016 y el 31 de diciembre de 2018, a menos que usted:</fo:block>
        <fo:list-block space-before=".15in" space-after=".15in">
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Sea menor de 18 años de edad o mayor de 49 años de edad</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>No esté física o mentalmente apto para trabajar (de acuerdo con un profesional médico)</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Esté asistiendo a un programa de tratamiento de drogas o alcohol</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Esté recibiendo Asistencia Temporal en Efectivo (TCA) o beneficios del Seguro de Desempleo</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Esté solicitando Seguro de Desempleo</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Esté cuidando a un niño menor de 18 años de edad que se encuentre bajo su caso de Suplementos Alimentarios</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Esté embarazada</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Esté trabajando con remuneración durante por lo menos 20 horas semanales (30 horas semanales si trabaja por cuenta propia)</fo:block>
                </fo:list-item-body>
            </fo:list-item>
            <fo:list-item space-after=".15in">
                <fo:list-item-label start-indent="1em">
                    <fo:block>
                        <fo:inline>&#x2022;</fo:inline>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="1.75em">
                    <fo:block>Esté inscrito en una escuela, capacitación o institución de educación superior por lo menos a tiempo parcial</fo:block>
                </fo:list-item-body>
            </fo:list-item>
        </fo:list-block>
        <fo:block space-before=".15in">Si ninguna de las situaciones mencionadas arriba aplica a su caso, usted tiene que trabajar por lo menos 20 horas semanales o inscribirse en una actividad laboral aprobada para poder seguir recibiendo los beneficios de Suplementos Alimenticios. Si trabaja por cuenta propia, usted tiene que trabajar por lo menos 30 horas semanales.</fo:block>
        <fo:block space-before=".15in">Si tiene alguna pregunta, por favor hable con el administrador de su caso. Las normas sobre este requisito de empleo se encuentran en el Código de Reglamentos Federales en 7CFR 273. En la página siguiente encontrará información sobre las adaptaciones razonables y audiencias justas.</fo:block>
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