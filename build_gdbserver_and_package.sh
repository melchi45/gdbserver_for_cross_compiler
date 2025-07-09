#!/bin/bash

# Default values
TOOLCHAIN_FILE=""
INSTALL_PATH="$(pwd)/work"
ARCHIVE_NAME="gdbserver.tar.gz"
GDB_REPO="https://sourceware.org/git/binutils-gdb.git"
GDB_SRC_DIR="gdb-12.1"
INIT_SCRIPT_NAME="S50gdb-server"
BUILD_PATH="$(pwd)/gdb-build"
CURRENT_PATH="$(pwd)"
MPC_VERSION="1.3.1" # Define MPC version as a variable
GMP_VERSION="6.2.1" # Define GMP version as a variable
MPFR_VERSION="4.2.2" # Define MPFR version as a variable
GDB_VERSION="12.1" # Define GDB version as a variable

# Function to display help
function display_help() {
  echo "Usage: $0 -t <toolchain_file> [-p <install_path>] [-h]"
  echo ""
  echo "Options:"
  echo "  -t <toolchain_file>   Specify the toolchain file (required)."
  echo "  -p <install_path>     Specify the installation path (optional, default: $(pwd)/work)."
  echo "  -h                    Display this help message and exit."
  exit 0
}

# Option handling
while getopts "t:p:" opt; do
  case $opt in
    t)
      TOOLCHAIN_FILE="$OPTARG"
      ;;
    p)
      INSTALL_PATH="$OPTARG"
      ;;
     h)
      display_help
      ;;
    *)
      display_help
      ;;
  esac
done

# Debugging: Print INSTALL_PATH
echo "INSTALL_PATH=$INSTALL_PATH"

# Check TOOLCHAIN_FILE
if [ -z "$TOOLCHAIN_FILE" ]; then
  echo "Error: Toolchain file not specified. Use -t option."
  exit 1
fi

# Load TOOLCHAIN_FILE
if [ -f "$TOOLCHAIN_FILE" ]; then
  source "$TOOLCHAIN_FILE"
else
  echo "Error: Toolchain file '$TOOLCHAIN_FILE' not found."
  exit 1
fi

# Debugging: Print environment variables
echo "TOOLCHAIN_NAME=$TOOLCHAIN_NAME"
echo "TOOLCHAIN_ROOT=$TOOLCHAIN_ROOT"
echo "CC=$CC"
echo "CXX=$CXX"
echo "AR=$AR"
echo "LD=$LD"
echo "NM=$NM"
echo "RANLIB=$RANLIB"
echo "STRIP=$STRIP"

# Check GCC support for C++17 and set CXXFLAGS
echo "Checking GCC support for C++17..."
if ${CXX} -std=c++17 -o /dev/null test.cpp >/dev/null 2>&1; then
  CXXFLAGS="-std=c++17"
  echo "C++17 is supported. Using CXXFLAGS=${CXXFLAGS}"
else
  echo "C++17 is not supported. Falling back to C++11..."
  CXXFLAGS="-std=c++11"
  echo "Using CXXFLAGS=${CXXFLAGS}"
fi

# Check and create ${BUILD_PATH} directory
if [ ! -d "${BUILD_PATH}" ]; then
  echo "${BUILD_PATH} does not exist. Creating..."
  mkdir -p "${BUILD_PATH}"
else
  echo "${BUILD_PATH} already exists."
fi
cd "${BUILD_PATH}"

# Check and download mpc-${MPC_VERSION}.tar.gz
if [ ! -f "${BUILD_PATH}/mpc-${MPC_VERSION}.tar.gz" ]; then
  echo "mpc-${MPC_VERSION}.tar.gz not found in ${BUILD_PATH}. Downloading..."
  wget -P "${BUILD_PATH}" "https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz"
else
  echo "mpc-${MPC_VERSION}.tar.gz already exists in ${BUILD_PATH}."
fi

# Check and remove mpc-${MPC_VERSION} directory
if [ -d "${BUILD_PATH}/mpc-${MPC_VERSION}" ]; then
  echo "mpc-${MPC_VERSION} directory exists. Removing..."
  rm -rf "${BUILD_PATH}/mpc-${MPC_VERSION}"
fi

# Extract mpc-${MPC_VERSION}.tar.gz
echo "Extracting mpc-${MPC_VERSION}.tar.gz..."
tar -xzf "${BUILD_PATH}/mpc-${MPC_VERSION}.tar.gz" -C "${BUILD_PATH}"

cd mpc-${MPC_VERSION}
./configure --host=${TOOLCHAIN_NAME} \
CC="${CC}" \
AR="${AR}" \
LD="${LD}" \
NM="${NM}" \
RANLIB="${RANLIB}" \
STRIP="${STRIP}" \
--prefix=${INSTALL_PATH} \
--disable-assembly
make -j$(nproc)
make install

# Check and download gmp-${GMP_VERSION}.tar.xz
if [ ! -f "${BUILD_PATH}/gmp-${GMP_VERSION}.tar.xz" ]; then
  echo "gmp-${GMP_VERSION}.tar.xz not found in ${BUILD_PATH}. Downloading..."
  wget -P "${BUILD_PATH}" "https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.xz"
else
  echo "gmp-${GMP_VERSION}.tar.xz already exists in ${BUILD_PATH}."
fi

# Check and remove gmp-${GMP_VERSION} directory
if [ -d "${BUILD_PATH}/gmp-${GMP_VERSION}" ]; then
  echo "gmp-${GMP_VERSION} directory exists. Removing..."
  rm -rf "${BUILD_PATH}/gmp-${GMP_VERSION}"
fi

# Extract gmp-${GMP_VERSION}.tar.xz
echo "Extracting gmp-${GMP_VERSION}.tar.xz..."
tar -xf "${BUILD_PATH}/gmp-${GMP_VERSION}.tar.xz" -C "${BUILD_PATH}"

cd gmp-${GMP_VERSION}
./configure --host=${TOOLCHAIN_NAME} \
CC="${CC}" \
AR="${AR}" \
LD="${LD}" \
NM="${NM}" \
RANLIB="${RANLIB}" \
STRIP="${STRIP}" \
--prefix=${INSTALL_PATH} \
--disable-assembly
make -j$(nproc)
make install

cd "${BUILD_PATH}"

# Check and download mpfr-${MPFR_VERSION}.tar.xz
if [ ! -f "${BUILD_PATH}/mpfr-${MPFR_VERSION}.tar.xz" ]; then
  echo "mpfr-${MPFR_VERSION}.tar.xz not found in ${BUILD_PATH}. Downloading..."
  wget -P "${BUILD_PATH}" "https://www.mpfr.org/mpfr-current/mpfr-${MPFR_VERSION}.tar.xz"
else
  echo "mpfr-${MPFR_VERSION}.tar.xz already exists in ${BUILD_PATH}."
fi

# Check and remove mpfr-${MPFR_VERSION} directory
if [ -d "${BUILD_PATH}/mpfr-${MPFR_VERSION}" ]; then
  echo "mpfr-${MPFR_VERSION} directory exists. Removing..."
  rm -rf "${BUILD_PATH}/mpfr-${MPFR_VERSION}"
fi

# Extract mpfr-${MPFR_VERSION}.tar.xz
echo "Extracting mpfr-${MPFR_VERSION}.tar.xz..."
tar -xf "${BUILD_PATH}/mpfr-${MPFR_VERSION}.tar.xz" -C "${BUILD_PATH}"

cd mpfr-${MPFR_VERSION}
./configure --host=${TOOLCHAIN_NAME} \
CC="${CC}" \
AR="${AR}" \
LD="${LD}" \
NM="${NM}" \
RANLIB="${RANLIB}" \
STRIP="${STRIP}" \
--prefix=${INSTALL_PATH} \
--with-gmp=${INSTALL_PATH}
make -j$(nproc)
make install

cd "${BUILD_PATH}"

# Check and download gdb-${GDB_VERSION}.tar.xz
if [ ! -f "${BUILD_PATH}/gdb-${GDB_VERSION}.tar.xz" ]; then
  echo "gdb-${GDB_VERSION}.tar.xz not found in ${BUILD_PATH}. Downloading..."
  wget -P "${BUILD_PATH}" "https://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.xz"
else
  echo "gdb-${GDB_VERSION}.tar.xz already exists in ${BUILD_PATH}."
fi

# Check and remove gdb-${GDB_VERSION} directory
if [ -d "${BUILD_PATH}/gdb-${GDB_VERSION}" ]; then
  echo "gdb-${GDB_VERSION} directory exists. Removing..."
  rm -rf "${BUILD_PATH}/gdb-${GDB_VERSION}"
fi

# Extract gdb-${GDB_VERSION}.tar.xz
echo "Extracting gdb-${GDB_VERSION}.tar.xz..."
tar -xf "${BUILD_PATH}/gdb-${GDB_VERSION}.tar.xz" -C "${BUILD_PATH}"

# Configure and build GDB
cd "${BUILD_PATH}"
cd "gdb-${GDB_VERSION}"

./configure --host=${TOOLCHAIN_NAME} \
CC="${CC}" \
CXX="${CXX}" \
AR="${AR}" \
LD="${LD}" \
NM="${NM}" \
RANLIB="${RANLIB}" \
STRIP="${STRIP}" \
CXXFLAGS="${CXXFLAGS}" \
LDFLAGS="-lstdc++" \
--prefix="${INSTALL_PATH}" \
--enable-lto \
--enable-gdbserver \
--enable-threading \
--with-mpc=${INSTALL_PATH} \
--with-gmp=${INSTALL_PATH} \
--with-mpfr=${INSTALL_PATH}
make -j$(nproc)
make install

# Check and create archive
if [ "${INSTALL_PATH}" = "${CURRENT_PATH}/work" ]; then
  # Check and remove existing archive
  if [ -f "${CURRENT_PATH}/${ARCHIVE_NAME}" ]; then
    echo "${CURRENT_PATH}/${ARCHIVE_NAME} already exists. Removing..."
    rm -f "${CURRENT_PATH}/${ARCHIVE_NAME}"
  fi

  # Create archive
  echo "Creating archive ${ARCHIVE_NAME} from ${INSTALL_PATH}..."
  tar -czvf ${CURRENT_PATH}/${ARCHIVE_NAME} ${INSTALL_PATH}
else
  echo "Skipping archive creation. INSTALL_PATH is not $(pwd)/work."
fi