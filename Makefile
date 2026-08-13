CC     = gcc
CFLAGS = -O0 -g
LIBS   = -lm

MACHINE_NAME := $(shell hostname)

# ── Build principal (requisito do enunciado) ──────────────────────────────────
compile:
	$(CC) $(CFLAGS) code/image_generator.c code/mandelbrot.c -o build/programa $(LIBS)

run:
	mkdir -p pictures
	./build/programa 1620 1080 -2 1 -1 1 500

# ── Medição de tempo com /usr/bin/time ───────────────────────────────────────
analytics-time: compile hardware-info
	mkdir -p pictures reports/$(MACHINE_NAME)/time
	@echo "Executando com /usr/bin/time (medição detalhada de tempo e recursos)..."
	/usr/bin/time -v ./build/programa 1620 1080 -2 1 -1 1 500 2>&1 | tee reports/$(MACHINE_NAME)/time/time_report.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório salvo em reports/$(MACHINE_NAME)/time/time_report.txt."
	@echo "---------------------------------------------------------"

# ── Relatório de Hardware ───────────────────────────────────────────────────────
hardware-info:
	@mkdir -p reports/$(MACHINE_NAME)
	@echo "# Especificações de Hardware - $(MACHINE_NAME)" > reports/$(MACHINE_NAME)/README.md
	@echo "" >> reports/$(MACHINE_NAME)/README.md
	@echo "## CPU" >> reports/$(MACHINE_NAME)/README.md
	@lscpu | grep "Model name" >> reports/$(MACHINE_NAME)/README.md || true
	@echo "" >> reports/$(MACHINE_NAME)/README.md
	@echo "## Caches" >> reports/$(MACHINE_NAME)/README.md
	@lscpu | grep -i cache >> reports/$(MACHINE_NAME)/README.md || true
	@echo "" >> reports/$(MACHINE_NAME)/README.md
	@echo "## RAM (Memória)" >> reports/$(MACHINE_NAME)/README.md
	@echo -n "- Total Disponível: " >> reports/$(MACHINE_NAME)/README.md
	@dmidecode -t memory 2>/dev/null | awk '/Size:/ && !/No Module/ {sum+=$$2} END {print sum "GB"}' >> reports/$(MACHINE_NAME)/README.md || true
	@dmidecode -t memory 2>/dev/null | awk '/Type:/ && !/Unknown/ && !/Error/ {print "- Type: " $$2; exit}' >> reports/$(MACHINE_NAME)/README.md || true
	@echo "" >> reports/$(MACHINE_NAME)/README.md
	@echo "## GPU (Vídeo)" >> reports/$(MACHINE_NAME)/README.md
	@lshw -C display 2>/dev/null | awk '/product:|vendor:|configuration:/ {gsub(/^[ \t]+/, "- "); print}' >> reports/$(MACHINE_NAME)/README.md || true

# ── gprof ─────────────────────────────────────────────────────────────────────
compile-profile:
	$(CC) $(CFLAGS) -pg code/image_generator.c code/mandelbrot.c -o build/programa_profile $(LIBS)

profile: compile-profile hardware-info
	mkdir -p pictures reports/$(MACHINE_NAME)/gprof
	@echo "Executando para coletar dados de profiling..."
	./build/programa_profile 1620 1080 -2 1 -1 1 500
	@if [ -f gmon.out ]; then mv gmon.out reports/$(MACHINE_NAME)/gprof/; fi
	@echo "Gerando relatório do gprof..."
	gprof ./build/programa_profile reports/$(MACHINE_NAME)/gprof/gmon.out > reports/$(MACHINE_NAME)/gprof/profiling_report.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório salvo em reports/$(MACHINE_NAME)/gprof/profiling_report.txt."
	@echo "Top 10 gargalos (flat profile):"
	@head -n 15 reports/$(MACHINE_NAME)/gprof/profiling_report.txt
	@echo "---------------------------------------------------------"

# ── perf ──────────────────────────────────────────────────────────────────────
profile-perf: compile hardware-info
	mkdir -p pictures reports/$(MACHINE_NAME)/perf
	@echo "Executando com perf stat (coletando métricas de hardware)..."
	perf stat -e cycles,instructions,cache-misses,cache-references,branch-misses,branches,L1-dcache-load-misses,LLC-load-misses -o reports/$(MACHINE_NAME)/perf/perf_stat.txt ./build/programa 1620 1080 -2 1 -1 1 500
	@echo "Executando com perf record (coletando call graph)..."
	perf record -o reports/$(MACHINE_NAME)/perf/perf.data -g ./build/programa 1620 1080 -2 1 -1 1 500
	@echo "Gerando relatório do perf..."
	perf report -f -i reports/$(MACHINE_NAME)/perf/perf.data --stdio > reports/$(MACHINE_NAME)/perf/perf_report.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório perf stat salvo em reports/$(MACHINE_NAME)/perf/perf_stat.txt:"
	@cat reports/$(MACHINE_NAME)/perf/perf_stat.txt
	@echo "---------------------------------------------------------"
	@echo "Relatório perf record (amostragem) salvo em reports/$(MACHINE_NAME)/perf/perf_report.txt."
	@head -n 30 reports/$(MACHINE_NAME)/perf/perf_report.txt
	@echo "---------------------------------------------------------"

# ── Todas as análises ─────────────────────────────────────────────────────────
analyze-all: clean analytics-time profile profile-perf
	@echo "========================================================="
	@echo "Todas as análises (time, gprof, perf) foram concluídas!"
	@echo "Os relatórios estão salvos na pasta reports/$(MACHINE_NAME)/"
	@echo "========================================================="

# ── Limpeza ───────────────────────────────────────────────────────────────────
clean:
	rm -f build/programa build/programa_profile
	rm -rf reports/$(MACHINE_NAME)

