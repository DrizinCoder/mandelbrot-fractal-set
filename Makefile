compile:
	gcc code/mandelbrot.c -o build/main

compile-image-generator:
	gcc code/image_generator.c -o build/image_generator -lm

run-image_generator:
	./build/image_generator 1620 1080 -2 1 -1 1 500

run:
	./build/main

analytics-time:
	/usr/bin/time -v ./build/main
	
clean:
	rm -f build/main

