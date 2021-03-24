# Migrate Artifacts to Maven Central
Script to migrate existing artifacts from JCenter to Maven Central, after the [jcenter/bintray shutdown announcement][shutdown].

To migrate an existing project to Maven Central, library developers will need to do two things:

1. Update (Gradle) scripts to publish to Maven Central
2. Migrate all existing artifacts from JCenter to Maven Central

This post will only cover the second step and hence assumes that the reader has a [Sonatype account](https://issues.sonatype.org/secure/Dashboard.jspa) and GPG key available.

Before using, [learn how to use the script and how it all works][blog].


[shutdown]: https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/
[sonatype]: https://issues.sonatype.org/secure/Dashboard.jspa
[blog]: https://jeroenmols.com/blog/2021/03/24/migrate-artifacts-mavencentral/#4b-add-all-required-info-to-pomxml
