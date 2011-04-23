<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

    <xsl:variable name="currentbits" select="substring-before(concat($bits, ','), ',')" />
    <xsl:variable name="remainingbits" select="substring-after($bits, ',')" />

    <xsl:if test="not(boolean($remainingbits) and $multibuild = 'false')">
      <xsl:call-template name="package-stub">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="idsuffix">
          <xsl:if test="$remainingbits">
            <xsl:value-of select="concat('-', $currentbits)" />
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="bits" select="substring-before(concat($bits, ','), ',')" />
        <xsl:with-param name="multibuild" select="$multibuild" />
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="$remainingbits">
      <xsl:text>

      </xsl:text>
      <xsl:call-template name="package-iterator">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="multibuild" select="$multibuild" />
        <xsl:with-param name="bits" select="$remainingbits" />
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <xsl:template name="package-stub">
    <xsl:param name="id" /> <!-- Base ID of the resulting package -->
    <xsl:param name="idsuffix" /> <!-- Suffix to attach to the end of the ID for this perticular instance -->
    <xsl:param name="bits" /> <!-- Which bit sizes to create a package for -->
    <xsl:param name="multibuild" /> <!-- Are there multiple instances of this package? -->
    
    <!-- Translate the package into a sect1 -->
    <xsl:element name="sect1">
      
      <!-- Set the ID of the target Sect1 -->
      <xsl:attribute name="id">
        <xsl:value-of select="concat($id, $idsuffix)" />
      </xsl:attribute>  
      
      <!-- New Line -->
      <xsl:text>
</xsl:text>
      
      <!-- Set the Target Filename -->
      <xsl:processing-instruction name="dbhtml">
        <xsl:text>filename=&quot;</xsl:text>
        <xsl:value-of select="concat($id, $idsuffix)" />
        <xsl:text>.html&quot;</xsl:text>
      </xsl:processing-instruction>
      
      <!-- New Line x2 -->
      <xsl:text>

</xsl:text>
      
      <!-- Determine if the title is going to have a suffix or not -->
      <xsl:variable name="titlesuffix">
        <xsl:if test="contains($clfs.multilib, ',') and ($multibuild = 'true')">
          <xsl:choose>
            <xsl:when test="$bits = '32'">
              <xsl:text>32Bit</xsl:text>
            </xsl:when>
            <xsl:when test="$bits = 'n32'">
              <xsl:text>N32</xsl:text>
            </xsl:when>
            <xsl:when test="$bits = '64'">
              <xsl:text>64Bit</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
      </xsl:variable>
      
      <!-- title: Write out a new title tag -->
      <xsl:element name="title">
        <xsl:value-of select="c:title" />
        <xsl:text>-</xsl:text>
        <xsl:value-of select="c:version" />
        <xsl:if test="string-length($titlesuffix) > 0">
          <xsl:text> - </xsl:text>
          <xsl:value-of select="$titlesuffix"/>
        </xsl:if>
      </xsl:element><!-- title -->

      <!-- New Line x2 -->
      <xsl:text>

</xsl:text>

      <!-- indexterm: Add the Intex Entry for this package -->
      <xsl:element name="indexterm">
        <xsl:attribute name="zone">
          <xsl:value-of select="concat($id, $idsuffix)" />
        </xsl:attribute>
        <xsl:text>
  </xsl:text>
        <xsl:element name="primary">
          <xsl:attribute name="sortas">
            <xsl:text>a-</xsl:text>
            <xsl:value-of select="c:title" />
          </xsl:attribute>
          <xsl:value-of select="c:title" />
        </xsl:element>
        <xsl:if test="string-length($titlesuffix) > 0">
          <xsl:text>
  </xsl:text>
          <xsl:element name="secondary">
            <xsl:value-of select="$titlesuffix" />
          </xsl:element>
        </xsl:if>
        <xsl:text>
</xsl:text>
      </xsl:element><!-- indexterm -->
      
      <!-- New Line x2 -->
      <xsl:text>

</xsl:text>

      <!-- sect2[role="installation"]: Add the sect2 for the package header -->
      <xsl:element name="sect2">
        <xsl:attribute name="role">
          <xsl:text>installation</xsl:text>
        </xsl:attribute>
        <xsl:text>
  </xsl:text>
        <xsl:element name="title" />
        <xsl:text>

  </xsl:text>
        <xsl:element name="para">
          <xsl:choose>
            <xsl:when test="$bits = '32'">
              <xsl:apply-templates select="c:description/@*|c:description/node()" mode="filter-bits-32" />
            </xsl:when>
            <xsl:when test="$bits = 'n32'">
              <xsl:apply-templates select="c:description/@*|c:description/node()" mode="filter-bits-n32" />
            </xsl:when>
            <xsl:when test="$bits = '64'">
              <xsl:apply-templates select="c:description/@*|c:description/node()" mode="filter-bits-64" />
            </xsl:when>
          </xsl:choose>
        </xsl:element>
        <xsl:text>

</xsl:text>
      </xsl:element>

      <!-- New Line x2 -->
      <xsl:text>

</xsl:text>

      <!-- c:install -> sect2: For each c:install build a sect2 section -->
      <xsl:for-each select="c:install">
        <xsl:element name="sect2">
          <xsl:text>
  </xsl:text>
          <xsl:element name="title">
            <xsl:text>Installing</xsl:text>
          </xsl:element>
          <xsl:text>

</xsl:text>
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
          <xsl:text>
</xsl:text>
        </xsl:element>
      </xsl:for-each><!-- c:install -> sect2  -->

      <!-- New Line x2 -->
      <xsl:text>

</xsl:text>

    </xsl:element><!-- Sect1 -->

  </xsl:template><!-- package-stub -->

  <!-- Apply the profile to the 32bit package -->
  
  <xsl:template match="c:para" mode="filter-bits-32">
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
          <xsl:element name="para">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="c:install/c:command" mode="filter-bits-32">
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
          <xsl:element name="userinput">
            <xsl:if test="@c:nodump = 'true'">
              <xsl:attribute name="role">
                <xsl:text>nodump</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="screen">
              <xsl:apply-templates select="@*|node()" mode="filter-bits-32" />
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:literal" mode="filter-bits-32">
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
          <xsl:element name="literal">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:replaceable" mode="filter-bits-32">
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
          <xsl:element name="replaceable">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:application" mode="filter-bits-32">
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
          <xsl:element name="application">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:dirname" mode="filter-bits-32">
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
          <xsl:element name="filename">
            <xsl:attribute name="class">
              <xsl:text>directory</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:filename" mode="filter-bits-32">
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
          <xsl:element name="filename">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:command" mode="filter-bits-32">
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
          <xsl:element name="command">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@c:arch" mode="filter-bits-32" />
  <xsl:template match="@c:bits" mode="filter-bits-32" />
  <xsl:template match="@c:multilib" mode="filter-bits-32" />

  <!-- Apply the profile to the n32 package -->
  
  <xsl:template match="c:para" mode="filter-bits-n32">
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
          <xsl:element name="para">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="c:install/c:command" mode="filter-bits-n32">
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
          <xsl:element name="userinput">
            <xsl:if test="@c:nodump = 'true'">
              <xsl:attribute name="role">
                <xsl:text>nodump</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="screen">
              <xsl:apply-templates select="@*|node()" mode="filter-bits-n32" />
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:literal" mode="filter-bits-n32">
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
          <xsl:element name="literal">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:replaceable" mode="filter-bits-n32">
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
          <xsl:element name="replaceable">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:application" mode="filter-bits-n32">
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
          <xsl:element name="application">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:dirname" mode="filter-bits-n32">
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
          <xsl:element name="filename">
            <xsl:attribute name="class">
              <xsl:text>directory</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:filename" mode="filter-bits-n32">
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
          <xsl:element name="filename">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:command" mode="filter-bits-n32">
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
          <xsl:element name="command">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@c:arch" mode="filter-bits-n32" />
  <xsl:template match="@c:bits" mode="filter-bits-n32" />
  <xsl:template match="@c:multilib" mode="filter-bits-n32" />

  <!-- Apply the profile to the 64bit package -->
  
  <xsl:template match="c:para" mode="filter-bits-64">
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
          <xsl:element name="para">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="c:install/c:command" mode="filter-bits-64">
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
          <xsl:element name="userinput">
            <xsl:if test="@c:nodump = 'true'">
              <xsl:attribute name="role">
                <xsl:text>nodump</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="screen">
              <xsl:apply-templates select="@*|node()" mode="filter-bits-64" />
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:literal" mode="filter-bits-64">
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
          <xsl:element name="literal">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:replaceable" mode="filter-bits-64">
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
          <xsl:element name="replaceable">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:application" mode="filter-bits-64">
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
          <xsl:element name="application">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:dirname" mode="filter-bits-64">
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
          <xsl:element name="filename">
            <xsl:attribute name="class">
              <xsl:text>directory</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:filename" mode="filter-bits-64">
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
          <xsl:element name="filename">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:command" mode="filter-bits-64">
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
          <xsl:element name="command">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
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