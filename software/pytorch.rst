Using PyTorch
=============

To use PyTorch on the cluster, start by reviewing the :ref:`Conda <conda>` installer
and how to manage :ref:`Conda environments <conda_create_env>`.

.. note::
    Newer PyTorch versions are not available via Conda, but you can install them using ``pip`` within Conda environments.

There are two main ways to use PyTorch:

1. **Using the Global Conda Environment**

   The cluster provides a pre-configured Conda environment with PyTorch.
   Only administrators can modify this environment, so you're limited to the installed packages.

   .. code-block:: bash

       module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym
       conda env list
       conda activate pytorch

2. **Creating a Custom Conda Environment**

   You can create your own environment and install PyTorch via ``pip``.
   Note that cloning the global ``pytorch`` environment won't include PyTorch itself, as it was installed via ``pip``.
   Our GPUs support CUDA up to 12.9. Below are installation examples:

   .. tabs::

       .. tab:: PyTorch 2.7.1 + CUDA 11.8

           .. code-block:: bash

               module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym
               conda create --name my_pytorch_cuda11.8
               conda activate my_pytorch_cuda11.8
               pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

       .. tab:: PyTorch 2.7.1 + CUDA 12.6

           .. code-block:: bash

               module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym
               conda create --name my_pytorch_cuda12.6
               conda activate my_pytorch_cuda12.6
               pip install torch torchvision torchaudio

       .. tab:: PyTorch 2.7.1 + CUDA 12.8

           .. code-block:: bash

               module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym
               conda create --name my_pytorch_cuda12.8
               conda activate my_pytorch_cuda12.8
               pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

Verifying GPU Availability
==========================

After installing PyTorch and activating your environment,
you can verify that PyTorch detects the available GPUs by using
the following Python commands on a GPU node:

.. code-block:: python

    import torch

    print("CUDA available:", torch.cuda.is_available())
    print("Number of GPUs:", torch.cuda.device_count())
    if torch.cuda.is_available():
        print("Current GPU:", torch.cuda.get_device_name(torch.cuda.current_device()))

Remember you'll need to request an interactive or batch job
to be able to ssh into a GPU node. For example:

.. code-block:: bash

    # Submit interactive job
    srun --partition=gpu --job-name test_my_pytorch_env \
        --time=05:00 --nodes=1 --gpus=1 --ntasks-per-node=1 \
        --pty /bin/bash -i
    
    # Create python file to test pytorch
    cat <<EOF > pytorch_test.py
    import torch

    print("CUDA available:", torch.cuda.is_available())
    print("Number of GPUs:", torch.cuda.device_count())
    if torch.cuda.is_available():
        print("Current GPU:", torch.cuda.get_device_name(torch.cuda.current_device()))
    EOF

    # Execute the test program
    module load miniforge3/24.3.0-0-gcc-11.5.0-wkw4vym
    conda activate my_pytorch_env
    python pytorch_test.py

If CUDA is available and at least one GPU is detected, you should see output similar to:

.. code-block:: text

    CUDA available: True
    Number of GPUs: 1
    Current GPU: NVIDIA H100 NVL

.. note::
    If `torch.cuda.is_available()` returns `False`, ensure that:
    
    - You are running on a compute node with GPU access (not a login or cpu node).
    - **Your job explicitely requests 1 or more GPUs** (e.g. ``--gpus=2``, ``--gpus-per-node=2``)
    - Your environment includes a PyTorch build with CUDA support.
    - The appropriate GPU drivers and CUDA libraries are available on the system.

