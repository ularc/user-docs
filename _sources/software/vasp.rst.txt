Using VASP
==========

The cluster provides two GPU-enabled versions of VASP:

- **6.4.3**: ``vasp/6.4.3-nvhpc-25.5-mkl-2025.1``
- **6.5.1**: ``vasp/6.5.1-nvhpc-25.5-mkl-2025.1``

Both are optimized for GPU usage and should be run in the ``gpu`` partition.

License Restrictions
====================

VASP is licensed software. Only users in the ``vasp`` group are authorized to use it.
To check your group membership run the command ``groups``.

If you're not a member and attempt to load a VASP module, you'll see an error like:

.. code-block:: text

    Lmod has detected the following error:  Access denied: user '<username>' is not in group 'vasp' 
    While processing the following module(s):
        Module fullname                   Module Filename
        ---------------                   ---------------
        vasp/6.5.1-nvhpc-25.5-mkl-2025.1  /opt/shared/modulefiles/manual/vasp/6.5.1-nvhpc-25.5-mkl-2025.1.lua

Running VASP
============

VASP is designed to run with one MPI process per GPU. Each process spawns multiple OpenMP threads,
ideally bound to separate CPU cores. For example, on a node with 2 GPUs and 48 CPU cores, use:

- **2 MPI processes** (1 per GPU)
- **24 OpenMP threads per process** (48 cores / 2 processes)

This ensures optimal utilization of both CPU and GPU resources.

Example Slurm Job Script
------------------------

.. code-block:: bash

    #!/bin/bash
    #SBATCH --job-name=vasp_gpu
    #SBATCH --partition=gpu
    #SBATCH --nodes=1
    #SBATCH --gpus-per-node=2
    #SBATCH --ntasks-per-node=2
    #SBATCH --cpus-per-task=24
    #SBATCH --gpus-per-task=1
    #SBATCH --time=02:00:00
    #SBATCH --output=vasp_%j.out
    #SBATCH --error=vasp_%j.err

    ulimit -l unlimited

    module load vasp/6.4.3-nvhpc-25.5-mkl-2025.1

    # Path to your VASP executable. You can use either of:
    # vasp_gam, vasp_ncl, or vasp_std
    # NOTE: The VASP_ROOT variable is set by the VASP module above.
    VASP_EXEC=$VASP_ROOT/bin/vasp_gam

    mpirun -np $SLURM_NTASKS --map-by node:PE=$SLURM_CPUS_PER_TASK --bind-to core \
        -x OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK \
        -x OMP_STACKSIZE=512m \
        -x OMP_PLACES=cores \
        -x OMP_PROC_BIND=close \
        $VASP_EXEC ...
