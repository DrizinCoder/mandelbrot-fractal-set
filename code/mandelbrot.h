#ifndef MANDELBROT_H
#define MANDELBROT_H

#include <complex.h>

typedef struct  {
    int check;
    double complex value;
    int iterations_to_scape;
} Mandelbrot_check_return;

Mandelbrot_check_return check_mandelbrot(double complex cpx_number, int max_iter);

#endif 
