#!/bin/bash

# merge_skadnetworks.sh
# Post-build script that merges SKAdNetworkItems from skNetworks.plist into the built Info.plist.
# This approach is needed because Tuist cannot use a default info.plist as XML.

set -e

PLIST_BUDDY="/usr/libexec/PlistBuddy"
INFO_PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
SK_NETWORKS_PLIST="${SRCROOT}/Resources/InfoPlist/skNetworks.plist"

if [ ! -f "${INFO_PLIST}" ]; then
    echo "Error: Info.plist not found at ${INFO_PLIST}"
    exit 1
fi

if [ ! -f "${SK_NETWORKS_PLIST}" ]; then
    echo "Error: skNetworks.plist not found at ${SK_NETWORKS_PLIST}"
    exit 1
fi

echo "Merging SKAdNetworkItems into Info.plist..."
echo "Info.plist: ${INFO_PLIST}"
echo "skNetworks.plist: ${SK_NETWORKS_PLIST}"

# Get count of items in the source plist
SOURCE_COUNT=$("${PLIST_BUDDY}" -c "Print :SKAdNetworkItems: " "${SK_NETWORKS_PLIST}" | grep -c "Dict {" || true)

if [ "${SOURCE_COUNT}" -eq 0 ]; then
    echo "No SKAdNetworkItems found in skNetworks.plist. Nothing to merge."
    exit 0
fi

echo "Found ${SOURCE_COUNT} SKAdNetworkIdentifiers in skNetworks.plist"

# Check if SKAdNetworkItems already exists in Info.plist
EXISTING_COUNT=0
if "${PLIST_BUDDY}" -c "Print :SKAdNetworkItems:" "${INFO_PLIST}" > /dev/null 2>&1; then
    EXISTING_COUNT=$("${PLIST_BUDDY}" -c "Print :SKAdNetworkItems: " "${INFO_PLIST}" | grep -c "Dict {" || true)
    echo "Found ${EXISTING_COUNT} existing SKAdNetworkIdentifiers in Info.plist"
else
    echo "SKAdNetworkItems does not exist in Info.plist. Creating new array."
    "${PLIST_BUDDY}" -c "Add :SKAdNetworkItems array" "${INFO_PLIST}"
fi

# Collect existing identifiers (lowercased) for dedup check
declare -a EXISTING_IDS=()
for (( i=0; i<EXISTING_COUNT; i++ )); do
    ID=$("${PLIST_BUDDY}" -c "Print :SKAdNetworkItems:${i}:SKAdNetworkIdentifier" "${INFO_PLIST}" 2>/dev/null || true)
    if [ -n "${ID}" ]; then
        EXISTING_IDS+=("$(echo "${ID}" | tr '[:upper:]' '[:lower:]')")
    fi
done

ADDED_COUNT=0

# Iterate over source identifiers and add missing ones
for (( i=0; i<SOURCE_COUNT; i++ )); do
    SOURCE_ID=$("${PLIST_BUDDY}" -c "Print :SKAdNetworkItems:${i}:SKAdNetworkIdentifier" "${SK_NETWORKS_PLIST}" 2>/dev/null || true)
    if [ -z "${SOURCE_ID}" ]; then
        continue
    fi

    SOURCE_ID_LOWER=$(echo "${SOURCE_ID}" | tr '[:upper:]' '[:lower:]')

    # Check if already exists
    FOUND=false
    for EXISTING_ID in "${EXISTING_IDS[@]}"; do
        if [ "${EXISTING_ID}" = "${SOURCE_ID_LOWER}" ]; then
            FOUND=true
            break
        fi
    done

    if [ "${FOUND}" = false ]; then
        NEW_INDEX=$((EXISTING_COUNT + ADDED_COUNT))
        "${PLIST_BUDDY}" -c "Add :SKAdNetworkItems:${NEW_INDEX} dict" "${INFO_PLIST}"
        "${PLIST_BUDDY}" -c "Add :SKAdNetworkItems:${NEW_INDEX}:SKAdNetworkIdentifier string ${SOURCE_ID}" "${INFO_PLIST}"
        echo "Added: ${SOURCE_ID}"
        ADDED_COUNT=$((ADDED_COUNT + 1))
    fi
done

echo "Done. Added ${ADDED_COUNT} new SKAdNetworkIdentifiers."
