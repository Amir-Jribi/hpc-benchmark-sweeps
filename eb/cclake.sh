#!/bin/bash

#
#export EASYBUILD_INSTALLPATH=/srv/software/easybuild
#export MODULEPATH="/srv/software/easybuild/a100/modules/all:/opt/ohpc/pub/modulefiles:/srv/software/modulefiles"
#newgrp hpc_vasp_6.6
ml load EasyBuild
ml unuse /home/amir.jribi-ext/.local/easybuild/modules/all:/srv/software/easybuild/h100/modules/all:/srv/software/easybuild/a100/modules/all
export EASYBUILD_INSTALLPATH=/srv/software/easybuild
export EASYBUILD_SOURCEPATH=$EASYBUILD_INSTALLPATH/sources
export EASYBUILD_BUILDPATH=$EASYBUILD_INSTALLPATH/build
export EASYBUILD_REPOSITORYPATH=$EASYBUILD_INSTALLPATH/ebfiles_repo
export EASYBUILD_MODULES_TOOL=Lmod
export EASYBUILD_BUILDPATH=/dev/shm
export EASYBUILD_GROUP_WRITABLE_INSTALLDIR=1
export EASYBUILD_SET_GID_BIT=1

#export EASYBUILD_ROBOT_PATHS=/home/amir.jribi-ext/a100:$EASYBUILD_ROBOT_PATHS
#export EASYBUILD_UMASK=002
#export EASYBUILD_PARALLEL=$SLURM_CPUS_PER_TASK
