.. _gaussian:

Using Gaussian
==============

The cluster provides the following versions of Gaussian:

- **16-A.03**: ``gaussian/16-A.03``

Running Gaussian
================

Example Slurm Job Script
------------------------

.. code-block:: bash

    #!/bin/bash
    #SBATCH --job-name=gaussian_gpu
    #SBATCH --partition=gpu
    #SBATCH --nodes=1
    #SBATCH --gpus-per-node=2
    #SBATCH --ntasks-per-node=2
    #SBATCH --cpus-per-task=24
    #SBATCH --gpus-per-task=1
    #SBATCH --time=02:00:00
    #SBATCH --output=gaussian_%j.out
    #SBATCH --error=gaussian_%j.err

    module load gaussian/16-A.03

    ## INSERT YOUR JOB HERE - EXAMPLE JOB IS IN DEVELOPMENT ##