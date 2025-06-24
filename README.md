# Projeto e Análise Comparativa de Sistemas de Controle de Suspensão Veicular

![Project Status: In Development](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![MATLAB](https://img.shields.io/badge/MATLAB-R2024a-blue?logo=mathworks)
![Simulink](https://img.shields.io/badge/Simulink-Control%20System-blue?logo=mathworks)

Este repositório contém um projeto de portfólio que detalha o projeto, simulação e análise comparativa de múltiplos sistemas de controle de suspensão veicular, demonstrando competências essenciais em dinâmica veicular, teoria de controle e engenharia de simulação.

---

### **Sumário Executivo**

O objetivo deste projeto é comparar o desempenho de sistemas de suspensão **passiva**, **semi-ativa (Skyhook)** e **ativa (PID e LQR)**. Utilizando um modelo de 1/4 de veículo no MATLAB/Simulink, a análise quantifica o clássico *trade-off* de engenharia entre **conforto do passageiro** (medido pela aceleração da massa suspensa) e **dirigibilidade/segurança** (medido pela variação da força de contato do pneu com o solo).

---

### **Tecnologias e Ferramentas Utilizadas**

* **Software de Simulação:** MATLAB, Simulink
* **Toolboxes:** Control System Toolbox
* **Controle de Versão:** Git, GitHub

---

### **Competências Demonstradas**

Este projeto é uma demonstração prática das seguintes habilidades técnicas:

* **Modelagem e Simulação:**
    * Desenvolvimento de modelos de sistemas dinâmicos (Dinâmica de Corpo Rígido) no Simulink a partir de primeiros princípios.
    * Configuração e melhores práticas de simulação (solvers, scripts de parâmetros).
* **Teoria de Controle:**
    * **Controle Passivo:** Análise de sistemas de segunda ordem e estabelecimento de linha de base (baseline).
    * **Controle Lógico/Semi-Ativo:** Implementação de controle baseado em regras (Skyhook) com `MATLAB Function`.
    * **Controle Clássico:** Projeto e sintonia de controlador **PID** em malha fechada.
    * **Controle Moderno/Ótimo:** Projeto de controlador **LQR (Linear Quadratic Regulator)** utilizando abordagem de Espaço de Estados.
* **Análise de Dados e Pós-processamento:**
    * Extração e visualização de dados de simulação com scripts MATLAB.
    * Cálculo de métricas de desempenho (RMS, picos, etc.).
* **Engenharia de Software (em contexto de simulação):**
    * Organização de projetos e controle de versão (Git/GitHub).
    * Criação de código modular e reutilizável.

---

### **Resultados Preliminares**

*(Esta seção será preenchida conforme o projeto avança nas fases 1-4).*

---

### **Como Executar as Simulações**

1.  Clone este repositório: `git clone https://github.com/[seu-usuario]/suspension-control-analysis.git`
2.  Abra o MATLAB.
3.  Navegue até a pasta `01_Simulation/scripts/`.
4.  Execute o script `setup_parameters.m` para carregar todas as variáveis no workspace.
5.  Abra o modelo Simulink desejado da pasta `01_Simulation/models/` e execute a simulação.

---

### **Referencial Técnico**

A modelagem e as teorias de controle aplicadas neste projeto são baseadas em trabalhos clássicos da engenharia automotiva:

* Gillespie, Thomas D. **"Fundamentals of Vehicle Dynamics."** SAE International, 1992.
* Milliken, William F., and Douglas L. Milliken. **"Race Car Vehicle Dynamics."** SAE International, 1995.
* Ogata, Katsuhiko. **"Modern Control Engineering."** Prentice Hall, 5th ed.