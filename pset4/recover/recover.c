#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// Define an 8 bit integer as BYTE
typedef uint8_t BYTE;

int main(int argc, char *argv[])
{
    // Must have to arguments. ./recover and file
    if (argc != 2)
    {
        printf("Usage: ./recover image\n");
        return 1;
    }

    // Open second argument as file
    FILE *infile = fopen(argv[1], "r");

    // If invalid infile, return
    if (!infile)
    {
        printf("No file with that name\n");
        return 1;
    }

    // Create pointer to img
    FILE *img = NULL;

    // Initialize jpegcount, and allocate space in memory for buffer and outfile
    int jpegcount = 0;

    unsigned char buffer[512];
    char *outfile = malloc(7 * sizeof(char));

    // fread return number of bytes it managed to read
    while (fread(buffer, 1, 512, infile) == 512)
    {
        // Check for header bytes
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
        {
            // Close previous image if this is not first
            if (jpegcount != 0)
            {
                fclose(img);
            }

            // Create filename
            sprintf(outfile, "%03i.jpg", jpegcount);

            // Open image file
            img = fopen(outfile, "w");

            // Write bytes from buffer to file
            fwrite(buffer, 1, 512, img);

            // Increase number of jpeg's created
            jpegcount++;
        }
        else
        {
            // If not beginning of jpeg, keep writing from buffer
            if (img != NULL)
            {
                fwrite(buffer, 1, 512, img);
            }
        }
    }

    // Free allocated memory
    free(outfile);

    // Return success
    return 0;
}
