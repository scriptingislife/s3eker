#!/bin/bash

LAMBDA_BUCKET="s3eker-lambda-store"
ORIG_DIR="$PWD"

mkdir dist 2>/dev/null

for D in */
do
    FUNCTION_NAME="${D%%/}" # Remove slash at end of dir name. dir/ to dir
    if [ "$FUNCTION_NAME" == "dist" ]
    then
        continue
    fi

    TARGET_DIR="./dist/$D"

    echo "Packing $D"
    
    # Install dependencies in dist/FUNCTION_NAME/
    cp -r "$D" "$TARGET_DIR"
    if [ -f "$FUNCTION_NAME/requirements.txt" ]; then
        pip3 install -r "$FUNCTION_NAME/requirements.txt" --target "$TARGET_DIR"
    fi
    
    cd "$TARGET_DIR"
    
    DIST_DIR=".."
    ZIP_FILENAME="$FUNCTION_NAME.zip"
    ZIP_FILE="$DIST_DIR/$ZIP_FILENAME"
    
    if zip "$ZIP_FILE"  ./*; then
        echo "Successfully zipped $FUNCTION_NAME"
        aws s3 cp "$ZIP_FILE" "s3://$LAMBDA_BUCKET/$FUNCTION_NAME/$ZIP_FILENAME"
        aws lambda update-function-code --function-name "s3eker-$FUNCTION_NAME" --s3-bucket $LAMBDA_BUCKET --s3-key "$FUNCTION_NAME/$ZIP_FILENAME" > /dev/null
    fi    
    
    cd $ORIG_DIR
    rm -r $TARGET_DIR

done