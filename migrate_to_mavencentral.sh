#!/bin/bash

# Copyright (C) 2021 Jeroen Mols (https://jeroenmols.com)
#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

set -euo pipefail

# TODO: add versions e.g. (1.0.0 1.0.1 1.0.2)
VERSIONS=()
# TODO : add artifact Id
ARTIFACT_ID=""
# TODO: https://dl.bintray.com/<bintray-org>/<bintray-repo>/<group-id-slash-separated>/<artifact-id>
BINTRAYURL=""

# TODO: define placeholder and provide additional pom information (starting with placeholder!)
ARTIFACT_EXTENSTION="aar"
POM_PLACEHOLDER="<packaging>.*>"
POM_REPLACEMENT="<packaging>aar</packaging>

  <name>name here</name>
  <description>description here</description>
  <url>url here</url>


  <licenses>
    <license>
      <name>license here</name>
      <url>url to license</url>
    </license>
  </licenses>

  <organization>
    <name>name here</name>
    <url>url here</url>
  </organization>

   <developers>
    <developer>
      <organization>name here</organization>
      <organizationUrl>url here</organizationUrl>
    </developer>
  </developers>

  <scm>
    <connection>url here</connection>
    <developerConnection>url here</developerConnection>
    <url>url here</url>
  </scm>
  "

# Constants
MAVEN_CENTRAL_STAGINGURL="https://oss.sonatype.org/service/local/staging/deploy/maven2"
MAVEN_CENTRAL_REPOID="ossrh"
OUTPUT_DIR="output"

# Utilities
function escape_pom() {
  echo "$1" | sed 's#/#\\/#g' | tr '\n' '@'
}

function xml_encode() {
  echo $1 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}



echo "Loading script input"
BASE64_SIGNING_KEY=$1
SONATYPE_USERNAME=$(xml_encode $2)
SONATYPE_PASSWORD=$(xml_encode $3)
echo $SONATYPE_PASSWORD
if [ -z "${BASE64_SIGNING_KEY}"  -o -z "${SONATYPE_USERNAME}" -o -z "${SONATYPE_PASSWORD}" ]; then
  echo "USAGE: migrate BASE64_SIGNING_KEY SONATYPE_USERNAME SONATYPE_PASSWORD"
  exit 1
fi



echo "Setup signing key"
echo $BASE64_SIGNING_KEY | base64 -d | gpg --import



echo "Setup Maven credentials"
mkdir -p ~/.m2
echo "<settings xmlns=\"http://maven.apache.org/SETTINGS/1.0.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd\">
  <servers>
    <server>
      <id>$MAVEN_CENTRAL_REPOID</id>
      <username>$SONATYPE_USERNAME</username>
      <password>$SONATYPE_PASSWORD</password>
    </server>
  </servers>
</settings>" > ~/.m2/settings.xml



echo "Migrate artifacts"
for v in ${VERSIONS[@]}; do
  echo "Migrating version $v"
  mkdir -p $OUTPUT_DIR/$v
  curl -L $BINTRAYURL/$v/$ARTIFACT_ID-$v.$ARTIFACT_EXTENSTION \
      -o $OUTPUT_DIR/$v/$ARTIFACT_ID-$v.$ARTIFACT_EXTENSTION
  curl -L $BINTRAYURL/$v/$ARTIFACT_ID-$v.pom \
      -o $OUTPUT_DIR/$v/$ARTIFACT_ID-$v.pom

  # Add required metadata to pom.xml
  sed -e "s/$POM_PLACEHOLDER/$(escape_pom "$POM_REPLACEMENT")/g" \
      $OUTPUT_DIR/$v/sdk-core-$v.pom |\
      tr '@' '\n' > temp.txt
  mv temp.txt $OUTPUT_DIR/$v/sdk-core-$v.pom

  mvn gpg:sign-and-deploy-file \
     -Durl=$MAVEN_CENTRAL_STAGINGURL \
     -DrepositoryId=$MAVEN_CENTRAL_REPOID \
     -DpomFile=$OUTPUT_DIR/$v/sdk-core-$v.pom \
     -Dfile=$OUTPUT_DIR/$v/sdk-core-$v.$ARTIFACT_EXTENSTION
done
