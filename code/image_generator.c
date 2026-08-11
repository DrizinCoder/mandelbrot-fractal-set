#include <stdio.h>
#include <stdlib.h>
#include "mandelbrot.h"

int mandelbrot(int px, int py, int width, int height, double minX, double maxX, double minY, double maxY, int max_iter) {
    double complex c;

    double unidades_largura = maxX - minX; // Quantidade de unidades de largura do plano
    double unidades_altura = maxY - minY; // Quantidade de unidades de altura do plano

    double proporcao_x = (px / (double)width); // De 0 a 1
    double proporcao_y = (py / (double)height); // De 0 a 1

    // Multiplica a proporção pelo tamanho total do plano matemático
    double deslocamento_x = unidades_largura * proporcao_x; 
    double deslocamento_y = unidades_altura * proporcao_y;

    // Soma o ponto de início (min) para achar a coordenada matemática exata
    double enquadramento_eixo_x = deslocamento_x + minX;
    double enquadramento_eixo_y = deslocamento_y + minY;

    // Número complexo que será calculado
    c = enquadramento_eixo_x + enquadramento_eixo_y * I; 

    Mandelbrot_check_return result = check_mandelbrot(c, max_iter);
    
    int iter = result.iterations_to_scape;

    return iter;
}

int main(int argc, char *argv[]) {
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

            int iter = mandelbrot(px, py, width, height, minX, maxX, minY, maxY, max_iter);
           
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
