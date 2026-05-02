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

// MARK: - Catalogo de Planos

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

// MARK: - Aula Coletiva

struct AulaColetiva: CustomStringConvertible {
    let id: Int
    let categoria: CategoriaAula
    let instrutor: Instrutor
    let diaSemana: String
    let horario: String
    let vagasTotais: Int
    var vagasOcupadas: Int = 0

    var vagasDisponiveis: Int { vagasTotais - vagasOcupadas }
    var estaLotada: Bool { vagasDisponiveis == 0 }

    var description: String {
        "[\(id)] \(categoria) | \(diaSemana) \(horario) | Instrutor: \(instrutor.nome) | Vagas: \(vagasDisponiveis)/\(vagasTotais)"
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

// MARK: - Matricula em Aula

struct MatriculaAula: CustomStringConvertible {
    let aulaId: Int
    let categoria: CategoriaAula
    let diaSemana: String
    let horario: String
    let nomeInstrutor: String

    var description: String {
        "\(categoria) | \(diaSemana) \(horario) | Instrutor: \(nomeInstrutor)"
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
    var aulasMatriculadas: [MatriculaAula] = []
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
        plano      = novoPlano
        modalidades = novasModalidades
        print("  Plano de \(nome) atualizado para '\(novoPlano.nome)'.")
    }

    func atualizarNivel(_ novoNivel: NivelExperiencia) {
        nivel = novoNivel
        print("  Nivel de \(nome) atualizado para '\(novoNivel)'.")
    }

    // Quantas reservas de instrutor o aluno ja tem nesta semana
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
        """
        Nome          : \(nome)
        Email         : \(email)
        Especialidade : \(especialidade)
        """
    }
}

// MARK: - Banco de dados em memoria

var alunos:       [Aluno]        = []
var instrutores:  [Instrutor]    = []
var aulasColetivas: [AulaColetiva] = []
var todasReservas: [ReservaInstrutor] = []
var proximoIdAula    = 1
var proximoIdReserva = 1

// Grade de horarios disponiveis para reserva de instrutor
let horariosDisponiveis: [(dia: String, hora: String)] = [
    ("Segunda", "07:00"), ("Segunda", "09:00"), ("Segunda", "18:00"),
    ("Terca",   "07:00"), ("Terca",   "10:00"), ("Terca",   "19:00"),
    ("Quarta",  "08:00"), ("Quarta",  "11:00"), ("Quarta",  "18:00"),
    ("Quinta",  "07:00"), ("Quinta",  "09:00"), ("Quinta",  "20:00"),
    ("Sexta",   "07:00"), ("Sexta",   "10:00"), ("Sexta",   "18:00"),
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

// MARK: - Selecao de modalidades

func selecionarModalidades(limite: Int) -> [CategoriaAula] {
    let todas = CategoriaAula.allCases
    if limite == Int.max {
        print("  Plano Black: acesso a todas as modalidades.")
        return todas
    }
    print("  Escolha \(limite) modalidade(s):")
    for (i, cat) in todas.enumerated() { print("    [\(i+1)] \(cat)") }
    var escolhidas: [CategoriaAula] = []
    while escolhidas.count < limite {
        let idx = lerOpcao(prompt: "Modalidade \(escolhidas.count+1)/\(limite):", opcoes: 1...todas.count)
        let cat = todas[idx - 1]
        if escolhidas.contains(where: { $0 == cat }) {
            print("     Modalidade ja escolhida.")
        } else {
            escolhidas.append(cat)
        }
    }
    return escolhidas
}

// MARK: - Cadastrar aulas coletivas automaticamente ao cadastrar instrutor

func gerarAulasParaInstrutor(_ instrutor: Instrutor) {
    let grade: [(String, String)] = [
        ("Segunda", "08:00"), ("Quarta", "10:00"), ("Sexta", "17:00")
    ]
    for (dia, hora) in grade {
        let aula = AulaColetiva(
            id: proximoIdAula,
            categoria: instrutor.especialidade,
            instrutor: instrutor,
            diaSemana: dia,
            horario: hora,
            vagasTotais: 15)
        aulasColetivas.append(aula)
        proximoIdAula += 1
    }
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
        print("  Logado como: \(aluno.nome)")
        print("  Plano      : \(aluno.plano.nome)")
        print()
        linha()
        print("  [1]  Matricular em aula coletiva")
        print("  [2]  Reservar horario com instrutor")
        print("  [3]  Minhas aulas coletivas")
        print("  [4]  Minhas reservas de instrutor")
        print("  [0]  Voltar ao menu principal")
        print()
        linha("*")

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...4)
        switch opcao {
        case 1: matricularEmAula(aluno)
        case 2: reservarInstrutor(aluno)
        case 3: listarAulasDoAluno(aluno)
        case 4: listarReservasDoAluno(aluno)
        case 0: return
        default: break
        }
        print("\n  Pressione Enter para continuar...")
        _ = readLine()
    }
}

func matricularEmAula(_ aluno: Aluno) {
    secao("MATRICULA EM AULA COLETIVA")

    // Verifica limite de aulas do plano
    let limite = aluno.plano.limiteAulasColetivas
    if limite != Int.max && aluno.aulasMatriculadas.count >= limite {
        print("  Voce atingiu o limite de \(limite) aulas coletivas do seu plano.")
        return
    }

    // Filtra aulas pelas modalidades permitidas do aluno
    let aulasPermitidas = aulasColetivas.filter { aula in
        aluno.modalidades.contains(where: { $0 == aula.categoria }) && !aula.estaLotada
    }

    if aulasPermitidas.isEmpty {
        print("  Nenhuma aula disponivel para suas modalidades no momento.")
        return
    }

    // Mostra aulas ja matriculadas para evitar duplicata
    let idsJaMatriculados = aluno.aulasMatriculadas.map { $0.aulaId }

    let disponiveis = aulasPermitidas.filter { !idsJaMatriculados.contains($0.id) }
    if disponiveis.isEmpty {
        print("  Voce ja esta matriculado em todas as aulas disponiveis para suas modalidades.")
        return
    }

    print()
    for aula in disponiveis { print("  \(aula)") }

    let ids = disponiveis.map { $0.id }
    print()
    print("  >> Informe o ID da aula (ou 0 para cancelar):", terminator: " ")
    guard let entrada = readLine(), let id = Int(entrada) else { return }
    if id == 0 { return }

    guard ids.contains(id), let idx = aulasColetivas.firstIndex(where: { $0.id == id }) else {
        print("  ID invalido.")
        return
    }

    aulasColetivas[idx].vagasOcupadas += 1
    let aula = aulasColetivas[idx]
    let matricula = MatriculaAula(
        aulaId: aula.id, categoria: aula.categoria,
        diaSemana: aula.diaSemana, horario: aula.horario,
        nomeInstrutor: aula.instrutor.nome)
    aluno.aulasMatriculadas.append(matricula)

    let restante = limite == Int.max ? "ilimitadas" : "\(limite - aluno.aulasMatriculadas.count) restante(s)"
    print("  Matriculado com sucesso em \(aula.categoria) - \(aula.diaSemana) \(aula.horario).")
    print("  Aulas coletivas disponiveis no plano: \(restante).")
}

func reservarInstrutor(_ aluno: Aluno) {
    secao("RESERVA DE HORARIO COM INSTRUTOR")

    // Verifica limite semanal do plano
    switch aluno.plano.acessoInstrutor {
    case .limitado(let max):
        if aluno.reservasNaSemana >= max {
            print("  Voce ja utilizou suas \(max) reservas semanais com instrutor.")
            return
        }
        let restantes = max - aluno.reservasNaSemana
        print("  Reservas restantes nesta semana: \(restantes)/\(max)")
    case .ilimitado:
        print("  Seu plano permite reservas ilimitadas com instrutores.")
    }

    if instrutores.isEmpty {
        print("  Nenhum instrutor cadastrado.")
        return
    }

    print()
    for (i, inst) in instrutores.enumerated() {
        print("  [\(i+1)] \(inst.nome) - \(inst.especialidade)")
    }
    let idxInst = lerOpcao(prompt: "Escolha o instrutor:", opcoes: 1...instrutores.count)
    let instrutor = instrutores[idxInst - 1]

    // Filtra horarios ja reservados por este instrutor
    let horariosOcupados = instrutor.reservas.map { "\($0.diaSemana)\($0.horario)" }
    let horariosLivres = horariosDisponiveis.filter {
        !horariosOcupados.contains("\($0.dia)\($0.hora)")
    }

    if horariosLivres.isEmpty {
        print("  \(instrutor.nome) nao possui horarios disponiveis.")
        return
    }

    secao("HORARIOS DISPONÍVEIS")
    for (i, h) in horariosLivres.enumerated() {
        print("  [\(i+1)] \(h.dia) - \(h.hora)")
    }
    let idxHor = lerOpcao(prompt: "Escolha o horario:", opcoes: 1...horariosLivres.count)
    let horario = horariosLivres[idxHor - 1]

    let reserva = ReservaInstrutor(
        id: proximoIdReserva,
        aluno: aluno,
        instrutor: instrutor,
        diaSemana: horario.dia,
        horario: horario.hora)
    proximoIdReserva += 1

    aluno.reservasInstrutor.append(reserva)
    instrutor.reservas.append(reserva)
    todasReservas.append(reserva)

    print("  Reserva confirmada: \(instrutor.nome) | \(horario.dia) \(horario.hora)")
}

func listarAulasDoAluno(_ aluno: Aluno) {
    secao("MINHAS AULAS COLETIVAS")
    guard !aluno.aulasMatriculadas.isEmpty else {
        print("  Voce nao esta matriculado em nenhuma aula coletiva.")
        return
    }
    for (i, m) in aluno.aulasMatriculadas.enumerated() {
        print("  [\(i+1)] \(m)")
    }
    let limite = aluno.plano.limiteAulasColetivas
    let usadas = aluno.aulasMatriculadas.count
    let status = limite == Int.max ? "Ilimitadas" : "\(usadas)/\(limite) usadas"
    print()
    print("  Aulas coletivas: \(status)")
}

func listarReservasDoAluno(_ aluno: Aluno) {
    secao("MINHAS RESERVAS DE INSTRUTOR")
    guard !aluno.reservasInstrutor.isEmpty else {
        print("  Voce nao possui reservas com instrutores.")
        return
    }
    for (i, r) in aluno.reservasInstrutor.enumerated() {
        print("  [\(i+1)] \(r.instrutor.nome) (\(r.instrutor.especialidade)) | \(r.diaSemana) \(r.horario)")
    }
    switch aluno.plano.acessoInstrutor {
    case .limitado(let max):
        print()
        print("  Reservas semanais: \(aluno.reservasNaSemana)/\(max)")
    case .ilimitado:
        print()
        print("  Reservas semanais: ilimitadas")
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
        print("\n  Bem-vindo(a), \(inst.nome)! [Especialidade: \(inst.especialidade)]")
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
        print("  Logado como: \(instrutor.nome)")
        print("  Especialidade: \(instrutor.especialidade)")
        print()
        linha()
        print("  [1]  Ver minhas aulas coletivas")
        print("  [2]  Ver reservas de horario")
        print("  [0]  Voltar ao menu principal")
        print()
        linha("*")

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...2)
        switch opcao {
        case 1: verAulasDoInstrutor(instrutor)
        case 2: verReservasDoInstrutor(instrutor)
        case 0: return
        default: break
        }
        print("\n  Pressione Enter para continuar...")
        _ = readLine()
    }
}

func verAulasDoInstrutor(_ instrutor: Instrutor) {
    secao("MINHAS AULAS COLETIVAS")
    let aulas = aulasColetivas.filter { $0.instrutor.nome == instrutor.nome }
    if aulas.isEmpty {
        print("  Nenhuma aula coletiva registrada.")
        return
    }
    for aula in aulas {
        let status = aula.estaLotada ? "[LOTADA]" : "[\(aula.vagasDisponiveis) vagas livres]"
        print("  \(aula.categoria) | \(aula.diaSemana) \(aula.horario) | \(status)")
    }
}

func verReservasDoInstrutor(_ instrutor: Instrutor) {
    secao("RESERVAS DE HORARIO COMIGO")
    if instrutor.reservas.isEmpty {
        print("  Nenhuma reserva agendada.")
        return
    }
    // Agrupa por dia
    let dias = ["Segunda", "Terca", "Quarta", "Quinta", "Sexta"]
    for dia in dias {
        let reservasDoDia = instrutor.reservas.filter { $0.diaSemana == dia }
        guard !reservasDoDia.isEmpty else { continue }
        print()
        print("  --- \(dia) ---")
        for r in reservasDoDia.sorted(by: { $0.horario < $1.horario }) {
            print("    \(r.horario) | Aluno: \(r.aluno.nome) [\(r.aluno.plano.nome)]")
        }
    }
}

// MARK: - Acoes do menu principal

func listarPlanos() {
    centralizar("PLANOS DISPONIVEIS")
    let normais = CatalogoPlanos.todos.filter { $0.nome.hasPrefix("Normal") }
    let blacks  = CatalogoPlanos.todos.filter { $0.nome.hasPrefix("Black") }

    secao("PLANO NORMAL")
    print("  - Acesso a 2 modalidades a escolha")
    print("  - Instrutor 2x por semana")
    print("  - Ate 8 aulas coletivas por mes")
    print()
    for (i, p) in normais.enumerated() {
        print("  [\(i+1)] \(p.nome) ........ R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }

    secao("PLANO BLACK")
    print("  - Acesso a TODAS as modalidades")
    print("  - Instrutor a qualquer momento")
    print("  - Aulas coletivas ilimitadas")
    print()
    for (i, p) in blacks.enumerated() {
        print("  [\(i+1)] \(p.nome) ......... R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }
    linha()
}

func cadastrarAluno() {
    centralizar("CADASTRAR ALUNO")
    let nome      = lerTexto(prompt: "Nome:")
    let email     = lerTexto(prompt: "Email:")
    let matricula = lerTexto(prompt: "Matricula:")

    secao("NIVEL DE EXPERIENCIA")
    for (i, n) in NivelExperiencia.allCases.enumerated() { print("  [\(i+1)] \(n)") }
    let nivel = NivelExperiencia.allCases[lerOpcao(prompt: "Nivel:", opcoes: 1...NivelExperiencia.allCases.count) - 1]

    secao("PLANO")
    for (i, p) in CatalogoPlanos.todos.enumerated() {
        print("  [\(i+1)] \(p.nome) - R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
    }
    let plano = CatalogoPlanos.todos[lerOpcao(prompt: "Plano:", opcoes: 1...CatalogoPlanos.todos.count) - 1]

    secao("MODALIDADES")
    let modalidades = selecionarModalidades(limite: plano.limiteModalidades)

    alunos.append(Aluno(nome: nome, email: email, matricula: matricula,
                        plano: plano, nivel: nivel, modalidades: modalidades))
    print()
    linha()
    print("  Aluno '\(nome)' cadastrado com sucesso!")
    linha()
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
    gerarAulasParaInstrutor(instrutor)

    print()
    linha()
    print("  Instrutor '\(nome)' cadastrado com sucesso!")
    print("  Aulas coletivas de \(esp) geradas: Seg 08h | Qua 10h | Sex 17h")
    linha()
}

func listarAlunos() {
    centralizar("ALUNOS CADASTRADOS")
    guard !alunos.isEmpty else { print("  Nenhum aluno cadastrado."); return }
    for (i, a) in alunos.enumerated() {
        print("\n  [\(i+1)]")
        a.description.split(separator: "\n").forEach { print("  \($0)") }
        linha()
    }
}

func listarInstrutores() {
    centralizar("INSTRUTORES CADASTRADOS")
    guard !instrutores.isEmpty else { print("  Nenhum instrutor cadastrado."); return }
    for (i, inst) in instrutores.enumerated() {
        print("\n  [\(i+1)]")
        inst.description.split(separator: "\n").forEach { print("  \($0)") }
        linha()
    }
}

func atualizarAluno() {
    centralizar("ATUALIZAR ALUNO")
    guard !alunos.isEmpty else { print("  Nenhum aluno cadastrado."); return }

    for (i, a) in alunos.enumerated() {
        print("  [\(i+1)] \(a.nome)  |  \(a.plano.nome)  |  \(a.nivel)")
    }
    let aluno = alunos[lerOpcao(prompt: "Aluno:", opcoes: 1...alunos.count) - 1]

    secao("O QUE ATUALIZAR?")
    print("  [1] Plano")
    print("  [2] Nivel")
    print("  [3] Ambos")
    let opcao = lerOpcao(prompt: "Opcao:", opcoes: 1...3)

    if opcao == 1 || opcao == 3 {
        secao("NOVO PLANO")
        for (i, p) in CatalogoPlanos.todos.enumerated() {
            print("  [\(i+1)] \(p.nome) - R$ \(String(format: "%.2f", p.valorMensalidade))/mes")
        }
        let novoPlano = CatalogoPlanos.todos[lerOpcao(prompt: "Plano:", opcoes: 1...CatalogoPlanos.todos.count) - 1]
        secao("NOVAS MODALIDADES")
        let novasMods = selecionarModalidades(limite: novoPlano.limiteModalidades)
        aluno.atualizarPlano(novoPlano, novasModalidades: novasMods)
    }

    if opcao == 2 || opcao == 3 {
        secao("NOVO NIVEL")
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
        let pad = max(0, (largura - titulo.count) / 2)
        print(String(repeating: " ", count: pad) + titulo)
        print(String(repeating: "*", count: largura))
        print()
        print("  --- Administracao ---")
        print("  [1]  Listar planos")
        print("  [2]  Cadastrar aluno")
        print("  [3]  Cadastrar instrutor")
        print("  [4]  Listar alunos")
        print("  [5]  Listar instrutores")
        print("  [6]  Atualizar aluno")
        print()
        print("  --- Acesso ---")
        print("  [7]  Area do Aluno")
        print("  [8]  Area do Instrutor")
        print()
        print("  [0]  Sair")
        print()
        print(String(repeating: "*", count: largura))

        let opcao = lerOpcao(prompt: "Escolha:", opcoes: 0...8)

        switch opcao {
        case 1: listarPlanos()
        case 2: cadastrarAluno()
        case 3: cadastrarInstrutor()
        case 4: listarAlunos()
        case 5: listarInstrutores()
        case 6: atualizarAluno()
        case 7:
            if let aluno = loginAluno() { menuAluno(aluno) }
        case 8:
            if let instrutor = loginInstrutor() { menuInstrutor(instrutor) }
        case 0:
            print()
            linha("*")
            print("  Encerrando o sistema. Ate logo!")
            linha("*")
            exit(0)
        default: break
        }

        print("\n  Pressione Enter para voltar ao menu...")
        _ = readLine()
    }
}

menuPrincipal()