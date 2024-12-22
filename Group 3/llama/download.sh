#!/usr/bin/env bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

set -e

read -p "Enter the URL from email: " PRESIGNED_URL
echo ""
read -p "Enter the list of models to download without spaces (7B,13B,70B,7B-chat,13B-chat,70B-chat), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [ "$MODEL_SIZE" = "" ]; then
    MODEL_SIZE="7B,13B,70B,7B-chat,13B-chat,70B-chat"
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
LICENSE_URL=$(echo "$PRESIGNED_URL" | sed 's/\*/LICENSE/')
USE_POLICY_URL=$(echo "$PRESIGNED_URL" | sed 's/\*/USE_POLICY.md/')
wget --continue "$LICENSE_URL" -O "${TARGET_FOLDER}/LICENSE"
wget --continue "$USE_POLICY_URL" -O "${TARGET_FOLDER}/USE_POLICY.md"

echo "Downloading tokenizer"
TOKENIZER_MODEL_URL=$(echo "$PRESIGNED_URL" | sed 's/\*/tokenizer.model/')
TOKENIZER_CHECKLIST_URL=$(echo "$PRESIGNED_URL" | sed 's/\*/tokenizer_checklist.chk/')
wget --continue "$TOKENIZER_MODEL_URL" -O "${TARGET_FOLDER}/tokenizer.model"
wget --continue "$TOKENIZER_CHECKLIST_URL" -O "${TARGET_FOLDER}/tokenizer_checklist.chk"
CPU_ARCH=$(uname -m)
if [ "$CPU_ARCH" = "arm64" ]; then
    (cd ${TARGET_FOLDER} && md5 tokenizer_checklist.chk)
else
    (cd ${TARGET_FOLDER} && md5sum -c tokenizer_checklist.chk)
fi

for m in ${MODEL_SIZE//,/ }
do
    if [ "$m" = "7B" ]; then
        SHARD=0
        MODEL_PATH="llama-2-7b"
    elif [ "$m" = "7B-chat" ]; then
        SHARD=0
        MODEL_PATH="llama-2-7b-chat"
    elif [ "$m" = "13B" ]; then
        SHARD=1
        MODEL_PATH="llama-2-13b"
    elif [ "$m" = "13B-chat" ]; then
        SHARD=1
        MODEL_PATH="llama-2-13b-chat"
    elif [ "$m" = "70B" ]; then
        SHARD=7
        MODEL_PATH="llama-2-70b"
    elif [ "$m" = "70B-chat" ]; then
        SHARD=7
        MODEL_PATH="llama-2-70b-chat"
    fi

    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        MODEL_FILE_URL=$(echo "$PRESIGNED_URL" | sed "s/\*/${MODEL_PATH}\/consolidated.${s}.pth/")
        wget --continue "$MODEL_FILE_URL" -O "${TARGET_FOLDER}/${MODEL_PATH}/consolidated.${s}.pth"
    done

    PARAMS_URL=$(echo "$PRESIGNED_URL" | sed "s/\*/${MODEL_PATH}\/params.json/")
    CHECKLIST_URL=$(echo "$PRESIGNED_URL" | sed "s/\*/${MODEL_PATH}\/checklist.chk/")
    wget --continue "$PARAMS_URL" -O "${TARGET_FOLDER}/${MODEL_PATH}/params.json"
    wget --continue "$CHECKLIST_URL" -O "${TARGET_FOLDER}/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    if [ "$CPU_ARCH" = "arm64" ]; then
      (cd ${TARGET_FOLDER}/${MODEL_PATH} && md5 checklist.chk)
    else
      (cd ${TARGET_FOLDER}/${MODEL_PATH} && md5sum -c checklist.chk)
    fi
done