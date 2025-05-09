.. _interactive_job:

Interactive Jobs
================

These jobs are meant for users who need to run commands or scripts interactively on a compute node.
For example, if you want to run a program or script and see its output or error messages in real time,
or if you need to test something quickly. 
When you submit an interactive job, SLURM allocates resources (like CPUs, memory, etc.)
for your job and opens an interactive session on one of the allocated nodes.
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
