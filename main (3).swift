import Foundation

// MARK: - Enums base

enum NivelExperiencia: String, CaseIterable, CustomStringConvertible {
    case iniciante     = "Iniciante"
    case intermediario = "Intermediario"
    case avancado      = "Avancado"
    var description: String { rawValue }
}

enum CategoriaAula: String, CaseIterable, CustomStringConvertible {
    case musculacao = "Musculacao"
    case spinning   = "Spinning"
    case yoga       = "Yoga"
    case funcional  = "Funcional"
    case luta       = "Luta"
    var description: String { rawValue }
}

enum AcessoInstrutor: CustomStringConvertible {
    case limitado(vezesSemanais: Int)
    case ilimitado
    var description: String {
        switch self {
        case .limitado(let v): return "\(v)x por semana"
        case .ilimitado:       return "A qualquer momento"
        }
    }
}

// MARK: - Plano de Assinatura

struct PlanoAssinatura: CustomStringConvertible {
    let nome: String
    let valorMensalidade: Double
    let limiteModalidades: Int
    let acessoInstrutor: AcessoInstrutor
    let limiteAulasColetivas: Int
    let duracaoEmMeses: Int

    var description: String {
        let modalidades = limiteModalidades == Int.max ? "Todas" : "\(limiteModalidades)"
        let aulas       = limiteAulasColetivas == Int.max ? "Ilimitadas" : "\(limiteAulasColetivas)/mes"
        return """
        Nome         : \(nome)
        Mensalidade  : R$ \(String(format: "%.2f", valorMensalidade))
        Modalidades  : \(modalidades)
        Instrutor    : \(acessoInstrutor)
        Aulas colet. : \(aulas)
        Duracao      : \(duracaoEmMeses) mes(es)
        """
    }
}

enum CatalogoPlanos {
    static let normalMensal = PlanoAssinatura(
        nome: "Normal Mensal",      valorMensalidade: 99.90,
        limiteModalidades: 2,       acessoInstrutor: .limitado(vezesSemanais: 2),
        limiteAulasColetivas: 8,    duracaoEmMeses: 1)
    static let normalTrimestral = PlanoAssinatura(
        nome: "Normal Trimestral",  valorMensalidade: 89.90,
        limiteModalidades: 2,       acessoInstrutor: .limitado(vezesSemanais: 2),
        limiteAulasColetivas: 8,    duracaoEmMeses: 3)
    static let normalAnual = PlanoAssinatura(
        nome: "Normal Anual",       valorMensalidade: 79.90,
        limiteModalidades: 2,       acessoInstrutor: .limitado(vezesSemanais: 2),
        limiteAulasColetivas: 8,    duracaoEmMeses: 12)
    static let blackMensal = PlanoAssinatura(
        nome: "Black Mensal",       valorMensalidade: 199.90,
        limiteModalidades: Int.max, acessoInstrutor: .ilimitado,
        limiteAulasColetivas: Int.max, duracaoEmMeses: 1)
    static let blackTrimestral = PlanoAssinatura(
        nome: "Black Trimestral",   valorMensalidade: 179.90,
        limiteModalidades: Int.max, acessoInstrutor: .ilimitado,
        limiteAulasColetivas: Int.max, duracaoEmMeses: 3)
    static let blackAnual = PlanoAssinatura(
        nome: "Black Anual",        valorMensalidade: 159.90,
        limiteModalidades: Int.max, acessoInstrutor: .ilimitado,
        limiteAulasColetivas: Int.max, duracaoEmMeses: 12)
    static let todos: [PlanoAssinatura] = [
        normalMensal, normalTrimestral, normalAnual,
        blackMensal,  blackTrimestral,  blackAnual
    ]
}

// MARK: - ==============================================
// MARK: - ETAPA 2A: CONTRATO DE MANUTENCAO
// MARK: - ==============================================

// Registro imutavel de cada reparo realizado
struct RegistroManutencao: CustomStringConvertible {
    let data: String
    let descricao: String
    let regularizado: Bool

    var description: String {
        let status = regularizado ? "Regularizado" : "Pendente"
        return "[\(data)] \(descricao) — \(status)"
    }
}

// Erro lanado quando a manutencao nao pode ser realizada
enum ErroManutencao: Error, CustomStringConvertible {
    case equipamentoDefeituoso(nome: String)

    var description: String {
        switch self {
        case .equipamentoDefeituoso(let nome):
            return "Falha: '\(nome)' esta defeituoso e nao pode receber manutencao sem reparo previo pela assistencia tecnica."
        }
    }
}

// Contrato de manutencao — qualquer entidade que o assine
// deve expor nome, historico e a acao de realizar reparo
protocol Manutencavel {
    var nomeItem: String { get }
    var historicoManutencao: [RegistroManutencao] { get }

    // throws: falha se o estado interno impedir a manutencao
    mutating func realizarManutencao(data: String, descricao: String, regularizado: Bool) throws
}

// MARK: - Estado de funcionamento do equipamento

enum EstadoEquipamento: String, CustomStringConvertible {
    case funcionando  = "Funcionando"
    case defeituoso   = "Defeituoso"
    var description: String { rawValue }
}

// MARK: - Equipamento Fisico (assina Manutencavel)

struct Equipamento: Manutencavel, CustomStringConvertible {
    let nomeItem: String
    let codigo: String
    private(set) var estado: EstadoEquipamento
    private(set) var historicoManutencao: [RegistroManutencao] = []

    init(nome: String, codigo: String, estado: EstadoEquipamento = .funcionando) {
        self.nomeItem = nome
        self.codigo   = codigo
        self.estado   = estado
    }

    // Cumpre o contrato: falha se defeituoso
    mutating func realizarManutencao(data: String, descricao: String, regularizado: Bool) throws {
        guard estado == .funcionando else {
            throw ErroManutencao.equipamentoDefeituoso(nome: nomeItem)
        }
        let registro = RegistroManutencao(data: data, descricao: descricao, regularizado: regularizado)
        historicoManutencao.append(registro)
    }

    // Permite marcar como defeituoso externamente (ex: relato de aluno)
    mutating func marcarComoDefeituoso() {
        estado = .defeituoso
    }

    // Assistencia tecnica reativa o equipamento para que manutencao volte a ser possivel
    mutating func reativar() {
        estado = .funcionando
        print("  Equipamento '\(nomeItem)' reativado e apto para manutencao.")
    }

    var description: String {
        let ultimos = historicoManutencao.suffix(3)
        let hist = ultimos.isEmpty
            ? "    (nenhum registro)"
            : ultimos.map { "    \($0)" }.joined(separator: "\n")
        return """
        Codigo  : \(codigo)
        Nome    : \(nomeItem)
        Estado  : \(estado)
        Ultimos registros:
        \(hist)
        """
    }
}

// MARK: - ==============================================
// MARK: - ETAPA 2B: CONTRATO BASE DE AULA
// MARK: - ==============================================

// Contrato que toda aula deve assinar — sem heranca
protocol Aula {
    var nomeAula: String { get }
    var instrutor: Instrutor { get }
    var categoria: CategoriaAula { get }
    var descricao: String { get }
}

// MARK: - Erros de inscricao

enum ErroInscricao: Error, CustomStringConvertible {
    case turmaLotada
    case alunoJaInscrito
    case abaixoDoMinimo(minimo: Int)

    var description: String {
        switch self {
        case .turmaLotada:
            return "Falha: turma sem vagas disponiveis."
        case .alunoJaInscrito:
            return "Falha: aluno ja esta inscrito nesta turma."
        case .abaixoDoMinimo(let min):
            return "Aviso: turma com menos de \(min) aluno(s) — minimo nao atingido."
        }
    }
}

// MARK: - Turma Coletiva (assina Aula, sem herdar de nenhuma classe)

class TurmaColetiva: Aula, CustomStringConvertible {
    let nomeAula: String
    let instrutor: Instrutor
    let categoria: CategoriaAula
    let descricao: String
    let diaSemana: String
    let horario: String
    let capacidadeMaxima: Int
    let capacidadeMinima: Int
    private(set) var alunosInscritos: [Aluno] = []

    var vagasDisponiveis: Int { capacidadeMaxima - alunosInscritos.count }
    var atingiuMinimo: Bool  { alunosInscritos.count >= capacidadeMinima }

    init(nome: String, instrutor: Instrutor, categoria: CategoriaAula,
         descricao: String, diaSemana: String, horario: String,
         capacidadeMaxima: Int, capacidadeMinima: Int) {
        self.nomeAula          = nome
        self.instrutor         = instrutor
        self.categoria         = categoria
        self.descricao         = descricao
        self.diaSemana         = diaSemana
        self.horario           = horario
        self.capacidadeMaxima  = capacidadeMaxima
        self.capacidadeMinima  = capacidadeMinima
    }

    // Inscreve o aluno respeitando vagas e unicidade
    func inscrever(aluno: Aluno) throws {
        if alunosInscritos.contains(where: { $0.matricula == aluno.matricula }) {
            throw ErroInscricao.alunoJaInscrito
        }
        if vagasDisponiveis == 0 {
            throw ErroInscricao.turmaLotada
        }
        alunosInscritos.append(aluno)
        if !atingiuMinimo {
            // Nao lanca erro — apenas avisa; a inscricao foi realizada
            print("  \(ErroInscricao.abaixoDoMinimo(minimo: capacidadeMinima))")
        }
    }

    func remover(aluno: Aluno) {
        alunosInscritos.removeAll { $0.matricula == aluno.matricula }
    }

    var description: String {
        let status = atingiuMinimo ? "Minimo atingido" : "Aguardando alunos"
        return """
        Turma    : \(nomeAula)
        Categoria: \(categoria)
        Instrutor: \(instrutor.nome)
        Horario  : \(diaSemana) \(horario)
        Vagas    : \(alunosInscritos.count)/\(capacidadeMaxima) | Min: \(capacidadeMinima) | \(status)
        Descricao: \(descricao)
        """
    }
}

// MARK: - Treino com Personal (assina Aula, sem herdar de nenhuma classe)

struct TreinoPersonal: Aula, CustomStringConvertible {
    let nomeAula: String
    let instrutor: Instrutor
    let categoria: CategoriaAula
    let descricao: String
    let aluno: Aluno
    let diaSemana: String
    let horario: String
    let duracaoMinutos: Int

    var description: String {
        """
        Treino   : \(nomeAula)
        Categoria: \(categoria)
        Instrutor: \(instrutor.nome)
        Aluno    : \(aluno.nome)
        Horario  : \(diaSemana) \(horario) (\(duracaoMinutos) min)
        Descricao: \(descricao)
        """
    }
}

// MARK: - Hierarquia de Pessoas (igual etapa 1)

class Pessoa: CustomStringConvertible {
    let nome: String
    let email: String
    init(nome: String, email: String) { self.nome = nome; self.email = email }
    func funcaoDescritiva() -> String { "Pessoa" }
    var description: String { "[\(funcaoDescritiva())] \(nome) <\(email)>" }
}

final class Aluno: Pessoa {
    let matricula: String
    private(set) var plano: PlanoAssinatura
    private(set) var nivel: NivelExperiencia
    private(set) var modalidades: [CategoriaAula]
    var aulasMatriculadas: [String] = []       // nome das turmas
    var reservasInstrutor: [ReservaInstrutor] = []

    init(nome: String, email: String, matricula: String,
         plano: PlanoAssinatura, nivel: NivelExperiencia, modalidades: [CategoriaAula]) {
        self.matricula   = matricula
        self.plano       = plano
        self.nivel       = nivel
        self.modalidades = modalidades
        super.init(nome: nome, email: email)
    }

    override func funcaoDescritiva() -> String { "Aluno" }

    func atualizarPlano(_ novoPlano: PlanoAssinatura, novasModalidades: [CategoriaAula]) {
        plano = novoPlano; modalidades = novasModalidades
        print("  Plano de \(nome) atualizado para '\(novoPlano.nome)'.")
    }
    func atualizarNivel(_ novoNivel: NivelExperiencia) {
        nivel = novoNivel
        print("  Nivel de \(nome) atualizado para '\(novoNivel)'.")
    }

    var reservasNaSemana: Int { reservasInstrutor.count }

    override var description: String {
        let mods = modalidades.map { $0.rawValue }.joined(separator: ", ")
        return """
        Matricula    : \(matricula)
        Nome         : \(nome)
        Email        : \(email)
        Nivel        : \(nivel)
        Plano        : \(plano.nome)
        Modalidades  : \(mods)
        Instrutor    : \(plano.acessoInstrutor)
        """
    }
}

final class Instrutor: Pessoa {
    let especialidade: CategoriaAula
    var reservas: [ReservaInstrutor] = []

    init(nome: String, email: String, especialidade: CategoriaAula) {
        self.especialidade = especialidade
        super.init(nome: nome, email: email)
    }
    override func funcaoDescritiva() -> String { "Instrutor" }
    override var description: String {
        "Nome: \(nome) | Email: \(email) | Especialidade: \(especialidade)"
    }
}

// MARK: - Reserva de Instrutor

struct ReservaInstrutor: CustomStringConvertible {
    let id: Int
    let aluno: Aluno
    let instrutor: Instrutor
    let diaSemana: String
    let horario: String
    var description: String {
        "[\(id)] Aluno: \(aluno.nome) | \(diaSemana) \(horario)"
    }
}

// MARK: - Banco de dados em memoria

var alunos:         [Aluno]         = []
var instrutores:    [Instrutor]     = []
var turmas:         [TurmaColetiva] = []
var treinos:        [TreinoPersonal] = []
var equipamentos:   [Equipamento]   = []
var todasReservas:  [ReservaInstrutor] = []
var proximoIdReserva = 1

let horariosDisponiveis: [(dia: String, hora: String)] = [
    ("Segunda","07:00"),("Segunda","09:00"),("Segunda","18:00"),
    ("Terca","07:00"),("Terca","10:00"),("Terca","19:00"),
    ("Quarta","08:00"),("Quarta","11:00"),("Quarta","18:00"),
    ("Quinta","07:00"),("Quinta","09:00"),("Quinta","20:00"),
    ("Sexta","07:00"),("Sexta","10:00"),("Sexta","18:00"),
]

// MARK: - Utilitarios de terminal

let largura = 52

func linha(_ c: Character = "-") { print(String(repeating: c, count: largura)) }

func centralizar(_ texto: String, com c: Character = "*") {
    print(String(repeating: c, count: largura))
    let pad = max(0, (largura - texto.count) / 2)
    print(String(repeating: " ", count: pad) + texto)
    print(String(repeating: c, count: largura))
}

func secao(_ titulo: String) {
    print()
    linha()
    let pad = max(0, (largura - titulo.count) / 2)
    print(String(repeating: " ", count: pad) + titulo)
    linha()
}

func lerTexto(prompt: String) -> String {
    print("  >> \(prompt)", terminator: " ")
    return readLine() ?? ""
}

func lerOpcao(prompt: String, opcoes: ClosedRange<Int>) -> Int {
    while true {
        print("  >> \(prompt)", terminator: " ")
        if let e = readLine(), let n = Int(e), opcoes.contains(n) { return n }
        print("     Opcao invalida. Tente novamente.")
    }
}

func dataHoje() -> String {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy"
    return f.string(from: Date())
}

// MARK: - Selecao de modalidades

func selecionarModalidades(limite: Int) -> [CategoriaAula] {
    let todas = CategoriaAula.allCases
    if limite == Int.max { print("  Plano Black: acesso a todas as modalidades."); return todas }
    print("  Escolha \(limite) modalidade(s):")
    for (i, cat) in todas.enumerated() { print("    [\(i+1)] \(cat)") }
    var escolhidas: [CategoriaAula] = []
    while escolhidas.count < limite {
        let idx = lerOpcao(prompt: "Modalidade \(escolhidas.count+1)/\(limite):", opcoes: 1...todas.count)
        let cat = todas[idx - 1]
        if escolhidas.contains(where: { $0 == cat }) { print("     Ja escolhida.") }
        else { escolhidas.append(cat) }
    }
    return escolhidas
}

// MARK: - Gerar turmas ao cadastrar instrutor

func gerarTurmasParaInstrutor(_ instrutor: Instrutor) {
    let grade = [("Segunda","08:00"),("Quarta","10:00"),("Sexta","17:00")]
    for (dia, hora) in grade {
        let turma = TurmaColetiva(
            nome: "\(instrutor.especialidade) - \(dia)",
            instrutor: instrutor,
            categoria: instrutor.especialidade,
            descricao: "Turma regular de \(instrutor.especialidade) com \(instrutor.nome)",
            diaSemana: dia, horario: hora,
            capacidadeMaxima: 15, capacidadeMinima: 3)
        turmas.append(turma)
    }
}

// MARK: - ===============================================
// MARK: - AREA DE MANUTENCAO (admin)
// MARK: - ===============================================

func menuManutencao() {
    while true {
        print()
        centralizar("AREA DE MANUTENCAO")
        print()
        print("  [1]  Cadastrar equipamento")
        print("  [2]  Listar equipamentos")
        print("  [3]  Registrar manutencao")
        print("  [4]  Marcar equipamento como defeituoso")
        print("  [5]  Reativar equipamento")
        print("  [0]  Voltar")
        print()
        linha("*")

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...5)
        switch opcao {
        case 1: cadastrarEquipamento()
        case 2: listarEquipamentos()
        case 3: registrarManutencao()
        case 4: marcarDefeituoso()
        case 5: reativarEquipamento()
        case 0: return
        default: break
        }
        print("\n  Pressione Enter para continuar...")
        _ = readLine()
    }
}

func cadastrarEquipamento() {
    secao("CADASTRAR EQUIPAMENTO")
    let nome   = lerTexto(prompt: "Nome do equipamento:")
    let codigo = lerTexto(prompt: "Codigo:")
    equipamentos.append(Equipamento(nome: nome, codigo: codigo))
    print("  Equipamento '\(nome)' cadastrado com sucesso.")
}

func listarEquipamentos() {
    secao("EQUIPAMENTOS")
    guard !equipamentos.isEmpty else { print("  Nenhum equipamento cadastrado."); return }
    for (i, eq) in equipamentos.enumerated() {
        print("\n  [\(i+1)]")
        eq.description.split(separator: "\n").forEach { print("  \($0)") }
        linha()
    }
}

func registrarManutencao() {
    secao("REGISTRAR MANUTENCAO")
    guard !equipamentos.isEmpty else { print("  Nenhum equipamento cadastrado."); return }

    for (i, eq) in equipamentos.enumerated() {
        print("  [\(i+1)] \(eq.nomeItem) [\(eq.estado)]")
    }
    let idx = lerOpcao(prompt: "Equipamento:", opcoes: 1...equipamentos.count) - 1
    let descricao = lerTexto(prompt: "Descricao do servico:")

    print("  Regularizado?")
    print("    [1] Sim")
    print("    [2] Nao")
    let reg = lerOpcao(prompt: "Opcao:", opcoes: 1...2) == 1

    do {
        try equipamentos[idx].realizarManutencao(
            data: dataHoje(), descricao: descricao, regularizado: reg)
        print("  Manutencao registrada com sucesso em '\(equipamentos[idx].nomeItem)'.")
    } catch let erro as ErroManutencao {
        print("\n  \(erro)")
    } catch {
        print("\n  Erro inesperado: \(error)")
    }
}

func marcarDefeituoso() {
    secao("MARCAR COMO DEFEITUOSO")
    guard !equipamentos.isEmpty else { print("  Nenhum equipamento cadastrado."); return }
    for (i, eq) in equipamentos.enumerated() { print("  [\(i+1)] \(eq.nomeItem) [\(eq.estado)]") }
    let idx = lerOpcao(prompt: "Equipamento:", opcoes: 1...equipamentos.count) - 1
    equipamentos[idx].marcarComoDefeituoso()
    print("  '\(equipamentos[idx].nomeItem)' marcado como defeituoso.")
}

func reativarEquipamento() {
    secao("REATIVAR EQUIPAMENTO")
    guard !equipamentos.isEmpty else { print("  Nenhum equipamento cadastrado."); return }
    let defeituosos = equipamentos.enumerated().filter { $0.element.estado == .defeituoso }
    guard !defeituosos.isEmpty else { print("  Nenhum equipamento defeituoso."); return }
    for (i, par) in defeituosos.enumerated() { print("  [\(i+1)] \(par.element.nomeItem)") }
    let idx = lerOpcao(prompt: "Equipamento:", opcoes: 1...defeituosos.count) - 1
    let idxReal = defeituosos[idx].offset
    equipamentos[idxReal].reativar()
}

// MARK: - ===============================================
// MARK: - AREA DE TURMAS (admin)
// MARK: - ===============================================

func menuTurmas() {
    while true {
        print()
        centralizar("GERENCIAR TURMAS")
        print()
        print("  [1]  Listar turmas coletivas")
        print("  [2]  Listar treinos com personal")
        print("  [3]  Criar turma coletiva manualmente")
        print("  [0]  Voltar")
        print()
        linha("*")

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...3)
        switch opcao {
        case 1: listarTurmas()
        case 2: listarTreinos()
        case 3: criarTurmaManual()
        case 0: return
        default: break
        }
        print("\n  Pressione Enter para continuar...")
        _ = readLine()
    }
}

func listarTurmas() {
    secao("TURMAS COLETIVAS")
    guard !turmas.isEmpty else { print("  Nenhuma turma cadastrada."); return }
    for (i, t) in turmas.enumerated() {
        print("\n  [\(i+1)]")
        t.description.split(separator: "\n").forEach { print("  \($0)") }
        linha()
    }
}

func listarTreinos() {
    secao("TREINOS COM PERSONAL")
    guard !treinos.isEmpty else { print("  Nenhum treino agendado."); return }
    for (i, t) in treinos.enumerated() {
        print("\n  [\(i+1)]")
        t.description.split(separator: "\n").forEach { print("  \($0)") }
        linha()
    }
}

func criarTurmaManual() {
    secao("CRIAR TURMA COLETIVA")
    guard !instrutores.isEmpty else { print("  Cadastre instrutores primeiro."); return }

    let nome = lerTexto(prompt: "Nome da turma:")

    print("  Instrutor:")
    for (i, inst) in instrutores.enumerated() { print("  [\(i+1)] \(inst.nome) (\(inst.especialidade))") }
    let instrutor = instrutores[lerOpcao(prompt: "Instrutor:", opcoes: 1...instrutores.count) - 1]

    print("  Categoria:")
    for (i, cat) in CategoriaAula.allCases.enumerated() { print("  [\(i+1)] \(cat)") }
    let categoria = CategoriaAula.allCases[lerOpcao(prompt: "Categoria:", opcoes: 1...CategoriaAula.allCases.count) - 1]

    let descricao  = lerTexto(prompt: "Descricao:")
    let diaSemana  = lerTexto(prompt: "Dia da semana:")
    let horario    = lerTexto(prompt: "Horario (ex: 09:00):")

    print("  >> Capacidade maxima:", terminator: " ")
    let capMax = Int(readLine() ?? "") ?? 15
    print("  >> Capacidade minima:", terminator: " ")
    let capMin = Int(readLine() ?? "") ?? 3

    let turma = TurmaColetiva(
        nome: nome, instrutor: instrutor, categoria: categoria,
        descricao: descricao, diaSemana: diaSemana, horario: horario,
        capacidadeMaxima: capMax, capacidadeMinima: capMin)
    turmas.append(turma)
    print("  Turma '\(nome)' criada com sucesso.")
}

// MARK: - Area do Aluno

func loginAluno() -> Aluno? {
    secao("LOGIN - AREA DO ALUNO")
    let nome      = lerTexto(prompt: "Nome:")
    let matricula = lerTexto(prompt: "Matricula:")
    if let aluno = alunos.first(where: {
        $0.nome.lowercased() == nome.lowercased() && $0.matricula == matricula
    }) {
        print("\n  Bem-vindo(a), \(aluno.nome)! [\(aluno.plano.nome)]")
        return aluno
    }
    print("\n  Nome ou matricula incorretos.")
    return nil
}

func menuAluno(_ aluno: Aluno) {
    while true {
        print()
        centralizar("AREA DO ALUNO")
        print()
        print("  Logado como : \(aluno.nome)")
        print("  Plano       : \(aluno.plano.nome)")
        print()
        linha()
        print("  [1]  Inscrever-se em turma coletiva")
        print("  [2]  Reservar horario com instrutor (personal)")
        print("  [3]  Minhas turmas")
        print("  [4]  Meus treinos com personal")
        print("  [0]  Voltar")
        print()
        linha("*")

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...4)
        switch opcao {
        case 1: inscreverEmTurma(aluno)
        case 2: reservarInstrutor(aluno)
        case 3: listarTurmasDoAluno(aluno)
        case 4: listarTreinosDoAluno(aluno)
        case 0: return
        default: break
        }
        print("\n  Pressione Enter para continuar...")
        _ = readLine()
    }
}

func inscreverEmTurma(_ aluno: Aluno) {
    secao("INSCREVER EM TURMA COLETIVA")

    let limite = aluno.plano.limiteAulasColetivas
    if limite != Int.max && aluno.aulasMatriculadas.count >= limite {
        print("  Limite de \(limite) aulas coletivas do plano atingido.")
        return
    }

    let turmasPermitidas = turmas.filter { turma in
    aluno.modalidades.contains(where: { $0 == turma.categoria })
}

    guard !turmasPermitidas.isEmpty else {
        print("  Nenhuma turma disponivel para suas modalidades.")
        return
    }

    for (i, t) in turmasPermitidas.enumerated() {
        let vagas = t.vagasDisponiveis > 0 ? "\(t.vagasDisponiveis) vagas" : "LOTADA"
        print("  [\(i+1)] \(t.nomeAula) | \(t.diaSemana) \(t.horario) | \(vagas)")
    }

    let idx = lerOpcao(prompt: "Turma (0 para cancelar):", opcoes: 0...turmasPermitidas.count)
    if idx == 0 { return }

    let turma = turmasPermitidas[idx - 1]
    guard let idxReal = turmas.firstIndex(where: { $0.nomeAula == turma.nomeAula }) else { return }

    do {
        try turmas[idxReal].inscrever(aluno: aluno)
        aluno.aulasMatriculadas.append(turma.nomeAula)
        let restante = limite == Int.max ? "ilimitadas" : "\(limite - aluno.aulasMatriculadas.count) restante(s)"
        print("  Inscrito com sucesso em '\(turma.nomeAula)'.")
        print("  Aulas disponiveis no plano: \(restante).")
    } catch let erro as ErroInscricao {
        print("\n  \(erro)")
    } catch {
        print("\n  Erro: \(error)")
    }
}

func reservarInstrutor(_ aluno: Aluno) {
    secao("RESERVAR HORARIO COM INSTRUTOR")

    switch aluno.plano.acessoInstrutor {
    case .limitado(let max):
        if aluno.reservasNaSemana >= max {
            print("  Limite de \(max) reservas semanais atingido.")
            return
        }
        print("  Reservas restantes: \(max - aluno.reservasNaSemana)/\(max)")
    case .ilimitado:
        print("  Reservas ilimitadas (Plano Black).")
    }

    guard !instrutores.isEmpty else { print("  Nenhum instrutor cadastrado."); return }

    for (i, inst) in instrutores.enumerated() {
        print("  [\(i+1)] \(inst.nome) (\(inst.especialidade))")
    }
    let instrutor = instrutores[lerOpcao(prompt: "Instrutor:", opcoes: 1...instrutores.count) - 1]

    let ocupados   = instrutor.reservas.map { "\($0.diaSemana)\($0.horario)" }
    let livres     = horariosDisponiveis.filter { !ocupados.contains("\($0.dia)\($0.hora)") }

    guard !livres.isEmpty else { print("  \(instrutor.nome) sem horarios disponiveis."); return }

    secao("HORARIOS DISPONIVEIS")
    for (i, h) in livres.enumerated() { print("  [\(i+1)] \(h.dia) - \(h.hora)") }
    let horario = livres[lerOpcao(prompt: "Horario:", opcoes: 1...livres.count) - 1]

    let reserva = ReservaInstrutor(
        id: proximoIdReserva, aluno: aluno, instrutor: instrutor,
        diaSemana: horario.dia, horario: horario.hora)
    proximoIdReserva += 1

    aluno.reservasInstrutor.append(reserva)
    instrutor.reservas.append(reserva)
    todasReservas.append(reserva)

    // Cria o TreinoPersonal correspondente
    let treino = TreinoPersonal(
        nomeAula: "Personal - \(aluno.nome)",
        instrutor: instrutor,
        categoria: instrutor.especialidade,
        descricao: "Treino individual de \(instrutor.especialidade)",
        aluno: aluno,
        diaSemana: horario.dia,
        horario: horario.hora,
        duracaoMinutos: 60)
    treinos.append(treino)

    print("  Reserva confirmada: \(instrutor.nome) | \(horario.dia) \(horario.hora)")
}

func listarTurmasDoAluno(_ aluno: Aluno) {
    secao("MINHAS TURMAS COLETIVAS")
    guard !aluno.aulasMatriculadas.isEmpty else { print("  Nenhuma turma inscrita."); return }
    for (i, nome) in aluno.aulasMatriculadas.enumerated() { print("  [\(i+1)] \(nome)") }
    let limite = aluno.plano.limiteAulasColetivas
    let status  = limite == Int.max ? "Ilimitadas" : "\(aluno.aulasMatriculadas.count)/\(limite)"
    print("\n  Aulas coletivas utilizadas: \(status)")
}

func listarTreinosDoAluno(_ aluno: Aluno) {
    secao("MEUS TREINOS COM PERSONAL")
    let meus = treinos.filter { $0.aluno.matricula == aluno.matricula }
    guard !meus.isEmpty else { print("  Nenhum treino agendado."); return }
    for (i, t) in meus.enumerated() {
        print("\n  [\(i+1)] \(t.instrutor.nome) | \(t.diaSemana) \(t.horario) | \(t.categoria)")
    }
}

// MARK: - Area do Instrutor

func loginInstrutor() -> Instrutor? {
    secao("LOGIN - AREA DO INSTRUTOR")
    let nome  = lerTexto(prompt: "Nome:")
    let email = lerTexto(prompt: "Email:")
    if let inst = instrutores.first(where: {
        $0.nome.lowercased() == nome.lowercased() && $0.email.lowercased() == email.lowercased()
    }) {
        print("\n  Bem-vindo(a), \(inst.nome)! [\(inst.especialidade)]")
        return inst
    }
    print("\n  Nome ou email incorretos.")
    return nil
}

func menuInstrutor(_ instrutor: Instrutor) {
    while true {
        print()
        centralizar("AREA DO INSTRUTOR")
        print()
        print("  Logado como  : \(instrutor.nome)")
        print("  Especialidade: \(instrutor.especialidade)")
        print()
        linha()
        print("  [1]  Minhas turmas coletivas")
        print("  [2]  Meus treinos com personal")
        print("  [3]  Agenda semanal completa")
        print("  [0]  Voltar")
        print()
        linha("*")

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...3)
        switch opcao {
        case 1: verTurmasDoInstrutor(instrutor)
        case 2: verTreinosDoInstrutor(instrutor)
        case 3: agendaSemanal(instrutor)
        case 0: return
        default: break
        }
        print("\n  Pressione Enter para continuar...")
        _ = readLine()
    }
}

func verTurmasDoInstrutor(_ instrutor: Instrutor) {
    secao("MINHAS TURMAS COLETIVAS")
    let minhas = turmas.filter { $0.instrutor.nome == instrutor.nome }
    guard !minhas.isEmpty else { print("  Nenhuma turma registrada."); return }
    for t in minhas {
        print()
        t.description.split(separator: "\n").forEach { print("  \($0)") }
        if !t.alunosInscritos.isEmpty {
            print("  Alunos:")
            for a in t.alunosInscritos { print("    - \(a.nome) [\(a.nivel)]") }
        }
        linha()
    }
}

func verTreinosDoInstrutor(_ instrutor: Instrutor) {
    secao("MEUS TREINOS COM PERSONAL")
    let meus = treinos.filter { $0.instrutor.nome == instrutor.nome }
    guard !meus.isEmpty else { print("  Nenhum treino agendado."); return }
    for (i, t) in meus.enumerated() {
        print("  [\(i+1)] \(t.aluno.nome) | \(t.diaSemana) \(t.horario) | \(t.duracaoMinutos) min")
    }
}

func agendaSemanal(_ instrutor: Instrutor) {
    secao("AGENDA SEMANAL COMPLETA")
    let dias = ["Segunda","Terca","Quarta","Quinta","Sexta"]
    let minhasTurmas   = turmas.filter  { $0.instrutor.nome == instrutor.nome }
    let meusTreinos    = treinos.filter { $0.instrutor.nome == instrutor.nome }
    let minhasReservas = instrutor.reservas

    for dia in dias {
        let t  = minhasTurmas.filter   { $0.diaSemana == dia }
        let tr = meusTreinos.filter    { $0.diaSemana == dia }
        let r  = minhasReservas.filter { $0.diaSemana == dia }
        guard !t.isEmpty || !tr.isEmpty || !r.isEmpty else { continue }
        print("\n  --- \(dia) ---")
        for item in t  { print("    \(item.horario) [TURMA]    \(item.nomeAula) (\(item.alunosInscritos.count) alunos)") }
        for item in tr { print("    \(item.horario) [PERSONAL] \(item.aluno.nome)") }
        for item in r  { print("    \(item.horario) [RESERVA]  \(item.aluno.nome)") }
    }
}

// MARK: - Acoes admin (reaproveitadas da etapa 1)

func listarPlanos() {
    centralizar("PLANOS DISPONIVEIS")
    let normais = CatalogoPlanos.todos.filter { $0.nome.hasPrefix("Normal") }
    let blacks  = CatalogoPlanos.todos.filter { $0.nome.hasPrefix("Black") }
    secao("PLANO NORMAL")
    print("  - 2 modalidades | Instrutor 2x/semana | 8 aulas/mes")
    for (i, p) in normais.enumerated() {
        print("  [\(i+1)] \(p.nome) ... R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }
    secao("PLANO BLACK")
    print("  - Todas modalidades | Instrutor ilimitado | Aulas ilimitadas")
    for (i, p) in blacks.enumerated() {
        print("  [\(i+1)] \(p.nome) .... R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }
    linha()
}

func cadastrarAluno() {
    centralizar("CADASTRAR ALUNO")
    let nome      = lerTexto(prompt: "Nome:")
    let email     = lerTexto(prompt: "Email:")
    let matricula = lerTexto(prompt: "Matricula:")
    secao("NIVEL")
    for (i, n) in NivelExperiencia.allCases.enumerated() { print("  [\(i+1)] \(n)") }
    let nivel = NivelExperiencia.allCases[lerOpcao(prompt: "Nivel:", opcoes: 1...NivelExperiencia.allCases.count) - 1]
    secao("PLANO")
    for (i, p) in CatalogoPlanos.todos.enumerated() {
        print("  [\(i+1)] \(p.nome) - R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }
    let plano = CatalogoPlanos.todos[lerOpcao(prompt: "Plano:", opcoes: 1...CatalogoPlanos.todos.count) - 1]
    secao("MODALIDADES")
    let mods = selecionarModalidades(limite: plano.limiteModalidades)
    alunos.append(Aluno(nome: nome, email: email, matricula: matricula,
                        plano: plano, nivel: nivel, modalidades: mods))
    print("\n  Aluno '\(nome)' cadastrado com sucesso.")
}

func cadastrarInstrutor() {
    centralizar("CADASTRAR INSTRUTOR")
    let nome  = lerTexto(prompt: "Nome:")
    let email = lerTexto(prompt: "Email:")
    secao("ESPECIALIDADE")
    for (i, c) in CategoriaAula.allCases.enumerated() { print("  [\(i+1)] \(c)") }
    let esp = CategoriaAula.allCases[lerOpcao(prompt: "Especialidade:", opcoes: 1...CategoriaAula.allCases.count) - 1]
    let instrutor = Instrutor(nome: nome, email: email, especialidade: esp)
    instrutores.append(instrutor)
    gerarTurmasParaInstrutor(instrutor)
    print("\n  Instrutor '\(nome)' cadastrado.")
    print("  Turmas de \(esp) geradas: Seg 08h | Qua 10h | Sex 17h")
}

func listarAlunos() {
    centralizar("ALUNOS CADASTRADOS")
    guard !alunos.isEmpty else { print("  Nenhum aluno."); return }
    for (i, a) in alunos.enumerated() {
        print("\n  [\(i+1)]")
        a.description.split(separator: "\n").forEach { print("  \($0)") }
        linha()
    }
}

func listarInstrutores() {
    centralizar("INSTRUTORES CADASTRADOS")
    guard !instrutores.isEmpty else { print("  Nenhum instrutor."); return }
    for (i, inst) in instrutores.enumerated() {
        print("\n  [\(i+1)] \(inst.description)")
        linha()
    }
}

func atualizarAluno() {
    centralizar("ATUALIZAR ALUNO")
    guard !alunos.isEmpty else { print("  Nenhum aluno."); return }
    for (i, a) in alunos.enumerated() { print("  [\(i+1)] \(a.nome) | \(a.plano.nome) | \(a.nivel)") }
    let aluno = alunos[lerOpcao(prompt: "Aluno:", opcoes: 1...alunos.count) - 1]
    secao("O QUE ATUALIZAR?")
    print("  [1] Plano  [2] Nivel  [3] Ambos")
    let opcao = lerOpcao(prompt: "Opcao:", opcoes: 1...3)
    if opcao == 1 || opcao == 3 {
        for (i, p) in CatalogoPlanos.todos.enumerated() {
            print("  [\(i+1)] \(p.nome) - R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
        }
        let novoPlano = CatalogoPlanos.todos[lerOpcao(prompt: "Plano:", opcoes: 1...CatalogoPlanos.todos.count) - 1]
        let novasMods = selecionarModalidades(limite: novoPlano.limiteModalidades)
        aluno.atualizarPlano(novoPlano, novasModalidades: novasMods)
    }
    if opcao == 2 || opcao == 3 {
        for (i, n) in NivelExperiencia.allCases.enumerated() { print("  [\(i+1)] \(n)") }
        aluno.atualizarNivel(NivelExperiencia.allCases[lerOpcao(prompt: "Nivel:", opcoes: 1...NivelExperiencia.allCases.count) - 1])
    }
}

// MARK: - Menu Principal

func menuPrincipal() {
    while true {
        print()
        print(String(repeating: "*", count: largura))
        let titulo = "SISTEMA DE ACADEMIA"
        print(String(repeating: " ", count: max(0,(largura-titulo.count)/2)) + titulo)
        print(String(repeating: "*", count: largura))
        print()
        print("  --- Administracao ---")
        print("  [1]  Listar planos")
        print("  [2]  Cadastrar aluno")
        print("  [3]  Cadastrar instrutor")
        print("  [4]  Listar alunos")
        print("  [5]  Listar instrutores")
        print("  [6]  Atualizar aluno")
        print("  [7]  Gerenciar turmas")
        print("  [8]  Manutencao de equipamentos")
        print()
        print("  --- Acesso ---")
        print("  [9]  Area do Aluno")
        print("  [10] Area do Instrutor")
        print()
        print("  [0]  Sair")
        print()
        print(String(repeating: "*", count: largura))

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...10)
        switch opcao {
        case 1:  listarPlanos()
        case 2:  cadastrarAluno()
        case 3:  cadastrarInstrutor()
        case 4:  listarAlunos()
        case 5:  listarInstrutores()
        case 6:  atualizarAluno()
        case 7:  menuTurmas()
        case 8:  menuManutencao()
        case 9:  if let a = loginAluno()     { menuAluno(a) }
        case 10: if let i = loginInstrutor() { menuInstrutor(i) }
        case 0:
            print(); linha("*")
            print("  Encerrando. Ate logo!")
            linha("*"); exit(0)
        default: break
        }
        print("\n  Pressione Enter para voltar ao menu...")
        _ = readLine()
    }
}

menuPrincipal()