#!/bin/bash
print_red() {
    printf "\033[1;31m%s\033[0m\n" "$1"
}


print_green() {
    printf "\033[1;32m%s\033[0m\n" "$1"
}

check_disk_space() {
    echo "===== Disk Space Check ====="
    df -h | awk 'NR>1 {print $1, $5}' | while read -r filesystem usage; do
        usage=$(echo "$usage" | sed 's/%//g')  # Remove percentage sign
        if [ "$usage" -gt 90 ]; then
            print_red "Warning: Disk space usage on $filesystem is above 90% ($usage%)"
        else
            print_green "Good: Disk space usage on $filesystem is at $usage%"
        fi
    done
}

check_memory_usage() {
    echo "===== Memory Usage Check ====="
    free | awk '/Mem:/ {print $3/$2 * 100.0}' | while read -r usage; do
        usage=${usage%.*} 
        if [ "$usage" -gt 90 ]; then
            print_red "Warning: Memory usage is above 90% ($usage%)"
        else
            print_green "Good: Memory usage is at $usage%"
        fi
    done
}


check_running_services() {
 echo "===== Running Services Check ====="
if command -v systemctl &> /dev/null && systemctl list-units --type=service --state=running &> /dev/null; then
      systemctl list-units --type=service --state=running
else
    echo "Using service command:"
    echo "----------------------"
    service --status-all |& grep +
fi
}


check_system_updates() {
    echo "===== System Updates Check ====="

    tail -n 50 /var/log/apt/history.log | tac
}

main()
{
    check_disk_space
    echo ""
    check_memory_usage
    echo ""
    check_running_services
    echo ""
    check_system_updates
    echo "System health check complete."

}
main
