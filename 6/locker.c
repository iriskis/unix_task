#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>


bool is_exists(const char* fname)
    {
        return access(fname, 0) != -1;
    }

void create_lock_file(char* file_name, char t_lock) {
    FILE* my_lock = fopen(file_name, "w");
    fprintf(my_lock, "%d %c\n", getpid(), t_lock);
    fclose(my_lock);
}

void write_to_file(char* file_name, char* record) {
    FILE* f = fopen(file_name, "a+");
    fprintf(f, "%s\n", record);
    fclose(f);
}

void read_file(char* file_name) {
    char buff[256];
    FILE* f = fopen(file_name, "r+");
    while(fgets(buff, 256, f))
        printf("%s", buff);
    fclose(f);
}

char* get_lock_file_name(char* fname){
    const char* extension = ".lck";
    char* lock_file = calloc(strlen(fname) + strlen(extension) + 1, 1);
    strcat(lock_file, fname);
    strcat(lock_file, extension);
    return lock_file;
}

int main(int argc, char* argv[])
{
    char type_lock;

    if (argc < 2)
    {
        printf("Specify arguments: file_name (for read file) or file_name srting (for write string to file)\n");
        return 1;
    }
    else
    {
        if (argc > 2)
        type_lock = 'w';
        else type_lock = 'r';
    }
    
    char* lock_file = get_lock_file_name(argv[1]);

    while(is_exists(lock_file))
    {
        sleep(1);
    }
    create_lock_file(lock_file, type_lock);
    
    switch(type_lock) 
    {
        case 'w':
            write_to_file(argv[1], argv[2]);
            sleep(5);
            break;
            
        case 'r':
            read_file(argv[1]);
            sleep(5);
            break; 
    }
    remove(lock_file);
    free(lock_file);
    return 0;
}