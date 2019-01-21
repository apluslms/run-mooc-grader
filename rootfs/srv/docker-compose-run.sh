#!/bin/bash
# Orders a container using docker run command.
# The container command is responsible to

SID=$1
GRADER_HOST=$2
DOCKER_IMAGE=$3
EXERCISE_MOUNT=${4%.}
SUBMISSION_MOUNT=$5
CMD=$6
COURSE_JSON=$7
EXERCISE_JSON=$8

exercise_path=${EXERCISE_MOUNT#/srv/courses/}
exercise_path=${exercise_path#/srv/grader/courses/}
exercise_path=${exercise_path%/}

# Manage for docker-compose setup, see test course for reference.
# Docker cannot bind volume from inside docker so global /tmp is used.
# The temporary exercise mount uses the submission ID to create unique directories
# in case multiple exercise graders are started at the same time.
# Removing and creating the same directory simultaneously in different processes
# obviously does not work.
TMP=/tmp/aplus
TMP_EXERCISE_MOUNT=$TMP/_ex/$SID/$exercise_path
TMP_SUBMISSION_MOUNT=$TMP/${SUBMISSION_MOUNT#/local/grader/uploads/}
rm -rf $TMP_EXERCISE_MOUNT
mkdir -p $TMP_EXERCISE_MOUNT
mkdir -p $TMP_SUBMISSION_MOUNT
cp -r $EXERCISE_MOUNT $(dirname $TMP_EXERCISE_MOUNT)/
cp -r $SUBMISSION_MOUNT $(dirname $TMP_SUBMISSION_MOUNT)/

# in personalized exercises, we need the file path to the correct instance
PERSONALIZED_MOUNT=$(echo "$EXERCISE_JSON" | jq -cr '.personalized_exercise // ""')

# normal exercises do not use the personalized mount
PERSONALIZED_ARG=''
if [ -n "$PERSONALIZED_MOUNT" ]; then
  TMP_PERSONALIZED_MOUNT=$TMP/_personalized/$SID/${PERSONALIZED_MOUNT#/local/grader/ex-meta/}
  rm -rf $TMP_PERSONALIZED_MOUNT
  mkdir -p $TMP_PERSONALIZED_MOUNT
  cp -r $PERSONALIZED_MOUNT $(dirname $TMP_PERSONALIZED_MOUNT)
  PERSONALIZED_ARG="-v $TMP_PERSONALIZED_MOUNT:/personalized_exercise"
fi


docker run \
  -d --rm \
  -e "SID=$SID" \
  -e "REC=$GRADER_HOST" \
  -v $TMP_EXERCISE_MOUNT:/exercise:ro \
  -v $TMP_SUBMISSION_MOUNT:/submission \
  $PERSONALIZED_ARG \
  --network=aplus_default \
  $DOCKER_IMAGE \
  $CMD

