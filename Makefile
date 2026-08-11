compile:
	gcc code/mandelbrot.c -o build/main

run:
	./build/main

analytics-time:
	/usr/bin/time -v ./build/main
	
clean:
	rm -f build/main

