---
layout: default
title: Slides
---

# AI-Panther HPC User Guide – Slide Outline

## Slide 1 – Title

- AI-Panther HPC User Guide
- Comprehensive overview of Florida Tech's GPU-accelerated cluster
- Presenter: Michael Johnson · Version 1.0 · Updated Nov 2024

## Slide 2 – Cluster Snapshot

- 32× NVIDIA A100 (40 GB) GPUs + 16 CPU nodes
- SLURM handles scheduling across GPU/CPU partitions
- Built for deep learning, scientific computation, and teaching labs

## Slide 3 – Onboarding Checklist

- TRACKS credentials, VPN access, and an SSH client required
- Preferred workflow: VS Code + Remote SSH extension
- Alternative: direct terminal `ssh your_user@ai-panther.fit.edu`

## Slide 4 – Connecting via VS Code

- Install VS Code + Remote SSH, then connect to `ai-panther.fit.edu`
- Select Linux host type, authenticate, and open project folder
- Benefit: integrated terminals, extensions, and remote Jupyter editing

## Slide 5 – Hardware Awareness

- Know key partitions: GPU (A100 nodes), general CPU, debug
- Detailed GPU specs documented for capacity planning
- Use `sinfo`, `squeue`, `nvidia-smi` to monitor utilization

## Slide 6 – SLURM Fundamentals

- Jobs run through SLURM; interactive vs. batch workflows covered
- Core commands: `srun`, `sbatch`, `scancel`, `sacct`
- Provided templates for GPU/CPU interactive sessions and batch scripts

## Slide 7 – Advanced SLURM Usage

- Requesting specific GPU nodes or multiple GPUs (up to 4/node)
- Examples for memory, time, and partition flags
- Emphasis on cancelling unused jobs and respecting partitions

## Slide 8 – Jupyter Notebook Workflow

- Launch script `start_jupyter.sh` automates tunnel + token flow
- Manual setup documented (load Python module, activate env, `jupyter lab`)
- Access via VS Code Remote or SSH tunnel; security reminders included

## Slide 9 – Python Environments

- Recommended: `python -m venv` per project
- Guidance on dependency pinning via `requirements.txt`
- Conda usage documented when pre-installed environments are needed

## Slide 10 – File & Data Management

- Storage map: home, project share, `/scratch` for high-I/O work
- Data transfer via `scp`, `rsync`, or VS Code Remote Explorer
- Best practices: quotas, cleaning temp files, using tarballs for large moves

## Slide 11 – Troubleshooting Playbook

- Common issues: no idle nodes, SSH problems, SLURM failures, OOM
- Step-by-step fixes (e.g., check partitions, review logs, adjust resources)
- Encourages consulting `sacct`, job output files, and support channels

## Slide 12 – Best Practices & Resources

- Resource etiquette, profiling tips, GPU efficiency reminders
- Cheat sheet of daily commands + PyTorch/TensorFlow GPU checks
- Links: SLURM docs, Florida Tech IT, support contacts, contribution note
