# ton-tools
---
This is a set of automated scripting tools for ton blockchain from TONCommunity, using these tools, you can compile the TON's source code, build your own Full-Node application, build Validator node, build Lite-Server and so on.

These automation tools are developed by Shell Script on Linux, so it is better for you to understand the basic command line operations on Linux system. And, in order to reduce unnecessary mistakes, we want your Linux operating system is CentOS 8.x or later, or Ubuntu 18.x or later.

---
setenv.sh&nbsp;&nbsp;&nbsp;&nbsp;--&nbsp;&nbsp; Define environment variables which are used in other script tools.

build.sh &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --&nbsp;&nbsp; Compile TON's source code and install relative program.

create-full-node.sh&nbsp;--&nbsp;&nbsp; Automatic build Full-Node program on your device.

start-full-node.sh&nbsp;--&nbsp;&nbsp; Full-Node program startup script.

install.sh&nbsp;--&nbsp;&nbsp; Install Full-Node program by ton binary file. 

---

Usage:

Stage 1 -- Modify `setenv.sh` according to your real environment variables

In this section, `PUBLIC_IP` is real public IPv4 address of your device, `TON_SRC_DIR` is a local directory to clone TON's source code, `TON_BUILD_DIR` is a local temporary directory to build TON's source code, `TON_ROOT_DIR` is a local directory to install TON's programs, `TON_WORK_DIR` is a local directory to save work data of ton blockchain. 

Then, we recommend setting all `TON_XXX_DIR` to SSD storage.

Stage 2 -- Compile and install TON programs

Now, you need to use `build.sh` script compilation and installation ton programs:

```
./build.sh
```

This process will take a long time, so you can have a drink of water first, Ha.

Stage 3 -- Create Full-Node application if you want

Now, if you want to create a Full-Node of ton blockchain, you can use the `fullnode.sh`:

```
./create-full-node.sh
```

