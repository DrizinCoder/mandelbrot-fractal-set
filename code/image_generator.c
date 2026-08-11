#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int testFractalPattern(int px, int py, int width, int height, int max_iter) {
    double x = (2.0 * px - width) / width;
    double y = (2.0 * py - height) / height;

    double dist = (x * x + y * y);
    double pattern = (1.0 + sin(dist * 10.0)) * 0.5;

    int iter = (int)(pattern * max_iter);

    return iter;
}

int main(int argc, char *argv[]) {
    printf("Você digitou %d argumentos.\n", argc);

    if (argc < 8) {
        printf("Uso: %s <width> <height> <minX> <maxX> <minY> <maxY> <max_iter>\n", argv[0]);
        return 1;
    }

    int width = atoi(argv[1]);
    printf("width: %d\n", width);
    int height = atoi(argv[2]);
    printf("height: %d\n", height);
    double minX = atof(argv[3]);
    printf("minX: %f\n", minX);
    double maxX = atof(argv[4]);
    printf("maxX: %f\n", maxX);
    double minY = atof(argv[5]);
    printf("minY: %f\n", minY);
    double maxY = atof(argv[6]);
    printf("maxY: %f\n", maxY);
    int max_iter = atoi(argv[7]);
    printf("max_iter: %d\n", max_iter);

    FILE *file_image = fopen("pictures/image.ppm", "wb");
    if (!file_image) {
        perror("Erro ao abrir arquivo");
        return 1;
    }

    fprintf(file_image, "P6\n%d %d\n255\n", width, height);

    for (int py = 0; py < height; py++) {
         for (int px = 0; px < width; px++) {

            int iter = testFractalPattern(px, py, width, height, max_iter);
           
            unsigned char r, g, b;

            //  dentro do limite
            if (iter == max_iter) { 
                r = g = b = 0;
            } 
            // fora do limite
            else {
                r = (iter * 9) % 256;
                g = (iter * 5) % 256;
                b = (iter * 11) % 256;
            }       

            fputc(r, file_image);
            fputc(g, file_image);
            fputc(b, file_image);
         }
    }

    fclose(file_image);
    return 0;
}
