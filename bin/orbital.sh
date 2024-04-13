#!/bin/bash

ACTION=${1:-"plan"}

TMP_DIR=$(mktemp -d /tmp/orbital.XXXXXXXXXX )

for OBJ in $( find . -type d -depth 1 | fzf --multi | xargs basename ); do
  echo "${OBJ}" >> "${TMP_DIR}/jobs.txt"
  PIPE="${TMP_DIR}/${OBJ}.pipe"

  mkfifo ${PIPE}
  touch ${TMP_DIR}/${OBJ}.{stdout,stderr}

  (
    cd "${PWD}/${OBJ}"
    terraform init --upgrade
    echo "Running Terraform '${ACTION}' for '${OBJ}'"
    cat "${PIPE}" | terraform ${ACTION}
    # TODO: WHy don't we make it here without 'enter'
    rm -f "${TMP_DIR}/${OBJ}.pid" "${PIPE}"
    echo "Task completed"
  ) \
  2> "${TMP_DIR}/${OBJ}.stderr" \
  1> "${TMP_DIR}/${OBJ}.stdout" \
  &
  echo "${!}" > "${TMP_DIR}/${OBJ}.pid"
done

cat "${TMP_DIR}/jobs.txt" | fzf \
  --disabled \
  --scrollbar \
  --bind "enter:execute(echo {q} > ${TMP_DIR}/{}.pipe)" \
  --bind='ctrl-/:toggle-search' \
  --preview "tail -f -n +1 ${TMP_DIR}/{}.stdout ${TMP_DIR}/{}.stderr" \
  --preview-window 'follow,up,90%'

for PIPE in $( find "${TMP_DIR}" -name "*.pipe" ); do
  echo "Asking '${PIPE}' to exit gracefully"
  echo "" > "${PIPE}"
done

for PID in $( find "${TMP_DIR}" -name '*.pid' | xargs cat ); do
  echo "Killing '${PID}' as it didn't exit gracefully in time"
  kill -1 -${PID}
done

rm -rf "${TMP_DIR}"
