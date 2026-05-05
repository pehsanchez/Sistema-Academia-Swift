# Sistema de Academia — Swift

Projeto acadêmico desenvolvido em Swift, simulando o sistema de gerenciamento de uma academia. O sistema foi construído em etapas progressivas, cobrindo desde a modelagem do domínio até a fachada central de gerenciamento.

---

## Etapas do Desenvolvimento

### Etapa 1 — Fundações do Domínio
Definição dos conjuntos fechados (`enum`) para nível de experiência e categorias de aula. Modelagem da entidade `PlanoAssinatura` como `struct` imutável, com catálogo em memória. Hierarquia de pessoas com `Pessoa` como base e `Aluno` e `Instrutor` como subclasses finais.

### Etapa 2 — Contratos de Comportamento
Introdução do `protocol Manutencavel`, exigindo histórico e a ação de reparo com `throws`. A `struct Equipamento` implementa o contrato e rejeita manutenção quando defeituosa. As aulas foram reestruturadas abandonando herança: `TurmaColetiva` e `TreinoPersonal` implementam o `protocol Aula` de forma independente. Inscrições em turmas controlam capacidade mínima e máxima.

### Etapa 3 — Gerenciador Central
A classe `GymManager` atua como fachada do domínio. Utiliza dicionários `[String: Entidade]` para busca O(1) por matrícula e e-mail. Protege contra cadastros duplicados, executa manutenção em lote com relatório de falhas e valida agendamento de personal em cadeia antes de consolidar.

### Etapa Final — Roteiro de Integração
População da memória com múltiplos perfis. Testes de todas as barreiras implementadas. Demonstração de polimorfismo em coleções heterogêneas. Métricas encapsuladas via `extension`.

---

## Diagrama de Classes

```
┌─────────────────────────────────────────────────────────────────┐
│                        <<enum>>                                 │
│                    NivelExperiencia                             │
│  iniciante | intermediario | avancado                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        <<enum>>                                 │
│                      CategoriaAula                              │
│  musculacao | spinning | yoga | funcional | luta                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        <<enum>>                                 │
│                     AcessoInstrutor                             │
│  limitado(vezesSemanais: Int) | ilimitado                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       <<struct>>                                │
│                     PlanoAssinatura                             │
├─────────────────────────────────────────────────────────────────┤
│  nome: String                                                   │
│  valorMensalidade: Double                                       │
│  limiteModalidades: Int                                         │
│  acessoInstrutor: AcessoInstrutor                               │
│  limiteAulasColetivas: Int                                      │
│  duracaoEmMeses: Int                                            │
│  permitePersonal: Bool  (computed)                              │
└─────────────────────────────────────────────────────────────────┘
                            ▲
                  CatalogoPlanos (enum namespace)
          normalMensal | normalTrimestral | normalAnual
          blackMensal  | blackTrimestral  | blackAnual

┌─────────────────────────────────────────────────────────────────┐
│                      <<protocol>>                               │
│                      Manutencavel                               │
├─────────────────────────────────────────────────────────────────┤
│  nomeItem: String  { get }                                      │
│  historicoManutencao: [RegistroManutencao]  { get }             │
│  realizarManutencao(data:descricao:regularizado:) throws        │
└──────────────────────────┬──────────────────────────────────────┘
                           │ implementa
┌──────────────────────────▼──────────────────────────────────────┐
│                       <<struct>>                                │
│                       Equipamento                               │
├─────────────────────────────────────────────────────────────────┤
│  nomeItem: String                                               │
│  codigo: String                                                 │
│  estado: EstadoEquipamento                                      │
│  historicoManutencao: [RegistroManutencao]                      │
├─────────────────────────────────────────────────────────────────┤
│  realizarManutencao(...)  throws  [falha se defeituoso]         │
│  marcarComoDefeituoso()                                         │
│  reativar()                                                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      <<protocol>>                               │
│                          Aula                                   │
├─────────────────────────────────────────────────────────────────┤
│  nomeAula: String  { get }                                      │
│  instrutor: Instrutor  { get }                                  │
│  categoria: CategoriaAula  { get }                              │
│  descricao: String  { get }                                     │
└──────────┬───────────────────────────────────┬──────────────────┘
           │ implementa                        │ implementa
┌──────────▼────────────────┐   ┌─────────────▼────────────────┐
│       <<class>>           │   │          <<struct>>          │
│     TurmaColetiva         │   │        TreinoPersonal        │
├───────────────────────────┤   ├──────────────────────────────┤
│  diaSemana, horario       │   │  aluno: Aluno                │
│  capacidadeMaxima: Int    │   │  diaSemana, horario          │
│  capacidadeMinima: Int    │   │  duracaoMinutos: Int         │
│  alunosInscritos: [Aluno] │   └──────────────────────────────┘
├───────────────────────────┤
│  inscrever(aluno:) throws │
│  remover(aluno:)          │
└───────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       <<class>>                                 │
│                         Pessoa                                  │
├─────────────────────────────────────────────────────────────────┤
│  nome: String                                                   │
│  email: String                                                  │
│  funcaoDescritiva() -> String                                   │
└──────────┬───────────────────────────────┬──────────────────────┘
           │ herda                         │ herda
┌──────────▼────────────────┐   ┌──────────▼───────────────────┐
│     <<final class>>       │   │      <<final class>>         │
│          Aluno            │   │          Instrutor           │
├───────────────────────────┤   ├──────────────────────────────┤
│  matricula: String        │   │  especialidade: CategoriaAula│
│  plano: PlanoAssinatura   │   │  reservas: [ReservaInstrutor]│
│  nivel: NivelExperiencia  │   └──────────────────────────────┘
│  modalidades: [Categoria] │
│  aulasMatriculadas: [String]│
│  reservasInstrutor: [...] │
├───────────────────────────┤
│  atualizarPlano(...)      │
│  atualizarNivel(...)      │
└───────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    <<final class>>                              │
│                       GymManager                                │
├─────────────────────────────────────────────────────────────────┤
│  alunosPorMatricula:  [String: Aluno]     (privado)             │
│  alunosPorEmail:      [String: Aluno]     (privado)             │
│  instrutoresPorEmail: [String: Instrutor] (privado)             │
│  instrutores:  [Instrutor]                                      │
│  equipamentos: [Equipamento]                                    │
│  turmas:       [TurmaColetiva]                                  │
│  treinos:      [TreinoPersonal]                                 │
├─────────────────────────────────────────────────────────────────┤
│  admitirAluno(...)       throws → Aluno                         │
│  admitirInstrutor(...)   throws → Instrutor                     │
│  buscarAluno(porMatricula:) → Aluno?                            │
│  buscarAluno(porEmail:)     → Aluno?                            │
│  buscarInstrutor(porEmail:) → Instrutor?                        │
│  atualizarPlano(...)     throws                                 │
│  atualizarNivel(...)     throws                                 │
│  adicionarEquipamento(...)                                      │
│  marcarEquipamentoDefeituoso(indice:)                           │
│  reativarEquipamento(indice:)                                   │
│  executarManutencaoEmLote(...) → RelatorioManutencao            │
│  agendarPersonal(...)    throws → TreinoPersonal                │
│  inscreverEmTurma(...)   throws                                 │
├─────────────────────────────────────────────────────────────────┤
│  <<extension>>                                                  │
│  gerarMetricas() → MetricasAcademia                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Como Executar

```bash
swift Academia.swift
```

Requer Swift 5.9 ou superior instalado. Para rodar o roteiro de integração automático (Etapa Final), utilize o arquivo `RoteiroDemonstracao.swift`.

---

## Estrutura dos Arquivos

| Arquivo | Conteúdo |
|---|---|
| `Academia.swift` | Sistema completo com menu interativo |
| `RoteiroDemonstracao.swift` | Roteiro de integração da etapa final |
| `README.md` | Este documento |

---

## Tecnologias

- Linguagem: Swift 5.9
- Paradigmas: Orientação a Objetos, Protocolos, Tipos de Valor
- Execução: Terminal (readLine)
