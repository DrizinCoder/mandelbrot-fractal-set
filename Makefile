CC     = gcc
CFLAGS = -O0 -g
LIBS   = -lm

# ── Build principal (requisito do enunciado) ──────────────────────────────────
compile:
	$(CC) $(CFLAGS) code/image_generator.c code/mandelbrot.c -o build/programa $(LIBS)

run:
	mkdir -p pictures
	./build/programa 1620 1080 -2 1 -1 1 500

# ── Medição de tempo com /usr/bin/time ───────────────────────────────────────
analytics-time: compile
	mkdir -p pictures
	/usr/bin/time -v ./build/programa 1620 1080 -2 1 -1 1 1000

# ── gprof ─────────────────────────────────────────────────────────────────────
compile-profile:
	$(CC) $(CFLAGS) -pg code/image_generator.c code/mandelbrot.c -o build/programa_profile $(LIBS)

profile: compile-profile
	mkdir -p pictures reports/gprof
	@echo "Executando para coletar dados de profiling..."
	./build/programa_profile 1620 1080 -2 1 -1 1 500
	@if [ -f gmon.out ]; then mv gmon.out reports/gprof/; fi
	@echo "Gerando relatório do gprof..."
	gprof ./build/programa_profile reports/gprof/gmon.out > reports/gprof/profiling_report.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório salvo em reports/gprof/profiling_report.txt."
	@echo "Top 10 gargalos (flat profile):"
	@head -n 15 reports/gprof/profiling_report.txt
	@echo "---------------------------------------------------------"

# ── perf ──────────────────────────────────────────────────────────────────────
profile-perf: compile
	mkdir -p pictures reports/perf
	@echo "Executando com perf stat (coletando métricas de hardware)..."
	perf stat -e cycles,instructions,cache-misses,cache-references,branch-misses,branches,L1-dcache-load-misses,LLC-load-misses -o reports/perf/perf_stat.txt ./build/programa 1620 1080 -2 1 -1 1 500
	@echo "Executando com perf record (coletando call graph)..."
	perf record -o reports/perf/perf.data -g ./build/programa 1620 1080 -2 1 -1 1 500
	@echo "Gerando relatório do perf..."
	perf report -f -i reports/perf/perf.data --stdio > reports/perf/perf_report.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório perf stat salvo em reports/perf/perf_stat.txt:"
	@cat reports/perf/perf_stat.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório perf record (amostragem) salvo em reports/perf/perf_report.txt."
	@head -n 30 reports/perf/perf_report.txt
	@echo "---------------------------------------------------------"

# ── Limpeza ───────────────────────────────────────────────────────────────────
clean:
	rm -f build/programa build/programa_profile
	rm -rf reports

