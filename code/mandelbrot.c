#include <stdio.h>
#include <stdlib.h>
#include <complex.h>
#define LIMIT 1000

typedef struct  {
    int check;
    double complex value;
    int iterations_to_scape;
} Mandelbrot_check_return;

Mandelbrot_check_return check_mandelbrot(double complex cpx_number){
    double complex f_x = 0.0;

    for(int i = 0; i < LIMIT; i++){
        f_x = cpow(f_x, 2) + cpx_number;
        if (cabs(f_x) > 2.0) {
            return (Mandelbrot_check_return){0, f_x, i};
        }
    }

    return (Mandelbrot_check_return){1, f_x, LIMIT};
}



int main(int argc, char *argv[]) {
    /*int width = atoi(argv[1]);
    int height = atoi(argv[2]);

    double minX = atof(argv[3]);
    double maxX = atof(argv[4]);
    double complex minY = atof(argv[5]);
    double complex maxY = atof(argv[6]);

    printf("%d\n", width);
    printf("%d\n", height);
    
    printf("%f\n", minX);
    printf("%f\n", maxX);
    printf("%f\n", minY);
    printf("%f\n", maxY);*/

    double real, imag;

    while (scanf("%lf %lf", &real, &imag) == 2) {
        double complex c = real + imag * I;
        Mandelbrot_check_return result = check_mandelbrot(c);

        if (result.check == 1) {
            printf("number: %.2f+%.2fi is in mandelbrot set\n", real, imag);
        } else {
            printf("number: %.2f+%.2fi not is in mandelbrot set\n", real, imag);
        }
    }

    return 0;
}