# Projeto: Geração de Imagens do Conjunto de Mandelbrot e Profiling
**Disciplina:** Computação de Alto Desempenho (HPC)

---

## 1. Descrição do Algoritmo

O programa implementa o cálculo do conjunto de Mandelbrot em linguagem C e gera uma imagem resultante. O algoritmo consiste em varrer uma grade bidimensional de pixels (com largura e altura definidas pelo usuário) e mapear cada coordenada discreta da imagem para uma coordenada contínua no plano complexo. 

O mapeamento é feito calculando a proporção do pixel em relação à dimensão total da imagem e aplicando uma transformação afim (escala e translação) para enquadrar o ponto na janela matemática especificada (entre `minX` e `maxX` para o eixo real, e `minY` e `maxY` para o eixo imaginário). 

Para determinar se um ponto pertence ao conjunto de Mandelbrot, o programa utiliza uma estrutura de dados própria (`struct`) para representar números complexos (partes real e imaginária). A função de verificação aplica a equação iterativamente até atingir o limite de iterações (`max_iter`). Para otimizar o desempenho computacional — considerando o alto volume de cálculos —, a verificação de divergência evita o cálculo oneroso da raiz quadrada; em vez de checar se o módulo da distância é maior que 2, o algoritmo verifica se a soma dos quadrados das partes real e imaginária ultrapassa 4 ($a^2 + b^2 > 4$). 

Os pontos que não escapam (pertencem ao conjunto) recebem a cor correspondente em escala de cinza/preto. Para os pontos que escapam, o valor da iteração de escape determina o tom do pixel. Finalmente, os pixels são gravados em disco, otimizados por meio de lotes de escrita utilizando a biblioteca padrão (ex. `fputc`).

---

## 2. Especificações de Hardware (Máquina LOQ)

Os testes e métricas de desempenho deste relatório foram obtidos utilizando uma máquina com as seguintes especificações físicas:

### CPU
- **Model name**: 12th Gen Intel(R) Core(TM) i5-12450HX
- **Arquitetura híbrida**: Núcleos de performance (`cpu_core`) e eficiência (`cpu_atom`).

### Caches
- **L1d cache**: 320 KiB (8 instances)
- **L1i cache**: 384 KiB (8 instances)
- **L2 cache**: 7 MiB (5 instances)
- **L3 cache**: 12 MiB (1 instance)

---

## 3. Detalhes de Compilação

Para garantir reprodutibilidade e a coleta correta das métricas de desempenho, o programa foi compilado utilizando o `gcc` (GNU Compiler Collection). Foram utilizadas configurações específicas dependendo da ferramenta de análise alvo:

- **Compilação padrão e medição de tempo, `perf`, `Valgrind` e `strace`**:
  ```bash
  gcc -O0 -g code/complex.c code/image_generator.c code/mandelbrot.c -o build/programa -lm
  ```
  A flag `-O0` desabilita as otimizações do compilador (requisito para forçar o processamento puro e manter o tempo de execução visível), enquanto a flag `-g` inclui símbolos de depuração, fundamentais para mapear as instruções às linhas de código no Valgrind e no `perf`. A flag `-lm` foi usada para linkar a biblioteca matemática (`math.h`).

- **Compilação com suporte ao `gprof`**:
  ```bash
  gcc -pg -O0 -g code/complex.c code/image_generator.c code/mandelbrot.c -o build/programa_profile -lm
  ```
  A inclusão da flag `-pg` instrumenta o código, inserindo chamadas à biblioteca de profiling a cada invocação de função, a fim de gerar o arquivo `gmon.out`.

---

## 4. Tabelas de Resultados

Os testes mais recentes foram executados processando uma imagem de **7680x5120**, limite no eixo real $[-2, 1]$, limite no eixo imaginário $[-1, 1]$ e limite de **500 iterações**.

#### Tabela 4.1: Medição Geral de Tempo e Recursos (`/usr/bin/time`)
| Métrica | Valor Obtido |
| :--- | :--- |
| **Wall-clock time** (Tempo total) | 25.04 s |
| **User time** (Tempo de CPU em modo usuário) | 24.92 s |
| **System time** (Tempo de CPU em modo kernel) | 0.11 s |
| **Percentual de uso da CPU** | 99% |
| **Maximum Resident Set Size (RSS)** | 2.380 KB |
| **Page Faults** (Major / Minor) | 0 / 98 |
| **Context Switches** (Voluntary / Involuntary) | 4 / 1.362 |

> **Observação (`time`):** O fato do uso da CPU estar em $99\%$, aliado ao *User Time* de $24.92s$ (quase igual ao tempo total de $25.04s$), evidencia que a aplicação é estritamente **CPU-bound**.

#### Tabela 4.2: Instrumentação de Funções (`gprof`)
| Função | % Tempo | Tempo self (s) | Chamadas | Self ns/call |
| :--- | :--- | :--- | :--- | :--- |
| `check_mandelbrot` | 98.60% | 23.31 s | 39.321.600 | 592.80 ns |
| `main` | 0.63% | 0.15 s | - | - |
| `mandelbrot` | 0.42% | 0.10 s | 39.321.600 | 2.54 ns |
| `_init` | 0.34% | 0.08 s | - | - |

> **Observação (`gprof`):** O *flat profile* revela que a função `check_mandelbrot` é o *hotspot* da aplicação, representando $98.60\%$ do tempo. As $39.321.600$ chamadas correspondem exatamente à quantidade de pixels gerados ($7680 \times 5120$).

#### Tabela 4.3: Métricas de Hardware por Amostragem (`perf stat`)
Nesta nova execução em um processador híbrido (Intel 12th Gen), o `perf stat` detalhou métricas segregadas por tipo de núcleo (`cpu_atom` e `cpu_core`):

| Métrica (Eventos) | cpu_atom (Eficiência) | cpu_core (Performance) | Total Aproximado |
| :--- | :--- | :--- | :--- |
| **Ciclos (cycles)** | 75.710.601.622 | 106.047.860.133 | ~ 181.75 Bilhões |
| **Instruções (instructions)** | 119.822.314.456 | 173.166.380.527 | ~ 292.98 Bilhões |
| **Cache Misses** | 342.467.807 | 3.935.014 | ~ 346.40 Milhões |
| **Branch Misses** | 110.990.040 | 14.286.870 | ~ 125.27 Milhões |
| **L1-dcache-load-misses** | `<not supported>` | 7.965.975 | 7.965.975 (apenas core) |

> **Observação (`perf`):** O `perf report` atrelou mais de $99\%$ da carga de processamento ao fluxo que finaliza na função `check_mandelbrot`. O alto número de instruções processadas pelo `cpu_core` evidencia o engajamento dos núcleos de performance nas operações aritméticas intensas (P-cores).

#### Tabela 4.4: Análise Determinística (`Valgrind`)
| Ferramenta | Métrica Analisada | Valor / Função | Observação |
| :--- | :--- | :--- | :--- |
| **Callgrind** | Total de Instruções (Ir) | 172.139.169.596 | - |
| **Callgrind** | Maior volume de Ir | `check_mandelbrot` | 94.20% do total (162.16 Bilhões) |
| **Cachegrind** | L1 Data Miss Rate (D1mr) | 0.1% | Excepcional localidade |
| **Cachegrind** | Maior volume de Leitura (Dr) | `check_mandelbrot` | 72.99 Bilhões (95.1% do total) |
| **Cachegrind** | Maior volume de Escrita (Dw) | `check_mandelbrot` | 21.33 Bilhões (91.2% do total) |

> **Observação (`Valgrind`):** A análise do *Cachegrind* demonstra que, apesar do enorme volume de dados manipulados pelas funções matemáticas (dezenas de bilhões de leituras e escritas), a taxa de falha na cache L1 de dados (D1mr) é virtualmente zero (0.1%), o que confirma o excelente aproveitamento da **localidade temporal e espacial** pela aplicação.

#### Tabela 4.5: Rastreamento de Chamadas de Sistema (`strace`)
| Syscall | % Tempo Kernel | Total de Chamadas | Observação |
| :--- | :--- | :--- | :--- |
| `openat` | 56.08% | 4 | Abertura de arquivos e bibliotecas |
| `write` | 27.19% | 28.810 | Escrita da imagem gerada no disco |
| `close` | 14.87% | 4 | Fechamento de descritores |

> **Observação (`strace`):** O número elevado de chamadas `write` (28.810) reflete a escrita sequencial dos pixels/metadados no disco. Ainda assim, o tempo total despendido pelo SO para lidar com essas syscalls foi mínimo (apenas $0.02$ segundos), reforçando que a aplicação gasta quase a totalidade de seu tempo em modo usuário (*user space*) realizando os cálculos matemáticos intensos.

---

## 5. Análise Crítica

A combinação do utilitário `time` com o `gprof` provou-se a mais prática e valiosa para o fluxo de trabalho durante este projeto. 

Inicialmente, o `/usr/bin/time` forneceu de forma rápida e direta a confirmação do perfil de execução da aplicação: ao evidenciar a altíssima taxa de uso de processador (99%) e a equivalência entre o tempo de usuário e o tempo total de execução, ficou provado que a natureza do problema é intrinsecamente CPU-bound. 

A partir desta constatação primária, o `gprof` revelou-se a ferramenta de diagnóstico de maior impacto prático. Ele apontou, instantaneamente e sem um overhead tão pesado quanto o do Valgrind, que virtualmente quase todo o tempo de processamento estava concentrado em uma única função: `check_mandelbrot`. Essa identificação direta do *hotspot* permitiu e direcionou os esforços para a otimização do algoritmo serial (como, por exemplo, substituir a onerosa chamada da função de raiz quadrada pela verificação algébrica $a^2 + b^2 > 4$). 

Como complemento refinado, o `perf` e seu subcomando `perf report` se mostraram excelentes para entender as nuances em nível de hardware (distinguindo até mesmo a divisão de trabalho entre *P-cores* e *E-cores* da arquitetura Intel). Eles ajudaram a compreender como as alterações nas operações da função impactavam os ciclos e as taxas de erro de predição de desvio (*branch misses*), fornecendo uma visão arquitetural de baixo nível que validou o sucesso do gprof, tudo isso utilizando amostragem com baixo custo de execução.

---

## 6. Automação e Execução (Makefile)

Para facilitar a compilação, execução e a coleta estruturada de dados, foi desenvolvido um `Makefile` robusto contendo os seguintes comandos (targets) principais:

- **`make run`**: Compila e executa a versão padrão do programa.
- **`make time`**: Compila e mede o tempo e recursos utilizando `/usr/bin/time`.
- **`make gprof`**: Compila com suporte a perfilamento e gera o flat profile e o call graph.
- **`make perf`**: Compila e analisa métricas de hardware utilizando `perf stat` e `perf record`/`report`.
- **`make valgrind`**: Executa análises rigorosas de instruções (Callgrind) e cache (Cachegrind).
- **`make strace`**: Rastrea e resume as chamadas de sistema (syscalls).
- **`make analyze-all`**: Executa a bateria completa de testes descritos acima (`time`, `gprof`, `perf`, `valgrind` e `strace`). Todos os relatórios gerados são salvos automaticamente na pasta `reports/$(HOSTNAME)/`, garantindo a separação e organização dos dados.
- **`make hardware-info`**: Utiliza utilitários de sistema (`lscpu`, `dmidecode`, `lshw`) para extrair as especificações de CPU, Cache, RAM e GPU da máquina host, gerando um relatório descritivo (`README.md`) junto aos relatórios de profiling.
- **`make clean`**: Remove os arquivos binários compilados e o diretório de relatórios.

Essa infraestrutura como código garantiu que os testes pudessem ser reproduzidos de maneira rigorosa e sistemática de forma individual, assim como todos de uma vez. Eliminou-se o risco de erros de digitação nos parâmetros e nas flags durante a coleta, conferindo maior credibilidade e rastreabilidade aos resultados apresentados neste relatório.
