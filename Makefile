CC     = gcc
CFLAGS = -O0 -g
LIBS   = -lm

# ── Build principal (requisito do enunciado) ──────────────────────────────────
compile:
	$(CC) $(CFLAGS) code/image_generator.c code/mandelbrot.c -o build/programa $(LIBS)

run:
	./build/programa 1620 1080 -2 1 -1 1 500

# ── Medição de tempo com /usr/bin/time ───────────────────────────────────────
analytics-time: compile
	/usr/bin/time -v ./build/programa 1620 1080 -2 1 -1 1 1000

# ── gprof ─────────────────────────────────────────────────────────────────────
compile-profile:
	$(CC) $(CFLAGS) -pg code/image_generator.c code/mandelbrot.c -o build/programa_profile $(LIBS)

profile: compile-profile
	@echo "Executando para coletar dados de profiling..."
	./build/programa_profile 1620 1080 -2 1 -1 1 500
	@echo "Gerando relatório do gprof..."
	gprof ./build/programa_profile gmon.out > profiling_report.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório salvo em profiling_report.txt."
	@echo "Top 10 gargalos (flat profile):"
	@head -n 15 profiling_report.txt
	@echo "---------------------------------------------------------"

# ── Limpeza ───────────────────────────────────────────────────────────────────
clean:
	rm -f build/programa build/programa_profile gmon.out profiling_report.txt perf_report.txt perf.data

