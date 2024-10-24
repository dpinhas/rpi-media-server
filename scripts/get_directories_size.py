#!/usr/bin/env python3
import argparse
import os
import subprocess

def parse_args():
    parser = argparse.ArgumentParser(description="Script to check directory sizes and output Prometheus metrics.")
    parser.add_argument('--debug', action='store_true', help='Enable debug mode')
    parser.add_argument('--directories', type=str, required=True, help='Comma-separated list of directories to check')
    return parser.parse_args()

def get_directory_sizes(directory):
    command = ['du', '--block-size=1', '--max-depth=1', directory]
    result = subprocess.run(command, capture_output=True, text=True)
    lines = result.stdout.strip().split('\n')
    
    sizes = []
    for line in lines:
        parts = line.split(maxsplit=1)
        if len(parts) == 2:
            size, dir_name = parts
            size = int(size)
            sizes.append((size, dir_name))
    return sizes

def format_directory_name(dir_name, root_dir):
    # Mapping for prefixes
    if root_dir.endswith("tv"):
        prefix = "[T]"
    elif root_dir.endswith("movies"):
        prefix = "[M]"
    else:
        prefix = ""

    # Replace root directory with prefix
    formatted_name = dir_name.replace(root_dir, prefix)
    formatted_name = formatted_name.replace('/', ' ')
    return formatted_name.strip()

def write_metrics(sizes, output_file, debug, directory):
    with open(output_file, 'w') as f:
        f.write("# HELP node_directory_size_bytes Disk space used by some directories\n")
        f.write("# TYPE node_directory_size_bytes gauge\n")
        
        sorted_sizes = sorted(sizes, key=lambda x: x[0], reverse=True)
        
        for size, dir_name in sorted_sizes:
            formatted_name = format_directory_name(dir_name, directory)
            # Exclude total size metrics for the parent directories
            if formatted_name != format_directory_name(directory, directory):
                metric_line = f"node_directory_size_bytes{{directory=\"{formatted_name}\"}} {size}\n"
                if debug:
                    print(metric_line.strip())
                else:
                    f.write(metric_line)

def main():
    args = parse_args()
    debug = args.debug
    directories = args.directories.split(',')
    
    for directory in directories:
        directory = directory.strip()
        if not os.path.isdir(directory):
            print(f"Directory not found: {directory}")
            continue
        
        output_file = f"/home/pi/rpi-media-server/config/custom_metrics/directory_size_{os.path.basename(directory)}.prom"
        sizes = get_directory_sizes(directory)
        write_metrics(sizes, output_file, debug, directory)

if __name__ == "__main__":
    main()

