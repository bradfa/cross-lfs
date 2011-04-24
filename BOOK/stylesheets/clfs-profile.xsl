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
        <xsl:with-param name="lastinseries">
          <xsl:choose>
            <xsl:when test="$remainingbits">
              <xsl:text>false</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>true</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
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
    <xsl:param name="lastinseries" /> <!-- Is this the past package in the multilib series? -->
    
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
        <xsl:if test="(string-length($titlesuffix) &gt; 0 and $lastinseries = 'false') or c:variant">
          <xsl:text>
  </xsl:text>
          <xsl:element name="secondary">
            <xsl:if test="c:variant">
              <xsl:value-of select="c:variant" />
            </xsl:if>
            <xsl:if test="string-length($titlesuffix) &gt; 0 and $lastinseries = 'false'">
              <xsl:if test="c:variant">
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:value-of select="$titlesuffix" />
            </xsl:if>
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
          <xsl:text>package</xsl:text>
        </xsl:attribute>
        <xsl:text>
  </xsl:text>
        <xsl:element name="title" />
        <xsl:text>

  </xsl:text>
        <xsl:element name="para">
          <xsl:choose>
            <xsl:when test="$bits = '32'">
              <xsl:apply-templates select="c:description/node()" mode="filter-bits-32" />
            </xsl:when>
            <xsl:when test="$bits = 'n32'">
              <xsl:apply-templates select="c:description/node()" mode="filter-bits-n32" />
            </xsl:when>
            <xsl:when test="$bits = '64'">
              <xsl:apply-templates select="c:description/node()" mode="filter-bits-64" />
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
            <xsl:attribute name="role">
              <xsl:text>installation</xsl:text>
            </xsl:attribute>
            <xsl:text>Installation of </xsl:text>
            <xsl:value-of select="../c:title" />
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

      <!-- c:config -> sect2: For each c:config build a sect2 section -->
      <xsl:for-each select="c:config">
        <xsl:element name="sect2">
          <xsl:attribute name="id">
            <xsl:value-of select="$id"/>
            <xsl:text>-conf</xsl:text>
          </xsl:attribute>
          <xsl:text>
  </xsl:text>
          <xsl:element name="title">
            <xsl:attribute name="role">
              <xsl:text>configuration</xsl:text>
            </xsl:attribute>
            <xsl:text>Configuring </xsl:text>
            <xsl:value-of select="../c:title" />
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
      </xsl:for-each><!-- c:config -> sect2  -->

      <!-- c:contents -> sect2: Build or reference the contents sect2 -->
      <xsl:for-each select="c:contents">

        <xsl:text>&#xa;&#xa;</xsl:text>

        <xsl:element name="sect2">
          <xsl:attribute name="role">
            <xsl:text>content</xsl:text>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="string-length(@c:ref) > 0 or $lastinseries = 'false'">
              <!-- Insert an xref to the actual contents list -->
              <xsl:text>&#xa;  </xsl:text>
              <xsl:element name="title" />
              <xsl:text>&#xa;&#xa;  </xsl:text>
            <xsl:element name="para">
              <xsl:text>Details on this package are located in </xsl:text>
              <xsl:element name="xref">
                <xsl:attribute name="linkend">
                  <xsl:choose>
                    <xsl:when test="string-length(@c:ref) > 0">
                      <xsl:value-of select="@c:ref" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$id" />
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>-contents</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="role">
                  <xsl:text>.</xsl:text>
                </xsl:attribute>
              </xsl:element>
            </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <!-- This page gets the contents list -->
              <xsl:attribute name="id">
                <xsl:value-of select="$id" />
                <xsl:text>-contents</xsl:text>
              </xsl:attribute>
              <xsl:text>&#xa;  </xsl:text>
              <xsl:element name="title">
                <xsl:text>Contents of </xsl:text>
                <xsl:value-of select="../c:title" />
              </xsl:element>
              <xsl:text>&#xa;&#xa;</xsl:text>
              <!-- Begin the Summary List -->
              <xsl:element name="segmentedlist">
                <xsl:if test="count(c:program) &gt; 0">
                  <xsl:text>&#xa;  </xsl:text>
                  <xsl:element name="segtitle">
                    <xsl:text>Installed Programs</xsl:text>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="count(c:library) &gt; 0">
                  <xsl:text>&#xa;  </xsl:text>
                  <xsl:element name="segtitle">
                    <xsl:text>Installed Libraries</xsl:text>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="count(c:directory) &gt; 0">
                  <xsl:text>&#xa;  </xsl:text>
                  <xsl:element name="segtitle">
                    <xsl:text>Installed Directories</xsl:text>
                  </xsl:element>
                </xsl:if>
                <xsl:text>&#xa;&#xa;  </xsl:text>
                <xsl:element name="seglistitem">
                  
                  <!-- Begin the seg list for Programs -->
                  <xsl:if test="count(c:program) &gt; 0">
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="seg">
                      <xsl:for-each select="c:program">
                        <xsl:value-of select="c:name" />
                        <xsl:if test="count(../c:program) &gt; 1">
                          <xsl:choose>
                            <xsl:when test="position() &lt; (last() - 1)">
                              <xsl:text>, </xsl:text>
                            </xsl:when>
                            <xsl:when test="position() = last() - 1">
                              <xsl:text> and </xsl:text>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:element>
                  </xsl:if>
                  <!-- End the seg list for Programs -->
                  
                  <!-- Begin the seg list for Libraries -->
                  <xsl:if test="count(c:library) &gt; 0">
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="seg">
                      <xsl:for-each select="c:library">
                        <xsl:value-of select="c:name" />
                        <xsl:if test="count(../c:library) &gt; 1">
                          <xsl:choose>
                            <xsl:when test="position() &lt; (last() - 1)">
                              <xsl:text>, </xsl:text>
                            </xsl:when>
                            <xsl:when test="position() = last() - 1">
                              <xsl:text> and </xsl:text>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:element>
                  </xsl:if>
                  <!-- End the seg list for Libraries -->
                  
                  <!-- Begin the seg list for Directories -->
                  <xsl:if test="count(c:directory) &gt; 0">
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="seg">
                      <xsl:for-each select="c:directory">
                        <xsl:value-of select="c:name" />
                        <xsl:if test="count(../c:directory) &gt; 1">
                          <xsl:if test="position() &lt; (last() - 1)">
                            <xsl:text>, </xsl:text>
                          </xsl:if>
                          <xsl:if test="position() = last() - 1">
                            <xsl:text> and </xsl:text>
                          </xsl:if>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:element>
                  </xsl:if>
                  <!-- End the seg list for Directories -->
                  
                  <xsl:text>&#xa;  </xsl:text>
                </xsl:element>
                <xsl:text>&#xa;</xsl:text>
              </xsl:element>
              <xsl:text>&#xa;&#xa;</xsl:text>
              <!-- End of the Summary List -->
              
              <!-- Begin Short Desc List -->
              <xsl:element name="variablelist">
                
                <!-- Render As -->
                <xsl:text>&#xa;  </xsl:text>
                <xsl:element name="bridgehead">
                  <xsl:attribute name="renderas">
                    <xsl:text>sect3</xsl:text>
                  </xsl:attribute>
                  <xsl:text>Short Descriptions</xsl:text>
                </xsl:element>
                
                <!-- Processing Instructions -->
                <xsl:text>&#xa;  </xsl:text>
                <xsl:processing-instruction name="dbfo">
                  <xsl:text>list-presentation="list"</xsl:text>
                </xsl:processing-instruction>
                <xsl:text>&#xa;  </xsl:text>
                <xsl:processing-instruction name="dbhtml">
                  <xsl:text>list-presentation="table"</xsl:text>
                </xsl:processing-instruction>
                
                <!-- Begin the Short Desc For-Each for Programs -->
                <xsl:for-each select="c:program">
                  <xsl:text>&#xa;&#xa;  </xsl:text>
                  <xsl:element name="varlistentry">
                    <xsl:attribute name="id">
                      <xsl:value-of select="c:name" />
                    </xsl:attribute>
                    
                    <!-- Term -->
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="term">
                      <xsl:element name="command">
                        <xsl:value-of select="c:name" />
                      </xsl:element>
                    </xsl:element>
                    <!-- End Term -->
                    
                    <!-- List Item -->
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="listitem">
                      
                      <xsl:text>&#xa;      </xsl:text>
                      <xsl:element name="para">
                        <xsl:apply-templates select="c:description/node()" />
                      </xsl:element>
                      
                      <xsl:text>&#xa;      </xsl:text>
                      <xsl:element name="indexterm">
                        <xsl:attribute name="zone">
                          <xsl:value-of select="$id" />
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="c:name" />
                        </xsl:attribute>
                        <xsl:text>&#xa;        </xsl:text>
                        <xsl:element name="primary">
                          <xsl:attribute name="sortas">
                            <xsl:text>b-</xsl:text>
                            <xsl:value-of select="c:name" />
                          </xsl:attribute>
                          <xsl:value-of select="c:name" />
                        </xsl:element>
                        <xsl:text>&#xa;      </xsl:text>
                      </xsl:element>
                      
                      <xsl:text>&#xa;    </xsl:text>
                    </xsl:element><!-- listitem -->
                    <!-- End List Item -->
                    
                    <xsl:text>&#xa;  </xsl:text>
                  </xsl:element><!-- varlistentry -->
                </xsl:for-each>
                <!-- End the Short Desc For-Each for Programs -->
                
                <!-- Begin the Short Desc For-Each for Libraries -->
                <xsl:for-each select="c:library">
                  <xsl:text>&#xa;&#xa;  </xsl:text>
                  <xsl:element name="varlistentry">
                    <xsl:attribute name="id">
                      <xsl:value-of select="c:name" />
                    </xsl:attribute>
                    
                    <!-- Term -->
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="term">
                      <xsl:element name="filename">
                        <xsl:attribute name="class">
                          <xsl:text>libraryfile</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="c:name" />
                      </xsl:element>
                    </xsl:element>
                    <!-- End Term -->
                    
                    <!-- List Item -->
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="listitem">
                      
                      <xsl:text>&#xa;      </xsl:text>
                      <xsl:element name="para">
                        <xsl:apply-templates select="c:description/node()" />
                      </xsl:element>
                      
                      <xsl:text>&#xa;      </xsl:text>
                      <xsl:element name="indexterm">
                        <xsl:attribute name="zone">
                          <xsl:value-of select="$id" />
                          <xsl:text> </xsl:text>
                          <xsl:value-of select="c:name" />
                        </xsl:attribute>
                        <xsl:text>&#xa;        </xsl:text>
                        <xsl:element name="primary">
                          <xsl:attribute name="sortas">
                            <xsl:text>c-</xsl:text>
                            <xsl:value-of select="c:name" />
                          </xsl:attribute>
                          <xsl:value-of select="c:name" />
                        </xsl:element>
                        <xsl:text>&#xa;      </xsl:text>
                      </xsl:element>
                      
                      <xsl:text>&#xa;    </xsl:text>
                    </xsl:element><!-- listitem -->
                    <!-- End List Item -->
                    
                    <xsl:text>&#xa;  </xsl:text>
                  </xsl:element><!-- varlistentry -->
                </xsl:for-each>
                <!-- End the Short Desc For-Each for Libraries -->
                
                <!-- Begin the Short Desc For-Each for Directories -->
                <xsl:for-each select="c:directory">
                  <xsl:text>&#xa;&#xa;  </xsl:text>
                  <xsl:element name="varlistentry">
                    <xsl:attribute name="id">
                      <xsl:text>dir</xsl:text>
                      <xsl:value-of select="translate(c:name, '/', '-')" />
                    </xsl:attribute>
                    
                    <!-- Term -->
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="term">
                      <xsl:element name="filename">
                        <xsl:attribute name="class">
                          <xsl:text>directory</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="c:name" />
                      </xsl:element>
                    </xsl:element>
                    <!-- End Term -->
                    
                    <!-- List Item -->
                    <xsl:text>&#xa;    </xsl:text>
                    <xsl:element name="listitem">
                      
                      <xsl:text>&#xa;      </xsl:text>
                      <xsl:element name="para">
                        <xsl:apply-templates select="c:description/node()" />
                      </xsl:element>
                      
                      <xsl:text>&#xa;      </xsl:text>
                      <xsl:element name="indexterm">
                        <xsl:attribute name="zone">
                          <xsl:value-of select="$id" />
                          <xsl:text> dir</xsl:text>
                          <xsl:value-of select="translate(c:name, '/', '-')" />
                        </xsl:attribute>
                        <xsl:text>&#xa;        </xsl:text>
                        <xsl:element name="primary">
                          <xsl:attribute name="sortas">
                            <xsl:text>e-</xsl:text>
                            <xsl:value-of select="c:name" />
                          </xsl:attribute>
                          <xsl:value-of select="c:name" />
                        </xsl:element>
                        <xsl:text>&#xa;      </xsl:text>
                      </xsl:element>
                      
                      <xsl:text>&#xa;    </xsl:text>
                    </xsl:element><!-- listitem -->
                    <!-- End List Item -->
                    
                    <xsl:text>&#xa;  </xsl:text>
                  </xsl:element><!-- varlistentry -->
                </xsl:for-each>
                <!-- End the Short Desc For-Each for Directories -->
                
                <xsl:text>&#xa;&#xa;</xsl:text>
              </xsl:element><!-- variablelist -->
              <!-- End Short Desc List -->
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:text>&#xa;&#xa;</xsl:text>
        </xsl:element><!-- sect2 -->
      </xsl:for-each><!-- c:contents -> sect2 -->
      
      <xsl:text>&#xa;&#xa;</xsl:text>

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
  
  <xsl:template match="c:note" mode="filter-bits-32">
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
          <xsl:element name="note">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:warning" mode="filter-bits-32">
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
          <xsl:element name="warning">
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
          <xsl:element name="screen">
            <xsl:if test="@c:nodump = 'true'">
              <xsl:attribute name="role">
                <xsl:text>nodump</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="userinput">
              <xsl:apply-templates select="node()" mode="filter-bits-32" />
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:emphasis" mode="filter-bits-32">
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
          <xsl:element name="emphasis">
            <xsl:apply-templates select="node()" mode="filter-bits-32" />
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
  
  <xsl:template match="c:note" mode="filter-bits-n32">
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
          <xsl:element name="note">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:warning" mode="filter-bits-n32">
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
          <xsl:element name="warning">
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
          <xsl:element name="screen">
            <xsl:if test="@c:nodump = 'true'">
              <xsl:attribute name="role">
                <xsl:text>nodump</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="userinput">
              <xsl:apply-templates select="node()" mode="filter-bits-n32" />
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:emphasis" mode="filter-bits-n32">
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
          <xsl:element name="emphasis">
            <xsl:apply-templates select="node()" mode="filter-bits-n32" />
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
  
  <xsl:template match="c:note" mode="filter-bits-64">
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
          <xsl:element name="note">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:warning" mode="filter-bits-64">
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
          <xsl:element name="warning">
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
          <xsl:element name="screen">
            <xsl:if test="@c:nodump = 'true'">
              <xsl:attribute name="role">
                <xsl:text>nodump</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="userinput">
              <xsl:apply-templates select="node()" mode="filter-bits-64" />
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="c:emphasis" mode="filter-bits-64">
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
          <xsl:element name="emphasis">
            <xsl:apply-templates select="node()" mode="filter-bits-64" />
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

  <!-- Templates for the Inline Elements outside of the build filter -->

  <xsl:template match="c:literal">
    <xsl:element name="literal">
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="c:replaceable">
    <xsl:element name="replaceable">
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="c:application">
    <xsl:element name="application">
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="c:dirname">
    <xsl:element name="filename">
      <xsl:attribute name="class">
        <xsl:text>directory</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="c:filename">
    <xsl:element name="filename">
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="c:command">
    <xsl:element name="command">
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>

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