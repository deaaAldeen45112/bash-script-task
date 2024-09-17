#!/bin/bash

directories_before=()
directories_after=()
usage() {
    echo "Usage: $0 [tar.bz2|zip] backup_dir_path directory1 [compression_level1] ... [directoryN] [compression_levelN]"
    echo "       Compression level for tar: 1 (fastest) to 9 (best compression), default: 6"
    echo "       Compression level for zip: 1 (fastest) to 9 (best compression), default: 6"
    echo "       If you specify 'tar.bz2', the script will use tar for archiving and lbzip2 for compression."
    exit 1
}
check_directory_exists() {
    local dir=$1
    local message=$2
    if [ ! -d "$dir" ]; then
        echo "$message"
        exit 1
    fi
}
create_backup_dir() {
    local dir=$1
    mkdir -p "$dir"
}
start_logging() {
    local log_file=$1
    local current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
    echo "Backup started at $current_datetime" >> "$log_file"
}
log_message() {
    local log_file=$1
    local message=$2
    local current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$current_datetime] $message" >> "$log_file"
}
log_error() {
    local log_file=$1
    local message=$2
    local current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$current_datetime] ERROR: $message" >> "$log_file" >&2
}
get_logical_processors() {
    local num_processors=$(grep -c '^processor' /proc/cpuinfo)
    echo "$num_processors"
}
MAX_CONCURRENT_PROCESSES=$(get_logical_processors)
backup_directory() {
    local comp_method=$1
    local dir=$2
    local backup_dir=$3
    local log_file=$4
    local compression_level=$5
    while [ "$(jobs | wc -l)" -ge "$MAX_CONCURRENT_PROCESSES" ]; do
        sleep 1
    done
        log_message "$log_file" "Starting backup of $dir"
    if [ -d "$dir" ]; then
        local archive_name=$(basename "$dir")_$(date +"%Y-%m-%d_%H-%M-%S").$comp_method
        directories_after+=("$backup_dir/$archive_name")
        if [ "$comp_method" == "tar.bz2" ]; then
            tar --use-compress-program="lbzip2 -${compression_level}" -cf "$backup_dir/$archive_name" "$dir" 2>>"$log_file" &
        elif [ "$comp_method" == "zip" ]; then
            zip "-$compression_level" -r "$backup_dir/$archive_name" "$dir" -x '*.tmp' > /dev/null 2>>"$log_file" &
        fi
        local pid=$!
        echo "Started backup of $dir in the background"
    else
        log_error "$log_file" "$dir is not a valid directory"
    fi
}
check_and_install_software() {
    local software=$1
    local package=""
    case "$software" in
        "tar") package="tar";;
        "zip") package="zip";;
        "lbzip2") package="lbzip2";;
        *)
            log_error "$LOG_FILE" "Invalid software specified. Only 'tar', 'zip', or 'lbzip2' are supported."
            exit 1;;
    esac
    if ! command -v $package &> /dev/null; then
        read -p "$package is not installed. Do you want to install it? (y/n) " response
        if [[ "$response" == "y" ]]; then
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y $package
            elif command -v yum &> /dev/null; then
                sudo yum install -y $package
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y $package
            else
                log_error "$LOG_FILE" "Could not determine package manager. Please install $package manually."
                exit 1
            fi
        else
            log_error "$LOG_FILE" "$package is required to run this script. Exiting."
            exit 1
        fi
    fi
}
main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
      usage
    fi
    if [ "$#" -lt 3 ]; then
        usage
    fi
    local comp_method=$1
    shift
    if [[ "$comp_method" != "tar.bz2" && "$comp_method" != "zip" ]]; then
        echo "Invalid compression method. Please choose 'tar.bz2' or 'zip'."
        usage
    fi
    if [ "$comp_method" == "tar.bz2" ]; then
            check_and_install_software "tar"
            check_and_install_software "lbzip2"
        else
            check_and_install_software "zip"
    fi
    local file_extension="$comp_method"
    local backup_dir="$1"
    shift
    local log_file="$backup_dir/backup.log"
    create_backup_dir "$backup_dir"
    start_logging "$log_file"
    local comp_level_list=()
    while [ $# -gt 0 ]; do
        local dir="$1"
        shift
        check_directory_exists "$dir" "Error: Directory '$dir' does not exist."
        directories_before+=("$dir")
        if [[ "$1" =~ ^[1-9]$ ]]; then
            local compression_level="$1"
            shift
        else
            local compression_level="6"
        fi
            comp_level_list+=("$compression_level")
        done
        for ((i = 0; i < ${#directories_before[@]}; i++)); do
            backup_directory "$file_extension" "${directories_before[$i]}" "$backup_dir" "$log_file" "${comp_level_list[$i]}"
        done
    wait
    for ((i = 0; i < ${#directories_after[@]}; i++)); do
            if [ ! -f "${directories_after[$i]}" ]; then
                local after_filename=$(basename "${directories_after[$i]}")
                log_error "$log_file" "check log file"
                exit 1
            fi
    done
    log_message "$log_file" "All backups completed."
    echo "All backups completed."
    echo "the report:"
    printf "%-30s | %-10s | %-40s | %-10s\n" "Directories Before Compression" "Size" "Directories After Compression" "Size"
    printf "%-30s | %-10s | %-40s | %-10s\n" "--------------------------" "----------" "------------------------------" "----------"
    for ((i = 0; i < ${#directories_before[@]}; i++)); do
           local before_size="N/A"
           local after_size="N/A"
           if [ -d "${directories_before[$i]}" ]; then
               before_size=$(du -sbh "${directories_before[$i]}" | cut -f1)
           fi
           if [ -f "${directories_after[$i]}" ]; then
               after_size=$(du -sbh "${directories_after[$i]}" | cut -f1)
           fi
            local after_filename=$(basename "${directories_after[$i]}")
            printf "%-30s | %-10s | %-40s | %-10s\n" "${directories_before[$i]}" "$before_size" "$after_filename" "$after_size"
    done
}
main "$@"
