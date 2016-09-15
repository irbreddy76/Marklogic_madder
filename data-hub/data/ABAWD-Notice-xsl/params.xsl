<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:f="foo" xmlns:b="bar"
      version="2.0">
    <xsl:param name="f:pName"/>
    <xsl:param name="b:bName"/>
    <xsl:param name="cName"/>
    <xsl:param name="greeting" select="'Hi there '"/>
    <xsl:template match="/">
       <output>
         <xsl:copy-of select="node"/>
         <greeting><xsl:value-of select="$greeting"/></greeting>
         <param><xsl:value-of select="$f:pName"/></param>
         <param><xsl:value-of select="$b:bName"/></param>
         <param><xsl:value-of select="$cName"/></param>
       </output>
    </xsl:template>
  </xsl:stylesheet>