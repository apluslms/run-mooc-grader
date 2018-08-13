#!/bin/bash
# Orders a container using docker run command.
# The container command is responsible to

set -x

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
TMP=/tmp/aplus
TMP_EXERCISE_MOUNT=$TMP/_ex/$exercise_path
TMP_SUBMISSION_MOUNT=$TMP/${SUBMISSION_MOUNT#/srv/data/mgrader_uploads/}
rm -rf $TMP_EXERCISE_MOUNT
mkdir -p $TMP_EXERCISE_MOUNT
mkdir -p $TMP_SUBMISSION_MOUNT
cp -r $EXERCISE_MOUNT $(dirname $TMP_EXERCISE_MOUNT)/
cp -r $SUBMISSION_MOUNT $(dirname $TMP_SUBMISSION_MOUNT)/

# use Python to parse EXERCISE_JSON
# function: prints a value from the EXERCISE_JSON
# param $1: the key whose value should be returned
parse_val_from_exercise_json () {
  local parsejson="import json; print(json.loads('$EXERCISE_JSON').get('$1', ''))"
  echo $(python3 -c "$parsejson")
}

# in personalized exercises, we need the file path to the correct instance
PERSONALIZED_MOUNT=$(parse_val_from_exercise_json personalized_exercise)

# normal exercises do not use the personalized mount
PERSONALIZED_ARG=''
if [ -n "$PERSONALIZED_MOUNT" ]; then
  TMP_PERSONALIZED_MOUNT=$TMP/_personalized/${PERSONALIZED_MOUNT##$GRADER_PERSONALIZED_CONTENT_PATH}
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

