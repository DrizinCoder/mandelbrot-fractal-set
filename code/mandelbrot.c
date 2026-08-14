#include <stdio.h>
#include "complex.h"
#include "mandelbrot.h"

Mandelbrot_check_return check_mandelbrot(Complex_number c, int max_iter){
    Complex_number f = {0.0, 0.0};

    for(int i = 0; i < max_iter; i++){
        f = complex_mult(f, f);  // f²
        f.real += c.real;        // f² + c
        f.imag += c.imag;

        if (f.real * f.real + f.imag * f.imag > 4.0) {
            return (Mandelbrot_check_return){0, f, i+1};
        }
    }

    return (Mandelbrot_check_return){1, f, max_iter};
}
