# Estratégia de redesign da interface GENIACS

O redesign será aplicado como uma camada de sobrescrita no código-fonte do GenieACS durante o build Docker, sem alterar os serviços ACS, banco MongoDB, portas ou lógica de provisionamento. A referência visual enviada será usada como direção estética: **interface clara, cartões arredondados, sombras suaves, navegação limpa, indicadores de status, tabelas mais legíveis e adaptação responsiva**.

A implementação será feita por arquivos em `genieacs-ui-overrides/`, copiados pelo `genieacs/Dockerfile` para dentro do código extraído do GenieACS antes do `npm run build`. Essa abordagem evita editar manualmente o ZIP original e deixa claro quais arquivos foram customizados para a identidade visual do projeto.

| Área | Estratégia |
|---|---|
| Layout geral | Modernizar cabeçalho, navegação, conteúdo e menu lateral com fundo claro, cartões e melhor espaçamento. |
| Responsividade | Reduzir larguras fixas, permitir rolagem horizontal controlada em tabelas e adaptar cabeçalho/menu para telas menores. |
| Tela de login | Criar uma tela profissional com painel visual, marca GENIACS/ACS e formulário em cartão. |
| Menus | Traduzir os rótulos principais para português sem alterar rotas nem permissões. |
| Tabelas e formulários | Melhorar contraste, foco, hover, botões, campos e ações críticas. |
| Compatibilidade | Não alterar chamadas de API, autorização, rotas, nomes internos de páginas nem componentes críticos de tarefas. |

A primeira entrega será uma remodelagem visual robusta e segura. Funcionalidades avançadas semelhantes ao painel da referência, como resumo por IA, gráficos reais de consumo, widgets de Wi-Fi e diagnóstico visual por dispositivo, exigiriam integração adicional com dados, tarefas e possivelmente APIs externas; portanto, não serão simuladas com dados falsos nesta etapa.
