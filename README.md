# GDB Server Build and Packaging Script

This script automates the process of downloading, building, and packaging the GDB server. It ensures that the GDB server is properly configured and installed in the specified directory.

---

## Features

1. **Download and Extract GDB Source**:

   - Checks if the GDB source archive (`gdb-${GDB_VERSION}.tar.xz`) exists in the build directory.
   - Downloads the archive from the GNU FTP server if it does not exist.
   - Extracts the archive into the build directory.
2. **Build and Install GDB**:

   - Configures the GDB build with the specified toolchain and dependencies.
   - Builds the GDB server using `make` with parallel jobs.
   - Installs the built GDB server into the specified installation path.
3. **Create Archive**:

   - If the installation path matches the default (`$(pwd)/work`), creates a compressed archive (`tar.gz`) of the installed files.
   - Removes any existing archive before creating a new one.

---

## Script Workflow

## Usage

The `build_gdbserver_and_package.sh` script automates the process of building and packaging the GDB server along with its dependencies. Below is the usage information for the script:

```bash
Usage: ./build_gdbserver_and_package.sh -t <toolchain_file> [-p <install_path>] [-h]
```

Exmaple:
The following is an example of building GDB for a toolchain based on the Ambarella CV2 SoC(System on Chip).

```bash
./build_gdbserver_and_package.sh -t cv2x.toolchain -f /home/user1/workspace/cv2/examples/work
```

## Toolchain Configuration

The `toolchain` file defines the environment variables required for cross-compiling projects targeting a specific architecture. It ensures that the correct compilers, linkers, and other tools are used during the build process.

### Purpose

The toolchain configuration is essential for cross-compilation, where the build system (host) differs from the target system. By setting up the appropriate environment variables, the toolchain ensures that the build process uses the correct tools for the target architecture.

### Key Variables

The following variables are defined in the `toolchain` file:

- **`TOOLCHAIN_ROOT`**:
  Specifies the root directory where the toolchain binaries are located.
  Example:

  ```plaintext
  TOOLCHAIN_ROOT="/usr/local/linaro-aarch64-2020.09-gcc10.2-linux5.4/bin"
  ```
- **`TOOLCHAIN_NAME`**:
  Defines the prefix used for the toolchain binaries.
  Example:

  ```plaintext
  TOOLCHAIN_NAME="aarch64-linux-gnu"
  ```
- **`Compiler and Tools:`**:
  The following tools are configured using the TOOLCHAIN_ROOT and TOOLCHAIN_NAME variables:

  ```plaintext
  CC: C compiler (${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}-gcc)
  CXX: C++ compiler (${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}-g++)
  AR: Archiver (${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}-ar)
  LD: Linker (${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}-ld)
  NM: Symbol table dumper (${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}-nm)
  RANLIB: Static library index generator (${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}-ranlib)
  STRIP: Debug symbol remover (${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}-strip)
  ```

### Usage

To use the toolchain configuration, source the toolchain file in your shell or build script before starting the build process:

This will set up the necessary environment variables for cross-compilation. After sourcing the file, you can use tools like make or cmake to build your project with the specified toolchain.

- **`Example`**:
  Here is an example of using the toolchain file in a build process:

  ```plaintext
  # Source the toolchain file
  source toolchain

  # Run the build process
  make
  ```


## Description of `launch.json`

### Purpose

The `launch.json` file is a configuration file used to set up the debugging environment in Visual Studio Code. This file defines the target program for debugging, the debugger path, remote debugging settings, and more. It is particularly useful for supporting remote debugging with a GDB server in cross-platform environments.

---

### 주요 필드 설명

1. `version`
   * Specifies the version of the configuration file.
   * Example: `"0.2.0"`
2. `configurations`
   * An array of debugging configurations. Each configuration defines a specific debugging environment.
3. `name`
   * The name of the debugging configuration. This name is used to select the configuration in the Visual Studio Code debugging menu.
   * Example: `"Attach to gdbserver (CV2 ARM)"`
4. `type`
   * Specifies the type of debugging. For C/C++ debugging, set it to `"cppdbg"`
5. `request`
   * Specifies the type of debugging request.
     * `"launch"`: Starts a new debugging session.
     * `"attach"`: Attaches to an already running target for debugging.
   * Example: `"launch"`
6. `program`
   * Specifies the path to the executable file to debug.
   * Example:
    ```plaintext
     "${workspaceFolder}/cv2x/bsp/rootfilesystem/nfsroot/cv2x/work/app/cv2xexample"
     ````
    This represents the path to the ELF file containing debugging symbols.
7. `miDebuggerServerAddress`
   * Specifies the IP address and port of the remote GDB server.
   * Example:
   ```plaintext
   "192.168.214.40:1234"`
   ```
    This indicates the IP and port of the remote device where the GDB server is running.
8. `miDebuggerPath`
   * Specifies the path to the GDB debugger.
   * Example:
    ```plaintext
     "/usr/bin/gdb-multiarch"
    ```
     or
    ```plaintext
     "aarch64-linux-gnu-gdb"
    ```
    This represents the path to the GDB debugger running locally.
9. `cwd`
   * Specifies the current working directory for the debugging session.
   * Example:
    ```plaintext
     "${workspaceFolder}/cv2x/bsp/rootfilesystem/nfsroot/cv2x/work/app"
     ```
10. `targetArchitecture`
    * Specifies the architecture of the debugging target.
    * Example:
    ```plaintext
    "arm64"
    ```
    This represents the ARM 64-bit architecture. It can also be set to `"arm"` if needed.
11. `stopAtEntry`
    * Specifies whether to stop at the program's entry point when debugging starts.
    * Example:
    ```plaintext
    `true`
    ```
12. `externalConsole`
    * Specifies whether to use an external console during debugging.
    * Example:
    ```plaintext
    `false`
    ```

---

### How to Use

1. **Create the File**
   Create a `launch.json` file in the `.vscode` directory of your project.
   Path: `${workspaceFolder}/.vscode/launch.json`
2. **Add Configurations** Add debugging configurations as shown in the examples above.
3. **Run Debugging**
   * Open the **Run and Debug** menu in Visual Studio Code and select the created debugging configuration.
   * Press `F5` to start debugging.

---

### Example

Below is an example configuration for debugging a program running on an ARM 64-bit architecture using a remote GDB server.

```plaintext
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Attach to gdbserver (CV2 ARM)",
      "type": "cppdbg",
      "request": "launch",
      "program": "${workspaceFolder}/cv2x/bsp/rootfilesystem/nfsroot/cv2x/work/app/cv2xexample",
      "miDebuggerServerAddress": "192.168.214.40:1234",
      "miDebuggerPath": "/usr/bin/gdb-multiarch",
      "cwd": "${workspaceFolder}/cv2x/bsp/rootfilesystem/nfsroot/cv2x/work/app",
      "targetArchitecture": "arm64",
      "stopAtEntry": true,
      "externalConsole": false
    }
  ]
}
```

---

### Notes

* **GDB Server** : You need to run `gdbserver` on the remote device. Example:
  ```plaintext
  gdbserver :1234 ./cv2xexample
  ```
* **Debugging Symbols** : The executable file `cv2xexample` must include debugging symbols.
* **Network Connection** : A network connection between the local machine and the remote device is required.
* **Debugger Path** : Ensure that the path to the GDB debugger installed on the local machine is correctly set in `miDebuggerPath`.
* 

### Ubuntu gdb build for Multi Architecture for aarch64/armv8-a

### 🔧 Building GDB 13.2 with AArch64 support and GMP/MPFR/MPC on Ubuntu 18.04

### 🖥️ Configuring VS Code for remote AArch64 debugging

### 🌐 Running gdbserver on the remote AArch64 device

### 🧱 Building GDB 13.2 with AArch64 and GMP/MPFR/MPC Support on Ubuntu 18.04
#### 1. Install required dependencies
```
sudo apt update
sudo apt install build-essential texinfo libncurses-dev python3-dev zlib1g-dev \
                 libgmp-dev libmpfr-dev libmpc-dev
```
These libraries enable advanced math support and expression parsing in GDB.

#### 2. Download and extract GDB source
```
wget https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.gz
tar -xvzf gdb-13.2.tar.gz
cd gdb-13.2
```
#### 3. Configure and build GDB with multiarch support
```
./configure --prefix=/opt/gdb-13.2 --enable-targets=all \
            --with-gmp --with-mpfr --with-mpc
make -j$(nproc)
sudo make install
```
The --enable-targets=all flag ensures support for multiple architectures including AArch64.

#### 4. Verify installation
```
/opt/gdb-13.2/bin/gdb --version
ldd /opt/gdb-13.2/bin/gdb | grep -E 'gmp|mpfr|mpc'
```
### 🖥️ VS Code Configuration for Remote AArch64 Debugging
Create or edit .vscode/launch.json in your project folder:

```
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Remote Debug (AArch64)",
      "type": "cppdbg",
      "request": "launch",
      "program": "${workspaceFolder}/myapp",  // Local binary with debug symbols
      "miDebuggerPath": "/opt/gdb-13.2/bin/gdb",  // Path to GDB 13.2
      "miDebuggerServerAddress": "192.168.214.34:1234",  // Remote gdbserver address
      "cwd": "${workspaceFolder}",
      "setupCommands": [
        {
          "description": "Set architecture to AArch64",
          "text": "set architecture aarch64",
          "ignoreFailures": false
        },
        {
          "description": "Load symbol file",
          "text": "file ${workspaceFolder}/myapp",
          "ignoreFailures": false
        }
      ],
      "stopAtEntry": true,
      "externalConsole": false
    }
  ]
}
```
### 🌐 Running gdbserver on the Remote AArch64 Device
#### 1. Install gdbserver
```
sudo apt update
sudo apt install gdbserver
```
#### 2. Transfer the target binary
Copy the debug-enabled binary (myapp) to the remote device:

```
scp myapp user@remote-device:/home/user/
```
#### 3. Launch gdbserver on the remote device
```
gdbserver :1234 ./myapp
```
Or attach to a running process:

```
gdbserver :1234 --attach <PID>
```
#### 4. Optional: Use SSH port forwarding
If direct access to port 1234 is blocked:

```
ssh -L 1234:localhost:1234 user@remote-device
```
