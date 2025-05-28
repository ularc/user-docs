Using R
=======

There are two ways to use R in the cluster:

#. Using a Conda environment (see our :ref:`Conda documentation<conda>` for more information).
#. Using a cluster provided module.

If a version of R you require is not available as a module, you should use Conda
to create a custom environment with the precise version you need:

#. Load the Miniconda module: ``module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym``.
#. Create an environment for R: ``conda create --name R_env``.
   See :ref:`this <conda_create_env>` section of our Conda documentation for more information on
   creation environments.
#. Activate newly created environment: ``conda activate R_env``.
#. Install ``r`` and ``r-essentials``: ``conda install r r-essentials``.
   See :ref:`this <conda_install_pkgs>` section of our Conda documentation for more information on specifying
   a particular version or R you want installed.
#. You can then launch R! We recommend installing packages using ``pak``
   (See Section :ref:`Using the pak Package Manager <r_pak_manager>` for more information).

If you are using a module, then you can start using R right after loading the module. When installing
packages, however, you need to provide a custom installation location.
See Section :ref:`Installing R packages in lustom locations <r_custom_install_location>` for more
information.

.. _r_custom_install_location:

Installing R packages in custom locations
=========================================

**If you are using an R module as opposed to Conda**,
R packages are stored by default in system directories that users cannot write to.
As a result, commands like:

.. code-block:: R

    install.packages("readr")
    install.packages(c("readr", "ggplot2", "tidyr"))

will fail with a "permission denied" error.

To install packages successfully, you should specify a custom library path—typically within your home directory:

1. Create a directory for your R packages (adjust the version as needed):

   .. code-block:: bash

       mkdir -p /home/user/R_lib/4.4.1

2. Launch R and install packages to that directory:

   .. code-block:: R

       install.packages(c("readr", "ggplot2", "tidyr"), lib="/home/user/R_lib/4.4.1")
       library("readr", lib.loc="/home/user/R_lib/4.4.1")

.. _r_pak_manager:

Using the `pak` Package Manager
-------------------------------

While ``install.packages()`` works for CRAN, many workflows require packages from Bioconductor, GitHub, or custom sources.
Tools like ``remotes``, ``devtools``, and ``BiocManager`` help, but managing dependencies across them can be complex.

We recommend using ``pak``, a unified package manager that supports CRAN, Bioconductor, GitHub, URLs, git repositories, and local files.
It simplifies installation and improves dependency handling.

Example usage:

.. code-block:: R

    # Install pak to your custom library
    install.packages("pak", lib="/home/user/R_lib/4.4.1")
    library("pak", lib.loc="/home/user/R_lib/4.4.1")

    # Install from CRAN or Bioconductor
    pak::pkg_install("ggplot2", lib="/home/user/R_lib/4.4.1")

    # Install from GitHub
    pak::pkg_install("tidyverse/tibble", lib="/home/user/R_lib/4.4.1")
