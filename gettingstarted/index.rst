HPC system overview
###################

About the cluster
=================

LARCC consists of 20 nodes that can be used for computation:

+-------------------+-----------+---------------+--------+
| Number of servers | CPU cores | GPU quantity  | Memory |
+===================+===========+===============+========+
| 10                | 128       | 0             | 502GB  |
+-------------------+-----------+---------------+--------+
| 10                | 48        | 2xNvidia H100 | 256GB  |
+-------------------+-----------+---------------+--------+

These nodes are named as follows:

- ``larcc-cpu1``, ``larcc-cpu2``, ..., ``larc-cpu10`` for nodes without any GPU.
- ``larcc-gpu1``, ``larcc-gpu2``, ..., ``larc-gpu10`` for nodes with GPUs.

In order to execute any kind of (scientific) software, such as Ansys, OpenFOAM, GROMACS, or others,
on these nodes, users must:

1. Log into a special node referred to hereinafter as the "login node" (see Section :ref:`logging-into-cluster` for more information).
2. Submit a *job declaration* to the scheduling system, `Slurm <https://slurm.schedmd.com/quickstart.html>`_. 
   Slurm ensures fair resource distribution among users by managing node allocation,
   CPU distribution, memory utilization, and other essential resources based on job requirements.

To prevent interference between users' jobs, access to nodes is restricted
to users with active jobs running on them. For example, if user "lk01" submits a job and
Slurm allocates ``larcc-cpu1`` for its execution, "lk01" will have exclusive access to log into ``larcc-cpu1``.

About Scientific Software
=========================

In Linux, program behavior is influenced by dynamic values called "environmental variables".
These variables can be created, modified, and removed as needed, shaping the functionality
of programs and services. For example, the ``PATH`` variable lists directories where binaries are stored.
When a command is executed, the system searches these directories for the corresponding binary.
If not found, it returns a "command not found" error.

Scientific software like GROMACS or OpenFOAM often define their own environmental variables,
which can be complex to manage. To simplify this, the cluster uses *Environmental Modules*
to dynamically adjust users' environments with modulefiles.

Users can explore available modules with the ``module available`` command and load
them using ``module load modulename``.

About Jobs
==========

Users can submit two types of jobs: interactive and batch.
Interactive jobs give direct access to the assigned node, allowing users to execute programs manually.
Batch jobs run autonomously via shell scripts without user intervention.

Batch jobs remain unaffected by disconnections, while interactive jobs may terminate.
To maintain continuity, users can use a terminal multiplexer like ``tmux``.
Running ``tmux`` before starting an interactive job creates
a persistent session that continues even if the connection is lost.

Quickstart
##########

.. _logging-into-cluster:

Logging into the cluster
========================

Upon creating an account, users are provided with a username and password, 
which they can utilize to access the cluster via SSH (Secure Shell Protocol).
The procedure entails employing an SSH client from their personal computers
to establish a connection with the login node. 

Using the command line
^^^^^^^^^^^^^^^^^^^^^^

Windows (versions 10 and 11)
inherently supports an SSH command-line client within PowerShell. Similarly, 
Mac and Linux based operating systems come equipped with a built-in SSH client
accessible via their respective terminals. 
The basic login process remains consistent across all of these platforms:

1. Launch the terminal on your personal computer.
2. Enter the ssh command using the following format: ``ssh username@hostname``. 
   In this particular scenario, the hostname is always ``larcc.hpc.louisville.edu``.
   For instance, if the user's name is "lk01", they would input
   ``ssh lk01@larcc.hpc.louisville.edu``.
   
   .. code-block:: RST
    :caption: TODO: Create new image

    .. image:: images/login_example.png
      :width: 600
      :alt: Example: cluster login

3. Provide your password and press Enter.

  .. code-block:: RST
    :caption: TODO: Create new image

    .. image:: images/login_example_2.png
      :width: 600
      :alt: Example: logged into the cluster

Alternatively, users can opt for other popular SSH clients installed on their personal computers,
such as `MobaXterm <https://mobaxterm.mobatek.net/>`_ and `PuTTY <https://www.putty.org/>`_.
PuTTY boasts a straightforward and user-friendly interface, while MobaXterm offers a 
tabbed interface with enhanced functionality, including a dedicated file manager 
that simplifies file management on the cluster and facilitates seamless information
transfer between the personal computer and the cluster.

Using MobaXterm
^^^^^^^^^^^^^^^

1. Click on "Session" at the top-left of the window

  .. image:: images/mobaxterm_conn_setup_1.png
    :width: 800

2. Setup your username and the cluster hostname ``larcc.hpc.louisville.edu``

  .. image:: images/mobaxterm_conn_setup_2.png
    :width: 800

3. A notice like the one below will appear the first time you connect to the cluster.
   Click "Accept".

  .. image:: images/mobaxterm_conn_setup_3.png
    :width: 800

4. Write your password (it will not be displayed as you type it) and hit Enter

  .. image:: images/mobaxterm_conn_setup_4.png
    :width: 800

Copying files to/from the cluster
=================================

Using the command line
^^^^^^^^^^^^^^^^^^^^^^

The command ``scp`` (available on Windows, Mac and Linux based OSs) is the preferred way
to copy files to and from the cluster. See a comprehensive list of options at the
`scp guide <https://man.openbsd.org/scp>`_. Since a user's
home directory (``/home/<username>``, or simply ``~``) is shared across all nodes, users are encouraged
to use their home directories as a staging area for file transfers.

**Example:** Assume user "John Doe" is assigned cluster account ``jd01``. The code below
shows how John would copy the file ``C:\Users\johndoe\Downloads\workload.jou`` from his
personal computer to his home directory (``/home/jd01``) in the cluster using the 
``scp`` command in Windows PowerShell.

..  code-block:: powershell
    
    # John could also use ~ instead of /home/jd01. That is, the following is also valid:
    # scp C:\Users\johndoe\Downloads\workload.jou jd01@larcc.hpc.louisville.edu:~
    scp C:\Users\johndoe\Downloads\workload.jou jd01@larcc.hpc.louisville.edu:/home/jd01

Suppose John Doe ran a simulation and got the results stored at ``/home/jd01/results/sim_1_res.dat``
in the cluster. If he wants to copy these retults to the folder ``C:\Users\johndoe\Documents`` 
of his Windows PC, he would execute the command below from a PowerShell session:

..  code-block:: powershell
    
    # The following is also valid:
    # scp jd01@larcc.hpc.louisville.edu:~/results/sim_1_res.dat C:\Users\johndoe\Documents
    scp jd01@larcc.hpc.louisville.edu:/home/jd01/results/sim_1_res.dat C:\Users\johndoe\Documents

Using MobaXterm
^^^^^^^^^^^^^^^

Downloading files or folders from the cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Locate the "File Explorer" from MobaXterm and navigate towards the location where the file
   or folder you want to download resides in.
  
  .. code-block:: RST
    :caption: TODO: Create new image

    .. image:: images/mobaxterm_file_copy_1.png
      :width: 800

2. Right click on the file or folder you want to download from the cluster and click on "Download".

  .. code-block:: RST
    :caption: TODO: Create new image

    .. image:: images/mobaxterm_file_copy_2.png
      :width: 800

Uploading files or folders to the cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Locate the "File Explorer" from MobaXterm and navigate towards the location where 
   you want to upload your files to.

  .. code-block:: RST
    :caption: TODO: Create new image

    .. image:: images/mobaxterm_file_copy_1.png
      :width: 800

2. Click on the upload icon within the "File Explorer" and select the file or folder you want to
   upload.

  .. code-block:: RST
    :caption: TODO: Create new image

    .. image:: images/mobaxterm_file_copy_3.png
      :width: 800

Using software installed in the cluster
=======================================

List available software
^^^^^^^^^^^^^^^^^^^^^^^

Use command ``module avail`` as shown in the example below:

..  code-block:: bash
  :caption: Example list of available software
    
    user@larcc-login1:~$ module avail

    ------------------------------- /apps/modulefiles/Linux ---------------------------
       ansys/2023r1                                         mkl/2023.0.0
       boost/1.81_gcc12.2_ompi4.1.5_python3.11.2            mpc/1.3.1
       cloog/0.20.0                                         mpfr/4.2.0
       cmake/3.26.1                                         openblas/0.3.21_gcc12.2
       fftw/3.3.10_ompi4.1.5_gcc12.2                        openfoam/2212
       gcc/12.2                                             openmpi/4.1.5_gcc12.2   (D)
       gmp/6.2.1                                            openmpi/4.1.5
       gromacs/2023_ompi4.1.5_gcc12.2                (S)    openssl/3.0.8_gcc12.2
       icu/72.1_gcc12.2                                     python/3.11.2_gcc12.2
       infiniband                                           ucx/1.14.0_gcc12.2
       lammps/23Jun2022_fftw3.3.10_ompi4.1.5_gcc12.2        zlib/1.2.13
       miniconda3/23.1.0

      Where:
       S:  Module is Sticky, requires --force to unload or purge
       D:  Default Module

Load software
^^^^^^^^^^^^^

Users **must** load programs with the ``module load <modulename>`` before launching them.
Multiple programs can be loaded at the same time, but there are cases where two or more may conflict.
For instance, programs ``openmpi/4.1.5_gcc12.2`` and ``openmpi/4.1.5`` cannot be loaded together.
For such cases the program loaded last is used. An example of this is shown below:

..  code-block:: bash
  :caption: Example of conflicting programs

    user@larcc-login1:~$ module load openmpi/4.1.5_gcc12.2
    user@larcc-login1:~$ module load openmpi/4.1.5

    Lmod is automatically replacing "gcc/12.2" with "openmpi/4.1.5".


    The following have been reloaded with a version change:
      1) openmpi/4.1.5_gcc12.2 => openmpi/4.1.5

.. warning::
    Programs **MUST** only be run through slurm, **NOT** on the login node (larcc-login1).
    Users can test their scripts using an interactive job first and then submit the appropriate
    batch job (See Section :ref:`slurm` for more details).

List currently loaded software
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use command ``module list`` as shown in the example below:

..  code-block:: bash
  :caption: Example list of currently loaded software

    user@larcc-login1:~$ module load python/3.11.2_gcc12.2
    user@larcc-login1:~$ module list

    Currently Loaded Modules:
      1) zlib/1.2.13   4) mpc/1.3.1      7) openssl/3.0.8_gcc12.2
      2) gmp/6.2.1     5) cloog/0.20.0   8) python/3.11.2_gcc12.2
      3) mpfr/4.2.0    6) gcc/12.2

Note that besides ``python/3.11.2_gcc12.2`` there are other programs loaded.
These other programs are dependencies that are automatically loaded.

Unloading software
^^^^^^^^^^^^^^^^^^

Use command ``module unload <modulefile>``. This command only unloads the
indicated program, but not its dependencies. To clean the environment and
unload all modules, users should use the command ``module purge``. Example:

..  code-block:: bash
  :caption: Example on how to unload software

    user@larcc-login1:~$ module load python/3.11.2_gcc12.2
    user@larcc-login1:~$ module unload python/3.11.2_gcc12.2
    user@larcc-login1:~$ module list

    Currently Loaded Modules:
      1) zlib/1.2.13   4) mpc/1.3.1      7) openssl/3.0.8_gcc12.2
      2) gmp/6.2.1     5) cloog/0.20.0
      3) mpfr/4.2.0    6) gcc/12.2



    user@larcc-login1:~$ module purge
    user@larcc-login1:~$ module list
    No modules loaded

Queues and jobs
===============

- The cluster has two queues named *compute* and *gpu*.
- To **see information about queues**, users can use the ``sinfo`` command.
- When users send jobs, they can monitor their job status using the ``squeue`` command.
- To **launch an interactive job**, users can user the
  ``srun --time=<walltime> --pty /bin/bash -i`` command.
  See Section :ref:`Starting an interactive job <interactive_job>` for more information.
- To **submit an unattended job**, users can use the command ``sbatch`` as follows: 
  ``sbatch /path/to/sbatch/script``.
  See Section :ref:`Submitting batch jobs <batch_job>` for more information
- To **cancel jobs**, users can use the ``scancel`` command as follows: ``scancel jobid``

Limits
======

- Users cannot request more than 3 nodes on a single job.
- The maximum allowed walltime for jobs on all queues is 14 days and 12h. Contact ITS - Research Computing if more
  time is required for a job.