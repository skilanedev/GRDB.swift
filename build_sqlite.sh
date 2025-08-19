# build_sqlite.sh

#!/bin/bash
set -e # Exit on error
# Constants
FRAMEWORK_NAME="SQLiteVec"  # Keep this to match Package.swift path
LIB_NAME="GRDBSQLite"  # New variable for library name
SQLITE_VERSION="3500400"
SQLITE_VEC_VERSION="vv0.1.7-alpha.2"
SQLITE_YEAR="2025" # Adjusted for URL
OUTPUT_DIR="build"
# --- Clean Up ---
rm -rf "${OUTPUT_DIR}" "${FRAMEWORK_NAME}.xcframework"
mkdir -p "${OUTPUT_DIR}/src" "${OUTPUT_DIR}/lib/macos-arm64" "${OUTPUT_DIR}/headers"
# --- Download and Extract SQLite Amalgamation ---
echo "--- Using local SQLite amalgamation files ---"
cp "sqlite3.c" "${OUTPUT_DIR}/src/"
cp "sqlite3.h" "${OUTPUT_DIR}/headers/"
cp "sqlite3ext.h" "${OUTPUT_DIR}/headers/"
# --- Download and Extract sqlite-vec ---
echo "--- Using local sqlite-vec files ---"
cp "sqlite-vec.c" "${OUTPUT_DIR}/src/vec.c"
cp "sqlite-vec.h" "${OUTPUT_DIR}/headers/"
# --- Compile for macOS arm64 ---
echo "--- Compiling for macOS arm64 ---"
CFLAGS="-DSQLITE_ENABLE_LOAD_EXTENSION -DSQLITE_ENABLE_FTS5 -DSQLITE_THREADSAFE=1 -DSQLITE_OMIT_DEPRECATED -DSQLITE_ENABLE_SNAPSHOT -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_JSON1 -DSQLITE_MEMDEBUG=1 -DSQLITE_DEBUG=1 -O2 -fPIC"
clang \
  -arch arm64 \
  -target arm64-apple-macos11.0 \
  -I"${OUTPUT_DIR}/headers" \
  ${CFLAGS} \
  -c "${OUTPUT_DIR}/src/sqlite3.c" -o "${OUTPUT_DIR}/lib/macos-arm64/sqlite3.o"
clang \
  -arch arm64 \
  -target arm64-apple-macos11.0 \
  -I"${OUTPUT_DIR}/headers" \
  ${CFLAGS} \
  -c "${OUTPUT_DIR}/src/vec.c" -o "${OUTPUT_DIR}/lib/macos-arm64/vec.o"
ar rcs "${OUTPUT_DIR}/lib/macos-arm64/lib${LIB_NAME}.a" \
  "${OUTPUT_DIR}/lib/macos-arm64/sqlite3.o" \
  "${OUTPUT_DIR}/lib/macos-arm64/vec.o"
# --- Prepare Headers ---
echo "--- Preparing headers and module.map ---"
# Headers already copied in local blocks
# Create module.modulemap
cat << EOF > "${OUTPUT_DIR}/headers/module.modulemap"
module GRDBSQLite {
  header "sqlite-vec.h"
  header "sqlite3.h"
  header "sqlite3ext.h"
  link "GRDBSQLite"
  export *
}
EOF
# --- Create XCFramework ---
echo "--- Creating ${FRAMEWORK_NAME}.xcframework ---"
xcodebuild -create-xcframework \
  -library "${OUTPUT_DIR}/lib/macos-arm64/lib${LIB_NAME}.a" \
  -headers "${OUTPUT_DIR}/headers" \
  -output "${FRAMEWORK_NAME}.xcframework"
echo "--- Build complete! ---"
echo "Created ${FRAMEWORK_NAME}.xcframework"
# --- Final Cleanup ---
rm -rf "${OUTPUT_DIR}"
rm -f "sqlite-amalgamation-*.zip" "sqlite-vec-*.zip"