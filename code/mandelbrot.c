#include <stdio.h>
#include <stdlib.h>
#include <complex.h>
#include "mandelbrot.h"

Mandelbrot_check_return check_mandelbrot(double complex cpx_number, int max_iter){
    double complex f_x = 0.0;

    for(int i = 0; i < max_iter; i++){
        f_x = cpow(f_x, 2) + cpx_number;
        if (cabs(f_x) > 2.0) {
            return (Mandelbrot_check_return){0, f_x, i+1};
        }
    }

    return (Mandelbrot_check_return){1, f_x, max_iter};
}

#ifndef NO_MAIN

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
        Mandelbrot_check_return result = check_mandelbrot(c, 1000);

        if (result.check == 1) {
            printf("number: %.2f+%.2fi is in mandelbrot set\n", real, imag);
        } else {
            printf("number: %.2f+%.2fi not is in mandelbrot set\n", real, imag);
        }
    }

    return 0;
}
#endif