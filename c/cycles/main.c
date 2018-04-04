#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <memory.h>
#include <sys/param.h>


unsigned long long count_cycles_at(int start, int end, unsigned long long path, int n, int* data) {
    int next;
    unsigned long long count, mask, masked;
    count = 0;
    int loc = end * n; // starting location for data about the vertex;
    next = data[loc];
    while (next >= 0 && loc < n*n) {
        if (next == start) {
            count++;
        } else if (next > start) {
            masked = 1;
            mask =  masked << (next);
            masked = mask & path;
            if (masked == 0) {
                masked = path | mask;
                count += count_cycles_at(start, next, masked, n, data);
            }
        }
        loc++;
        next = data[loc];
    }
    return count;
}

unsigned long long count_cycles(int n, int* data) {
    int i;
    unsigned long long c = 0;
    for (i = 0; i < n; i++) {
        c += count_cycles_at(i, i, 0, n, data);
    }
    return c;
}

void read_graph(char* fn, int n, int* data) {
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    int vert, edge_n;
    const char space[2] = " ";
    char* token;

    fp = fopen(fn, "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);

    while ((read = getline(&line, &len, fp)) != -1) {
        if (read > 0 && line[0] != '#') {
            edge_n = 0;
            token = strtok(line, space);
            if (token == NULL) {
                printf("no integers in %s", line);
                continue;
            }
            vert = atoi(token);
            token = strtok(NULL, space);
            while (token != NULL) {
                data[vert*n + edge_n] = atoi(token);
                edge_n++;
                token = strtok(NULL, space);
            }
        }
    }

    fclose(fp);
    if (line)
        free(line);
}

int main(int argc, const char* argv[]) {
    const int n = atoi(argc > 1 ? argv[1] : "35");
    char fn[100];
    sprintf(fn, "/Users/gic/code/cycles/data/graph%d.adj", n);
    time_t start = time(0);
    int* data =(int *) malloc(n*n*sizeof(int));
    for (int i = 0; i < n*n; i ++) {
        data[i] = -1; // -1 is used as a terminator throughout
    }
    read_graph(fn, n, data);
    unsigned long long cycles = count_cycles(n, data);
    time_t stop = time(0);
    free(data);
    printf("Found %llu cycles in %ld sec\n", cycles, stop - start);
    return 0;
}