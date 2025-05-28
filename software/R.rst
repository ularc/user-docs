Installing R Packages in Custom Locations
=========================================

By default, R modules store packages in system directories that users cannot write to. As a result, commands like:

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
