#!/bin/sh
: "${DATA_DIR:?DATA_DIR is not set}"
exec pocketbase serve --dir "${DATA_DIR}" --http "0.0.0.0:8090"
