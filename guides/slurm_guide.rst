Slurm Queueing System Guide
###########################

Basic Slurm Terminology
=======================

Partition (a.k.a. Queue)
------------------------

A partition is a logical grouping of compute nodes, similar to a queue. Each partition may have different hardware, time limits, or access policies.
Use ``sinfo`` to list available partitions.

To check the current status of available queues and nodes, use the ``sinfo`` command.
This command provides a snapshot of which nodes are idle, allocated, or down, along with their associated partitions and time limits.

Example output:

.. code-block::

    PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
    compute*     up 3-00:00:00      1  alloc larcc-cpu3
    compute*     up 3-00:00:00      9   idle larcc-cpu[1-2,4-10]
    gpu          up 2-00:00:00      3  alloc larcc-gpu[1-3]
    gpu          up 2-00:00:00      7   idle larcc-gpu[4-10]

In this example:

- The compute partition has 10 nodes, 1 of which is currently in use (alloc) and 9 are idle.
- The gpu partition has 10 nodes, with 3 allocated and 7 idle.
- The TIMELIMIT column shows the maximum wall time allowed per job in each partition.

Node
----

A node is a physical machine in the cluster. Each node has a specific number of CPU cores, memory, and possibly GPUs.

To get detailed information about a specific node, use:

.. code-block::

    scontrol show node <nodename>

For example:

.. code-block::
     
    scontrol show node larcc-cpu1

This will return detailed specs and current usage for the node:

.. code-block:: text

    NodeName=larcc-cpu1 Arch=x86_64 CoresPerSocket=64 
       CPUAlloc=0 CPUEfctv=128 CPUTot=128 CPULoad=0.00
       AvailableFeatures=(null)
       ActiveFeatures=(null)
       Gres=(null)
       NodeAddr=larcc-cpu1 NodeHostName=larcc-cpu1 Version=24.11.4
       OS=Linux 5.14.0-503.38.1.el9_5.x86_64 #1 SMP PREEMPT_DYNAMIC Wed Apr 16 16:38:39 UTC 2025 
       RealMemory=515002 AllocMem=0 FreeMem=505959 Sockets=2 Boards=1
       State=IDLE ThreadsPerCore=1 TmpDisk=0 Weight=1 Owner=N/A MCS_label=N/A
       Partitions=compute 
       BootTime=2025-05-15T13:30:56 SlurmdStartTime=2025-07-30T13:57:36
       LastBusyTime=2025-09-22T16:10:19 ResumeAfterTime=None
       CfgTRES=cpu=128,mem=515002M,billing=128
       AllocTRES=
       CurrentWatts=240 AveWatts=180

Key fields to note:

- CPUTot: Total number of CPU cores available.
- RealMemory: Total memory available on the node.
- State: Current status (e.g., IDLE, ALLOC, DOWN).
- Partitions: Indicates which queue(s) the node belongs to.

Job
---

A job is a unit of work submitted to Slurm. It can be a single task or a collection of tasks (e.g., simulations, data processing).

Jobs are submitted using sbatch (batch jobs) or srun (interactive jobs).

A Job can have 5 states:

- PD (Pending): Waiting for resources.
- R (Running): Currently executing.
- CG (Completing): Finishing up.
- CD (Completed): Finished successfully.
- F (Failed): Encountered an error.

To view jobs currently in the queue or running, use: ``squeue``.

Example output:

.. code-block::

                    JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                 3777   compute matlab_p jd01  R    4:02:04      1 larcc-cpu3
    3852_[226-241%20]       gpu Ecthelio jd02 PD       0:00      1 (QOSMaxNodePerUserLimit)
             3852_224       gpu Ecthelio jd02  R       2:00      1 larcc-gpu3
             3852_225       gpu Ecthelio jd02  R       2:00      1 larcc-gpu3
             3852_222       gpu Ecthelio jd02  R       2:01      1 larcc-gpu2
             3852_223       gpu Ecthelio jd02  R       2:01      1 larcc-gpu2
                 3343       gpu sno_pv80 jd03  R    4:02:05      1 larcc-gpu1

Explanation of columns:

- JOBID: Unique identifier for each job.
- PARTITION: Queue the job was submitted to.
- NAME: Job name.
- USER: Submitting user.
- ST: Job status (R = Running, PD = Pending).
- TIME: Runtime so far.
- NODELIST(REASON): Node(s) assigned or reason for pending status.


Job Steps
----------

A job step is a unit of work executed within a running job. 
While a job defines the overall resource allocation (e.g., number of nodes, CPUs, memory, time),
job steps are the actual commands or tasks that run using those resources.

Key Characteristics of a Job Step:

- **Executed with srun:** Job steps are typically launched using the ``srun`` command inside a job script or interactively.
- **Shares job resources:** All job steps run within the resource allocation defined by the parent job (``sbatch``).
- **Can run in parallel:** Multiple job steps can be launched simultaneously, each using a subset of the allocated resources.
- **Useful for multi-task jobs:** Ideal when you want to run several independent tasks (e.g., simulations, analyses) within a single job submission.

.. _interactive_job:

Interactive Jobs
================

These jobs are meant for users who need to run commands or scripts interactively on a compute node.
For example, if you want to run a program or script and see its output or error messages in real time,
or if you need to test something quickly.

You can submit an interactive job in two ways:

1. First request resources with the ``salloc`` command followed by creating one or multiple jobsteps
   with the ``srun`` command. In  Users typically use the following template:

.. code-block:: bash

    salloc --partition=gpu \
           --job-name tensorflow \
           --time=5:00:00 \
           --nodes=1 \
           --ntasks=2 \
           --gpus-per-task=1 \
           --cpus-per-task=24

2. Run ``srun`` directly to both allocate resources and launch a single jobstep at the same time.

Slurm allocates resources (like CPUs, memory, etc.)
for your job and opens an interactive session. When this ha

.. code-block:: text

    [jd01@larcc-login1 ~]$ salloc --partition=gpu --job-name tensorflow --time=5:00:00 --nodes=1 --ntasks=2 --gpus-per-task=1 --cpus-per-task=24
    salloc: Granted job allocation 3844
    salloc: Nodes larcc-gpu4 are ready for job
    bash-5.1$

on one of the allocated nodes.
You can then execute commands directly in that session.

Submitting interactive jobs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``srun`` command, with the ``-i`` and ``--pty`` options, facilitates launching interactive jobs.
Users typically use the following template:

.. code-block:: bash

    srun --nodes=<nodes> --ntasks-per-node=<cpus> --time=<walltime> --pty /bin/bash -i

Here, ``<nodes>`` specifies the number of nodes, 
``<cpus>`` denotes processors per node, and ``<walltime>`` sets the maximum duration for the session.
Additional options like ``--mem`` can be included to customize job requirements
(see `Slurm's srun manual <https://slurm.schedmd.com/srun.html>`_ for more information).

.. note::

    Interactive jobs are mainly for testing. For larger workloads, batch jobs are recommended.

Upon starting an interactive job, the system provides feedback:

.. code-block::

    srun: job 12345 queued and waiting for resources
    srun: job 12345 has been allocated resources

The user is then logged into an allocated node. Ending the session will terminate the job.
Jobs exceeding walltime or memory limits will be automatically aborted.

Interactive Job Example
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    # 1. log into the cluster
    ssh user@larcc.hpc.louisville.edu
    # 2. start a job in the longjobs queue with the following specifications:
    #    a) The maximum time allowed for the job to run is 5h (--time=5:00:00)
    #    b) The maximum memory that can be used by the job is 10G (--mem=10G)
    #    c) Run on a single node (--nodes=1)
    #    d) Allocate 4 cores for this job on the node (--ntasks-per-node=4)
    #    e) Instead of hanging and waiting for resources to be available, exit immediately (-i)
    #    f) Specify the task (a shell in this case) to execute (--pty /bin/bash)
    srun --partition=longjobs --time=5:00:00 --mem=10G --ntasks-per-node=4 --nodes=1 --pty /bin/bash -i

.. note::
    The ``-i`` option for ``srun`` is optional. It prevents your terminal from hanging
    if the job is queued due to unavailable resources when the command is executed.

Keeping an interactive job alive
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To prevent premature termination of interactive jobs due to connection disruptions,
using a terminal multiplexer like ``tmux`` is recommended. Follow these steps:

1. Log into the cluster.
2. Run ``tmux new -s session_name``, where ``session_name``
   can be any name you choose. **Your terminal will change**, showing a green strip at the bottom,
   indicating you are in a tmux session. The session name appears at the bottom left, and the node's
   hostname is at the bottom right.
3. Launch your interactive job within the tmux session.

If disconnected, reconnect to the login node and use ``tmux attach -t session_name`` to resume your session.
For multiple sessions, use ``tmux list-session`` (or, even shorter, ``tmux ls``) to list them.

.. _batch_job:

Batch Jobs
==========

These are jobs that are submitted to run in the background without requiring direct user interaction
once they start. The user submits the job to a queue, and Slurm schedules the job to run when resources
become available. This is ideal for large, non-interactive computational tasks, simulations, data analysis, etc.

Here, you write a job script (typically a shell script) that contains the commands to execute your task,
along with Slurm directives to specify resource requirements (e.g., number of nodes, CPUs, memory, etc.).
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


Strategies When Submitting Slurm Jobs
======================================

Due to LARCC's resource policies (see :ref:`Resource restrictions <resource_restrictions>`), users are limited to:

- 20 concurrent job submissions.
- 2 nodes maximum per user.

Depending on your resource requests, multiple jobs may run on the same node, but the 20-job submission limit must always be respected. To
maximize resource utilization while complying with these restrictions, there are two strategies you can follow.

Strategy 1: Single Job with Multiple Job Steps
----------------------------------------------

If your workload consists of many small, independent tasks (e.g., 50 simulations), and each task uses only a few cores,
you can submit a single job that launches multiple parallel job steps within the script.

**Example Setup:**

- Each node in the compute queue has 128 cores.
- Request 2 nodes. So, 256 cores total.
- Divide 256 cores across 50 tasks. That is ~5 cores per task (``floor(256/50)``).
- Each node has ~515 GB of memory. That is ~4023 MB per core (``floor(515GB/128)``).

Assuming each individual task takes up to 6 hours and all tasks run in parallel, the overall runtime should also be around 6 hours.
However, in practice, delays or unexpected hang-ups can occur. To account for this, it's a good idea to request additional time as a buffer.

For example, adding a 2-hour grace period brings the total requested runtime to 8 hours,
which helps ensure the job completes successfully even if a few tasks take longer than expected.

**Sample Slurm Script:**

.. code-block:: bash

    #SBATCH --partition=compute
    #SBATCH --nodes=2
    #SBATCH --ntasks=256
    #SBATCH --time=08:00:00
    #SBATCH --mem-per-cpu=4023M
    #SBATCH --error=job.err
    #SBATCH --output=job.out
    #SBATCH --name=my_simulations

    module load your_program

    for i in {1..50}; do
      # --exact       Each job step is only given the resources it requested to avoid contention
      # --exclusive   Ensures srun uses distinct CPUs for each job step
      # The & makes each job step run in parallel
      srun --exact --exclusive --cpus-per-task=5 your_program ... &
    done

    # wait for all job steps to finish
    wait

**This approach:**

- Submits only one job, staying within the 20-job limit.
- Maximizes utilization of your allowed 2 nodes.

Strategy 2: Job Arrays
----------------------

If you prefer to submit each task as a separate job, use Slurm job arrays.
Each array index counts as a job, so you must limit concurrent jobs to 20.

**Example Setup:**

- 50 tasks total, so ``--array=0-49%20`` (only 20 run at a time).
- 2 nodes have 256 cores. So, with 20 array jobs running at a time you can maximize utilization with 12 cores per array job (``floor(256/20)``).
- Memory per task: 12 cores * 4023 MB = 48276 MB.

**Sample Slurm Script:**

.. code-block:: bash

    #SBATCH --partition=compute
    #SBATCH --ntasks=12
    #SBATCH --mem=48276M
    #SBATCH --array=0-49%20
    #SBATCH --time=08:00:00
    #SBATCH --error=array_%A_%a.err
    #SBATCH --output=array_%A_%a.out
    #SBATCH --name=my_array_jobs

    module load your_program

    your_program ...

**This approach:**

- Uses job arrays to manage many tasks.
- Keeps concurrent jobs within the allowed limit.