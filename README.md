# Projeto e Análise Comparativa de Sistemas de Controle de Suspensão Veicular

![Status do Projeto: Fase 1 Concluída](https://img.shields.io/badge/status-Fase%201%20Concluída-brightgreen)
![MATLAB](https://img.shields.io/badge/MATLAB-R2024a-blue?logo=mathworks)
![Simulink](https://img.shields.io/badge/Simulink-Control%20System-blue?logo=mathworks)

Este repositório contém um projeto de portfólio que detalha o projeto, simulação e análise comparativa de múltiplos sistemas de controle de suspensão veicular, demonstrando competências essenciais em dinâmica veicular, teoria de controle e engenharia de simulação.

---

### **Sumário Executivo**

O objetivo deste projeto é comparar o desempenho de sistemas de suspensão **passiva**, **semi-ativa (Skyhook)** e **ativa (PID e LQR)**. Utilizando um modelo de 1/4 de veículo no MATLAB/Simulink, a análise quantifica o clássico *trade-off* de engenharia entre **conforto do passageiro** e **dirigibilidade/segurança**. O sistema passivo, agora finalizado, serve como uma linha de base (baseline) quantitativa para as melhorias que serão implementadas com os sistemas controlados.

### **Animação do Sistema Passivo**

*(Instrução para você: grave sua tela rodando a animação e use um software como ScreenToGif, LICEcap ou o gravador do Windows/macOS para criar um GIF. Salve o GIF em `02_Documentation/images/passive_animation.gif` e descomente a linha abaixo).*

---

### **Resultados da Fase 1: Suspensão Passiva**

A simulação da linha de base foi realizada em um cenário de 25 segundos com duas perturbações (lombadas) para avaliar a resposta e a capacidade de recuperação do sistema.

*(Instrução para você: rode o script `run_simulation_passive.m`, salve a figura com os 4 gráficos como `passive_results.png` na pasta `02_Documentation/images/` e descomente a linha abaixo).*

#### **Análise Quantitativa**

Os resultados demonstram o comportamento característico de um sistema passivo. A passagem pela lombada induz picos de aceleração no chassi, prejudicando o conforto, e causa uma variação significativa na força de contato do pneu com o solo, o que pode comprometer a dirigibilidade e a segurança em condições limite.

| Métrica de Desempenho (KPI) | Valor (Suspensão Passiva) | Descrição |
| :--- | :--- | :--- |
| **Conforto:** Aceleração RMS do Chassi | `[Insira o valor do seu resultado aqui]` m/s² | Mede a "vibração" sentida pelo passageiro. Menor é melhor. |
| **Dirigibilidade:** Força Mínima no Pneu | `[Insira o valor do seu resultado aqui]` N | Indica a perda de carga no pneu. Valores negativos indicam tendência de decolagem. |
| **Variação de Carga no Pneu** | `[Insira o valor do seu resultado aqui]` % | Variação percentual da força no pneu. Menor é melhor. |

---

### **Tecnologias e Competências Demonstradas**

* **Modelagem e Simulação (Fase 1):**
    * Desenvolvimento de modelos de sistemas dinâmicos (1/4 de veículo) no Simulink.
    * Boas práticas de simulação (configuração de solver, scripts de parâmetros, gerenciamento de caminhos).
    * Análise de estabilidade inicial e cálculo de condições de equilíbrio estático.
* **Análise de Dados e Automação (Fase 1):**
    * Criação de scripts MATLAB para automação do fluxo de trabalho (setup -> simulação -> pós-processamento).
    * Extração e visualização de dados com `plot` e `subplot`.
    * Criação de animações dinâmicas para visualização de resultados.
    * Definição e cálculo de KPIs (Métricas de Desempenho).
* **Teoria de Controle (Próximas Fases):**
    * Controle Semi-Ativo (Skyhook).
    * Controle Clássico (PID).
    * Controle Moderno/Ótimo (LQR).
* **Controle de Versão:** Uso de Git para versionamento e documentação de progresso.

---

### **Como Executar as Simulações**

1.  Clone este repositório.
2.  Abra o MATLAB.
3.  Navegue até a pasta `02_Scripts_Matlab/`.
4.  Execute o script mestre `run_simulation_passive.m` para rodar a simulação da suspensão passiva e gerar todos os resultados.

---

### **Referencial Técnico**

* Gillespie, Thomas D. **"Fundamentals of Vehicle Dynamics."** SAE International, 1992.
* Milliken, William F., and Douglas L. Milliken. **"Race Car Vehicle Dynamics."** SAE International, 1995.
* Ogata, Katsuhiko. **"Modern Control Engineering."** Prentice Hall, 5th ed.