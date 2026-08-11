compile:
	gcc code/mandelbrot.c -o build/main

compile-image-generator:
	gcc code/image_generator.c code/mandelbrot.c -DNO_MAIN -o build/image_generator -lm

run-image_generator:
	time -v ./build/image_generator 1620 1080 -2 1 -1 1 500

run:
	./build/main

analytics-time:
	/usr/bin/time -v ./build/main
	
compile-profile:
	gcc code/image_generator.c code/mandelbrot.c -pg -DNO_MAIN -o build/image_generator_profile -lm

profile: compile-profile
	@echo "Executando o gerador para coletar dados (isso pode levar alguns segundos)..."
	./build/image_generator_profile 1620 1080 -2 1 -1 1 500
	@echo "Gerando relatorio do gprof..."
	gprof ./build/image_generator_profile gmon.out > profiling_report.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório salvo em profiling_report.txt."
	@echo "Aqui está o Top 10 gargalos (Top of flat profile):"
	@head -n 15 profiling_report.txt
	@echo "---------------------------------------------------------"

clean:
	rm -f build/main build/image_generator build/image_generator_profile gmon.out profiling_report.txt perf_report.txt perf.data

