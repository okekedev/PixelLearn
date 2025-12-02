import Foundation

// MARK: - Models

struct Question: Codable {
    let id: String
    let subject: String
    let level: Int
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String?
}

struct QuestionBank: Codable {
    let questions: [Question]
}

// MARK: - Math Question Generator

class MathQuestionGenerator {

    func generate(level: Int, count: Int) -> [Question] {
        var questions: [Question] = []

        for _ in 0..<count {
            let question = generateQuestion(level: level)
            questions.append(question)
        }

        return questions
    }

    private func generateQuestion(level: Int) -> Question {
        switch level {
        case 1...5:
            return generateAddition(level: level)
        case 6...10:
            return generateSubtraction(level: level)
        case 11...15:
            return generateMultiplication(level: level)
        case 16...20:
            return generateDivision(level: level)
        case 21...25:
            return generateOrderOfOperations(level: level)
        case 26...30:
            return generateFractions(level: level)
        case 31...35:
            return generateDecimals(level: level)
        case 36...40:
            return generatePercentages(level: level)
        case 41...45:
            return generateLinearEquations(level: level)
        case 46...50:
            return generateQuadratics(level: level)
        case 51...55:
            return generateGeometry(level: level)
        case 56...58:
            return generateTrigonometry(level: level)
        case 59...62:
            return generateDerivatives(level: level)
        case 63...64:
            return generateIntegrals(level: level)
        default:
            return generateMultivariable(level: level)
        }
    }

    private func generateAddition(level: Int) -> Question {
        let maxNum = 5 + level * 3
        let a = Int.random(in: 1...maxNum)
        let b = Int.random(in: 1...maxNum)
        let answer = a + b

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(a) + \(b)?",
            options: generateOptions(correct: answer, range: 1...5),
            correctIndex: 0,
            explanation: "\(a) + \(b) = \(answer)"
        )
    }

    private func generateSubtraction(level: Int) -> Question {
        let maxNum = 10 + (level - 5) * 5
        let a = Int.random(in: 10...maxNum)
        let b = Int.random(in: 1..<a)
        let answer = a - b

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(a) - \(b)?",
            options: generateOptions(correct: answer, range: 1...5),
            correctIndex: 0,
            explanation: "\(a) - \(b) = \(answer)"
        )
    }

    private func generateMultiplication(level: Int) -> Question {
        let maxNum = 5 + (level - 10) * 2
        let a = Int.random(in: 2...min(12, maxNum))
        let b = Int.random(in: 2...min(12, maxNum))
        let answer = a * b

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(a) × \(b)?",
            options: generateOptions(correct: answer, range: 2...10),
            correctIndex: 0,
            explanation: "\(a) × \(b) = \(answer)"
        )
    }

    private func generateDivision(level: Int) -> Question {
        let b = Int.random(in: 2...12)
        let answer = Int.random(in: 2...12)
        let a = b * answer

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(a) ÷ \(b)?",
            options: generateOptions(correct: answer, range: 1...3),
            correctIndex: 0,
            explanation: "\(a) ÷ \(b) = \(answer)"
        )
    }

    private func generateOrderOfOperations(level: Int) -> Question {
        let a = Int.random(in: 2...10)
        let b = Int.random(in: 2...5)
        let c = Int.random(in: 1...10)

        let patterns: [(String, Int)] = [
            ("\(a) + \(b) × \(c)", a + b * c),
            ("\(a) × \(b) + \(c)", a * b + c),
            ("(\(a) + \(b)) × \(c)", (a + b) * c),
            ("\(a) × (\(b) + \(c))", a * (b + c))
        ]

        let (text, answer) = patterns.randomElement()!

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(text)?",
            options: generateOptions(correct: answer, range: 5...20),
            correctIndex: 0,
            explanation: "Following order of operations (PEMDAS): \(text) = \(answer)"
        )
    }

    private func generateFractions(level: Int) -> Question {
        let denominators = [2, 3, 4, 5, 6, 8, 10]
        let d1 = denominators.randomElement()!
        let d2 = denominators.randomElement()!
        let n1 = Int.random(in: 1..<d1)
        let n2 = Int.random(in: 1..<d2)

        let lcd = lcm(d1, d2)
        let sum = (n1 * (lcd / d1)) + (n2 * (lcd / d2))
        let gcdResult = gcd(sum, lcd)
        let simplifiedNum = sum / gcdResult
        let simplifiedDen = lcd / gcdResult

        let correctAnswer = simplifiedDen == 1 ? "\(simplifiedNum)" : "\(simplifiedNum)/\(simplifiedDen)"

        var options = [correctAnswer]
        options.append("\((n1 + n2))/\(d1 + d2)")
        options.append("\((n1 * n2))/\(d1 * d2)")
        options.append("\(sum)/\(lcd)")
        options = Array(Set(options))
        while options.count < 4 {
            options.append("\(Int.random(in: 1...10))/\(Int.random(in: 2...12))")
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: correctAnswer) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(n1)/\(d1) + \(n2)/\(d2)?",
            options: Array(options.prefix(4)),
            correctIndex: correctIndex,
            explanation: "Find common denominator \(lcd), then add: \(n1)/\(d1) + \(n2)/\(d2) = \(correctAnswer)"
        )
    }

    private func generateDecimals(level: Int) -> Question {
        let a = Double.random(in: 1.0...10.0).rounded(toPlaces: 1)
        let b = Double.random(in: 1.0...10.0).rounded(toPlaces: 1)
        let answer = (a + b).rounded(toPlaces: 1)

        var options = [String(format: "%.1f", answer)]
        options.append(String(format: "%.1f", answer + 0.1))
        options.append(String(format: "%.1f", answer - 0.1))
        options.append(String(format: "%.1f", answer + 1.0))
        options.shuffle()
        let correctIndex = options.firstIndex(of: String(format: "%.1f", answer)) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(String(format: "%.1f", a)) + \(String(format: "%.1f", b))?",
            options: options,
            correctIndex: correctIndex,
            explanation: "\(String(format: "%.1f", a)) + \(String(format: "%.1f", b)) = \(String(format: "%.1f", answer))"
        )
    }

    private func generatePercentages(level: Int) -> Question {
        let percentages = [10, 20, 25, 50, 75, 100]
        let percent = percentages.randomElement()!
        let base = Int.random(in: 2...20) * 10
        let answer = base * percent / 100

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(percent)% of \(base)?",
            options: generateOptions(correct: answer, range: 5...20),
            correctIndex: 0,
            explanation: "\(percent)% of \(base) = \(base) × \(percent)/100 = \(answer)"
        )
    }

    private func generateLinearEquations(level: Int) -> Question {
        let a = Int.random(in: 2...10)
        let x = Int.random(in: 1...10)
        let b = Int.random(in: 1...20)
        let result = a * x + b

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "Solve for x: \(a)x + \(b) = \(result)",
            options: generateOptions(correct: x, range: 1...3),
            correctIndex: 0,
            explanation: "x = (\(result) - \(b)) / \(a) = \(x)"
        )
    }

    private func generateQuadratics(level: Int) -> Question {
        let r1 = Int.random(in: 1...5)
        let r2 = Int.random(in: 1...5)
        let a = 1
        let b = -(r1 + r2)
        let c = r1 * r2

        let bSign = b >= 0 ? "+" : "-"
        let cSign = c >= 0 ? "+" : "-"

        let correctAnswer = "x = \(r1) or x = \(r2)"
        var options = [correctAnswer]
        options.append("x = \(-r1) or x = \(-r2)")
        options.append("x = \(r1 + 1) or x = \(r2 + 1)")
        options.append("x = \(r1 * 2) or x = \(r2 * 2)")
        options.shuffle()
        let correctIndex = options.firstIndex(of: correctAnswer) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "Solve: x² \(bSign) \(abs(b))x \(cSign) \(abs(c)) = 0",
            options: options,
            correctIndex: correctIndex,
            explanation: "Factor: (x - \(r1))(x - \(r2)) = 0, so \(correctAnswer)"
        )
    }

    private func generateGeometry(level: Int) -> Question {
        let shapes = ["rectangle", "triangle", "circle"]
        let shape = shapes.randomElement()!

        switch shape {
        case "rectangle":
            let l = Int.random(in: 3...12)
            let w = Int.random(in: 3...12)
            let area = l * w
            return Question(
                id: UUID().uuidString,
                subject: "Math",
                level: level,
                text: "Find the area of a rectangle with length \(l) and width \(w).",
                options: generateOptions(correct: area, range: 5...15),
                correctIndex: 0,
                explanation: "Area = length × width = \(l) × \(w) = \(area)"
            )
        case "triangle":
            let b = Int.random(in: 4...12)
            let h = Int.random(in: 4...12)
            let area = (b * h) / 2
            return Question(
                id: UUID().uuidString,
                subject: "Math",
                level: level,
                text: "Find the area of a triangle with base \(b) and height \(h).",
                options: generateOptions(correct: area, range: 3...10),
                correctIndex: 0,
                explanation: "Area = (1/2) × base × height = (1/2) × \(b) × \(h) = \(area)"
            )
        default:
            let r = Int.random(in: 2...7)
            let area = Double.pi * Double(r * r)
            let roundedArea = Int(area.rounded())
            return Question(
                id: UUID().uuidString,
                subject: "Math",
                level: level,
                text: "Find the approximate area of a circle with radius \(r). (Use π ≈ 3.14)",
                options: generateOptions(correct: roundedArea, range: 5...15),
                correctIndex: 0,
                explanation: "Area = πr² = π × \(r)² ≈ \(roundedArea)"
            )
        }
    }

    private func generateTrigonometry(level: Int) -> Question {
        let angles = [0, 30, 45, 60, 90]
        let angle = angles.randomElement()!
        let functions = ["sin", "cos", "tan"]
        let function = functions.randomElement()!

        let values: [String: [Int: String]] = [
            "sin": [0: "0", 30: "1/2", 45: "√2/2", 60: "√3/2", 90: "1"],
            "cos": [0: "1", 30: "√3/2", 45: "√2/2", 60: "1/2", 90: "0"],
            "tan": [0: "0", 30: "√3/3", 45: "1", 60: "√3", 90: "undefined"]
        ]

        let correctAnswer = values[function]![angle]!
        let allValues = ["0", "1/2", "√2/2", "√3/2", "1", "√3/3", "√3", "undefined", "2", "-1"]
        var options = [correctAnswer]
        for val in allValues.shuffled() {
            if !options.contains(val) && options.count < 4 {
                options.append(val)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: correctAnswer) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "What is \(function)(\(angle)°)?",
            options: options,
            correctIndex: correctIndex,
            explanation: "\(function)(\(angle)°) = \(correctAnswer)"
        )
    }

    private func generateDerivatives(level: Int) -> Question {
        let n = Int.random(in: 2...6)
        let coef = Int.random(in: 1...5)

        let patterns: [(question: String, answer: String, explanation: String)] = [
            ("d/dx[\(coef)x^\(n)]", "\(coef * n)x^\(n-1)", "Power rule: d/dx[ax^n] = anx^(n-1)"),
            ("d/dx[x^\(n) + \(coef)x]", "\(n)x^\(n-1) + \(coef)", "Sum rule: differentiate each term"),
            ("d/dx[e^x]", "e^x", "The derivative of e^x is itself"),
            ("d/dx[sin(x)]", "cos(x)", "The derivative of sin(x) is cos(x)"),
            ("d/dx[cos(x)]", "-sin(x)", "The derivative of cos(x) is -sin(x)"),
            ("d/dx[ln(x)]", "1/x", "The derivative of ln(x) is 1/x")
        ]

        let (question, answer, explanation) = patterns.randomElement()!

        var options = [answer]
        let wrongOptions = ["\(n)x^\(n)", "x^\(n+1)", "\(coef)x^\(n)", "x^\(n-1)", "sin(x)", "-cos(x)", "e^x", "x"]
        for opt in wrongOptions.shuffled() {
            if !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: answer) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "Find \(question)",
            options: options,
            correctIndex: correctIndex,
            explanation: explanation
        )
    }

    private func generateIntegrals(level: Int) -> Question {
        let n = Int.random(in: 1...5)
        let coef = Int.random(in: 1...4)

        let patterns: [(question: String, answer: String, explanation: String)] = [
            ("∫x^\(n) dx", "x^\(n+1)/\(n+1) + C", "Power rule: ∫x^n dx = x^(n+1)/(n+1) + C"),
            ("∫\(coef)x dx", "\(coef)x²/2 + C", "∫ax dx = ax²/2 + C"),
            ("∫e^x dx", "e^x + C", "∫e^x dx = e^x + C"),
            ("∫cos(x) dx", "sin(x) + C", "∫cos(x) dx = sin(x) + C"),
            ("∫sin(x) dx", "-cos(x) + C", "∫sin(x) dx = -cos(x) + C"),
            ("∫1/x dx", "ln|x| + C", "∫1/x dx = ln|x| + C")
        ]

        let (question, answer, explanation) = patterns.randomElement()!

        var options = [answer]
        let wrongOptions = ["x^\(n+2)/\(n+2) + C", "\(n)x^\(n-1) + C", "x^\(n) + C", "e^x", "cos(x) + C", "sin(x)", "ln(x)"]
        for opt in wrongOptions.shuffled() {
            if !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: answer) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "Evaluate \(question)",
            options: options,
            correctIndex: correctIndex,
            explanation: explanation
        )
    }

    private func generateMultivariable(level: Int) -> Question {
        let patterns: [(question: String, answer: String, explanation: String)] = [
            ("∂/∂x[x²y + xy²]", "2xy + y²", "Partial derivative: treat y as constant"),
            ("∂/∂y[x²y + xy²]", "x² + 2xy", "Partial derivative: treat x as constant"),
            ("∂/∂x[x³ + 3x²y + y³]", "3x² + 6xy", "Partial derivative with respect to x"),
            ("∂/∂y[x³ + 3x²y + y³]", "3x² + 3y²", "Partial derivative with respect to y"),
            ("∇f where f = x² + y²", "(2x, 2y)", "Gradient: (∂f/∂x, ∂f/∂y)"),
            ("∂²/∂x²[x³y²]", "6xy²", "Second partial derivative")
        ]

        let (question, answer, explanation) = patterns.randomElement()!

        var options = [answer]
        let wrongOptions = ["x² + y²", "2x + 2y", "xy", "x²y²", "(2x, 2y)", "3x² + 2y", "6x²y"]
        for opt in wrongOptions.shuffled() {
            if !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: answer) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Math",
            level: level,
            text: "Find \(question)",
            options: options,
            correctIndex: correctIndex,
            explanation: explanation
        )
    }

    private func generateOptions(correct: Int, range: ClosedRange<Int>) -> [String] {
        var options = [String(correct)]
        var attempts = 0
        while options.count < 4 && attempts < 20 {
            let offset = Int.random(in: range) * (Bool.random() ? 1 : -1)
            let wrong = max(0, correct + offset)
            let wrongStr = String(wrong)
            if !options.contains(wrongStr) {
                options.append(wrongStr)
            }
            attempts += 1
        }
        while options.count < 4 {
            options.append(String(Int.random(in: 1...100)))
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: String(correct)) ?? 0

        var reordered = options
        reordered.remove(at: correctIndex)
        reordered.insert(String(correct), at: 0)
        return reordered
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    private func lcm(_ a: Int, _ b: Int) -> Int {
        (a * b) / gcd(a, b)
    }
}

// MARK: - Grammar Question Generator

class GrammarQuestionGenerator {

    private let grammarRules: [(level: ClosedRange<Int>, rules: [(question: String, options: [String], correct: Int, explanation: String)])] = [
        // Levels 1-10: Basic homophones
        (1...10, [
            ("Which is correct?", ["Their going to the store.", "They're going to the store.", "There going to the store.", "Thier going to the store."], 1, "'They're' is the contraction of 'they are'."),
            ("Choose the correct sentence:", ["Your the best player!", "You're the best player!", "Youre the best player!", "Your' the best player!"], 1, "'You're' is the contraction of 'you are'."),
            ("Which is grammatically correct?", ["Its a beautiful day.", "It's a beautiful day.", "Its' a beautiful day.", "Its's a beautiful day."], 1, "'It's' is the contraction of 'it is'."),
            ("Select the correct form:", ["The dog wagged it's tail.", "The dog wagged its tail.", "The dog wagged its' tail.", "The dog wagged it is tail."], 1, "'Its' (no apostrophe) shows possession."),
            ("Which sentence is correct?", ["I want to go their.", "I want to go there.", "I want to go they're.", "I want to go thier."], 1, "'There' refers to a place."),
        ]),
        // Levels 11-20: Subject-verb agreement
        (11...20, [
            ("Which is correct?", ["The team are playing well.", "The team is playing well.", "The team be playing well.", "The team were playing well."], 1, "Collective nouns like 'team' take singular verbs in American English."),
            ("Select the correct sentence:", ["Everyone have their own opinion.", "Everyone has their own opinion.", "Everyone has his own opinion.", "Everyone have his own opinion."], 1, "'Everyone' is singular and takes 'has'."),
            ("Which is grammatically correct?", ["Neither of the books are interesting.", "Neither of the books is interesting.", "Neither of the books were interesting.", "Neither of the books be interesting."], 1, "'Neither' is singular and takes 'is'."),
            ("Choose the correct form:", ["The news are surprising.", "The news is surprising.", "The news were surprising.", "The news be surprising."], 1, "'News' is uncountable and takes a singular verb."),
            ("Which sentence is correct?", ["Mathematics are my favorite subject.", "Mathematics is my favorite subject.", "Mathematics were my favorite subject.", "Mathematic is my favorite subject."], 1, "Subjects ending in -ics take singular verbs."),
        ]),
        // Levels 21-30: Pronoun cases
        (21...30, [
            ("Which is correct?", ["Me and him went to the park.", "Him and I went to the park.", "He and I went to the park.", "He and me went to the park."], 2, "Use 'I' as a subject. 'He and I' is correct for the subject position."),
            ("Select the correct sentence:", ["Between you and I, this is wrong.", "Between you and me, this is wrong.", "Between I and you, this is wrong.", "Between me and you, this is wrong."], 1, "After prepositions, use object pronouns: 'you and me'."),
            ("Which is grammatically correct?", ["Give the book to John and I.", "Give the book to John and me.", "Give the book to I and John.", "Give the book to me and John."], 1, "After 'to', use object pronouns: 'John and me'."),
            ("Choose the correct form:", ["Us students need more time.", "We students need more time.", "Ourselves students need more time.", "Our students need more time."], 1, "'We' is the subject pronoun before 'students'."),
            ("Which sentence is correct?", ["Whom is calling?", "Who is calling?", "Whose is calling?", "Who's is calling?"], 1, "'Who' is used for subjects; 'whom' for objects."),
        ]),
        // Levels 31-40: Commonly confused words
        (31...40, [
            ("Which is correct?", ["I could of done better.", "I could have done better.", "I could off done better.", "I could've of done better."], 1, "'Could have' (could've) is correct, not 'could of'."),
            ("Select the correct sentence:", ["The effect was immediate.", "The affect was immediate.", "The affection was immediate.", "The effection was immediate."], 0, "'Effect' is usually a noun; 'affect' is usually a verb."),
            ("Which is grammatically correct?", ["Lay down and rest.", "Lie down and rest.", "Laid down and rest.", "Lied down and rest."], 1, "'Lie' means to recline; 'lay' requires an object."),
            ("Choose the correct form:", ["I accept your apology.", "I except your apology.", "I expect your apology.", "I excerpt your apology."], 0, "'Accept' means to receive; 'except' means to exclude."),
            ("Which sentence is correct?", ["The principle of the school spoke.", "The principal of the school spoke.", "The principel of the school spoke.", "The princpal of the school spoke."], 1, "'Principal' is a person; 'principle' is a rule or belief."),
        ]),
        // Levels 41-50: Advanced grammar
        (41...50, [
            ("Which is correct?", ["If I was rich, I would travel.", "If I were rich, I would travel.", "If I am rich, I would travel.", "If I be rich, I would travel."], 1, "Subjunctive mood uses 'were' for hypotheticals."),
            ("Select the correct sentence:", ["I wish I was there.", "I wish I were there.", "I wish I am there.", "I wish I be there."], 1, "Subjunctive 'were' is used after 'wish'."),
            ("Which is grammatically correct?", ["The data shows improvement.", "The data show improvement.", "The datas show improvement.", "The datum shows improvement."], 1, "'Data' is plural (though singular usage is becoming accepted)."),
            ("Choose the correct form:", ["Less people came today.", "Fewer people came today.", "Lesser people came today.", "Few people came today."], 1, "'Fewer' for countable nouns; 'less' for uncountable."),
            ("Which sentence is correct?", ["This is the most unique design.", "This is a unique design.", "This is more unique design.", "This is uniquer design."], 1, "'Unique' is absolute and shouldn't be modified with 'most'."),
        ]),
        // Levels 51-65: Expert level
        (51...65, [
            ("Which is correct?", ["The committee have reached their decision.", "The committee has reached its decision.", "The committee have reached its decision.", "The committee has reached their decision."], 1, "In American English, collective nouns are singular."),
            ("Select the correct sentence:", ["Who's book is this?", "Whose book is this?", "Whos book is this?", "Whom's book is this?"], 1, "'Whose' shows possession; 'who's' means 'who is'."),
            ("Which demonstrates correct parallelism?", ["She likes hiking, to swim, and biking.", "She likes hiking, swimming, and biking.", "She likes to hike, swimming, and to bike.", "She likes hike, swim, and bike."], 1, "Parallel structure: use the same grammatical form."),
            ("Choose the correct form:", ["Due to the rain, the game was cancelled.", "Because of the rain, the game was cancelled.", "Due to rain, the game was cancelled.", "Dues to the rain, the game was cancelled."], 1, "'Because of' is preferred over 'due to' at the start of a sentence."),
            ("Which sentence is correct?", ["The reason is because he was late.", "The reason is that he was late.", "The reason is since he was late.", "The reason is for he was late."], 1, "'The reason is that' is correct; 'because' is redundant."),
        ])
    ]

    func generate(level: Int, count: Int) -> [Question] {
        var questions: [Question] = []

        let applicableRules = grammarRules.filter { $0.level.contains(level) }
        guard let ruleSet = applicableRules.first else {
            return questions
        }

        for i in 0..<count {
            let rule = ruleSet.rules[i % ruleSet.rules.count]
            var options = rule.options
            options.shuffle()
            let correctAnswer = rule.options[rule.correct]
            let newCorrectIndex = options.firstIndex(of: correctAnswer) ?? 0

            let question = Question(
                id: UUID().uuidString,
                subject: "Grammar",
                level: level,
                text: rule.question,
                options: options,
                correctIndex: newCorrectIndex,
                explanation: rule.explanation
            )
            questions.append(question)
        }

        return questions
    }
}

// MARK: - Memory Question Generator

class MemoryQuestionGenerator {

    func generate(level: Int, count: Int) -> [Question] {
        var questions: [Question] = []

        for _ in 0..<count {
            let question = generateQuestion(level: level)
            questions.append(question)
        }

        return questions
    }

    private func generateQuestion(level: Int) -> Question {
        let types = ["number", "letter", "shape", "color", "pattern"]
        let type = types.randomElement()!

        switch type {
        case "number":
            return generateNumberSequence(level: level)
        case "letter":
            return generateLetterSequence(level: level)
        case "shape":
            return generateShapePattern(level: level)
        case "color":
            return generateColorSequence(level: level)
        default:
            return generateMathPattern(level: level)
        }
    }

    private func generateNumberSequence(level: Int) -> Question {
        let length = min(3 + level / 10, 10)
        let sequence = (0..<length).map { _ in Int.random(in: 1...9) }
        let sequenceStr = sequence.map(String.init).joined(separator: " - ")
        let answerStr = sequence.map(String.init).joined(separator: "")

        var options = [answerStr]
        while options.count < 4 {
            var wrongSeq = sequence
            let changeIndex = Int.random(in: 0..<length)
            wrongSeq[changeIndex] = Int.random(in: 1...9)
            let wrongStr = wrongSeq.map(String.init).joined(separator: "")
            if !options.contains(wrongStr) {
                options.append(wrongStr)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: answerStr) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Memory",
            level: level,
            text: "Remember this sequence: \(sequenceStr)\n\nWhat was the sequence?",
            options: options,
            correctIndex: correctIndex,
            explanation: "The correct sequence was: \(sequenceStr)"
        )
    }

    private func generateLetterSequence(level: Int) -> Question {
        let length = min(3 + level / 12, 8)
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let sequence = (0..<length).map { _ in String(letters.randomElement()!) }
        let sequenceStr = sequence.joined(separator: " - ")
        let answerStr = sequence.joined(separator: "")

        var options = [answerStr]
        while options.count < 4 {
            var wrongSeq = sequence
            let changeIndex = Int.random(in: 0..<length)
            wrongSeq[changeIndex] = String(letters.randomElement()!)
            let wrongStr = wrongSeq.joined(separator: "")
            if !options.contains(wrongStr) {
                options.append(wrongStr)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: answerStr) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Memory",
            level: level,
            text: "Remember these letters: \(sequenceStr)\n\nWhat was the sequence?",
            options: options,
            correctIndex: correctIndex,
            explanation: "The correct sequence was: \(sequenceStr)"
        )
    }

    private func generateShapePattern(level: Int) -> Question {
        let shapes = ["Circle", "Square", "Triangle", "Star", "Diamond", "Heart"]
        let length = min(3 + level / 15, 6)
        let sequence = (0..<length).map { _ in shapes.randomElement()! }
        let sequenceStr = sequence.joined(separator: ", ")

        var options = [sequenceStr]
        while options.count < 4 {
            var wrongSeq = sequence
            let changeIndex = Int.random(in: 0..<length)
            wrongSeq[changeIndex] = shapes.randomElement()!
            let wrongStr = wrongSeq.joined(separator: ", ")
            if !options.contains(wrongStr) {
                options.append(wrongStr)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: sequenceStr) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Memory",
            level: level,
            text: "Remember these shapes: \(sequenceStr)\n\nWhat was the pattern?",
            options: options,
            correctIndex: correctIndex,
            explanation: "The correct pattern was: \(sequenceStr)"
        )
    }

    private func generateColorSequence(level: Int) -> Question {
        let colors = ["Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Pink", "Brown"]
        let length = min(3 + level / 13, 7)
        let sequence = (0..<length).map { _ in colors.randomElement()! }
        let sequenceStr = sequence.joined(separator: ", ")

        var options = [sequenceStr]
        while options.count < 4 {
            var wrongSeq = sequence
            let changeIndex = Int.random(in: 0..<length)
            wrongSeq[changeIndex] = colors.randomElement()!
            let wrongStr = wrongSeq.joined(separator: ", ")
            if !options.contains(wrongStr) {
                options.append(wrongStr)
            }
        }
        options.shuffle()
        let correctIndex = options.firstIndex(of: sequenceStr) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Memory",
            level: level,
            text: "Remember these colors: \(sequenceStr)\n\nWhat was the sequence?",
            options: options,
            correctIndex: correctIndex,
            explanation: "The correct sequence was: \(sequenceStr)"
        )
    }

    private func generateMathPattern(level: Int) -> Question {
        let start = Int.random(in: 1...10)
        let increment = Int.random(in: 1...5)
        let length = min(4 + level / 20, 8)

        let sequence = (0..<length).map { start + $0 * increment }
        let sequenceStr = sequence.dropLast().map(String.init).joined(separator: ", ") + ", ?"
        let answer = sequence.last!

        var options = [String(answer)]
        options.append(String(answer + increment))
        options.append(String(answer - 1))
        options.append(String(answer + 2))
        options.shuffle()
        let correctIndex = options.firstIndex(of: String(answer)) ?? 0

        return Question(
            id: UUID().uuidString,
            subject: "Memory",
            level: level,
            text: "What comes next in the pattern?\n\(sequenceStr)",
            options: options,
            correctIndex: correctIndex,
            explanation: "The pattern increases by \(increment) each time. Next number: \(answer)"
        )
    }
}

// MARK: - Helper Extensions

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Main Generator

func generateAllQuestions() {
    let mathGenerator = MathQuestionGenerator()
    let grammarGenerator = GrammarQuestionGenerator()
    let memoryGenerator = MemoryQuestionGenerator()

    let questionsPerLevel = 100
    let levels = 1...65

    print("Generating questions...")
    print("Levels: \(levels.lowerBound) to \(levels.upperBound)")
    print("Questions per level: \(questionsPerLevel)")
    print("Total questions per subject: \(levels.count * questionsPerLevel)")
    print("Total questions: \(levels.count * questionsPerLevel * 3)")
    print("")

    // Generate Math questions
    print("Generating Math questions...")
    var mathQuestions: [Question] = []
    for level in levels {
        let questions = mathGenerator.generate(level: level, count: questionsPerLevel)
        mathQuestions.append(contentsOf: questions)
        if level % 10 == 0 {
            print("  Level \(level) complete...")
        }
    }

    // Generate Grammar questions
    print("Generating Grammar questions...")
    var grammarQuestions: [Question] = []
    for level in levels {
        let questions = grammarGenerator.generate(level: level, count: questionsPerLevel)
        grammarQuestions.append(contentsOf: questions)
        if level % 10 == 0 {
            print("  Level \(level) complete...")
        }
    }

    // Generate Memory questions
    print("Generating Memory questions...")
    var memoryQuestions: [Question] = []
    for level in levels {
        let questions = memoryGenerator.generate(level: level, count: questionsPerLevel)
        memoryQuestions.append(contentsOf: questions)
        if level % 10 == 0 {
            print("  Level \(level) complete...")
        }
    }

    // Save to JSON files
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let outputDir = FileManager.default.currentDirectoryPath + "/../PixelLearn/Resources/Questions"

    do {
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

        // Math
        let mathBank = QuestionBank(questions: mathQuestions)
        let mathData = try encoder.encode(mathBank)
        let mathPath = outputDir + "/math_questions.json"
        try mathData.write(to: URL(fileURLWithPath: mathPath))
        print("\nSaved \(mathQuestions.count) math questions to \(mathPath)")

        // Grammar
        let grammarBank = QuestionBank(questions: grammarQuestions)
        let grammarData = try encoder.encode(grammarBank)
        let grammarPath = outputDir + "/grammar_questions.json"
        try grammarData.write(to: URL(fileURLWithPath: grammarPath))
        print("Saved \(grammarQuestions.count) grammar questions to \(grammarPath)")

        // Memory
        let memoryBank = QuestionBank(questions: memoryQuestions)
        let memoryData = try encoder.encode(memoryBank)
        let memoryPath = outputDir + "/memory_questions.json"
        try memoryData.write(to: URL(fileURLWithPath: memoryPath))
        print("Saved \(memoryQuestions.count) memory questions to \(memoryPath)")

        print("\nTotal questions generated: \(mathQuestions.count + grammarQuestions.count + memoryQuestions.count)")
        print("Done!")

    } catch {
        print("Error saving files: \(error)")
    }
}

// Run the generator
generateAllQuestions()
