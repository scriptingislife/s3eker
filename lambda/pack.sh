#!/bin/bash

DIST_DIR="../dist"
LAMBDA_BUCKET="s3eker-lambda-store"

mkdir dist 2>/dev/null

for D in */
do
    DIR_NAME="${D%%/}" # Remove slash at end of dir name. dir/ to dir
    if [ "$DIR_NAME" == "dist" ]
    then
        continue
    fi

    cd $D
    echo "Packing $D"
    ZIP_FILENAME="$DIR_NAME.zip"
    ZIP_FILE="$DIST_DIR/$ZIP_FILENAME"
    zip "$ZIP_FILE"  main.py
    aws s3 cp "$ZIP_FILE" "s3://$LAMBDA_BUCKET/$DIR_NAME/$ZIP_FILENAME"
    aws lambda update-function-code --function-name "s3eker-$DIR_NAME" --s3-bucket $LAMBDA_BUCKET --s3-key "$DIR_NAME/$ZIP_FILENAME"
done