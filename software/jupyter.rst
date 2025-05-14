.. _jupyter:

Launching a notebook
====================

1. Login into the cluster and install jupyter in a virtual environment through `miniforge`.

    .. code-block:: bash

        module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym
        conda create -n jupyter python numpy pandas notebook

2. Login into the cluster and start an interactive job. For example,

    .. code-block:: bash

        srun --partition=gpu --job-name jupyter --time=5:00:00 --nodes=1 --pty /bin/bash -i
    
3. When you land on the assigned compute node, take note of the hostname of the server assigned 
   to your job as you will need it for the following steps (you can use the ``hostname`` command).
   Then, start a jupyter server as follows:

    .. code-block:: bash

        module load miniforge
        conda activate jupyter
        # This line prints a random, available port for you to use,
        # so take note of the number printed and replace <port> in the next
        # command with said number.
        comm -23 <(seq 1024 65535 | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf | head -n 1
        jupyter notebook --no-browser --port=<port>
    

4. From **your (personal) laptop**, run the following:

    .. code-block:: bash
        
        ssh -J username@larcc.hpc.louisville.edu -L <port>:localhost:<port> username@<node_hostname>
    
    For example, assume you landed on the server ``larcc-gpu1`` on step 2 and jupyter is using port 7070,
    then you would run: ``ssh -J username@larcc.hpc.louisville.edu -L 7070:localhost:7070 username@larcc-gpu1``.

5. Access jupyter through **your (personal) laptop's web browser** by entering in the navigation bar:
   ``localhost:<port>``. Following the example from step 4, you would use ``localhost:7070``.
