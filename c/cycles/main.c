#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <memory.h>


int get_edges_from(int* edges, int vertex, int n, int*data) {
    int loc = vertex * n; // starting location for data about the vertex;
    int val = data[loc];
    int index = 0;
    while (val >= 0 && index < n) {
        edges[index] = val;
        index++;
        loc++;
        val = data[loc];
    }
    return index;
}

int path_does_not_cross(int vertex, int path_length, int* path) {
    // count_cycles at already checked path[0],
    // we don't need to check path[-1] because these graphs don't have self edges
    for (int i = 1; i < path_length -1; i++) {
        if (vertex == path[i]) {
            return 0;
        }
    }
    return 1;
}

int count_cycles_at(int path_length, int* path, int n, int* data) {
    int next, i, j;
    int count = 0;
    int* edges = malloc(n * sizeof(int));
    int* newpath = malloc( (path_length + 1) * sizeof(int));
    int n_edges = get_edges_from(edges, path[path_length - 1], n, data);
    for (i = 0; i < n_edges; i++) {
        next = edges[i];
        if (next == path[0]) {
            count++;
        } else if (next > path[0] && path_does_not_cross(next, path_length, path)) {
            for (j = 0; j < path_length; j++) {
                newpath[j] = path[j];
            }
            newpath[path_length] = next;
            count = count + count_cycles_at(path_length + 1, newpath, n, data);
        }
    }
    free(edges);
    free(newpath);
    return count;
}

int count_cycles(int n, int* data) {
    int i, c;
    c = 0;
    for (i = 0; i < n; i++) {
        c += count_cycles_at(1, &i, n, data);
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
    const int n = atoi(argc > 1 ? argv[1] : "20");
    char fn[100];
    sprintf(fn, "/Users/gic/code/cycles/data/graph%d.adj", n);
    time_t start = time(0);
    int* data =(int *) malloc(n*n*sizeof(int));
    for (int i = 0; i < n*n; i ++) {
        data[i] = -1; // -1 is used as a terminator throughout
    }
    read_graph(fn, n, data);
    int cycles = count_cycles(n, data);
    time_t stop = time(0);
    free(data);
    printf("Found %d cycles in %d sec\n", cycles, stop - start);
    return 0;
}