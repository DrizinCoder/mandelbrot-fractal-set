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