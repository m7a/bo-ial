<?xml version="1.0" encoding="UTF-8"?>
<!--
	https://stackoverflow.com/questions/29298507/xmlstarlet-xinclude-xslt
	xmlstarlet tr __xinclude remove_containers.xml.xsl index.xhtml > out.xhtml
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xmlns:masysma="https://masysma.net/32/ial.xhtml"
			xmlns="http://www.w3.org/1999/xhtml">
	<!-- unclear if cdata-section-elements really improves the situation? -->
	<xsl:output method="xml" cdata-section-elements="style script"/>
	<xsl:template match="masysma:*">
		<xsl:apply-templates select="*"/>
	</xsl:template>
	<!-- https://en.wikipedia.org/wiki/Identity_transform -->
	<xsl:template match="@*|node()">
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
	</xsl:template>
</xsl:transform>
