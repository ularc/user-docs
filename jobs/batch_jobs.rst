.. _batch_job:

Batch Jobs
==========

These are jobs that are submitted to run in the background without requiring direct user interaction
once they start. The user submits the job to a queue, and SLURM schedules the job to run when resources
become available. This is ideal for large, non-interactive computational tasks, simulations, data analysis, etc.

Here, you write a job script (typically a shell script) that contains the commands to execute your task,
along with SLURM directives to specify resource requirements (e.g., number of nodes, CPUs, memory, etc.).
Once submitted, the job runs automatically without user interaction. 

Submitting batch jobs
^^^^^^^^^^^^^^^^^^^^^

The command ``sbatch`` serves as the means to submit batch jobs to Slurm,
typically in the form of a shell script written in the bash command language.

.. note::

    A shell script is essentially a text file containing instructions
    that are parsed and executed by a shell or command-line interpreter.

When submitting a job to Slurm, the shell script must adhere to the following requirements:

1. The first line of the script should specify the shell to be used.
   This is accomplished by including a shebang (``#!``) followed by ``/bin/env``, a space,
   and the name of the desired shell. For example, for a bash script: ``#!/bin/env bash``.
   Alternatively, the path to the shell can be used directly: ``#!/bin/bash``.

2. The script should define a set of parameters in the form of comments
   (lines preceded by the ``#`` symbol). These parameters are utilized by Slurm
   to establish job priority and resource requirements. Each parameter should begin
   with the word ``SBATCH`` and should be placed on its own separate line. For instance:

   .. code-block:: bash
   		
      #!/bin/env bash
      #SBATCH --job-name=some_job_name
      #SBATCH --time=01:00

A list of common sbatch options is provided below for convenience:

.. csv-table:: Common sbatch options
  :header-rows: 1
  :widths:  5, 8, 5, 4
  :stub-columns: 1
  :file: csv/sbatch_cmds.csv

For more comprehensive details, please consult 
`Slurm's sbatch manual <https://slurm.schedmd.com/sbatch.html>`_.

Once the necessary parameters have been incorporated into the script,
users should proceed to configure the environment for the application they intend to execute.
If the job uses a software installed within the cluster,
users are encouraged to load the corresponding modulefiles within the script using
the ``module load <modulefile>`` command.
Alternatively, users can load their custom modulefiles or manually set
the required environmental variables.
Any additional tasks such as directory or file creation, among others,
should be performed at this stage. Note that the submission script
essentially functions as a shell script with additional comments at the beginning.
As such, any actions that a user would typically carry out in a regular shell session
can be executed within the script.

Finally, the script should encompass the core job tasks, 
which typically involve executing simulations, experiments, or other relevant operations.
During this phase, users would typically initiate the necessary scientific software required
for their specific needs.

Batch Job Example
^^^^^^^^^^^^^^^^^

Consider the following bash script:

..  code-block:: bash
    :caption: Example bash script to launch a batch job

     #!/bin/bash
     #SBATCH --job-name=example_batch_job
     #SBATCH --error=/home/user/%x.%j.err
     #SBATCH --output=/home/user/%x.%j.out
     #SBATCH --time=05:30:00
     #SBATCH --ntasks-per-node=128
     #SBATCH --nodes=2
     #SBATCH --partition=compute
     
     # print list of nodes assigned to the job.
     # Example output:
     # larcc-cpu1
     # larcc-cpu2
     scontrol show hostnames $SLURM_JOB_NODELIST


In this script, the job is assigned the name *example_batch_job* using the ``#SBATCH --job-name``
directive. The maximum allowed running time is set to 5 hours and 30 minutes through the 
``#SBATCH --time`` directive. The job is configured to utilize 2 nodes (``#SBATCH --nodes``)
and 128 processors per node (``#SBATCH --ntasks-per-node``). It is intended to run in the *compute* queue
(``#SBATCH --partition``). Any encountered error messages are to be stored in the file 
``/home/user/%x.%j.out``, where ``%x`` is replaced with the job name specified with the
``#SBATCH --job-name`` directive and ``%j`` is replaced with the job ID assigned by Slurm.
Similarly, non-error messages are directed to the file ``/home/user/%x.%j.err``
for logging purposes. The environmental variable ``SLURM_JOB_NODELIST`` is passed
to the script by slurm (see section :ref:`Slurm environmental variables <slurm_env_vars>`).

Suppose this script is located at path: ``/home/user/example_batch_job.sh``. Then,
the command below would submit the batch job to slurm:

..  code-block:: bash
    
    sbatch /home/user/example_batch_job.sh
