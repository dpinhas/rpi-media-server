#!/usr/bin/env python3

import os
import sys
import logging

# Set the static destination path
DESTINATION_PATH = "/mnt/data/library/downloads/complete/"

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler("hardlink_creator.log"),
            logging.StreamHandler(sys.stdout)
        ]
    )

def process_file(file_path):
    if not os.path.isfile(file_path):
        logging.error(f"Source file '{file_path}' does not exist.")
        return

    file_name = os.path.basename(file_path)
    
    if "-thumb" in file_name:
        logging.info(f"Ignoring file: {file_name} (contains '-thumb')")
        return

    if "HeBits" in file_name:
        # Correctly remove "HeBits" and ensure formatting is preserved
        base_name = file_name.replace(".HeBits-", "-")  # Replace ".HeBits-" with just "-"
        base_name = base_name.replace("HeBits-", "-")  # Handle any edge cases
        dir_name = file_name.rsplit(".", 1)[0]
        target_dir = os.path.join(DESTINATION_PATH, dir_name)
        target_file = os.path.join(target_dir, base_name)

        try:
            os.makedirs(target_dir, exist_ok=True)
            os.link(file_path, target_file)
            logging.info(f"Created hard link: {file_path} -> {target_file}")
        except Exception as e:
            logging.error(f"Failed to create hard link for '{file_path}': {e}")

def process_directory(dir_path):
    if not os.path.isdir(dir_path):
        logging.error(f"Source path '{dir_path}' is not a directory or does not exist.")
        return

    for root, _, files in os.walk(dir_path):
        for file in files:
            process_file(os.path.join(root, file))

def main():
    setup_logging()

    if len(sys.argv) != 2:
        logging.error("Usage: python create_hardlinks.py <source_path_or_file>")
        sys.exit(1)

    src_path = os.path.abspath(sys.argv[1])

    if os.path.isdir(src_path):
        logging.info(f"Processing directory: '{src_path}'")
        process_directory(src_path)
    elif os.path.isfile(src_path):
        logging.info(f"Processing file: '{src_path}'")
        process_file(src_path)
    else:
        logging.error(f"Source path '{src_path}' does not exist.")

    logging.info("Hard link creation completed.")

if __name__ == "__main__":
    main()

