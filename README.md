# GenieACS Docker Stack (com detecção AVX automática)

Este repositório entrega **GenieACS completo (CWMP, NBI, FS + GUI)** rodando no Docker Compose, com **MongoDB automaticamente compatível**:

- Se CPU ⇒ **com AVX** → MongoDB 6.x
- Se CPU ⇒ **sem AVX** → MongoDB 4.4

---

## 🚀 Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/genieacs-docker.git
   cd genieacs-docker
