#!/bin/sh

ARB_DIR="lib/l10n/arb"
GENERATED_CODE_DIR="lib/l10n/dart/"
RESOURCE_FILE="lib/locale/string_resources.dart"

if [ "$1" = "--extract" ]; then
    flutter pub run intl_translation:extract_to_arb --output-dir="$ARB_DIR" "$RESOURCE_FILE"
elif [ "$1" = "--generate" ]; then
    flutter pub run intl_translation:generate_from_arb --output-dir="$GENERATED_CODE_DIR" \
        --no-use-deferred-loading $ARB_DIR/intl_en.arb $ARB_DIR/intl_es.arb $ARB_DIR/intl_fr.arb "$RESOURCE_FILE"
    flutter format $GENERATED_CODE_DIR
else
    echo "Localization help script."
    echo ""
    echo "Usage:"
    echo "$0 --extract\t\tExtract strings from Dart file ($RESOURCE_FILE)."
    echo "$0 --generate\t\tGenerate Dart code from ARB files ($ARB_DIR)/*"
    echo ""
fi

