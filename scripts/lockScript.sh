#!/bin/bash

LOCK_FILE="./lockfile.txt"

# Check if the lock file exists
while [ -e "$LOCK_FILE" ]; do
    echo "Lock detected. Waiting for the lock to be released..."
    sleep 1  # Adjust the sleep duration as needed
done

# Acquire the lock
echo "Acquiring lock..."
touch "$LOCK_FILE"

# Run the command
echo "Running the command..."
$@

# Release the lock
echo "Releasing lock..."
rm -f "$LOCK_FILE"
echo "Lock released."
