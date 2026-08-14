#include <stdio.h>

typedef struct {
	double real;
	double imag;
} Complex_number;

double real_part(Complex_number number){
	double real = number.real;
	return real;
}


double imag_part(Complex_number number){
	double imag = number.imag;
	return imag;
}

void print_complex(Complex_number number){
	printf("Complex Number: %.2f + j%.2f\n", number.real, number.imag);
	return;
}

Complex_number complex_mult(Complex_number c1, Complex_number c2){
	double p1 = 0.0, p2 = 0.0, p3 = 0.0, p4 = 0.0, sum_p1 = 0.0, sum_p2 = 0.0;
	Complex_number result;

	p1 = c1.real * c2.real;
	p2 = c1.real * c2.imag;
	p3 = c1.imag * c2.real;
	p4 = c1.imag * c2.imag * (-1);
	
	sum_p1 = p1 + p4;
	sum_p2 = p2 + p3;

	result.real = sum_p1;
	result.imag = sum_p2;
	return result;
}

int main(){

	Complex_number c1;
	c1.real = 1.0;
	c1.imag = 2.0;
	
	Complex_number c2;
	c2.real = 2.0;
	c2.imag = 1.0;

	Complex_number c3;
	c3 = complex_mult(c1, c2);

	print_complex(c3);
	return 0;
}
