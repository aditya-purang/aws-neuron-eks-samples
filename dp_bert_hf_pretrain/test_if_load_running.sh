#!/bin/bash

while true; do
    if kubectl get vcjob | grep Running | grep bert; then
        echo "Volcano job with 'bert' found running."
    else
        echo "No volcano job with 'bert' found. Now running the torchx command."
        /local/home/puranga/.local/bin/torchx run \
            -s kubernetes --workspace="file:///$PWD/docker" \
            -cfg queue=test,image_repo=037647485236.dkr.ecr.us-west-2.amazonaws.com/eks_torchx_tutorial_ergon_demo \
            lib/trn1_dist_ddp.py:generateAppDef \
            --name berttrain \
            --script_args "--batch_size 16 --grad_accum_usteps 32 \
                --data_dir /data/bert_pretrain_wikicorpus_tokenized_hdf5_seqlen128 \
                --output_dir /data/output" \
            --nnodes 2 \
            --nproc_per_node 32 \
            --image 037647485236.dkr.ecr.us-west-2.amazonaws.com/eks_torchx_tutorial_ergon_demo:bert_pretrain \
            --script dp_bert_large_hf_pretrain_hdf5.py \
            --bf16 True \
            --cacheset bert-large \
            --instance_type trn1.32xlarge
    fi
    sleep 60
done
