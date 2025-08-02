#!/bin/bash

# Exit on error
set -e

echo "Downloading AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

echo "Unzipping package..."
unzip -q awscliv2.zip

echo "Installing AWS CLI..."
sudo ./aws/install

echo "Cleaning up..."
rm -rf awscliv2.zip aws/

echo "Verifying installation..."
aws --version

echo "AWS CLI v2 installed successfully."

