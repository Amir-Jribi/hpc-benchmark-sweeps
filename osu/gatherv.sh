#!/bin/bash
#
#SBATCH --job-name=osu_benchmark_gatherv
#SBATCH --nodes=64
#SBATCH --ntasks=64
#SBATCH --ntasks-per-node=1
#SBATCH --output=./slurm/gatherv_%A_64n_1ppn_d.out
#SBATCH --error=./slurm/gatherv_%A_64n_1ppn_d.err
#SBATCH --time=10:00:00

ml purge
ml load EasyBuild
ml load OSU-Micro-Benchmarks/7.4-gompi-2024a
ml load Nsight-Systems/2025.3.1

#mpirun hostname
#UCX_NET_DEVICES=mlx5_0:1 #select infiniband device
#-x UCX_LOG_LEVEL=info \
#-x UCX_RNDV_THRESH=inf \
#-x UCX_PROTO_INFO=y \ this is no longer enabled
#--mca coll_base_verbose 100 \ in stderr
#echo $SLURM_JOB_NODELIST > nodes.txt
#export UCX_RNDV_THRESH=1
#export UCX_LOG_LEVEL=info
#export UCX_TLS=rc,sm,self
#export UCX_PROTO_INFO=y



export OMPI_MCA_btl='^uct,ofi'
export OMPI_MCA_pml='ucx'
export OMPI_MCA_mtl='^ofi'
export UCX_NET_DEVICES=mlx5_0:1

mkdir -p ./ucx_proto_details

export UCX_PROTO_ENABLE=y
export UCX_PROTO_INFO=y
export UCX_PROTO_INFO_DIR="$PWD/ucx_proto_details"

export UCX_LOG_LEVEL=info
mkdir -p ./ucx_64n_1ppn_d_${SLURM_JOB_ID}
export UCX_LOG_FILE="./ucx_64n_1ppn_d_${SLURM_JOB_ID}/ucx_%h_%p.log"

#mkdir -p ./nsys_gatherv
#export UCX_PROTO_INFO=y
#export UCX_LOG_LEVEL=info
#export NSYS_MPI_STORE_TEAMS_PER_RANK=1
srun --mpi=pmix osu_gatherv -m 8388608  -x 100 -i 1000 -f
#srun --mpi=pmix osu_gatherv -m 262144:262144 -x 100 -i 1000 -f

#srun --mpi=pmix \
#  bash -c '
#    if [[ "$SLURM_PROCID" -lt 4 ]]; then
#      nsys profile \
#        --trace=mpi,ucx,osrt \
#         --nic-metrics=true --stats=true \
#        -o "nsys_gatherv/rank_${SLURM_PROCID}" \
#        osu_gatherv -f -m 262144:262144
#    else
#      osu_gatherv -f -m 262144:262144
#    fi
#  '

#srun --mpi=pmix --nodes=64 --ntasks=64 --ntasks-per-node=1 osu_gatherv -m 2048 -x 100 -i 1000 -f
#mpirun  \
#    --mca pml ucx \
#    --mca plm_rsh_no_tree_spawn true \
#    --leave-session-attached \
#    --map-by ppr:2:node \
#    -x UCX_NET_DEVICES=mlx5_0:1 \
#    --hostfile nodes.txt \
#    -np 128 osu_gatherv -m 2048 -x 100 -i 1000
