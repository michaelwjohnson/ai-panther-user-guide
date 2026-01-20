#!/bin/bash

# Script to find idle GPU node and start Jupyter notebook server
# Author: Michael Johnson
# Date: November 4, 2024

set -e  # Exit on any error

echo "┌─────────────────────────────────────────────────────────┐"
echo "│ Checking for idle GPU nodes in gpu1 partition...       │"
echo "└─────────────────────────────────────────────────────────┘"

# Function to check node status
check_gpu_nodes() {
    echo "Available GPU nodes in gpu1 partition:"
    sinfo -p gpu1 -N -o "%N %T %C %G" --noheader
    echo ""
    
    # Get idle nodes
    idle_nodes=$(sinfo -p gpu1 -N -t idle -o "%N" --noheader | head -1)
    
    if [ -z "$idle_nodes" ]; then
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ [✗] No idle nodes found in gpu1 partition              │"
        echo "└─────────────────────────────────────────────────────────┘"
        echo "Current node states:"
        sinfo -p gpu1 -N -o "%N %T %C %G"
        
        echo ""
        echo "╔═════════════════════════════════════════════════════════╗"
        echo "║ Would you like to:                                      ║"
        echo "╠═════════════════════════════════════════════════════════╣"
        echo "║ 1. Wait and check again (y/n)?                          ║"
        echo "║ 2. Try a different partition (enter partition name)?    ║"
        echo "║ 3. Exit (any other key)?                                ║"
        echo "╚═════════════════════════════════════════════════════════╝"
        read -p "Choose option: " choice
        
        case $choice in
            [Yy]* )
                echo "[⧗] Waiting 30 seconds before checking again..."
                sleep 30
                check_gpu_nodes
                ;;
            * )
                if [[ "$choice" != [Nn]* ]] && [[ ! -z "$choice" ]]; then
                    echo "[↻] Checking partition: $choice"
                    idle_nodes=$(sinfo -p "$choice" -N -t idle -o "%N" --noheader | head -1)
                    if [ ! -z "$idle_nodes" ]; then
                        echo "[✓] Found idle node: $idle_nodes in partition $choice"
                        PARTITION="$choice"
                        return 0
                    else
                        echo "[✗] No idle nodes in partition $choice either"
                        exit 1
                    fi
                else
                    echo "[→] Exiting..."
                    exit 1
                fi
                ;;
        esac
    else
        echo "[✓] Found idle node: $idle_nodes"
        PARTITION="gpu1"
        return 0
    fi
}

# Check for idle nodes
check_gpu_nodes
NODE=$idle_nodes

echo "┌─────────────────────────────────────────────────────────┐"
echo "│ Starting interactive session on node: $NODE"
echo "└─────────────────────────────────────────────────────────┘"
echo "This will:"
echo "   → Allocate the node: $NODE"
echo "   → Start an interactive bash session"
echo "   → Launch Jupyter notebook server on 0.0.0.0:8888"
echo ""

# Get current working directory to maintain context
CURRENT_DIR=$(pwd)
echo "[📂] Current directory: $CURRENT_DIR"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "[⚠] Cleaning up..."
}
trap cleanup EXIT

echo "[▶] Submitting interactive job to SLURM..."

# Submit interactive job that will run the setup script
srun -p "$PARTITION" \
     --nodelist="$NODE" \
     --time=8:00:00 \
     --gres=gpu:1 \
     --mem=32G \
     --cpus-per-task=4 \
     --pty \
     /bin/bash -c '
        echo "╔═════════════════════════════════════════════════════════╗"
        echo "║ [✓] Node allocated successfully!                        ║"
        echo "╚═════════════════════════════════════════════════════════╝"
        echo "[●] Running on: $(hostname)"
        echo "[⚙] Setting up environment..."
        
        # Change to the original working directory
        cd "'"$CURRENT_DIR"'"
        echo "[📂] Working directory: $(pwd)"
        
        # Load any necessary modules (uncomment if needed)
        # module load python/3.9
        # module load cuda/11.8
        
        # Activate the project virtual environment
        # Update VENV_PATH to point to your virtual environment
        VENV_PATH="$HOME/.venv"  # Default location - modify as needed
        if [ -f "$VENV_PATH/bin/activate" ]; then
            echo "[🐍] Activating virtual environment at: $VENV_PATH"
            . "$VENV_PATH/bin/activate"
            export PATH="$VENV_PATH/bin:$PATH"
            export VIRTUAL_ENV="$VENV_PATH"
        else
            echo "[⚠] Virtual environment not found at $VENV_PATH"
            echo "[⚠] Using system Python"
        fi
        
        echo "[🐍] Python version: $(python --version)"
        echo "[🐍] Python executable: $(which python)"
        echo "[⚡] PyTorch CUDA available: $(python -c "import torch; print(torch.cuda.is_available())" 2>/dev/null || echo "PyTorch not available")"
        
        # Install jupyter if not available
        if ! command -v jupyter &> /dev/null; then
            echo "[📦] Installing Jupyter..."
            pip install jupyter
        fi
        
        echo "┌─────────────────────────────────────────────────────────┐"
        echo "│ [▶] Starting Jupyter notebook server...                 │"
        echo "└─────────────────────────────────────────────────────────┘"
        echo "[◉] Server will be accessible at: http://$(hostname -I | awk "{print \$1}"):8888"
        echo "[↗] Or from your local machine via SSH tunnel:"
        echo "    ssh -L 8888:$(hostname -I | awk "{print \$1}"):8888 $USER@ai-panther.fit.edu"
        echo ""
        echo "[■] To stop the server, press Ctrl+C"
        echo "═══════════════════════════════════════════════════════════"
        
        # Start Jupyter notebook with proper ServerApp configuration
        jupyter notebook \
            --no-browser \
            --ip=0.0.0.0 \
            --port=8888 \
            --allow-root
    '

echo ""
echo "┌─────────────────────────────────────────────────────────┐"
echo "│ [✓] Session completed!                                  │"
echo "└─────────────────────────────────────────────────────────┘"

