#!/bin/bash
#SBATCH --job-name=rstudio-server
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --partition=compute
#SBATCH --output=/home/%u/rstudio-server.out.%j
#SBATCH --error=/home/%u/rstudio-server.err.%j

module load python/3.11.7-gcc-8.3.0
module load singularity/4.1.2

## CHANGE ME!!! ###################################
VERSION_OF_R=4.2
# Folder where the singularity instances are saved
FOLDER_CONTAINER_INSTANCES=$HOME
##################################################

CONTAINER=${FOLDER_CONTAINER_INSTANCES}/rstudio_${VERSION_OF_R}.sif

if ! [ -f $CONTAINER ]; then
    printf "Please run singularity pull docker://rocker/rstudio:${VERSION_OF_R} and, once the download finishes, make sure the rstudio_${VERSION_OF_R}.sif file is placed in ${FOLDER_CONTAINER_INSTANCES}" 1>&2
fi

# Generate a random diectory in /tmp for RStudio to save files to.
workdir=$(python -c 'import tempfile; print(tempfile.mkdtemp())')
mkdir -p -m 700 ${workdir}/run ${workdir}/tmp ${workdir}/var/lib/rstudio-server
cat > ${workdir}/database.conf <<END
provider=sqlite
directory=/var/lib/rstudio-server
END
# Set R_LIBS_USER to a path specific to rocker/rstudio to avoid conflicts with
# personal libraries from any R installation in the host environment.
cat > ${workdir}/rsession.sh <<END
#!/bin/sh
export OMP_NUM_THREADS=${SLURM_JOB_CPUS_PER_NODE}
export R_LIBS_USER=${HOME}/R/rocker-rstudio/${VERSION_OF_R}
exec /usr/lib/rstudio-server/bin/rsession "\${@}"
END

chmod +x ${workdir}/rsession.sh

# Bind folders in local filessystem to rstudio container
export SINGULARITY_BIND="${workdir}/run:/run,${workdir}/tmp:/tmp,${workdir}/database.conf:/etc/rstudio/database.conf,${workdir}/rsession.sh:/etc/rstudio/rsession.sh,${workdir}/var/lib/rstudio-server:/var/lib/rstudio-server"

# Do not suspend idle sessions.
export SINGULARITYENV_RSTUDIO_SESSION_TIMEOUT=0

export SINGULARITYENV_USER=$(id -un)
export SINGULARITYENV_PASSWORD=$(openssl rand -base64 15)

readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

   ssh -J ${USER}@larcc.hpc.louisville.edu -N -L 8787:localhost:${PORT} ${SINGULARITYENV_USER}@${HOSTNAME}

   and point your web browser to http://localhost:8787

2. log in to RStudio Server using the following credentials:

   user: ${SINGULARITYENV_USER}
   password: ${SINGULARITYENV_PASSWORD}

When done using RStudio Server, terminate the job by:

1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END

singularity exec --cleanenv ${CONTAINER} \
    /usr/lib/rstudio-server/bin/rserver --www-port ${PORT} \
            --server-user=$USER \
            --auth-none=0 \
            --auth-pam-helper-path=pam-helper \
            --auth-stay-signed-in-days=30 \
            --auth-timeout-minutes=0 \
            --rsession-path=/etc/rstudio/rsession.sh
printf 'rserver exited' 1>&2
