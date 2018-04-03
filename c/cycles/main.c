#include <stdio.h>
#include <time.h>
#include <stdlib.h>


int count_cycles(int n, int* data) {
    return 42;
}

void read_graph(char* fn, int n, int* data) {
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    fp = fopen(fn, "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);

    while ((read = getline(&line, &len, fp)) != -1) {
        if (read > 0 && line[0] != '#') {
            printf("%s", line);
        }
    }

    fclose(fp);
    if (line)
        free(line);
}

int main(int argc, const char* argv[]) {
    const int n = atoi(argc > 1 ? argv[1] : "20");
    char fn[100];
    sprintf(fn, "/Users/gic/code/cycles/data/graph%d.adj", n);
    time_t start = time(0);
    int* data =(int *) malloc(n*n*sizeof(int));
    read_graph(fn, n, data);
    int cycles = count_cycles(n, data);
    time_t stop = time(0);
    free(data);
    printf("Found %d cycles in %d sec\n", cycles, stop - start);
    return 0;
}