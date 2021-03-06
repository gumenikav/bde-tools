=========
Tutorials
=========

.. _tutorials-build_bde:

Use waf to Build BDE
====================

.. note::

   The following instruction assumes that you are running a unix
   platform. Building on windows is similar, except you must use the equivalent
   commands in windows command prompt. For more details, please see
   :ref:`waf-windows`.

First, clone the bde and bde-tools repositores from `github
<https://github.com/bloomberg/bde>`_:

::

   $ git clone https://github.com/bloomberg/bde.git
   $ git clone https://github.com/bloomberg/bde-tools.git

Then, add the ``<bde-tools>/bin`` to the ``PATH`` environment variable:

::

   $ export PATH=<bde-tools>/bin:$PATH

.. note::

   Instead of adding ``bde-tools/bin`` to your ``PATH``, you can also execute
   the scripts in ``bde-tools/bin`` directly.

Now, go to the root of the bde repository and build the libraries in it:

::

    $ cd <bde>
    $ waf configure
    $ waf build --target bslstl  # build just the bslstl package
    $ waf build  # build all libraries
    $ waf build --test build  # build all test drivers
    $ waf build --test run  # run all test drivers

The linked libraries, test drivers, and other build artifacts should be in the
build output directory, which by default is just "build".

See :ref:`waf-top` for detailed reference.

.. _tutorials-setwafenv-bde:

Use bde_setwafenv.py to Build BDE
=================================

First, specify the compilers available on your system in a
``~/.bdecompilerconfig``.  Here is an example:

::

   [
        {
            "hostname": ".*",
            "uplid": "unix-linux-",
            "compilers": [
                {
                    "type": "gcc",
                    "c_path": "/opt/swt/install/gcc-4.7.2/bin/gcc",
                    "cxx_path": "/opt/swt/install/gcc-4.7.2/bin/g++",
                    "version": "4.7.2"
                },
                {
                    "type": "gcc",
                    "c_path": "/opt/swt/install/gcc-4.3.5/bin/gcc",
                    "cxx_path": "/opt/swt/install/gcc-4.3.5/bin/g++",
                    "version": "4.3.5"
                },
                {
                    "type": "gcc",
                    "c_path": "/usr/bin/gcc",
                    "cxx_path": "/usr/bin/g++",
                    "version": "4.1.2"
                }
            ]
        }
   ]

See :ref:`setwafenv-compiler_config` for more details.

Then, follow the instructions from :ref:`tutorials-build_bde` to checkout bde
and bde-tools and add bde-tools/bin to your PATH.

Next, use ``bde_setwafenv.py`` to set up the environment variables:

::

   $ eval $(bde_setwafenv.py -i /tmp/bde-install -t dbg_mt_exc_64 -c gcc-4.7.2)

   using configuration: /home/che2/.bdecompilerconfig
   using compiler: gcc-4.7.2
   using ufid: dbg_exc_mt_64
   using install directory: /tmp/bde-install

.. note::

   Here we choose to use :ref:`bde_repo-ufid` to specify the build
   configuration.  You can also use the :ref:`qualified configuration options
   <waf-qualified_build_config>`.

The actual environment variables being set will depend on your machine's
platform :ref:`bde_repo-uplid`. On my machine, the following Bourne shell
commands are evaluated to set the environment variables:

::

   export BDE_WAF_UPLID=unix-linux-x86_64-3.2.0-gcc-4.7.2
   export BDE_WAF_UFID=dbg_exc_mt_64
   export BDE_WAF_BUILD_DIR="unix-linux-x86_64-3.2.0-gcc-4.7.2-dbg_exc_mt_64"
   export WAFLOCK=".lock-waf-unix-linux-x86_64-3.2.0-gcc-4.7.2-dbg_exc_mt_64"
   export CXX=/usr/bin/g++
   export CC=/usr/bin/gcc
   export PREFIX="/tmp/bde-install/unix-linux-x86_64-3.2.0-gcc-4.7.2-dbg_exc_mt_64"
   export PKG_CONFIG_PATH="/tmp/bde-install/unix-linux-x86_64-3.2.0-gcc-4.7.2-dbg_exc_mt_64/lib/pkgconfig"
   unset BDE_WAF_COMP_FLAGS

Then, build BDE using waf:

::

   $ cd <bde>
   $ waf configure build

See :ref:`setwafenv-top` for detailed reference.

.. _tutorials-workspace:

Creating a New Application Using Waf
====================================

The following example demonstrates how to create a simple application `myapp`
that builds using 'waf'.  This example application consists of a simple 
"hello world" `main` and an empty component.

First we create a new directory 'workspace' that will hold our application::

   $ mkdir workspace
   $ cd workspace

Then we copy the default `wscript` file from `bde-tools`::

   $ cp path/to/bde-tools/share/wscript ./

Then we create a basic physcial organization of directories for our
application.  A reference for the physical organization is here: 
:ref:`bde_repo-physical_layout`.  Since this is an application,
we will create a directory `myapp` under the `applications` directory.  This 
application will have 1 component `mycomponent` and a `main` located in 
`myapp.m.cpp`.  The resulting directory structure should look like::

   |-- applications
   |   `-- myapp
   |       |-- myapp.m.cpp
   |       |-- mycomponent.cpp
   |       |-- mycomponent.h
   |       |-- mycomponent.t.cpp
   |       `-- package
   |           |-- myapp.dep
   |           `-- myapp.mem
   `-- wscript

**myapp.m.cpp**
    This file contains the `main` of the application (as indicated by the 
    `.m.cpp` filename suffix).  Note that is the one artifact containing
    C++ code that is not in a component.  For the moment it contains:

::

   #include <iostream>
   int main()
   {
       std::cout << "hello world" << std::endl;
   }
   
**mycomponent.h/.cpp/.t.cpp**
    A simple component -- empty files for the purposes of illustration.

**package**
    A directory containing :ref:`bde_repo-metadata` for the application.

**myapp.dep**
    A list of dependencies for the application ( :ref:`bde_repo-dep` ).  
    Currently empty.  An example `dep` file for a project using BDE might be:

::

   bsl
   bdl
   bal
   btl

**myapp.mem**
    A list of components in the package ( :ref:`bde_repo-mem` ).  Currently:

::

   mycomponent   # currently the only component

Notice that its possible to configure the top-level directory names (here, 
`application`) by supplying a `.bdelayoutconfig`.  See 
:ref:`bde_repo-layout_customize`.


Building myapp
--------------

From the top-level workspace directory we can now run `waf configure`:

:: 

   $ waf configure
   ...
   # UORs, inner packages, and components   : 1 0 1

Notice that `waf configure` is reporting 1 UOR (unit-of-release), which is
our application, and 1 component (the empty `mycomponent`).

Then we can build our application::

   $ waf build
   [5/5] Linking path/to/executable/applications/myapp/myapp

Finally we can run it::

   $ path/to/executable/applications/myapp/myapp
   hello world

Use waf Workspace to Build Multiple BDE-Style Repositories
==========================================================

You can you the workspace feature to build multiple BDE-style repositories in
the same way as a single repository (see :ref:`waf-workspace`)

For example, suppose that you have the following BDE-style repositories that
that you want to build together: ``bsl-internal``, ``bde-core``, and
``bde-bb``.

First, create a directory to serve as the root of the workspace, say
``myworkspace``:

::

   $ mkdir myworkspace

Then, check out the repositories that will be part of the workspace:

::

   $ cd myworkspace
   $ git clone <bsl-internal-url>
   $ git clone <bde-core-url>
   $ git clone <bde-bb-url>

Next, add a empty file named ``.bdeworkspaceconfig`` and copy
``bde-tools/share/wscript`` to the root of the workspace:

::

   $ touch .bdeworkspaceconfig
   $ cp <bde-tools>/share/wscript .

The workspace should now have the following layout:

::

   myworkspace
   |-- .bdeworkspaceconfig
   |-- wscript
   |-- bsl-internal
   |   |-- wscript
   |   `-- ...      <-- other files in bsl-internal
   |-- bde-core
   |   `-- ...      <-- files in bde-core
   `-- bde-bb
       `-- ...      <-- files in bde-bb


Now, you can build every repository in the workspace together:

::

   $ waf configure
   $ waf build

bde_setwafenv.py works the same way for a workspace as a regular repository.


.. note::

   You must be in the root directory of the workspace to build the workspace.
   If you go into a repository contained in the workspace, any waf commands
   will apply to that repository directly.

.. _tutorials-setwafenv-bde-app:

Use bde_setwafenv.py to Build an Application on Top of BDE
==========================================================

First, follow :ref:`tutorials-setwafenv-bde` to create
``~/.bdecompilerconfig``, set up the environment variables using
bde_setwafenv.py, and build BDE.

Then, install bde:

::

   $ cd <bde>
   $ waf install

On my machine, the headers, libraries, and pkg-config files are installed to
``/tmp/bde-install/unix-linux-x86_64-3.2.0-gcc-4.7.2-dbg_exc_mt_64``:

::

   /tmp/bde-install/unix-linux-x86_64-3.2.0-gcc-4.7.2-dbg_exc_mt_64
   |
   |-- include
   |   |
   |   `-- ...  <-- header files
   |
   `-- lib
    |
    |-- libbdl.a
    |-- libbsl.a
    |-- libdecnumber.a
    |-- libinteldfp.a
    `-- pkgconfig
        |
        |-- bdl.pc
        |-- bsl.pc
        |-- decnumber.pc
        `-- inteldfp.pc

Next, create a new repository containing the application that we are going to
be building.

::

   $ mkdir testrepo
   $ cd testrepo
   $ cp <bde-tools>/share/wscript .  # wscript is required for using waf

Then, create the following directory and file structure in the repo
(see :ref:`bde_repo-physical_layout` for more details):

::

   testrepo
   |
   |-- wscript
   `-- applications
      |
      `-- myapp
          |
          |-- myapp.m.cpp
          `-- package
              |
              |-- myapp.dep
              `-- myapp.mem

Contents of myapp.m.cpp:

::

    #include <bsl_vector.h>
    #include <bsl_iostream.h>

    int main(int, char *[])
    {
        bsl::vector<int> v;

        v.push_back(3);
        v.push_back(2);
        v.push_back(5);

        for (bsl::vector<int>::const_iterator iter = v.begin();
            iter != v.end();
            ++iter) {
            bsl::cout << *iter << bsl::endl;
        }

        return 0;
    }

Contents of myapp.dep:

::

   bsl # we depend on bsl

``myapp.mem`` should be empty because myapp doesn't contain any components
except the ``.m.cpp``, which is implicitly included in an application package.

Now, we can build this application using waf:

::

   $ cd <testrepo>
   $ waf configure
   $ waf build

.. _tutorials-setwafenv-bde-windows:

Use bde_setwafenv.py to Build BDE on Windows
============================================

bde_setwafenv.py can be used on Windows through Cygwin or Git for Windows (msysgit).

**Prerequisites**:

- `Cygwin <https://www.cygwin.com/>`_ or `Git for Windows (msysgit) <https://msysgit.github.io/>`_
- Windows and Cygwin versions of Python 2.6, 2.7, or 3.3+

First, make sure you have cloned the bde and bde-tools repositories, and that
you have added ``bde-tools/bin`` to your system's PATH.

Then, for Cygwin, export the WIN_PYTHON environment variable to point to the
*Cygwin* path of the *Windows* version of Python.  For example, if the Windows
version of Python is installed to ``C:\Python27\python``, then you can use the
following command to set up the required WIN_PYTHON environment variable:

::

   $ export WIN_PYTHON=/cygdrive/c/Python27/python

For msysgit, add Windows version of Python to the system PATH.

Next, in the Cygwin or msysgit bash shell, run the following command to set the
environment variables for waf:

::

   $ bde_setwafenv.py list  # list available compilers on windows
   $ eval $(bde_setwafenv.py -i ~/tmp/bde-install -c cl-18.00) # use visual studio 2013

.. note::

   On Windows, bde_setwafenv.py does not use ``~/.bdecompilerconfig``. Instead
   it uses a list of hard-coded available compilers on windows and do not check
   those compilers are available. It is your job to make sure that you are
   using an already installed Visual Studio compiler.

Now, you can build bde using ``waf`` in msysgit or ``cygwaf.sh`` in cygwin:

::

   $ cd <bde>

   # in msysgit
   $ waf configure
   $ waf build

   # in Cygwin
   $ cygwaf.sh configure
   $ cygwaf.sh build

.. important::

   Even though bde_setwafenv.py is supported on only Cygwin in Windows, Cygwin
   itself is not a supported build platform by :ref:`waf-top`.  Once
   bde_setwafenv.py is executed in Cygwin, ``bde-tools/bin/cygwaf.sh``
   (preferred) or ``bde-tools/bin/waf.bat`` must be used instead of executing
   ``waf`` directly. ``cygwaf.sh`` will invoke ``waf`` using the windows
   version of Python and build using the Visual Studio C/C++ compiler selected.
   You can download a free version of Visual Studio Express from `Microsoft
   <https://www.visualstudio.com/en-us/products/visual-studio-express-vs.aspx>`_.

.. TODO: Building an Library That Does Not Depend on BDE
.. TODO: Building an Application That Does Not Depend on BDE
