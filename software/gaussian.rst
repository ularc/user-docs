.. _gaussian:

Using Gaussian
==============

The cluster provides the following versions of Gaussian:

- **16-A.03**: ``module load gaussian/16-A.03``

Running Gaussian
================

When loading a gaussian module, the ``GAUSS_SCRDIR`` is automatically set to your scratch
space: ``/mnt/scratch/local/$USER`` (see :ref:`our storage guide <storage-on-compute-nodes>` for more information). If you
want to overwrite this value to use a different directory (e.g. ``/mnt/scratch/local/$USER/gaussian``):

- ensure the folder pointed to by ``GAUSS_SCRDIR`` exists. Keep in mind that your scratch folder ``/mnt/scratch/local/$USER`` is local to each node,
  deleted at the end of each job and created when starting a new job (see :ref:`our storage guide <storage-on-compute-nodes>` for more information).
- do so **AFTER** loading the module, else your change will have no effect. For example,

.. code-block:: bash

    # This works
    mkdir -p /mnt/scratch/local/$USER/gaussian
    module load gaussian/16-A.03
    export GAUSS_SCRDIR="/mnt/scratch/local/$USER/gaussian"

    # This does not
    mkdir -p /mnt/scratch/local/$USER/gaussian
    export GAUSS_SCRDIR="/mnt/scratch/local/$USER/gaussian"
    module load gaussian/16-A.03

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