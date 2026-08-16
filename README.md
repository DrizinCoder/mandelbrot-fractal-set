# Projeto: Geração de Imagens do Conjunto de Mandelbrot e Profiling
**Disciplina:** Computação de Alto Desempenho (HPC)

---

## 1. Descrição do Algoritmo

O programa implementa o cálculo do conjunto de Mandelbrot em linguagem C e gera uma imagem resultante. O algoritmo consiste em varrer uma grade bidimensional de pixels (com largura e altura definidas pelo usuário) e mapear cada coordenada discreta da imagem para uma coordenada contínua no plano complexo. 

O mapeamento é feito calculando a proporção do pixel em relação à dimensão total da imagem e aplicando uma transformação afim (escala e translação) para enquadrar o ponto na janela matemática especificada (entre `minX` e `maxX` para o eixo real, e `minY` e `maxY` para o eixo imaginário). 

Para determinar se um ponto pertence ao conjunto de Mandelbrot, o programa utiliza uma estrutura de dados própria (`struct`) para representar números complexos (partes real e imaginária). A função de verificação aplica a equação iterativamente até atingir o limite de iterações (`max_iter`). Para otimizar o desempenho computacional — considerando o alto volume de cálculos —, a verificação de divergência evita o cálculo oneroso da raiz quadrada; em vez de checar se o módulo da distância é maior que 2, o algoritmo verifica se a soma dos quadrados das partes real e imaginária ultrapassa 4 ($a^2 + b^2 > 4$). 

Os pontos que não escapam (pertencem ao conjunto) recebem a cor correspondente em escala de cinza/preto. Para os pontos que escapam, o valor da iteração de escape determina o tom do pixel. Finalmente, os pixels são gravados em disco, otimizados por meio de lotes de escrita utilizando a biblioteca padrão (ex. `fputc`).

---

## 2. Detalhes de Compilação

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

## 3. Tabelas de Resultados

Os testes foram executados processando uma imagem de 1920x1080, limite no eixo real $[-2, 1]$, limite no eixo imaginário $[-1, 1]$ e limite de 3000 iterações.

#### Tabela 3.1: Medição Geral de Tempo e Recursos (`/usr/bin/time`)
| Métrica | Valor Obtido |
| :--- | :--- |
| **Wall-clock time** (Tempo total) | 8.16 s |
| **User time** (Tempo de CPU em modo usuário) | 8.14 s |
| **System time** (Tempo de CPU em modo kernel) | 0.00 s |
| **Percentual de uso da CPU** | 99% |
| **Maximum Resident Set Size (RSS)** | 1.896 KB |
| **Page Faults** (Major / Minor) | 0 / 95 |
| **Context Switches** (Voluntary / Involuntary) | 2 / 35 |

> **Observação (`time`):** O fato do uso da CPU estar em $99\%$, aliado ao *User Time* de $8.14s$ (quase igual ao tempo total de $8.16s$), evidencia que a aplicação é estritamente **CPU-bound**.

#### Tabela 3.2: Instrumentação de Funções (`gprof`)
| Função | % Tempo | Tempo self (s) | Chamadas | Self ms/call |
| :--- | :--- | :--- | :--- | :--- |
| `check_mandelbrot` | 100.00% | 8.14 s | 2.073.600 | 0.0039 ms |
| `main` | 0.12% | 0.01 s | - | - |
| `mandelbrot` | 0.00% | 0.00 s | 2.073.600 | 0.0000 ms |

> **Observação (`gprof`):** O *flat profile* revela que a função `check_mandelbrot` é o *hotspot* absoluto da aplicação. As $2.073.600$ chamadas correspondem exatamente à quantidade de pixels da imagem ($1920 \times 1080$).

#### Tabela 3.3: Métricas de Hardware por Amostragem (`perf stat`)
| Métrica (Eventos) | Valor Registrado |
| :--- | :--- |
| **Ciclos Totais (cycles)** | 37.222.450.557 |
| **Instruções Executadas (instructions)** | 49.426.843.635 |
| **Instruções por Ciclo (IPC)** | 1.33 |
| **Cache Misses** / Cache References | 197.823 / 561.574 |
| **Branch Misses** | 746.455 (0.02% de erro) |
| **L1-dcache-load-misses** | 974.613 |

#### Tabela 3.4: Análise Determinística de Cache e Instruções (`Valgrind`)
| Ferramenta Valgrind | Métrica Analisada | Valor / Observação |
| :--- | :--- | :--- |
| **Callgrind** | Total de Instruções (Ir) | 49.382.185.819 |
| **Callgrind** | Função com mais instruções | `check_mandelbrot` (99,23% do total) |
| **Cachegrind** | D1 Misses (L1 Data Cache) | 1.410 (~ 0,00%) |
| **Cachegrind** | LL Misses (Last Level Cache)| 1.186 (~ 0,00%) |

> **Observação (`Valgrind`):** O número exato de instruções coletado por instrumentação (Callgrind) é extremamente próximo do valor amostrado via contadores de hardware (`perf stat`). As baixíssimas taxas de *misses* no Cachegrind confirmam que o algoritmo possui excelente localidade temporal e espacial.

#### Tabela 3.5: Rastreamento de Chamadas de Sistema (`strace`)
| Syscall | % Tempo Kernel | Total de Chamadas |
| :--- | :--- | :--- |
| `close` | 98.53% | 4 |
| `write` | 1.47% | 1.527 |
| `mmap` | 0.00% | 12 |

> **Observação (`strace`):** O tempo total despendido em syscalls (Kernel mode) foi menor que $1$ milissegundo ($0,000886$ s), consolidando que o código praticamente não é interrompido para tarefas de I/O.

---

## 4. Análise Crítica

A combinação do utilitário `time` com o `gprof` provou-se a mais prática e valiosa para o fluxo de trabalho durante este projeto. 

Inicialmente, o `/usr/bin/time` forneceu de forma rápida e direta a confirmação do perfil de execução da aplicação: ao evidenciar a altíssima taxa de uso de processador (99%) e a equivalência entre o tempo de usuário e o tempo total de execução, ficou provado que a natureza do problema é intrinsecamente CPU-bound. 

A partir desta constatação primária, o `gprof` revelou-se a ferramenta de diagnóstico de maior impacto prático. Ele apontou, instantaneamente e sem um overhead tão pesado quanto o do Valgrind, que virtualmente 100% do tempo de processamento estava concentrado em uma única função: `check_mandelbrot`. Essa identificação direta do *hotspot* permitiu e direcionou os esforços para a otimização do algoritmo serial (como, por exemplo, substituir a onerosa chamada da função de raiz quadrada pela verificação algébrica $a^2 + b^2 > 4$). 

Como complemento refinado, o `perf` e seu subcomando `perf report` se mostraram excelentes para entender as nuances em nível de hardware. Eles ajudaram a compreender como as alterações nas operações da função impactavam os ciclos e as taxas de erro de predição de desvio (*branch misses*), fornecendo uma visão arquitetural de baixo nível que validou o sucesso do gprof, tudo isso utilizando amostragem com baixo custo de execução.

---

## 5. Automação e Execução (Makefile)

Para facilitar a compilação, execução e a coleta estruturada de dados, foi desenvolvido um `Makefile` robusto contendo os seguintes comandos (targets) principais:

- **`make run`**: Compila e executa a versão padrão do programa.
- **`make analyze-all`**: Compila o código com as flags necessárias para cada ferramenta e executa uma bateria completa de testes de profiling (`time`, `gprof`, `perf`, `Valgrind` e `strace`). Todos os relatórios gerados são salvos automaticamente na pasta `reports/$(HOSTNAME)/`, garantindo a separação e organização dos dados por ambiente/máquina de execução.
- **`make hardware-info`**: Utiliza utilitários de sistema (`lscpu`, `dmidecode`, `lshw`) para extrair as especificações de CPU, Cache, RAM e GPU da máquina host, gerando um relatório descritivo (`README.md`) junto aos relatórios de profiling.
- **`make clean`**: Remove os arquivos binários compilados e o diretório de relatórios.

Essa infraestrutura como código garantiu que os testes pudessem ser reproduzidos de maneira rigorosa e sistemática. Eliminou-se o risco de erros de digitação nos parâmetros e nas flags durante a coleta, conferindo maior credibilidade e rastreabilidade aos resultados apresentados neste relatório.
