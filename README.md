---
layout: default
title: User Guide
---

# AI-Panther HPC User Guide

A comprehensive guide for using AI-Panther, Florida Tech's High-Performance Computing (HPC) cluster.


## 1. Introduction {#introduction}

AI-Panther is Florida Tech's High-Performance Computing (HPC) cluster designed for computationally intensive research and academic projects.

**Key Capabilities:**

- 32 NVIDIA A100 GPUs (40GB each) for deep learning and GPU computing
- 16 CPU nodes for general computation
- SLURM job scheduler for resource management

**Who Should Use This Guide:**

- Students and researchers new to HPC clusters
- Users familiar with Python/coding but new to cluster computing
- Anyone needing GPU resources for machine learning or data science

**What You'll Learn:**

1. Connecting to AI-Panther via VS Code or SSH
2. Submitting and managing SLURM jobs
3. Managing files and Python environments
4. Best practices and troubleshooting

---

## 2. Getting Started {#getting-started}

### Prerequisites

1. **TRACKS Account** - Your Florida Tech username and password
2. **VPN Access** - Required when off-campus ([Setup instructions](https://fit.edu/vpn))
3. **SSH Client** - VS Code with Remote-SSH extension (recommended) or terminal

### Connecting to AI-Panther

#### Method 1: VS Code with Remote-SSH (Recommended)

**Setup:**

1. Install [VS Code](https://code.visualstudio.com/)
2. Install the [Remote-SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
   - Open Extensions (`Ctrl+Shift+X`)
   - Search for "Remote - SSH"
   - Install the Microsoft extension
3. Connect to AI-Panther:
   - Press `F1` → "Remote-SSH: Connect to Host"
   - Enter: `your_username@ai-panther.fit.edu`
   - Select **Linux** when prompted (first time only)
   - Enter your password
4. Open your project folder (File → Open Folder)

**Benefits:**

- Integrated file editing and terminal
- Extensions work on remote files
- No manual file transfers

#### Method 2: Command Line SSH

If you're comfortable with terminals, you can connect directly:

```bash
ssh your_username@ai-panther.fit.edu
```

### Initial Setup

Once connected, create your project workspace:

```bash
# Check current directory
pwd

# Create project folders
mkdir -p projects/{data,scripts,notebooks}
cd projects
```

**Common Terminal Shortcuts:**

- `Tab`: Auto-complete paths and filenames
- `Up arrow`: Recall previous commands
- `Ctrl+C`: Cancel running command
- `Ctrl+L`: Clear terminal screen

### Understanding AI-Panther's Resources

**CPU Nodes** (16 nodes: node01-node16)

- Think of these as very powerful regular computers
- Good for: Data processing, simulations, non-GPU tasks
- Available through different time limits (more on this later)

**GPU Nodes** (8 nodes with 32 GPUs total!)

- GPUs are special processors great for AI and deep learning
- **gpu1 partition**: 4 nodes (gpu01-gpu04) with high-performance A100 GPUs
- **gpu2 partition**: 4 nodes (gpu05-gpu08) with standard A100 GPUs
- Each node has 4 GPUs, and each GPU has 40GB of memory
- Perfect for: Training neural networks, machine learning, data science

#### Detailed GPU Information

**GPU1 Partition (High-Performance):**

- **Nodes**: gpu01, gpu02, gpu03, gpu04
- **GPU Model**: NVIDIA A100-SXM4-40GB
- **Total GPUs**: 16 (4 per node)
- **Memory**: 40GB per GPU
- **Power**: 400W per GPU
- **Best for**: Intensive training, large models, multi-GPU workloads

**GPU2 Partition (Standard):**

- **Nodes**: gpu05, gpu06, gpu07, gpu08
- **GPU Model**: NVIDIA A100-PCIE-40GB
- **Total GPUs**: 16 (4 per node)
- **Memory**: 40GB per GPU
- **Power**: 250W per GPU
- **Best for**: General GPU computing, inference, lighter training

**Both partitions:**

- CUDA Version: 12.9
- Driver: 575.51.03
- Time Limit: Unlimited

**Choosing Between gpu1 and gpu2:**

- **gpu1 (SXM4)**: Higher performance, better for intensive training
- **gpu2 (PCIe)**: Slightly lower performance but still excellent for most workloads
- **Strategy**: Try gpu1 first; if busy, gpu2 is nearly as good

**How to Request GPUs:**

Single GPU (most common):

```bash
# Let SLURM choose best available node
srun -p gpu1 --gres=gpu:1 --mem=16G --time=4:00:00 --pty /bin/bash

# Try gpu2 if gpu1 is busy
srun -p gpu2 --gres=gpu:1 --mem=16G --time=4:00:00 --pty /bin/bash
```

Multiple GPUs:

```bash
# 2 GPUs (for multi-GPU training)
srun -p gpu1 --gres=gpu:2 --mem=64G --cpus-per-task=8 --time=8:00:00 --pty /bin/bash

# All 4 GPUs on one node (for large models)
srun -p gpu1 --gres=gpu:4 --mem=128G --cpus-per-task=16 --time=12:00:00 --pty /bin/bash
```

**Checking GPU Availability:**

```bash
# See all GPU nodes
sinfo -p gpu1,gpu2

# See only idle nodes
sinfo -p gpu1,gpu2 -t idle

# View GPU usage on gpu1 nodes
srun -p gpu1 nvidia-smi
```

**Using GPUs in Your Code:**

For PyTorch:

```python
import torch

# Check CUDA availability
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"Number of GPUs: {torch.cuda.device_count()}")
print(f"Current GPU: {torch.cuda.get_device_name(0)}")

# Move model and data to GPU
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = model.to(device)
data = data.to(device)
```

For TensorFlow:

```python
import tensorflow as tf

# Check GPU availability
print("GPUs Available:", tf.config.list_physical_devices('GPU'))
```

**GPU Best Practices:**

- Start with 1 GPU and scale up if needed
- Each A100 has 40GB memory—consider your model size
- Match CPU cores to GPU count (e.g., 4 CPUs per GPU)
- Use `nvidia-smi` to check GPU utilization
- Look for 70-100% GPU utilization for good efficiency

**Storage Space:**

- **Home directory** (`~/`) - Your personal space (starts in /home1/your_username)
  - Limited space, backed up regularly
  - Store your code, scripts, small files here
  
- **Project storage** - For larger datasets
  - Ask your advisor about project folder locations
  
- **Temporary storage** (`/tmp/`) - Fast but temporary
  - Files here are deleted after your job finishes
  - Good for intermediate processing files

**The Job Scheduler (SLURM):**

Since many people use AI-Panther, there's a "scheduler" called SLURM that:

- Takes your request for resources (like "I need 1 GPU for 2 hours")
- Finds available resources
- Runs your code on those resources
- Manages the queue when resources are busy

---

## 3. Working with SLURM (The Job Scheduler) {#working-with-slurm-the-job-scheduler}

### What is SLURM?

SLURM (Simple Linux Utility for Resource Management) manages job scheduling and resource allocation on AI-Panther. It ensures fair access to compute nodes by:

- Queuing and prioritizing job requests
- Allocating requested resources (CPUs, GPUs, memory, time)
- Managing job execution and monitoring

**Job Types:**

1. **Interactive Jobs** (`srun`) - Direct terminal access to compute nodes for development and testing
2. **Batch Jobs** (`sbatch`) - Submit scripts for automated execution, ideal for long-running tasks

### Interactive Jobs

Request immediate access to compute resources:

**Basic CPU job:**

```bash
srun --mem=8G --cpus-per-task=2 --time=30:00 --pty /bin/bash
```

**Parameters:**

- `--mem=8G` - Memory allocation
- `--cpus-per-task=2` - CPU cores
- `--time=30:00` - Time limit (MM:SS or HH:MM:SS)
- `--pty /bin/bash` - Interactive shell

Your prompt will change to show the compute node (e.g., `node05`) when the job starts. Type `exit` to return to the login node.

**GPU job:**

```bash
srun --partition=gpu1 --gres=gpu:1 --mem=32G --cpus-per-task=4 --time=2:00:00 --pty /bin/bash
```

### Partitions

**CPU Partitions:**

| Partition | Time Limit | Best For |
|-----------|------------|----------|
| **short*** (default) | 45 minutes | Testing, debugging, quick analyses |
| **med** | 4 hours | Standard computational tasks |
| **long** | 7 days | Long training runs, simulations |
| **eternity** | Unlimited | Very long jobs (use responsibly) |

**GPU Partitions:**

| Partition | GPUs | Time Limit | Best For |
|-----------|------|------------|----------|
| **gpu1** | 16x A100-SXM4 | Unlimited | High-performance deep learning |
| **gpu2** | 16x A100-PCIe | Unlimited | General GPU computing |

Check partition availability:

```bash
sinfo              # All partitions
sinfo -p gpu1      # Specific partition
sinfo -t idle      # Show only idle nodes
```

### Essential SLURM Commands

| Command | What It Does | Example |
|---------|--------------|---------|
| `sinfo` | Show partition and node status | `sinfo -p gpu1` |
| `squeue` | View job queue | `squeue -u $USER` |
| `srun` | Run interactive job | `srun -p gpu1 --gres=gpu:1 --pty bash` |
| `sbatch` | Submit batch job script | `sbatch job.slurm` |
| `scancel` | Cancel a job | `scancel 12345` |
| `sacct` | View job history | `sacct --starttime=2024-01-01` |

### More Interactive Job Examples

### Request specific GPU node

srun -w gpu02 -p gpu1 --gres=gpu:1 --mem=32G --time=4:00:00 --pty bash

### Multiple GPUs (up to 4 per node)

srun -p gpu1 --gres=gpu:2 --mem=64G --time=4:00:00 --pty /bin/bash

```

**Key Options:**
- `-p partition` - Select partition (short, med, long, gpu1, gpu2)
- `--mem=16G` - Memory allocation
- `--cpus-per-task=4` - CPU cores
- `--time=2:00:00` - Time limit (HH:MM:SS)
- `--gres=gpu:N` - Request N GPUs (gpu partitions only)
- `-w node_name` - Target specific node

### Batch Jobs

Create a job script for long-running or automated tasks:

**Example: `train_model.slurm`**
```bash
#!/bin/bash
#SBATCH --job-name=my_training_job
#SBATCH --partition=gpu1
#SBATCH --gres=gpu:1
#SBATCH --time=8:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/job_%j.out
#SBATCH --error=logs/job_%j.err

echo "Job started on $(hostname) at $(date)"
echo "Job ID: $SLURM_JOB_ID"

# Activate environment
source ~/projects/myproject/.venv/bin/activate

# Run training
python train.py --epochs 100 --batch-size 64

echo "Job finished at $(date)"
```

**2. Submit the job:**

```bash
sbatch train_model.slurm
```

**3. Monitor your job:**

```bash
squeue -u $USER                    # View queue
sacct -j <job_id>                  # Job details
tail -f logs/job_<job_id>.out      # Watch output
```

---



## 4. Python Environments {#python-environments}

### Virtual Environments

**venv:**

```bash
python -m venv ~/myproject/.venv
source ~/myproject/.venv/bin/activate
```

**virtualenv:**

```bash
virtualenv ~/myproject/.venv
source ~/myproject/.venv/bin/activate
```

### Dependency Management

**Install packages:**

```bash
pip install numpy pandas torch torchvision
```

**Save dependencies:**

```bash
pip freeze > requirements.txt
```

**Install from requirements:**

```bash
pip install -r requirements.txt
```

### Using Conda

If Conda is available on the cluster:

```bash
module load anaconda3
conda create -n myenv python=3.9
conda activate myenv
```

**Install packages:**

```bash
conda install numpy pandas pytorch torchvision pytorch-cuda=11.8 -c pytorch -c nvidia
```

---

## 5. File Management {#file-management}

### Storage Locations

Typical storage hierarchy:

- **Home directory** (`~/`): Limited space, backed up, for personal files
- **Project directories** (`/project/` or `/scratch/`): Larger storage, may not be backed up
- **Temporary storage** (`/tmp/`): Fast local storage on compute nodes, cleared after job

Check your disk usage:

```bash
du -sh ~/*
df -h ~
```

### Data Transfer

**From local to AI-Panther:**

```bash
scp -r /local/path/ your_username@ai-panther.fit.edu:~/remote/path/
```

**From AI-Panther to local:**

```bash
scp -r your_username@ai-panther.fit.edu:~/remote/path/ /local/path/
```

**Using rsync (preserves timestamps, more efficient):**

```bash
rsync -avz /local/path/ your_username@ai-panther.fit.edu:~/remote/path/
```

**For large transfers, consider:**

```bash
rsync -avz --progress /local/path/ your_username@ai-panther.fit.edu:~/remote/path/
```

### File Best Practices

1. **Organize your directories** - Keep projects separate
2. **Clean up regularly** - Delete unnecessary files and old datasets
3. **Use .gitignore** - Don't version control large data files
4. **Compress datasets** - Use `.tar.gz` for archiving
5. **Document your data** - Keep README files describing your datasets

---

## 6. Troubleshooting {#troubleshooting}

### Common Issues

#### "No idle nodes available"

**Solution 1:** Wait and try again later

```bash
watch -n 60 'sinfo -p gpu1'
```

**Solution 2:** Try a different partition

```bash
sinfo  # See all partitions
srun -p cpu ...  # Use CPU partition instead
```

**Solution 3:** Reduce resource requirements

```bash
# Instead of:
srun -p gpu1 --gres=gpu:2 --mem=64G --time=24:00:00 ...

# Try:
srun -p gpu1 --gres=gpu:1 --mem=32G --time=8:00:00 ...
```

### SSH Connection Problems

**Issue: Connection refused**

- Check VPN connection
- Verify you're using the correct hostname
- Try from a different network

**Issue: Connection timeout**

```bash
ssh -vvv your_username@ai-panther.fit.edu  # Verbose output for debugging
```

**Issue: Authentication failed**

- Verify your credentials
- Check if your account is active
- Contact IT support

### Job Failures

**Check job status:**

```bash
squeue -u $USER
sacct -j <job_id>
```

**View job output:**

```bash
cat job_<job_id>.out
cat job_<job_id>.err
```

**Common reasons for job failures:**

1. **Out of time**: Increase `--time` parameter
2. **Out of memory**: Increase `--mem` parameter
3. **File not found**: Check paths in your script
4. **Module not loaded**: Add necessary `module load` commands

### Out of Memory Errors

**In Python:**

```python
import torch

# Clear GPU cache
torch.cuda.empty_cache()

# Use smaller batch sizes
batch_size = 32  # Try reducing this

# Enable gradient checkpointing
model.gradient_checkpointing_enable()
```

**Monitor memory usage:**

```bash
# GPU memory
nvidia-smi

# System memory
free -h
htop
```

---

## 7. Best Practices {#best-practices}

### Resource Management

1. **Request appropriate resources**:
   - Don't over-request (blocks resources for others)
   - Don't under-request (job may fail)

2. **Set realistic time limits**:
   - Shorter jobs may schedule faster
   - Add buffer time for unexpected delays

3. **Cancel unused jobs**:

   ```bash
   scancel <job_id>
   scancel -u $USER  # Cancel all your jobs
   ```

4. **Check job efficiency**:

   ```bash
   seff <job_id>  # If available
   ```

### Code Optimization

1. **Profile your code**:

   ```python
   import cProfile
   cProfile.run('your_function()')
   ```

2. **Use vectorization**:
   - NumPy operations instead of loops
   - Pandas operations instead of iterating rows

3. **Leverage GPUs efficiently**:
   - Maximize batch sizes
   - Use mixed precision training
   - Profile GPU utilization

4. **Test locally first**:
   - Debug on small datasets
   - Use `--time=0:30:00` for test runs

### Cluster Etiquette

1. **Be considerate of others**:
   - Don't monopolize resources
   - Cancel jobs you no longer need

2. **Use appropriate partitions**:
   - Use debug partition for testing
   - Use GPU partition only when you need GPUs

3. **Optimize I/O**:
   - Minimize frequent small file operations
   - Use local scratch space for temporary files

4. **Document your work**:
   - Comment your job scripts
   - Keep a log of experiments

---

## 8. Additional Resources {#additional-resources}

### Official Documentation

- **SLURM Documentation**: [https://slurm.schedmd.com/](https://slurm.schedmd.com/)
- **Florida Tech IT Support**: Contact your university IT department

### Useful Commands Cheat Sheet

```bash
# Check cluster status
sinfo
sinfo -p gpu1

# View your jobs
squeue -u $USER

# Submit batch job
sbatch job.slurm

# Interactive session
srun -p gpu1 --gres=gpu:1 --pty /bin/bash

# Cancel job
scancel <job_id>

# Job history
sacct -u $USER

# Check disk usage
du -sh ~/*
quota -s  # If quota system is enabled

# Module system (if available)
module avail
module load python/3.9
module list

# GPU monitoring
nvidia-smi
watch -n 1 nvidia-smi
```

### Python/ML Specific

**PyTorch GPU Check:**

```python
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA version: {torch.version.cuda}")
print(f"Device count: {torch.cuda.device_count()}")
print(f"Current device: {torch.cuda.current_device()}")
print(f"Device name: {torch.cuda.get_device_name(0)}")
```

**TensorFlow GPU Check:**

```python
import tensorflow as tf
print(f"GPU available: {tf.config.list_physical_devices('GPU')}")
```

### Getting Help

If you encounter issues not covered in this guide:

1. **Check SLURM logs**: `sacct` and job output files
2. **Search documentation**: SLURM docs and Florida Tech wiki
3. **Contact support**: Your university's HPC support team
4. **Community resources**: Stack Overflow, HPC forums

---

## Contributing

Found an error or want to add information? This guide is meant to be a living document. Feel free to submit issues or pull requests to improve it!

## License

This guide is provided as-is for educational purposes.

---

**Last Updated**: November 2024
**Maintainer**: Michael Johnson
**Version**: 1.0
