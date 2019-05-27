#include <stdio.h>
#include <unistd.h>


int main(int argc, char* argv[])
{
    FILE* outfile = fopen(argv[1], "wb");
	char buff[1024];
	int b_count = 0; 

    while ((b_count = read(0, buff, 1024)) > 0){
		int zeros_count = 0;
		int is_sparse = 0;

		for (int i = 0; i < b_count; i++)
		{
		    if (buff[i] == 0)
		    {
		        is_sparse = 1;
		        zeros_count++;	        
		        continue;
		    }

		    if (is_sparse)
		    {
		        fseek(outfile, zeros_count, SEEK_CUR);
		        is_sparse = 0;
		        zeros_count = 0;
		    }

		    fwrite(&buff[i], 1, 1, outfile);
		}
		
		if (is_sparse)
		    fseek(outfile, zeros_count, SEEK_CUR);
		
	}

    fclose(outfile);
    return 0;
}
