#!/bin/bash
#
# fix_doc_enums.sh - Fix enum parameter types in Godot doc XML files
#
# The gendocs tool outputs enum parameters as type="ClassName.EnumName"
# but Godot's documentation system expects type="int" enum="ClassName.EnumName"
#
# Run this after gendocs to fix the XML files.
#

set -e

DOC_DIR="${1:-doc_classes}"

if [ ! -d "$DOC_DIR" ]; then
    echo "Error: Directory '$DOC_DIR' not found"
    echo "Usage: $0 [doc_classes_directory]"
    exit 1
fi

# Pattern matches: type="ClassName.EnumName"
# where ClassName starts with uppercase and EnumName starts with uppercase
# Replaces with: type="int" enum="ClassName.EnumName"

count=0
for xml_file in "$DOC_DIR"/*.xml; do
    if [ -f "$xml_file" ]; then
        # Use sed to fix the pattern
        # Match type="Word.Word" where both parts start with uppercase
        if grep -q 'type="[A-Z][a-zA-Z0-9]*\.[A-Z][a-zA-Z0-9]*"' "$xml_file"; then
            sed -i '' -E 's/type="([A-Z][a-zA-Z0-9]*\.[A-Z][a-zA-Z0-9]*)"/type="int" enum="\1"/g' "$xml_file"
            echo "Fixed: $(basename "$xml_file")"
            ((count++)) || true
        fi
    fi
done

if [ $count -eq 0 ]; then
    echo "No files needed fixing"
else
    echo "Fixed $count file(s)"
fi
