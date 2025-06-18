.. _gaussian:

Using Gaussian
==============

The cluster provides the following versions of Gaussian:

- **16-A.03**: ``gaussian/16-A.03``

Please note that a scratch directory (GAUSS_SCRDIR) must be present,
therefore please use an interactive slurm session to do your testing
as the login node does not have access to a scratch directory at this time.

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
    module load openmpi

    # Set Gaussian scratch directory
    # The default is "/mnt/scratch/local/$USER"
    export GAUSS_SCRDIR=/mnt/scratch/local/$USER/gaussian_scratch
    mkdir -p $GAUSS_SCRDIR

    # Gaussian input file
    INPUTFILE="molecule.com"

    # Run Gaussian with MPI support
    mpirun -np $SLURM_NTASKS g16 < $INPUTFILE > molecule.log