#!/bin/bash -e
# This script will build the project.

SWITCHES="-s --console=plain -x release -x artifactoryPublish -x bintrayUpload -x bintrayPublish"
# circleci does not like \n
ORG_GRADLE_PROJECT_SIGNING_KEY="$(echo -e "$ORG_GRADLE_PROJECT_SIGNING_KEY")"

if [ $CIRCLE_PR_NUMBER ]; then
  echo -e "WARN: Should not be here => Found Pull Request #$CIRCLE_PR_NUMBER => Branch [$CIRCLE_BRANCH]"
  echo -e "Not attempting to publish"
elif [ -z $CIRCLE_TAG ]; then
  echo -e "Publishing Snapshot => Branch ['$CIRCLE_BRANCH']"
  ./gradlew snapshot publishNebulaPublicationToSnapshotRepository $SWITCHES -x test
elif [ $CIRCLE_TAG ]; then
  echo -e "Publishing Release => Branch ['$CIRCLE_BRANCH']  Tag ['$CIRCLE_TAG']"
  case "$CIRCLE_TAG" in
  *-M\.*)
    ./gradlew -Prelease.disableGitChecks=true -Prelease.useLastTag=true candidate publishNebulaPublicationToMilestoneRepository $SWITCHES
    ;;
  *)
    ./gradlew -Prelease.disableGitChecks=true -Prelease.useLastTag=true final publishNebulaPublicationToMavenCentralRepository closeAndReleaseMavenCentralStagingRepository $SWITCHES
    ;;
  esac
else
  echo -e "WARN: Should not be here => Branch ['$CIRCLE_BRANCH']  Tag ['$CIRCLE_TAG']  Pull Request ['$CIRCLE_PR_NUMBER']"
  echo -e "Not attempting to publish"
fi

EXIT=$?

exit $EXIT
