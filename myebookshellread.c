#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_LINE 4096
#define TMPFILE "tmp_reader_output.txt"
#define BOOKMARK_EXT ".bookmark"
#define ESPEAK_COMMAND "/usr/bin/espeak -v f4 -p85"

void cleanup_tmp() {
    remove(TMPFILE);
}

int file_exists(const char *filename) {
    return access(filename, F_OK) == 0;
}

void get_file_ext(const char *filename, char *ext, size_t size) {
    const char *dot = strrchr(filename, '.');
    if (dot && strlen(dot) < size) {
        strncpy(ext, dot + 1, size - 1);
    } else {
        ext[0] = '\0';
    }
}

void run_converter(const char *input, const char *ext, const char *arg3, char *output_file) {
    char command[1024];
    int converted = 0;

    if (arg3 && strcmp(arg3, "man") == 0) {
        snprintf(command, sizeof(command), "man -Tascii %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "gz") == 0) {
        snprintf(command, sizeof(command), "gunzip -c %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "bz2") == 0) {
        snprintf(command, sizeof(command), "bunzip2 -c %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "xz") == 0) {
        snprintf(command, sizeof(command), "unxz -c %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "ps") == 0) {
        snprintf(command, sizeof(command), "ps2ascii %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "pdf") == 0) {
        snprintf(command, sizeof(command), "pdf2txt %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "epub") == 0) {
        snprintf(command, sizeof(command), "epub2txt %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "odt") == 0) {
        snprintf(command, sizeof(command), "odt2txt %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "html") == 0 || strcmp(ext, "htm") == 0) {
        snprintf(command, sizeof(command), "html2text %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "tex") == 0) {
        snprintf(command, sizeof(command), "detex %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "1") == 0 || strcmp(ext, "2") == 0 || strcmp(ext, "ms") == 0) {
        snprintf(command, sizeof(command), "groff -Tascii -ms %s > %s", input, output_file);
        converted = 1;
    } else if (strcmp(ext, "me") == 0) {
        snprintf(command, sizeof(command), "groff -Tascii -me %s > %s", input, output_file);
        converted = 1;
    }

    if (converted) {
        system(command);
        atexit(cleanup_tmp);
    } else {
        strncpy(output_file, input, 255);
    }
}

int get_bookmark(const char *bookmark_file) {
    FILE *f = fopen(bookmark_file, "r");
    if (!f) return 1;

    int val;
    if (fscanf(f, "%d", &val) != 1) val = 1;
    fclose(f);
    return val;
}

void save_bookmark(const char *bookmark_file, int line) {
    FILE *f = fopen(bookmark_file, "w");
    if (!f) return;
    fprintf(f, "%d\n", line);
    fclose(f);
}

int count_lines(const char *filename) {
    FILE *f = fopen(filename, "r");
    if (!f) return 0;
    int lines = 0;
    char buf[MAX_LINE];
    while (fgets(buf, sizeof(buf), f)) lines++;
    fclose(f);
    return lines;
}

void speak_lines(const char *filename, const char *bookmark_file, int start_line) {
    FILE *f = fopen(filename, "r");
    if (!f) {
        perror("Unable to open file");
        return;
    }

    int total_lines = count_lines(filename);
    char line[MAX_LINE];
    int line_num = 1;

    while (fgets(line, sizeof(line), f)) {
        if (line_num >= start_line) {
            int percent = (100 * line_num) / total_lines;
            printf("%d (%d%%): %s", line_num, percent, line);

            char command[4096];
            snprintf(command, sizeof(command), "echo \"%s\" | %s", line, ESPEAK_COMMAND);
            FILE *espeak = popen(command, "r");
            if (espeak) pclose(espeak);

            save_bookmark(bookmark_file, line_num);
        }
        line_num++;
    }
    fclose(f);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s FILE [start-line] [man|noconv]\n", argv[0]);
        return 1;
    }

    const char *filename = argv[1];
    int start_line = (argc >= 3) ? atoi(argv[2]) : -1;
    const char *arg3 = (argc >= 4) ? argv[3] : NULL;

    char ext[32];
    get_file_ext(filename, ext, sizeof(ext));

    char output_file[256] = TMPFILE;
    run_converter(filename, ext, arg3, output_file);

    char bookmark_file[300];
    snprintf(bookmark_file, sizeof(bookmark_file), "%s%s", filename, BOOKMARK_EXT);

    if (start_line <= 0) {
        start_line = file_exists(bookmark_file) ? get_bookmark(bookmark_file) : 1;
    }

    speak_lines(output_file, bookmark_file, start_line);
    return 0;
}
