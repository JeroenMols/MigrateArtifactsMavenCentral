# Migrate Artifacts to Maven Central
Script to migrate existing artifacts from JCenter to Maven Central, after the [jcenter/bintray shutdown announcement][shutdown].

This repository contains a script to help migrate an existing project to Maven Central:

- ~~Update (Gradle) scripts to publish to Maven Central~~
- Migrate all existing artifacts from JCenter to Maven Central

Because all secrets are injected into the script, this is ideal to run on a CI environment.

To use, make sure `mvn` and `gpg` are installed, fill in the TODO's and run:

```bash
$ ./migrate_to_mavencentral.sh $BASE64_SIGNING_KEY $SONATYPE_USERNAME $SONATYPE_PASSWORD
```

For a more detailed explanation, read my accompanying blog post: [Migrate existing artifacts from JCenter to Maven Central][blog]. 


[shutdown]: https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/
[sonatype]: https://issues.sonatype.org/secure/Dashboard.jspa
[blog]: https://jeroenmols.com/blog/2021/03/24/migrate-artifacts-mavencentral/#4b-add-all-required-info-to-pomxml
