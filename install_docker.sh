#!/bin/bash
set -e

echo "Upgrading pip..."
python3 -m pip install --upgrade pip

echo "Installing Python dependencies..."
python3 -m pip install -r requirements.txt

echo "Checking for ModelScan..."
python3 -m pip install 'modelscan[tensorflow,h5py]' 

echo "Checkinf for KitOps..."
python3 -m pip install kitops

python3 -m pip install torch