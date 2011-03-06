<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:c="http://schema.cross-lfs.org/book"
  version="1.0">

  <!-- Declare our output type -->
  <xsl:output method="xml"
    indent="no"
    omit-xml-declaration="no"
    encoding="utf-8"
    doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
    doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" />

  <xsl:param name="clfs.arch" select="''" />
  <xsl:param name="clfs.multilib" select="''" />

  <!-- Apply the other templates -->
  <xsl:template match="@*|node()" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Build the package xml -->
  <xsl:template match="//c:package">
    <xsl:param name="id" select="@id" />
    <xsl:param name="multibuild" select="@c:multibuild" />
    <xsl:call-template name="package-iterator">
      <xsl:with-param name="id" select="$id" />
      <xsl:with-param name="multibuild" select="$multibuild" />
      <xsl:with-param name="bits" select="$clfs.multilib" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="package-iterator">
    <xsl:param name="id" /> <!-- Base ID of the resulting package -->
    <xsl:param name="multibuild" /> <!-- Do we need to install for each bitsize? -->
    <xsl:param name="bits" /> <!-- Which bit sizes to create a package for -->
    <xsl:choose>
      <xsl:when test="$multibuild = 'true'">
        <xsl:variable name="currentbits" select="substring-before(concat($bits, ','), ',')" />
        <xsl:variable name="remainingbits" select="substring-after($bits, ',')" />
        <xsl:call-template name="package-stub">
          <xsl:with-param name="id" select="$id" />
          <xsl:with-param name="idsuffix">
            <xsl:if test="$remainingbits">
              <xsl:value-of select="concat('-', $currentbits)" />
            </xsl:if>
          </xsl:with-param>
          <xsl:with-param name="bits" select="substring-before(concat($bits, ','), ',')" />
        </xsl:call-template>
        <xsl:if test="$remainingbits">
          <xsl:text>

          </xsl:text>
          <xsl:call-template name="package-iterator">
            <xsl:with-param name="id" select="$id" />
            <xsl:with-param name="multibuild" select="$multibuild" />
            <xsl:with-param name="bits" select="$remainingbits" />
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="package-stub">
          <xsl:with-param name="id" select="$id" />
          <xsl:with-param name="idsuffix" />
          <xsl:with-param name="bits" select="substring-before(concat($bits, ','), ',')" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="package-stub">
    <xsl:param name="id" /> <!-- Base ID of the resulting package -->
    <xsl:param name="idsuffix" /> <!-- Suffix to attach to the end of the ID for this perticular instance -->
    <xsl:param name="bits" /> <!-- Which bit sizes to create a package for -->

    <xsl:for-each select="sect1">

      <xsl:copy>
        <xsl:attribute name="id">
          <xsl:value-of select="concat($id, $idsuffix)" />
        </xsl:attribute>
        <xsl:attribute name="role">
          <xsl:text>package</xsl:text>
        </xsl:attribute>
        <xsl:processing-instruction name="dbhtml">
          <xsl:text>filename=&quot;</xsl:text>
          <xsl:value-of select="concat($id, $idsuffix)" />
          <xsl:text>.html&quot;</xsl:text>
        </xsl:processing-instruction>
        <xsl:choose>
          <xsl:when test="$bits = '32'">
            <xsl:apply-templates select="@*|node()" mode="filter-bits-32" />
          </xsl:when>
          <xsl:when test="$bits = 'n32'">
            <xsl:apply-templates select="@*|node()" mode="filter-bits-n32" />
          </xsl:when>
          <xsl:when test="$bits = '64'">
            <xsl:apply-templates select="@*|node()" mode="filter-bits-64" />
          </xsl:when>
        </xsl:choose>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <!-- Apply the profile to the 32bit package -->

  <xsl:template match="@*|node()" mode="filter-bits-32">
    <xsl:variable name="ismultilib">
      <xsl:choose>
        <xsl:when test="contains($clfs.multilib, ',')">
          <xsl:text>true</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>false</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="(string-length(@c:arch) = 0) or contains(concat(',',@c:arch,','), concat(',', $clfs.arch, ','))">
      <xsl:if test="(string-length(@c:multilib) = 0) or contains(concat(',',@c:multilib,','), concat(',', $ismultilib, ','))">
        <xsl:if test="(string-length(@c:bits) = 0) or contains(concat(',',@c:bits,','), ',32,')">
          <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="filter-bits-32" />
          </xsl:copy>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@c:arch" mode="filter-bits-32" />
  <xsl:template match="@c:bits" mode="filter-bits-32" />
  <xsl:template match="@c:multilib" mode="filter-bits-32" />

  <!-- Apply the profile to the n32 package -->

  <xsl:template match="@*|node()" mode="filter-bits-n32">
    <xsl:variable name="ismultilib">
      <xsl:choose>
        <xsl:when test="contains($clfs.multilib, ',')">
          <xsl:text>true</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>false</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="(string-length(@c:arch) = 0) or contains(concat(',',@c:arch,','), concat(',', $clfs.arch, ','))">
      <xsl:if test="(string-length(@c:multilib) = 0) or contains(concat(',',@c:multilib,','), concat(',', $ismultilib, ','))">
        <xsl:if test="(string-length(@c:bits) = 0) or contains(concat(',',@c:bits,','), ',n32,')">
          <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="filter-bits-n32" />
          </xsl:copy>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@c:arch" mode="filter-bits-n32" />
  <xsl:template match="@c:bits" mode="filter-bits-n32" />
  <xsl:template match="@c:multilib" mode="filter-bits-n32" />

  <!-- Apply the profile to the 64bit package -->

  <xsl:template match="@*|node()" mode="filter-bits-64">
    <xsl:variable name="ismultilib">
      <xsl:choose>
        <xsl:when test="contains($clfs.multilib, ',')">
          <xsl:text>true</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>false</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="(string-length(@c:arch) = 0) or contains(concat(',',@c:arch,','), concat(',', $clfs.arch, ','))">
      <xsl:if test="(string-length(@c:multilib) = 0) or contains(concat(',',@c:multilib,','), concat(',', $ismultilib, ','))">
        <xsl:if test="(string-length(@c:bits) = 0) or contains(concat(',',@c:bits,','), ',64,')">
          <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="filter-bits-64" />
          </xsl:copy>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@c:arch" mode="filter-bits-64" />
  <xsl:template match="@c:bits" mode="filter-bits-64" />
  <xsl:template match="@c:multilib" mode="filter-bits-64" />

  <!-- Apply the profile filter to the entire document -->
  <xsl:template match="//*[@c:arch]|//*[@c:multilib]">
    <xsl:variable name="ismultilib">
      <xsl:choose>
        <xsl:when test="contains($clfs.multilib, ',')">
          <xsl:text>true</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>false</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="(string-length(@c:arch) = 0) or contains(concat(',',@c:arch,','), concat(',', $clfs.arch, ','))">
      <xsl:if test="(string-length(@c:multilib) = 0) or contains(concat(',',@c:multilib,','), concat(',', $ismultilib, ','))">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Remove the profileing attributes for the remaining objects -->
  <xsl:template match="@c:arch" />
  <xsl:template match="@c:bits" />
  <xsl:template match="@c:multilib" />

</xsl:stylesheet>