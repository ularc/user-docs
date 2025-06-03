Understanding Storage on Compute Nodes
######################################

When working on any compute node within the system, there are
two primary types of storage available to users: ``scratch`` storage and ``home`` storage.
These are illustrated in the diagram below:

.. image:: images/logical_storage_architecture.png
   :width: 600
   :alt: Logical Storage Architecture

Storage Types
=============

``scratch`` Storage
-------------------
- **Local to each compute node**: This means it is **not shared** across nodes.
- **High performance**: Offers significantly faster read/write speeds compared to ``home`` storage.
- **Limited capacity**: Typically smaller in size, so it's best suited for temporary files and high-speed I/O operations during job execution.

``home`` Storage
----------------
- **Shared across all nodes**: Accessible from any compute node in the system.
- **Large capacity**: Designed to store a user's persistent data, such as source code, datasets, and results.
- **Slower access**: Due to its shared nature, read/write operations are generally slower than ``scratch`` storage.

Recommended Workflow
====================

A common and efficient workflow for running jobs on the system is:

1. **Prepare Input Data**: Copy necessary input files from your ``home`` storage to the node's local ``scratch`` storage at the start of your job.
2. **Run the Application**: Configure your application to read from and write to the ``scratch`` storage during execution.
   This takes advantage of its high-speed performance.
3. **Save Results**: Once the job completes, copy the output files back to your ``home`` storage for long-term retention.

.. note::

   Always ensure that your input and output data will fit within the available space on ``scratch`` storage.
   If your files exceed this capacity, you may need to adjust your workflow accordingly.
