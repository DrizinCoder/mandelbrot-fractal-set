# Mandelbrot Fractal Set

Um gerador de fractais Mandelbrot escrito em C. 
Este projeto também inclui um conjunto de scripts no `Makefile` para realizar Análise de Performance (Profiling) rigorosa usando ferramentas como `gprof`, `perf`, e `valgrind`.

## Como executar

Para compilar o código e gerar a imagem do fractal:
```bash
make run
```
A imagem resultante (`image.ppm`) será salva na pasta `pictures/`.

## Análise de Performance (Profiling)

O projeto automatiza a geração de relatórios de performance e extração de dados do hardware. **Os relatórios são salvos e organizados automaticamente por máquina (usando o hostname) dentro da pasta `reports/`.** Portanto, os detalhes de hardware (CPU, RAM, Cache, GPU) de cada máquina que executar os testes estarão disponíveis em `reports/<maquina>/README.md`.

### Comandos de Profiling

Para rodar **todas as análises rápidas** (Tempo bruto, Gprof e Perf):
```bash
sudo make analyze-all
```
