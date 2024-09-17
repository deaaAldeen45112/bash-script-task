# Linux Command Mastery and Scripting Project

## Overview

This project demonstrates advanced skills in Linux shell scripting by automating common system administration tasks, including backup and system health checks. The assignment involves creating optimized shell scripts, analyzing their performance, and documenting the results. Additionally, the project includes a video demonstration showcasing the functionality of the scripts.

## Table of Contents
- [Scripts](#scripts)
  - [Backup Script](#backup-script)
  - [System Health Check Script](#system-health-check-script)
- [Performance Analysis & Optimization](#performance-analysis--optimization)
- [Documentation](#documentation)
- [Video Presentation](#video-presentation)

## Scripts

### 1. Backup Script
**Filename**: `backup_script.sh`

#### Purpose:
This script automates the process of backing up specified directories, compressing them, and logging the backup process. It supports two compression methods: `lbzip2` and `zip`.

#### Features:
- **Directory Backup**: Allows the user to specify one or more directories to be backed up.
- **Compression Methods**:
  - **Tar + lbzip2**: The script uses `tar` for archiving the specified directories and `lbzip2` for parallel compression, ensuring efficient use of multiple CPU cores.
  - **Zip**: The script also provides an option to use `zip`, which both archives and compresses the files in a single step.
- **Logging**: Logs important events, including the start and end time of the backup, file sizes, and any encountered errors, to a log file.
- **Error Handling**: Handles common errors such as missing directories, lack of permissions, or full disk, and logs these issues for troubleshooting.
- **Backup Report**: After the backup completes, the script reports the size of the backup files and logs any encountered issues.

#### Note:
- **Tar + lbzip2**: 
  - `tar` is primarily used for archiving, packaging multiple files and directories into a single archive without compressing them.
  - When combined with `lbzip2`, it offers both archiving and compression. The `lbzip2` command runs in parallel, leveraging multi-core CPUs for faster compression.
  
- **Zip**: 
  - `zip` is a combined tool for archiving and compressing, creating compressed archives in a single step. It’s easier to use but may not offer the same level of performance as `lbzip2` on systems with multiple CPU cores.

### 2. System Health Check Script
**Filename**: `health_check_script.sh`

This script checks the health of the system and generates a report. The health check includes:
- Disk space usage for all mounted file systems.
- Memory and swap usage.
- Verification of critical services.
- Checking for any pending system updates.
- Outputs a comprehensive report with suggestions for corrective actions if necessary.

## Performance Analysis & Optimization

Both scripts were analyzed for performance and optimized in the following ways:
- **Backup Script**: Added parallel compression using `lbzip2` for faster backup in multi-core systems.
- **System Health Script**: Reduced the execution time by using built-in Linux tools like `df`, `free`, and `systemctl` for efficient checks. Memory usage optimizations were implemented by avoiding unnecessary subshells.

Performance details and the impact of these optimizations are described in the accompanying documentation.

## Documentation
A full project report is available in `documentation_report.pdf`. This report includes:
- Detailed descriptions of the purpose and functionality of each script.
- Insights from the performance analysis, including benchmarking results.
- An explanation of optimizations applied and their impact on the script's performance.

## Video Presentation
A video presentation demonstrating the functionality of both scripts and the performance analysis process is available on YouTube:  
[Watch the Video Presentation](https://www.youtube.com/watch?v=0OVyrp144sE)

The video walks through:
- The execution of the scripts.
- The performance evaluation process.
- The optimizations applied to enhance the performance of each script.

