#include <errno.h>
#include <libproc.h>
#include <mach/mach_time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <time.h>

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    char *end;
    long pid = strtol(argv[1], &end, 10);
    if (*end || pid <= 0 || pid > 2147483647) return 2;
    struct rusage_info_v2 usage = {0};
    if (proc_pid_rusage((int)pid, RUSAGE_INFO_V2, (rusage_info_t *)&usage)) {
        perror("proc_pid_rusage");
        return 1;
    }
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    double cpu_ns = ((double)usage.ri_user_time + usage.ri_system_time) * timebase.numer / timebase.denom;
    printf("{\"pid\":%ld,\"start\":%llu,\"cpu_ns\":%.0f,\"monotonic\":%.9f,"
           "\"footprint_bytes\":%llu,\"rss_bytes\":%llu}\n",
           pid, usage.ri_proc_start_abstime, cpu_ns, now.tv_sec + now.tv_nsec / 1e9,
           usage.ri_phys_footprint, usage.ri_resident_size);
    return 0;
}
