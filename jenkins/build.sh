#!/bin/bash

basedir="${WORKSPACE}"

cat > build.xml <<EOS
<?xml version="1.0" encoding="UTF-8"?>

<project name="${JOB_NAME}" default="build">
 <target name="build"
   depends="prepare,lint,phploc,pdepend,phpmd-ci,phpcs-ci,phpcpd,phpdox,phpunit,phpcb"/>

 <target name="build-parallel"
   depends="prepare,lint,tools-parallel,phpunit,phpcb"/>

 <target name="tools-parallel" description="Run tools in parallel">
  <parallel threadCount="2">
   <sequential>
    <antcall target="pdepend"/>
    <antcall target="phpmd-ci"/>
   </sequential>
   <antcall target="phpcpd"/>
   <antcall target="phpcs-ci"/>
   <antcall target="phploc"/>
   <antcall target="phpdox"/>
  </parallel>
 </target>

 <target name="clean" description="Cleanup build artifacts">
  <delete dir="${basedir}/build/api"/>
  <delete dir="${basedir}/build/code-browser"/>
  <delete dir="${basedir}/build/coverage"/>
  <delete dir="${basedir}/build/logs"/>
  <delete dir="${basedir}/build/pdepend"/>
 </target>

 <target name="prepare" depends="clean" description="Prepare for build">
  <mkdir dir="${basedir}/build/api"/>
  <mkdir dir="${basedir}/build/code-browser"/>
  <mkdir dir="${basedir}/build/coverage"/>
  <mkdir dir="${basedir}/build/logs"/>
  <mkdir dir="${basedir}/build/pdepend"/>
  <mkdir dir="${basedir}/build/phpdox"/>
 </target>

 <target name="lint" description="Perform syntax check of sourcecode files">
  <apply executable="php" failonerror="false">
   <arg value="-l" />

   <fileset dir="${basedir}/src">
    <include name="**/*.php" />
    <modified />
   </fileset>

  </apply>
 </target>

 <target name="phploc" description="Measure project size using PHPLOC">
  <exec executable="phploc">
   <arg value="--log-csv" />
   <arg value="${basedir}/build/logs/phploc.csv" />
   <arg path="${basedir}/src" />
  </exec>
 </target>

 <target name="pdepend" description="Calculate software metrics using PHP_Depend">
  <exec executable="pdepend">
   <arg value="--jdepend-xml=${basedir}/build/logs/jdepend.xml" />
   <arg value="--jdepend-chart=${basedir}/build/pdepend/dependencies.svg" />
   <arg value="--overview-pyramid=${basedir}/build/pdepend/overview-pyramid.svg" />
   <arg path="${basedir}/src" />
  </exec>
 </target>

 <target name="phpmd"
         description="Perform project mess detection using PHPMD and print human readable output. Intended for usage on the command line before committing.">
  <exec executable="phpmd">
   <arg path="${basedir}/src" />
   <arg value="text" />
   <arg value="${basedir}/build/phpmd.xml" />
  </exec>
 </target>

 <target name="phpmd-ci" description="Perform project mess detection using PHPMD creating a log file for the continuous integration server">
  <exec executable="phpmd">
   <arg path="${basedir}/src" />
   <arg value="xml" />
   <arg value="${basedir}/build/phpmd.xml" />
   <arg value="--reportfile" />
   <arg value="${basedir}/build/logs/pmd.xml" />
  </exec>
 </target>

 <target name="phpcs"
         description="Find coding standard violations using PHP_CodeSniffer and print human readable output. Intended for usage on the command line before committing.">
  <exec executable="phpcs">
   <arg value="--standard=${basedir}/build/phpcs.xml" />
   <arg path="${basedir}/src" />
  </exec>
 </target>

 <target name="phpcs-ci" description="Find coding standard violations using PHP_CodeSniffer creating a log file for the continuous integration server">
  <exec executable="phpcs" output="/dev/null">
   <arg value="--report=checkstyle" />
   <arg value="--report-file=${basedir}/build/logs/checkstyle.xml" />
   <arg value="--standard=${basedir}/build/phpcs.xml" />
   <arg path="${basedir}/src" />
  </exec>
 </target>

 <target name="phpcpd" description="Find duplicate code using PHPCPD">
  <exec executable="phpcpd">
   <arg value="--log-pmd" />
   <arg value="${basedir}/build/logs/pmd-cpd.xml" />
   <arg path="${basedir}/src" />
  </exec>
 </target>

 <target name="phpdox" description="Generate API documentation using phpDox">
  <exec executable="phpdox"/>
 </target>

 <target name="phpunit" description="Run unit tests with PHPUnit">
  <exec executable="phpunit" failonerror="true">
    <arg value="--debug" />
    <arg value="-c" />
    <arg value="app/phpunit.xml.dist" />
  </exec>
 </target>

 <target name="phpcb" description="Aggregate tool output with PHP_CodeBrowser">
  <exec executable="phpcb">
   <arg value="--log" />
   <arg path="${basedir}/build/logs" />
   <arg value="--source" />
   <arg path="${basedir}/src" />
   <arg value="--output" />
   <arg path="${basedir}/build/code-browser" />
  </exec>
 </target>
</project>

EOS

if [ ! -d "build" ]; then
    mkdir build
fi

curl https://raw.github.com/cbsi/cbsi-php-coding-standard/master/ruleset.xml -o build/phpcs.xml

cat > build/phpmd.xml <<EOS
<ruleset name="name-of-your-coding-standard"
  xmlns="http://pmd.sf.net/ruleset/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://pmd.sf.net/ruleset/1.0.0
                      http://pmd.sf.net/ruleset_xml_schema.xsd"
  xsi:noNamespaceSchemaLocation="http://pmd.sf.net/ruleset_xml_schema.xsd">
  <description>Description of your coding standard</description>

  <rule ref="rulesets/codesize.xml/CyclomaticComplexity" />
  <rule ref="rulesets/codesize.xml/NPathComplexity" />

</ruleset>

EOS


