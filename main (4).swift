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

    var permitePersonal: Bool {
        switch acessoInstrutor {
        case .ilimitado:           return true
        case .limitado(let vezes): return vezes > 0
        }
    }

    var description: String {
        let mods  = limiteModalidades == Int.max ? "Todas" : "\(limiteModalidades)"
        let aulas = limiteAulasColetivas == Int.max ? "Ilimitadas" : "\(limiteAulasColetivas)/mes"
        return """
        Nome         : \(nome)
        Mensalidade  : R$ \(String(format: "%.2f", valorMensalidade))
        Modalidades  : \(mods)
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

// MARK: - Contrato de Manutencao

struct RegistroManutencao: CustomStringConvertible {
    let data: String
    let descricao: String
    let regularizado: Bool
    var description: String {
        "[\(data)] \(descricao) — \(regularizado ? "Regularizado" : "Pendente")"
    }
}

enum ErroManutencao: Error, CustomStringConvertible {
    case equipamentoDefeituoso(nome: String)
    var description: String {
        switch self {
        case .equipamentoDefeituoso(let n):
            return "'\(n)' esta defeituoso e nao pode receber manutencao."
        }
    }
}

protocol Manutencavel {
    var nomeItem: String { get }
    var historicoManutencao: [RegistroManutencao] { get }
    mutating func realizarManutencao(data: String, descricao: String, regularizado: Bool) throws
}

enum EstadoEquipamento: String, CustomStringConvertible {
    case funcionando = "Funcionando"
    case defeituoso  = "Defeituoso"
    var description: String { rawValue }
}

struct Equipamento: Manutencavel, CustomStringConvertible {
    let nomeItem: String
    let codigo: String
    private(set) var estado: EstadoEquipamento
    private(set) var historicoManutencao: [RegistroManutencao] = []

    init(nome: String, codigo: String, estado: EstadoEquipamento = .funcionando) {
        self.nomeItem = nome; self.codigo = codigo; self.estado = estado
    }

    mutating func realizarManutencao(data: String, descricao: String, regularizado: Bool) throws {
        guard estado == .funcionando else {
            throw ErroManutencao.equipamentoDefeituoso(nome: nomeItem)
        }
        historicoManutencao.append(
            RegistroManutencao(data: data, descricao: descricao, regularizado: regularizado))
    }

    mutating func marcarComoDefeituoso() { estado = .defeituoso }
    mutating func reativar()             { estado = .funcionando }

    var description: String {
        let hist = historicoManutencao.suffix(3)
            .map { "    \($0)" }.joined(separator: "\n")
        return """
        Codigo  : \(codigo)
        Nome    : \(nomeItem)
        Estado  : \(estado)
        Ultimos registros:
        \(hist.isEmpty ? "    (nenhum)" : hist)
        """
    }
}

// MARK: - Contrato de Aula

protocol Aula {
    var nomeAula:  String        { get }
    var instrutor: Instrutor     { get }
    var categoria: CategoriaAula { get }
    var descricao: String        { get }
}

enum ErroInscricao: Error, CustomStringConvertible {
    case turmaLotada
    case alunoJaInscrito
    case abaixoDoMinimo(minimo: Int)
    var description: String {
        switch self {
        case .turmaLotada:             return "Turma sem vagas disponiveis."
        case .alunoJaInscrito:         return "Aluno ja inscrito nesta turma."
        case .abaixoDoMinimo(let min): return "Aviso: minimo de \(min) aluno(s) ainda nao atingido."
        }
    }
}

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
    var atingiuMinimo: Bool   { alunosInscritos.count >= capacidadeMinima }

    init(nome: String, instrutor: Instrutor, categoria: CategoriaAula,
         descricao: String, diaSemana: String, horario: String,
         capacidadeMaxima: Int, capacidadeMinima: Int) {
        self.nomeAula         = nome
        self.instrutor        = instrutor
        self.categoria        = categoria
        self.descricao        = descricao
        self.diaSemana        = diaSemana
        self.horario          = horario
        self.capacidadeMaxima = capacidadeMaxima
        self.capacidadeMinima = capacidadeMinima
    }

    func inscrever(aluno: Aluno) throws {
        if alunosInscritos.contains(where: { $0.matricula == aluno.matricula }) {
            throw ErroInscricao.alunoJaInscrito
        }
        guard vagasDisponiveis > 0 else { throw ErroInscricao.turmaLotada }
        alunosInscritos.append(aluno)
        if !atingiuMinimo { print("  \(ErroInscricao.abaixoDoMinimo(minimo: capacidadeMinima))") }
    }

    func remover(aluno: Aluno) {
        alunosInscritos.removeAll { $0.matricula == aluno.matricula }
    }

    var description: String {
        """
        Turma    : \(nomeAula)
        Categoria: \(categoria)
        Instrutor: \(instrutor.nome)
        Horario  : \(diaSemana) \(horario)
        Vagas    : \(alunosInscritos.count)/\(capacidadeMaxima) | Min: \(capacidadeMinima) | \(atingiuMinimo ? "Minimo atingido" : "Aguardando")
        """
    }
}

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
        Instrutor: \(instrutor.nome)
        Aluno    : \(aluno.nome)
        Horario  : \(diaSemana) \(horario) (\(duracaoMinutos) min)
        """
    }
}

// MARK: - Hierarquia de Pessoas

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
    var aulasMatriculadas: [String] = []
    var reservasInstrutor: [ReservaInstrutor] = []
    var reservasNaSemana: Int { reservasInstrutor.count }

    init(nome: String, email: String, matricula: String,
         plano: PlanoAssinatura, nivel: NivelExperiencia,
         modalidades: [CategoriaAula]) {
        self.matricula  = matricula
        self.plano      = plano
        self.nivel      = nivel
        self.modalidades = modalidades
        super.init(nome: nome, email: email)
    }

    override func funcaoDescritiva() -> String { "Aluno" }

    func atualizarPlano(_ novo: PlanoAssinatura, novasModalidades: [CategoriaAula]) {
        plano = novo; modalidades = novasModalidades
    }
    func atualizarNivel(_ novo: NivelExperiencia) { nivel = novo }

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

struct ReservaInstrutor: CustomStringConvertible {
    let id: Int
    let aluno: Aluno
    let instrutor: Instrutor
    let diaSemana: String
    let horario: String
    var description: String { "[\(id)] \(aluno.nome) | \(diaSemana) \(horario)" }
}

// MARK: - Erros de Admissao

enum ErroAdmissao: Error, CustomStringConvertible {
    case matriculaDuplicada(matricula: String)
    case emailDuplicado(email: String)
    case instrutorNaoEncontrado
    case alunoNaoEncontrado
    case planoNaoPermitePersonal(plano: String)
    case limiteReservasAtingido(limite: Int)
    case horarioIndisponivel

    var description: String {
        switch self {
        case .matriculaDuplicada(let m): return "Matricula '\(m)' ja cadastrada."
        case .emailDuplicado(let e):     return "Email '\(e)' ja cadastrado."
        case .instrutorNaoEncontrado:    return "Instrutor nao encontrado."
        case .alunoNaoEncontrado:        return "Aluno nao encontrado."
        case .planoNaoPermitePersonal(let p):
            return "O plano '\(p)' nao autoriza agendamento de personal trainer."
        case .limiteReservasAtingido(let l):
            return "Limite de \(l) reservas semanais atingido pelo plano."
        case .horarioIndisponivel:       return "Horario indisponivel para o instrutor escolhido."
        }
    }
}

// MARK: - Relatorio de Manutencao

struct RelatorioManutencao {
    let dataExecucao: String
    let totalVerificados: Int
    let sucessos: [String]
    let falhas: [(nome: String, motivo: String)]

    func imprimir() {
        linha("=")
        let titulo = "RELATORIO DE MANUTENCAO EM LOTE"
        print(String(repeating: " ", count: max(0, (largura - titulo.count) / 2)) + titulo)
        linha("=")
        print("  Data       : \(dataExecucao)")
        print("  Verificados: \(totalVerificados)")
        print("  Sucessos   : \(sucessos.count)")
        print("  Falhas     : \(falhas.count)")
        if !sucessos.isEmpty {
            print("\n  Manutencao realizada:")
            sucessos.forEach { print("    + \($0)") }
        }
        if !falhas.isEmpty {
            print("\n  Equipamentos com falha:")
            falhas.forEach { print("    - \($0.nome): \($0.motivo)") }
        }
        linha("=")
    }
}

// MARK: - GymManager

final class GymManager {

    private var alunosPorMatricula:  [String: Aluno]    = [:]
    private var alunosPorEmail:      [String: Aluno]    = [:]
    private var instrutoresPorEmail: [String: Instrutor] = [:]

    private(set) var instrutores:  [Instrutor]      = []
    private(set) var equipamentos: [Equipamento]    = []
    private(set) var turmas:       [TurmaColetiva]  = []
    private(set) var treinos:      [TreinoPersonal] = []

    private var proximoIdReserva = 1

    var alunos: [Aluno] { Array(alunosPorMatricula.values) }

    // MARK: Admissao

    func admitirAluno(nome: String, email: String, matricula: String,
                      plano: PlanoAssinatura, nivel: NivelExperiencia,
                      modalidades: [CategoriaAula]) throws -> Aluno {
        if alunosPorMatricula[matricula] != nil {
            throw ErroAdmissao.matriculaDuplicada(matricula: matricula)
        }
        if alunosPorEmail[email.lowercased()] != nil {
            throw ErroAdmissao.emailDuplicado(email: email)
        }
        let aluno = Aluno(nome: nome, email: email, matricula: matricula,
                          plano: plano, nivel: nivel, modalidades: modalidades)
        alunosPorMatricula[matricula]      = aluno
        alunosPorEmail[email.lowercased()] = aluno
        return aluno
    }

    func admitirInstrutor(nome: String, email: String,
                          especialidade: CategoriaAula) throws -> Instrutor {
        if instrutoresPorEmail[email.lowercased()] != nil {
            throw ErroAdmissao.emailDuplicado(email: email)
        }
        let instrutor = Instrutor(nome: nome, email: email, especialidade: especialidade)
        instrutoresPorEmail[email.lowercased()] = instrutor
        instrutores.append(instrutor)
        gerarTurmasParaInstrutor(instrutor)
        return instrutor
    }

    // MARK: Consulta

    func buscarAluno(porMatricula matricula: String) -> Aluno? {
        alunosPorMatricula[matricula]
    }
    func buscarAluno(porEmail email: String) -> Aluno? {
        alunosPorEmail[email.lowercased()]
    }
    func buscarInstrutor(porEmail email: String) -> Instrutor? {
        instrutoresPorEmail[email.lowercased()]
    }

    // MARK: Atualizacao

    func atualizarPlano(matricula: String, novoPlano: PlanoAssinatura,
                        novasModalidades: [CategoriaAula]) throws {
        guard let aluno = alunosPorMatricula[matricula] else {
            throw ErroAdmissao.alunoNaoEncontrado
        }
        aluno.atualizarPlano(novoPlano, novasModalidades: novasModalidades)
        print("  Plano de \(aluno.nome) atualizado para '\(novoPlano.nome)'.")
    }

    func atualizarNivel(matricula: String, novoNivel: NivelExperiencia) throws {
        guard let aluno = alunosPorMatricula[matricula] else {
            throw ErroAdmissao.alunoNaoEncontrado
        }
        aluno.atualizarNivel(novoNivel)
        print("  Nivel de \(aluno.nome) atualizado para '\(novoNivel)'.")
    }

    // MARK: Equipamentos

    func adicionarEquipamento(nome: String, codigo: String,
                              estado: EstadoEquipamento = .funcionando) {
        equipamentos.append(Equipamento(nome: nome, codigo: codigo, estado: estado))
    }

    // Metodos de mutacao encapsulados para evitar erro de mutating em struct
    func realizarManutencaoEquipamento(indice: Int, descricao: String,
                                       regularizado: Bool) throws {
        try equipamentos[indice].realizarManutencao(
            data: dataHoje(), descricao: descricao, regularizado: regularizado)
    }

    func marcarEquipamentoDefeituoso(indice: Int) {
        equipamentos[indice].marcarComoDefeituoso()
    }

    func reativarEquipamento(indice: Int) {
        equipamentos[indice].reativar()
        print("  '\(equipamentos[indice].nomeItem)' reativado.")
    }

    // MARK: Manutencao em Lote

    func executarManutencaoEmLote(descricao: String) -> RelatorioManutencao {
        let data     = dataHoje()
        var sucessos = [String]()
        var falhas   = [(nome: String, motivo: String)]()

        for i in equipamentos.indices {
            do {
                try equipamentos[i].realizarManutencao(
                    data: data, descricao: descricao, regularizado: true)
                sucessos.append(equipamentos[i].nomeItem)
            } catch let erro as ErroManutencao {
                falhas.append((nome: equipamentos[i].nomeItem, motivo: erro.description))
            } catch {
                falhas.append((nome: equipamentos[i].nomeItem,
                               motivo: error.localizedDescription))
            }
        }

        return RelatorioManutencao(dataExecucao: data, totalVerificados: equipamentos.count,
                                   sucessos: sucessos, falhas: falhas)
    }

    // MARK: Agendamento de Personal

    func agendarPersonal(matriculaAluno: String, emailInstrutor: String,
                         diaSemana: String, horario: String) throws -> TreinoPersonal {
        guard let aluno = alunosPorMatricula[matriculaAluno] else {
            throw ErroAdmissao.alunoNaoEncontrado
        }
        guard let instrutor = instrutoresPorEmail[emailInstrutor.lowercased()] else {
            throw ErroAdmissao.instrutorNaoEncontrado
        }
        guard aluno.plano.permitePersonal else {
            throw ErroAdmissao.planoNaoPermitePersonal(plano: aluno.plano.nome)
        }
        if case .limitado(let max) = aluno.plano.acessoInstrutor {
            if aluno.reservasNaSemana >= max {
                throw ErroAdmissao.limiteReservasAtingido(limite: max)
            }
        }
        let ocupados = instrutor.reservas.map { "\($0.diaSemana)\($0.horario)" }
        guard !ocupados.contains("\(diaSemana)\(horario)") else {
            throw ErroAdmissao.horarioIndisponivel
        }

        let reserva = ReservaInstrutor(id: proximoIdReserva, aluno: aluno,
                                       instrutor: instrutor,
                                       diaSemana: diaSemana, horario: horario)
        proximoIdReserva += 1
        aluno.reservasInstrutor.append(reserva)
        instrutor.reservas.append(reserva)

        let treino = TreinoPersonal(
            nomeAula: "Personal - \(aluno.nome)",
            instrutor: instrutor,
            categoria: instrutor.especialidade,
            descricao: "Treino individual de \(instrutor.especialidade)",
            aluno: aluno, diaSemana: diaSemana, horario: horario, duracaoMinutos: 60)
        treinos.append(treino)
        return treino
    }

    // MARK: Inscricao em Turma

    func inscreverEmTurma(matriculaAluno: String, nomeTurma: String) throws {
        guard let aluno = alunosPorMatricula[matriculaAluno] else {
            throw ErroAdmissao.alunoNaoEncontrado
        }
        guard let turma = turmas.first(where: { $0.nomeAula == nomeTurma }) else { return }
        let limite = aluno.plano.limiteAulasColetivas
        if limite != Int.max && aluno.aulasMatriculadas.count >= limite { return }
        try turma.inscrever(aluno: aluno)
        aluno.aulasMatriculadas.append(nomeTurma)
    }

    // MARK: Turmas

    private func gerarTurmasParaInstrutor(_ instrutor: Instrutor) {
        let grade = [("Segunda","08:00"),("Quarta","10:00"),("Sexta","17:00")]
        for (dia, hora) in grade {
            turmas.append(TurmaColetiva(
                nome: "\(instrutor.especialidade) - \(dia)",
                instrutor: instrutor,
                categoria: instrutor.especialidade,
                descricao: "Turma regular de \(instrutor.especialidade) com \(instrutor.nome)",
                diaSemana: dia, horario: hora,
                capacidadeMaxima: 15, capacidadeMinima: 3))
        }
    }

    func adicionarTurma(_ turma: TurmaColetiva) {
        turmas.append(turma)
    }
}

// MARK: - Instancia global

let gym = GymManager()

// MARK: - Utilitarios de terminal

let largura = 52

func linha(_ c: Character = "-") {
    print(String(repeating: c, count: largura))
}

func centralizar(_ texto: String, com c: Character = "*") {
    print(String(repeating: c, count: largura))
    print(String(repeating: " ", count: max(0, (largura - texto.count) / 2)) + texto)
    print(String(repeating: c, count: largura))
}

func secao(_ titulo: String) {
    print()
    linha()
    print(String(repeating: " ", count: max(0, (largura - titulo.count) / 2)) + titulo)
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

func selecionarModalidades(limite: Int) -> [CategoriaAula] {
    let todas = CategoriaAula.allCases
    if limite == Int.max {
        print("  Plano Black: todas as modalidades.")
        return todas
    }
    print("  Escolha \(limite) modalidade(s):")
    for (i, c) in todas.enumerated() { print("    [\(i+1)] \(c)") }
    var escolhidas: [CategoriaAula] = []
    while escolhidas.count < limite {
        let idx = lerOpcao(prompt: "Modalidade \(escolhidas.count+1)/\(limite):",
                           opcoes: 1...todas.count)
        let cat = todas[idx - 1]
        if escolhidas.contains(where: { $0 == cat }) { print("     Ja escolhida.") }
        else { escolhidas.append(cat) }
    }
    return escolhidas
}

let horariosDisponiveis: [(dia: String, hora: String)] = [
    ("Segunda","07:00"),("Segunda","09:00"),("Segunda","18:00"),
    ("Terca","07:00"),("Terca","10:00"),("Terca","19:00"),
    ("Quarta","08:00"),("Quarta","11:00"),("Quarta","18:00"),
    ("Quinta","07:00"),("Quinta","09:00"),("Quinta","20:00"),
    ("Sexta","07:00"),("Sexta","10:00"),("Sexta","18:00"),
]

// MARK: - Menus de Administracao

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
    print("  - Todas as modalidades | Instrutor ilimitado | Aulas ilimitadas")
    for (i, p) in blacks.enumerated() {
        print("  [\(i+1)] \(p.nome) .... R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }
}

func cadastrarAluno() {
    centralizar("CADASTRAR ALUNO")
    let nome      = lerTexto(prompt: "Nome:")
    let email     = lerTexto(prompt: "Email:")
    let matricula = lerTexto(prompt: "Matricula:")
    secao("NIVEL")
    for (i, n) in NivelExperiencia.allCases.enumerated() { print("  [\(i+1)] \(n)") }
    let nivel = NivelExperiencia.allCases[
        lerOpcao(prompt: "Nivel:", opcoes: 1...NivelExperiencia.allCases.count) - 1]
    secao("PLANO")
    for (i, p) in CatalogoPlanos.todos.enumerated() {
        print("  [\(i+1)] \(p.nome) - R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }
    let plano = CatalogoPlanos.todos[
        lerOpcao(prompt: "Plano:", opcoes: 1...CatalogoPlanos.todos.count) - 1]
    secao("MODALIDADES")
    let mods = selecionarModalidades(limite: plano.limiteModalidades)
    do {
        let aluno = try gym.admitirAluno(nome: nome, email: email, matricula: matricula,
                                         plano: plano, nivel: nivel, modalidades: mods)
        print("\n  Aluno '\(aluno.nome)' admitido com sucesso.")
    } catch let e as ErroAdmissao { print("\n  Erro: \(e)") }
      catch { print("\n  Erro: \(error)") }
}

func cadastrarInstrutor() {
    centralizar("CADASTRAR INSTRUTOR")
    let nome  = lerTexto(prompt: "Nome:")
    let email = lerTexto(prompt: "Email:")
    secao("ESPECIALIDADE")
    for (i, c) in CategoriaAula.allCases.enumerated() { print("  [\(i+1)] \(c)") }
    let esp = CategoriaAula.allCases[
        lerOpcao(prompt: "Especialidade:", opcoes: 1...CategoriaAula.allCases.count) - 1]
    do {
        let inst = try gym.admitirInstrutor(nome: nome, email: email, especialidade: esp)
        print("\n  Instrutor '\(inst.nome)' admitido.")
        print("  Turmas de \(esp) geradas: Seg 08h | Qua 10h | Sex 17h")
    } catch let e as ErroAdmissao { print("\n  Erro: \(e)") }
      catch { print("\n  Erro: \(error)") }
}

func listarAlunos() {
    centralizar("ALUNOS CADASTRADOS")
    let lista = gym.alunos
    guard !lista.isEmpty else { print("  Nenhum aluno."); return }
    for (i, a) in lista.enumerated() {
        print("\n  [\(i+1)]")
        a.description.split(separator: "\n").forEach { print("  \($0)") }
        linha()
    }
}

func listarInstrutores() {
    centralizar("INSTRUTORES CADASTRADOS")
    guard !gym.instrutores.isEmpty else { print("  Nenhum instrutor."); return }
    for (i, inst) in gym.instrutores.enumerated() {
        print("  [\(i+1)] \(inst.description)")
    }
}

func atualizarAluno() {
    centralizar("ATUALIZAR ALUNO")
    let lista = gym.alunos
    guard !lista.isEmpty else { print("  Nenhum aluno."); return }
    for (i, a) in lista.enumerated() {
        print("  [\(i+1)] \(a.nome) | \(a.matricula) | \(a.plano.nome)")
    }
    let aluno = lista[lerOpcao(prompt: "Aluno:", opcoes: 1...lista.count) - 1]
    print("  [1] Plano  [2] Nivel  [3] Ambos")
    let opcao = lerOpcao(prompt: "Opcao:", opcoes: 1...3)
    if opcao == 1 || opcao == 3 {
        for (i, p) in CatalogoPlanos.todos.enumerated() { print("  [\(i+1)] \(p.nome)") }
        let novoPlano = CatalogoPlanos.todos[
            lerOpcao(prompt: "Plano:", opcoes: 1...CatalogoPlanos.todos.count) - 1]
        let novasMods = selecionarModalidades(limite: novoPlano.limiteModalidades)
        try? gym.atualizarPlano(matricula: aluno.matricula,
                                novoPlano: novoPlano, novasModalidades: novasMods)
    }
    if opcao == 2 || opcao == 3 {
        for (i, n) in NivelExperiencia.allCases.enumerated() { print("  [\(i+1)] \(n)") }
        let novoNivel = NivelExperiencia.allCases[
            lerOpcao(prompt: "Nivel:", opcoes: 1...NivelExperiencia.allCases.count) - 1]
        try? gym.atualizarNivel(matricula: aluno.matricula, novoNivel: novoNivel)
    }
}

// MARK: - Menu de Manutencao

func menuManutencao() {
    while true {
        print(); centralizar("MANUTENCAO DE EQUIPAMENTOS"); print()
        print("  [1]  Cadastrar equipamento")
        print("  [2]  Listar equipamentos")
        print("  [3]  Registrar manutencao individual")
        print("  [4]  Executar manutencao em LOTE")
        print("  [5]  Marcar como defeituoso")
        print("  [6]  Reativar equipamento")
        print("  [0]  Voltar"); print(); linha("*")

        switch lerOpcao(prompt: "Escolha:", opcoes: 0...6) {
        case 1:
            let nome   = lerTexto(prompt: "Nome:")
            let codigo = lerTexto(prompt: "Codigo:")
            gym.adicionarEquipamento(nome: nome, codigo: codigo)
            print("  Equipamento cadastrado.")
        case 2:
            guard !gym.equipamentos.isEmpty else { print("  Nenhum equipamento."); break }
            for (i, eq) in gym.equipamentos.enumerated() {
                print("\n  [\(i+1)]")
                eq.description.split(separator: "\n").forEach { print("  \($0)") }
                linha()
            }
        case 3:
            guard !gym.equipamentos.isEmpty else { print("  Nenhum equipamento."); break }
            for (i, eq) in gym.equipamentos.enumerated() {
                print("  [\(i+1)] \(eq.nomeItem) [\(eq.estado)]")
            }
            let idx  = lerOpcao(prompt: "Equipamento:", opcoes: 1...gym.equipamentos.count) - 1
            let desc = lerTexto(prompt: "Descricao:")
            print("  Regularizado? [1] Sim  [2] Nao")
            let reg = lerOpcao(prompt: "Opcao:", opcoes: 1...2) == 1
            do {
                try gym.realizarManutencaoEquipamento(indice: idx, descricao: desc,
                                                      regularizado: reg)
                print("  Manutencao registrada.")
            } catch let e as ErroManutencao { print("  \(e)") }
              catch { print("  Erro: \(error)") }
        case 4:
            guard !gym.equipamentos.isEmpty else { print("  Nenhum equipamento."); break }
            let desc = lerTexto(prompt: "Descricao do servico em lote:")
            gym.executarManutencaoEmLote(descricao: desc).imprimir()
        case 5:
            guard !gym.equipamentos.isEmpty else { print("  Nenhum equipamento."); break }
            for (i, eq) in gym.equipamentos.enumerated() {
                print("  [\(i+1)] \(eq.nomeItem) [\(eq.estado)]")
            }
            let idx = lerOpcao(prompt: "Equipamento:", opcoes: 1...gym.equipamentos.count) - 1
            gym.marcarEquipamentoDefeituoso(indice: idx)
            print("  Marcado como defeituoso.")
        case 6:
            let defeituosos = gym.equipamentos.indices.filter {
                gym.equipamentos[$0].estado == .defeituoso
            }
            guard !defeituosos.isEmpty else { print("  Nenhum defeituoso."); break }
            for (i, idx) in defeituosos.enumerated() {
                print("  [\(i+1)] \(gym.equipamentos[idx].nomeItem)")
            }
            let sel = lerOpcao(prompt: "Equipamento:", opcoes: 1...defeituosos.count) - 1
            gym.reativarEquipamento(indice: defeituosos[sel])
        case 0: return
        default: break
        }
        print("\n  Pressione Enter..."); _ = readLine()
    }
}

// MARK: - Menu de Turmas

func menuTurmas() {
    while true {
        print(); centralizar("GERENCIAR TURMAS"); print()
        print("  [1]  Listar turmas coletivas")
        print("  [2]  Listar treinos com personal")
        print("  [0]  Voltar"); print(); linha("*")

        switch lerOpcao(prompt: "Escolha:", opcoes: 0...2) {
        case 1:
            guard !gym.turmas.isEmpty else { print("  Nenhuma turma."); break }
            for (i, t) in gym.turmas.enumerated() {
                print("\n  [\(i+1)]")
                t.description.split(separator: "\n").forEach { print("  \($0)") }
                linha()
            }
        case 2:
            guard !gym.treinos.isEmpty else { print("  Nenhum treino."); break }
            for (i, t) in gym.treinos.enumerated() {
                print("\n  [\(i+1)]")
                t.description.split(separator: "\n").forEach { print("  \($0)") }
                linha()
            }
        case 0: return
        default: break
        }
        print("\n  Pressione Enter..."); _ = readLine()
    }
}

// MARK: - Area do Aluno

func loginAluno() -> Aluno? {
    secao("LOGIN - AREA DO ALUNO")
    let nome      = lerTexto(prompt: "Nome:")
    let matricula = lerTexto(prompt: "Matricula:")
    if let aluno = gym.buscarAluno(porMatricula: matricula),
       aluno.nome.lowercased() == nome.lowercased() {
        print("\n  Bem-vindo(a), \(aluno.nome)! [\(aluno.plano.nome)]")
        return aluno
    }
    print("\n  Nome ou matricula incorretos.")
    return nil
}

func menuAluno(_ aluno: Aluno) {
    while true {
        print(); centralizar("AREA DO ALUNO"); print()
        print("  Logado como : \(aluno.nome)")
        print("  Plano       : \(aluno.plano.nome)"); print()
        linha()
        print("  [1]  Inscrever-se em turma coletiva")
        print("  [2]  Agendar personal trainer")
        print("  [3]  Minhas turmas")
        print("  [4]  Meus treinos com personal")
        print("  [0]  Voltar"); print(); linha("*")

        switch lerOpcao(prompt: "Escolha:", opcoes: 0...4) {
        case 1: inscreverEmTurmaAluno(aluno)
        case 2: agendarPersonalAluno(aluno)
        case 3:
            secao("MINHAS TURMAS")
            if aluno.aulasMatriculadas.isEmpty { print("  Nenhuma turma.") }
            else { aluno.aulasMatriculadas.enumerated()
                .forEach { print("  [\($0+1)] \($1)") } }
        case 4:
            secao("MEUS TREINOS COM PERSONAL")
            let meus = gym.treinos.filter { $0.aluno.matricula == aluno.matricula }
            if meus.isEmpty { print("  Nenhum treino.") }
            else { meus.forEach {
                print("  \($0.instrutor.nome) | \($0.diaSemana) \($0.horario)")
            }}
        case 0: return
        default: break
        }
        print("\n  Pressione Enter..."); _ = readLine()
    }
}

func inscreverEmTurmaAluno(_ aluno: Aluno) {
    secao("INSCREVER EM TURMA COLETIVA")
    let disponiveis = gym.turmas.filter { turma in
        aluno.modalidades.contains(where: { $0 == turma.categoria })
            && turma.vagasDisponiveis > 0
    }
    guard !disponiveis.isEmpty else {
        print("  Nenhuma turma disponivel para suas modalidades.")
        return
    }
    for (i, t) in disponiveis.enumerated() {
        print("  [\(i+1)] \(t.nomeAula) | \(t.diaSemana) \(t.horario) | \(t.vagasDisponiveis) vagas")
    }
    let idx = lerOpcao(prompt: "Turma (0 cancelar):", opcoes: 0...disponiveis.count)
    guard idx > 0 else { return }
    do {
        try gym.inscreverEmTurma(matriculaAluno: aluno.matricula,
                                  nomeTurma: disponiveis[idx-1].nomeAula)
        print("  Inscrito com sucesso.")
    } catch let e as ErroInscricao { print("  \(e)") }
      catch { print("  Erro: \(error)") }
}

func agendarPersonalAluno(_ aluno: Aluno) {
    secao("AGENDAR PERSONAL TRAINER")
    guard !gym.instrutores.isEmpty else { print("  Nenhum instrutor disponivel."); return }
    for (i, inst) in gym.instrutores.enumerated() {
        print("  [\(i+1)] \(inst.nome) (\(inst.especialidade))")
    }
    let instrutor = gym.instrutores[
        lerOpcao(prompt: "Instrutor:", opcoes: 1...gym.instrutores.count) - 1]

    let ocupados = instrutor.reservas.map { "\($0.diaSemana)\($0.horario)" }
    let livres   = horariosDisponiveis.filter { !ocupados.contains("\($0.dia)\($0.hora)") }
    guard !livres.isEmpty else { print("  Sem horarios disponiveis."); return }

    secao("HORARIOS DISPONIVEIS")
    for (i, h) in livres.enumerated() { print("  [\(i+1)] \(h.dia) - \(h.hora)") }
    let horario = livres[lerOpcao(prompt: "Horario:", opcoes: 1...livres.count) - 1]

    do {
        let treino = try gym.agendarPersonal(
            matriculaAluno: aluno.matricula,
            emailInstrutor: instrutor.email,
            diaSemana: horario.dia,
            horario: horario.hora)
        print("  Treino confirmado: \(treino.instrutor.nome) | \(treino.diaSemana) \(treino.horario)")
    } catch let e as ErroAdmissao { print("\n  Erro: \(e)") }
      catch { print("\n  Erro: \(error)") }
}

// MARK: - Area do Instrutor

func loginInstrutor() -> Instrutor? {
    secao("LOGIN - AREA DO INSTRUTOR")
    let nome  = lerTexto(prompt: "Nome:")
    let email = lerTexto(prompt: "Email:")
    if let inst = gym.buscarInstrutor(porEmail: email),
       inst.nome.lowercased() == nome.lowercased() {
        print("\n  Bem-vindo(a), \(inst.nome)!")
        return inst
    }
    print("\n  Dados incorretos.")
    return nil
}

func menuInstrutor(_ instrutor: Instrutor) {
    while true {
        print(); centralizar("AREA DO INSTRUTOR"); print()
        print("  Logado como  : \(instrutor.nome)")
        print("  Especialidade: \(instrutor.especialidade)"); print()
        linha()
        print("  [1]  Minhas turmas coletivas")
        print("  [2]  Meus treinos com personal")
        print("  [3]  Agenda semanal completa")
        print("  [0]  Voltar"); print(); linha("*")

        switch lerOpcao(prompt: "Escolha:", opcoes: 0...3) {
        case 1:
            secao("MINHAS TURMAS")
            let minhas = gym.turmas.filter { $0.instrutor.nome == instrutor.nome }
            if minhas.isEmpty { print("  Nenhuma turma.") }
            else { minhas.forEach { t in
                print()
                t.description.split(separator: "\n").forEach { print("  \($0)") }
                if !t.alunosInscritos.isEmpty {
                    print("  Alunos:")
                    t.alunosInscritos.forEach { print("    - \($0.nome)") }
                }
                linha()
            }}
        case 2:
            secao("MEUS TREINOS COM PERSONAL")
            let meus = gym.treinos.filter { $0.instrutor.nome == instrutor.nome }
            if meus.isEmpty { print("  Nenhum treino.") }
            else { meus.forEach {
                print("  \($0.aluno.nome) | \($0.diaSemana) \($0.horario)")
            }}
        case 3:
            secao("AGENDA SEMANAL")
            let dias = ["Segunda","Terca","Quarta","Quinta","Sexta"]
            for dia in dias {
                let t = gym.turmas.filter {
                    $0.instrutor.nome == instrutor.nome && $0.diaSemana == dia }
                let p = gym.treinos.filter {
                    $0.instrutor.nome == instrutor.nome && $0.diaSemana == dia }
                guard !t.isEmpty || !p.isEmpty else { continue }
                print("\n  --- \(dia) ---")
                t.forEach { print("    \($0.horario) [TURMA]    \($0.nomeAula)") }
                p.forEach { print("    \($0.horario) [PERSONAL] \($0.aluno.nome)") }
            }
        case 0: return
        default: break
        }
        print("\n  Pressione Enter..."); _ = readLine()
    }
}

// MARK: - Menu Principal

func menuPrincipal() {
    while true {
        print()
        print(String(repeating: "*", count: largura))
        let t = "SISTEMA DE ACADEMIA"
        print(String(repeating: " ", count: max(0, (largura - t.count) / 2)) + t)
        print(String(repeating: "*", count: largura)); print()
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

        switch lerOpcao(prompt: "Escolha:", opcoes: 0...10) {
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
        print("\n  Pressione Enter para voltar ao menu..."); _ = readLine()
    }
}

menuPrincipal()