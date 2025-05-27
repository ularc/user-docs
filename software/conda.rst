.. _conda:

The Conda installer
===================

The Conda installer is a package manager and environment manager for
Python, R, and other languages. It comes in 3 flavors:

- **Anaconda:** The Anaconda (company) driven Conda installer with hundreds of scientific packages included.
- **Miniconda:** The Anaconda (company) driven minimalistic Conda installer including only Python by default.
- **Miniforge:** The community (conda-forge) driven minimalistic Conda installer
  using the ``conda-forge`` channel by default.

LARCC only offers support for **Miniforge** as it works just like Anaconda
or Miniconda but is lightweight and specifically built to support
open-source and customizable environments. Compared to the other 2, it:

- is smaller than Anaconda (no preinstalled packages).
- does not rely on the default Anaconda channel, which can sometimes have licensing issues.
- uses conda-forge as its default channel—a large, community-maintained repository of conda packages.

Using Conda
===========

Here are some useful conda commands users are encouraged to get familiar with:

.. list-table:: Some useful Conda commands
   :widths: 40 50
   :header-rows: 1

   * - Command
     - Meaning
   * - ``conda create --name my_env PCKAGE1 PACKAGE2``
     - Create a new environment named ``my_env``, install packages ``PCKAGE1`` and ``PACKAGE2``
   * - ``conda activate my_env``
     - Activate environment ``my_env`` to use packages installed in it
   * - ``conda deactivate``
     - Deactivate a currently activated environment. You can only have one environment activated
       at once, so there is not need to name the environment you want to deactivate.
   * - ``conda env list``
     - Get a list of all available environments. Active environment is shown with *
   * - ``conda env remove --name my_env``
     - Remove environment ``my_env`` and everything in it
   * - ``conda install PACKAGE``
     - Install a package. You can also specify the version of the package by using
       the syntax ``PACKAGE=version``. For example, ``conda install python=3.15``. 
   * - ``conda update PACKAGE``
     - Update a package
   * - ``conda search PACKAGE``
     - Search for package

As an example, a typical workflow for python looks like this:

.. code-block:: bash

    module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym
    # Create a custom environment. In this case, create
    # an environment named "my_env" and install packages
    # numpy and scipy
    conda create --name my_env python=3.11 numpy scipy
    # Activate the environment "my_env"
    conda activate my_env
    # Suppose you realized you need the pandas package.
    # So, install it!
    conda install pandas

