#!/bin/bash
set -e

echo ""
echo "Starting Environment Setup for Safe Use of Public Model from Hugging Face"
echo "-------------------"

# Step 1. Check for Python 3
echo "Checking for Python 3..."
if command -v python3 &> /dev/null; then
    PYTHON=python3
elif command -v python &> /dev/null && python --version | grep -q "Python 3"; then
    PYTHON=python
else
    echo "Python 3 not found. You need to install Python 3.8 or higher first."

    read -p "Would you like to try installing Python 3 now? (Y/n): " answer
    answer=${answer:-Y} # defaults to Yes

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        OS=$(uname)
        echo "Attempting Python 3 install for $OS..."

        if [[ "$OS" == "Darwin" ]]; then
            # macOS
            if ! command -v brew &> /dev/null; then
                echo "Homebrew is required to install Python on macOS."
                echo "Visit https://brew.sh and install Homebrew first, then try running this script again. :)"
                exit 1
            fi
            brew install python
        elif [[ "$OS" == "Linux" ]]; then
            # Linux
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y python3 python3-venv
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y python3 python3-virtualenv
            else
                echo "Unsupported Linux pkg manager. Please install Python manually, then try running this script again. :)"
                exit 1
            fi
        else
            echo "Unsupported OS. Please install Python manually from https://www.python.org/"
            exit 1
        fi
    
        # Retry detection post-install
        if command -v python3 &> /dev/null; then
            PYTHON=python3
        else
            echo "Python installation failed - please install manually."
            exit 1
        fi
    else
        echo "Python 3 is required. Please install it manually from https://www.python.org/ and rerun this script."
        exit 1
    fi
fi

echo "Using $($PYTHON --version)"

 
# 2. Create and activate virtual environment
echo ""
echo "Creating virtual environment..."
$PYTHON -m venv venv
source venv/bin/activate


# 3. Upgrade pip and install requirements
echo ""
echo "Upgrading pip and installing dependencies..."
pip install --upgrade pip
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "No requirements.txt found. Skipping base dependency install..."
fi


# 4. Install ModelScan
echo ""
echo "Checking for ModelScan..."
if ! command -v modelscan &> /dev/null; then
    echo "ModelScan not found. Attempting pip install..."
    pip install 'modelscan[ tensorflow, h5py ]' || echo "ModelScan installation failed. Please install manually."
else
    echo "ModelScan installed successfully!"
fi


#5. Install KitOps
echo ""
echo "Checking for KitOps..."
if ! command -v kit &> /dev/null; then
    echo "KitOps not found. Attempting pip install now..."
    pip install kitops || echo "KitOps installation failed. Please install manually." # OR custom curl/npm/install link
else
    echo "KitOps is installed"
fi


# Final Message
echo "Environment setup complete! Activate your environment with:"
echo "   `source venv/bin/activate`"