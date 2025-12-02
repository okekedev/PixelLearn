import Foundation

actor QuestionBankService {
    static let shared = QuestionBankService()

    private var mathQuestions: [Int: [Question]] = [:]
    private var grammarQuestions: [Int: [Question]] = [:]
    private var usedQuestionIds: Set<UUID> = []

    private init() {}

    func getRandomQuestion(for subject: Subject, level: Int) async -> Question {
        ensureQuestionsLoaded(for: subject, level: level)

        let questions: [Question]

        switch subject {
        case .math:
            questions = mathQuestions[level] ?? []
        case .grammar:
            questions = grammarQuestions[level] ?? []
        case .memory:
            return generateFallbackQuestion(for: subject, level: level)
        }

        let unused = questions.filter { !usedQuestionIds.contains($0.id) }

        if let question = unused.randomElement() {
            usedQuestionIds.insert(question.id)
            return question
        }

        if let question = questions.randomElement() {
            return question
        }

        return generateFallbackQuestion(for: subject, level: level)
    }

    private func ensureQuestionsLoaded(for subject: Subject, level: Int) {
        switch subject {
        case .math:
            if mathQuestions[level] == nil {
                mathQuestions[level] = generateMathQuestionsForLevel(level)
            }
        case .grammar:
            if grammarQuestions[level] == nil {
                grammarQuestions[level] = generateGrammarQuestionsForLevel(level)
            }
        case .memory:
            break
        }
    }

    func resetUsedQuestions() {
        usedQuestionIds.removeAll()
    }

    // MARK: - Math Questions

    private func generateMathQuestionsForLevel(_ level: Int) -> [Question] {
        var questions: [Question] = []

        switch level {
        case 1...5:
            questions = generateAdditionQuestions(level: level)
        case 6...10:
            questions = generateSubtractionQuestions(level: level)
        case 11...15:
            questions = generateMultiplicationQuestions(level: level)
        case 16...20:
            questions = generateDivisionQuestions(level: level)
        case 21...25:
            questions = generateOrderOfOpsQuestions(level: level)
        case 26...30:
            questions = generateFractionQuestions(level: level)
        case 31...35:
            questions = generateDecimalQuestions(level: level)
        case 36...40:
            questions = generatePercentageQuestions(level: level)
        case 41...45:
            questions = generateLinearEquationQuestions(level: level)
        case 46...50:
            questions = generateQuadraticQuestions(level: level)
        case 51...55:
            questions = generateGeometryQuestions(level: level)
        case 56...58:
            questions = generateTrigQuestions(level: level)
        case 59...62:
            questions = generateDerivativeQuestions(level: level)
        case 63...64:
            questions = generateIntegralQuestions(level: level)
        default:
            questions = generateMultivariableQuestions(level: level)
        }

        return questions
    }

    private func generateAdditionQuestions(level: Int) -> [Question] {
        let maxNum = 5 + level * 4
        var questions: [Question] = []
        var usedPairs: Set<String> = []

        for a in 1...maxNum {
            for b in 1...maxNum where a <= b {
                let key = "\(a)+\(b)"
                guard !usedPairs.contains(key) else { continue }
                usedPairs.insert(key)

                let answer = a + b
                let options = generateUniqueOptions(correct: answer, variance: 3)

                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(a) + \(b)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                    explanation: "\(a) + \(b) = \(answer)"
                ))

                if questions.count >= 15 { return questions }
            }
        }
        return questions
    }

    private func generateSubtractionQuestions(level: Int) -> [Question] {
        let maxNum = 10 + (level - 5) * 5
        var questions: [Question] = []
        var usedPairs: Set<String> = []

        for a in 5...maxNum {
            for b in 1..<a {
                let key = "\(a)-\(b)"
                guard !usedPairs.contains(key) else { continue }
                usedPairs.insert(key)

                let answer = a - b
                let options = generateUniqueOptions(correct: answer, variance: 4)

                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(a) - \(b)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                    explanation: "\(a) - \(b) = \(answer)"
                ))

                if questions.count >= 15 { return questions }
            }
        }
        return questions
    }

    private func generateMultiplicationQuestions(level: Int) -> [Question] {
        let maxNum = 6 + (level - 10) * 2
        var questions: [Question] = []
        var usedPairs: Set<String> = []

        for a in 2...min(12, maxNum) {
            for b in 2...min(12, maxNum) where a <= b {
                let key = "\(a)x\(b)"
                guard !usedPairs.contains(key) else { continue }
                usedPairs.insert(key)

                let answer = a * b
                let options = generateUniqueOptions(correct: answer, variance: 6)

                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(a) × \(b)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                    explanation: "\(a) × \(b) = \(answer)"
                ))

                if questions.count >= 15 { return questions }
            }
        }
        return questions
    }

    private func generateDivisionQuestions(level: Int) -> [Question] {
        var questions: [Question] = []
        var usedPairs: Set<String> = []

        for divisor in 2...12 {
            for quotient in 2...12 {
                let dividend = divisor * quotient
                let key = "\(dividend)/\(divisor)"
                guard !usedPairs.contains(key) else { continue }
                usedPairs.insert(key)

                let options = generateUniqueOptions(correct: quotient, variance: 3)

                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(dividend) ÷ \(divisor)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(quotient)) ?? 0,
                    explanation: "\(dividend) ÷ \(divisor) = \(quotient)"
                ))

                if questions.count >= 15 { return questions }
            }
        }
        return questions
    }

    private func generateOrderOfOpsQuestions(level: Int) -> [Question] {
        let expressions: [(text: String, answer: Int, explanation: String)] = [
            ("2 + 3 × 4", 14, "Multiply first: 3 × 4 = 12, then add: 2 + 12 = 14"),
            ("5 × 2 + 3", 13, "Multiply first: 5 × 2 = 10, then add: 10 + 3 = 13"),
            ("(2 + 3) × 4", 20, "Parentheses first: 2 + 3 = 5, then multiply: 5 × 4 = 20"),
            ("10 - 2 × 3", 4, "Multiply first: 2 × 3 = 6, then subtract: 10 - 6 = 4"),
            ("(8 - 3) × 2", 10, "Parentheses first: 8 - 3 = 5, then multiply: 5 × 2 = 10"),
            ("6 + 8 ÷ 2", 10, "Divide first: 8 ÷ 2 = 4, then add: 6 + 4 = 10"),
            ("12 ÷ 4 + 5", 8, "Divide first: 12 ÷ 4 = 3, then add: 3 + 5 = 8"),
            ("(6 + 6) ÷ 3", 4, "Parentheses first: 6 + 6 = 12, then divide: 12 ÷ 3 = 4"),
            ("3 × 4 - 2 × 5", 2, "Multiply: 3 × 4 = 12, 2 × 5 = 10, then subtract: 12 - 10 = 2"),
            ("2 × (5 + 3)", 16, "Parentheses first: 5 + 3 = 8, then multiply: 2 × 8 = 16"),
            ("15 - 3 × 4", 3, "Multiply first: 3 × 4 = 12, then subtract: 15 - 12 = 3"),
            ("(10 - 4) × 3", 18, "Parentheses first: 10 - 4 = 6, then multiply: 6 × 3 = 18"),
            ("4 + 6 × 2 - 3", 13, "Multiply first: 6 × 2 = 12, then: 4 + 12 - 3 = 13"),
            ("20 ÷ (2 + 3)", 4, "Parentheses first: 2 + 3 = 5, then divide: 20 ÷ 5 = 4"),
            ("8 × 2 - 4 × 3", 4, "Multiply: 8 × 2 = 16, 4 × 3 = 12, then: 16 - 12 = 4")
        ]

        return expressions.prefix(15).map { expr in
            let options = generateUniqueOptions(correct: expr.answer, variance: 5)
            return Question(
                subject: .math,
                level: level,
                text: "What is \(expr.text)?",
                options: options,
                correctIndex: options.firstIndex(of: String(expr.answer)) ?? 0,
                explanation: expr.explanation
            )
        }
    }

    private func generateFractionQuestions(level: Int) -> [Question] {
        let fractions: [(text: String, answer: String, explanation: String)] = [
            ("1/2 + 1/2", "1", "1/2 + 1/2 = 2/2 = 1"),
            ("1/4 + 1/4", "1/2", "1/4 + 1/4 = 2/4 = 1/2"),
            ("1/3 + 1/3", "2/3", "1/3 + 1/3 = 2/3"),
            ("1/2 + 1/4", "3/4", "2/4 + 1/4 = 3/4"),
            ("2/3 + 1/3", "1", "2/3 + 1/3 = 3/3 = 1"),
            ("1/5 + 2/5", "3/5", "1/5 + 2/5 = 3/5"),
            ("3/4 - 1/4", "1/2", "3/4 - 1/4 = 2/4 = 1/2"),
            ("2/3 - 1/3", "1/3", "2/3 - 1/3 = 1/3"),
            ("1/2 × 1/2", "1/4", "1/2 × 1/2 = 1/4"),
            ("2/3 × 3/4", "1/2", "2/3 × 3/4 = 6/12 = 1/2"),
            ("1/2 ÷ 1/4", "2", "1/2 ÷ 1/4 = 1/2 × 4/1 = 2"),
            ("3/4 + 1/2", "5/4", "3/4 + 2/4 = 5/4"),
            ("5/6 - 1/3", "1/2", "5/6 - 2/6 = 3/6 = 1/2"),
            ("2/5 + 1/10", "1/2", "4/10 + 1/10 = 5/10 = 1/2"),
            ("1/3 × 3", "1", "1/3 × 3 = 3/3 = 1")
        ]

        return fractions.map { frac in
            var options = [frac.answer]
            let wrongOptions = ["1/3", "1/4", "2/3", "3/4", "1/2", "1", "2", "1/5", "2/5", "3/5"]
            for opt in wrongOptions where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            return Question(
                subject: .math,
                level: level,
                text: "What is \(frac.text)?",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: frac.answer) ?? 0,
                explanation: frac.explanation
            )
        }
    }

    private func generateDecimalQuestions(level: Int) -> [Question] {
        let decimals: [(text: String, answer: String, explanation: String)] = [
            ("0.5 + 0.5", "1.0", "0.5 + 0.5 = 1.0"),
            ("0.3 + 0.7", "1.0", "0.3 + 0.7 = 1.0"),
            ("1.2 + 0.8", "2.0", "1.2 + 0.8 = 2.0"),
            ("2.5 - 1.5", "1.0", "2.5 - 1.5 = 1.0"),
            ("3.6 - 1.2", "2.4", "3.6 - 1.2 = 2.4"),
            ("0.5 × 2", "1.0", "0.5 × 2 = 1.0"),
            ("0.25 × 4", "1.0", "0.25 × 4 = 1.0"),
            ("1.5 × 2", "3.0", "1.5 × 2 = 3.0"),
            ("2.4 ÷ 2", "1.2", "2.4 ÷ 2 = 1.2"),
            ("4.5 ÷ 3", "1.5", "4.5 ÷ 3 = 1.5"),
            ("0.1 + 0.2", "0.3", "0.1 + 0.2 = 0.3"),
            ("0.6 - 0.4", "0.2", "0.6 - 0.4 = 0.2"),
            ("0.2 × 5", "1.0", "0.2 × 5 = 1.0"),
            ("3.0 ÷ 1.5", "2.0", "3.0 ÷ 1.5 = 2.0"),
            ("2.5 + 2.5", "5.0", "2.5 + 2.5 = 5.0")
        ]

        return decimals.map { dec in
            var options = [dec.answer]
            let wrongOptions = ["0.5", "1.5", "2.0", "2.5", "3.0", "0.3", "0.7", "1.2", "0.8", "4.0"]
            for opt in wrongOptions where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            return Question(
                subject: .math,
                level: level,
                text: "What is \(dec.text)?",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: dec.answer) ?? 0,
                explanation: dec.explanation
            )
        }
    }

    private func generatePercentageQuestions(level: Int) -> [Question] {
        let percentages: [(text: String, answer: Int, explanation: String)] = [
            ("10% of 100", 10, "10% of 100 = 100 × 0.10 = 10"),
            ("25% of 80", 20, "25% of 80 = 80 × 0.25 = 20"),
            ("50% of 60", 30, "50% of 60 = 60 × 0.50 = 30"),
            ("20% of 50", 10, "20% of 50 = 50 × 0.20 = 10"),
            ("75% of 40", 30, "75% of 40 = 40 × 0.75 = 30"),
            ("10% of 200", 20, "10% of 200 = 200 × 0.10 = 20"),
            ("50% of 120", 60, "50% of 120 = 120 × 0.50 = 60"),
            ("25% of 200", 50, "25% of 200 = 200 × 0.25 = 50"),
            ("20% of 75", 15, "20% of 75 = 75 × 0.20 = 15"),
            ("30% of 50", 15, "30% of 50 = 50 × 0.30 = 15"),
            ("40% of 25", 10, "40% of 25 = 25 × 0.40 = 10"),
            ("15% of 60", 9, "15% of 60 = 60 × 0.15 = 9"),
            ("5% of 200", 10, "5% of 200 = 200 × 0.05 = 10"),
            ("100% of 45", 45, "100% of 45 = 45"),
            ("80% of 50", 40, "80% of 50 = 50 × 0.80 = 40")
        ]

        return percentages.map { pct in
            let options = generateUniqueOptions(correct: pct.answer, variance: 10)
            return Question(
                subject: .math,
                level: level,
                text: "What is \(pct.text)?",
                options: options,
                correctIndex: options.firstIndex(of: String(pct.answer)) ?? 0,
                explanation: pct.explanation
            )
        }
    }

    private func generateLinearEquationQuestions(level: Int) -> [Question] {
        let equations: [(text: String, answer: Int, explanation: String)] = [
            ("2x = 10", 5, "x = 10 ÷ 2 = 5"),
            ("3x = 15", 5, "x = 15 ÷ 3 = 5"),
            ("x + 5 = 12", 7, "x = 12 - 5 = 7"),
            ("x - 3 = 8", 11, "x = 8 + 3 = 11"),
            ("4x = 20", 5, "x = 20 ÷ 4 = 5"),
            ("2x + 3 = 11", 4, "2x = 8, x = 4"),
            ("3x - 5 = 10", 5, "3x = 15, x = 5"),
            ("5x + 2 = 17", 3, "5x = 15, x = 3"),
            ("4x - 8 = 12", 5, "4x = 20, x = 5"),
            ("x/2 = 6", 12, "x = 6 × 2 = 12"),
            ("x/3 = 4", 12, "x = 4 × 3 = 12"),
            ("2x + 6 = 18", 6, "2x = 12, x = 6"),
            ("3x - 9 = 0", 3, "3x = 9, x = 3"),
            ("5x = 35", 7, "x = 35 ÷ 5 = 7"),
            ("x + 10 = 25", 15, "x = 25 - 10 = 15")
        ]

        return equations.map { eq in
            let options = generateUniqueOptions(correct: eq.answer, variance: 3)
            return Question(
                subject: .math,
                level: level,
                text: "Solve for x: \(eq.text)",
                options: options,
                correctIndex: options.firstIndex(of: String(eq.answer)) ?? 0,
                explanation: eq.explanation
            )
        }
    }

    private func generateQuadraticQuestions(level: Int) -> [Question] {
        let quadratics: [(text: String, answer: String, explanation: String)] = [
            ("x² = 9", "x = 3 or x = -3", "√9 = ±3"),
            ("x² = 16", "x = 4 or x = -4", "√16 = ±4"),
            ("x² = 25", "x = 5 or x = -5", "√25 = ±5"),
            ("x² - 4 = 0", "x = 2 or x = -2", "x² = 4, x = ±2"),
            ("x² - 9 = 0", "x = 3 or x = -3", "x² = 9, x = ±3"),
            ("(x-1)(x-2) = 0", "x = 1 or x = 2", "Zero product property"),
            ("(x+1)(x-3) = 0", "x = -1 or x = 3", "Zero product property"),
            ("(x-2)(x-4) = 0", "x = 2 or x = 4", "Zero product property"),
            ("x² + x - 6 = 0", "x = 2 or x = -3", "Factors: (x-2)(x+3) = 0"),
            ("x² - 5x + 6 = 0", "x = 2 or x = 3", "Factors: (x-2)(x-3) = 0"),
            ("x² - x - 2 = 0", "x = 2 or x = -1", "Factors: (x-2)(x+1) = 0"),
            ("x² + 2x - 8 = 0", "x = 2 or x = -4", "Factors: (x-2)(x+4) = 0"),
            ("x² - 4x + 3 = 0", "x = 1 or x = 3", "Factors: (x-1)(x-3) = 0"),
            ("x² - 6x + 8 = 0", "x = 2 or x = 4", "Factors: (x-2)(x-4) = 0"),
            ("x² + 5x + 6 = 0", "x = -2 or x = -3", "Factors: (x+2)(x+3) = 0")
        ]

        return quadratics.map { quad in
            var options = [quad.answer]
            let wrongOptions = [
                "x = 1 or x = -1", "x = 2 or x = -2", "x = 3 or x = -3",
                "x = 4 or x = -4", "x = 0 or x = 1", "x = 1 or x = 2",
                "x = -1 or x = 2", "x = 0 or x = 3"
            ]
            for opt in wrongOptions where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            return Question(
                subject: .math,
                level: level,
                text: "Solve: \(quad.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: quad.answer) ?? 0,
                explanation: quad.explanation
            )
        }
    }

    private func generateGeometryQuestions(level: Int) -> [Question] {
        let geometry: [(text: String, answer: Int, explanation: String)] = [
            ("Area of rectangle: 5 × 4", 20, "Area = length × width = 5 × 4 = 20"),
            ("Area of rectangle: 6 × 3", 18, "Area = length × width = 6 × 3 = 18"),
            ("Area of square: side = 5", 25, "Area = s² = 5² = 25"),
            ("Area of square: side = 7", 49, "Area = s² = 7² = 49"),
            ("Triangle area: base=6, height=4", 12, "Area = (1/2) × 6 × 4 = 12"),
            ("Triangle area: base=8, height=5", 20, "Area = (1/2) × 8 × 5 = 20"),
            ("Perimeter of square: side = 6", 24, "Perimeter = 4 × 6 = 24"),
            ("Perimeter of rectangle: 5 × 3", 16, "Perimeter = 2(5+3) = 16"),
            ("Circle area: radius = 2 (use π≈3)", 12, "Area ≈ 3 × 2² = 12"),
            ("Circle circumference: r = 3 (use π≈3)", 18, "C ≈ 2 × 3 × 3 = 18"),
            ("Volume of cube: side = 3", 27, "V = s³ = 3³ = 27"),
            ("Volume of cube: side = 4", 64, "V = s³ = 4³ = 64"),
            ("Pythagorean: 3² + 4² = ?", 25, "9 + 16 = 25"),
            ("Pythagorean: 5² + 12² = ?", 169, "25 + 144 = 169"),
            ("Area of parallelogram: b=8, h=3", 24, "Area = base × height = 8 × 3 = 24")
        ]

        return geometry.map { geo in
            let options = generateUniqueOptions(correct: geo.answer, variance: 8)
            return Question(
                subject: .math,
                level: level,
                text: geo.text,
                options: options,
                correctIndex: options.firstIndex(of: String(geo.answer)) ?? 0,
                explanation: geo.explanation
            )
        }
    }

    private func generateTrigQuestions(level: Int) -> [Question] {
        let trig: [(text: String, answer: String, explanation: String)] = [
            ("sin(0°)", "0", "sin(0°) = 0"),
            ("sin(30°)", "1/2", "sin(30°) = 1/2"),
            ("sin(45°)", "√2/2", "sin(45°) = √2/2"),
            ("sin(60°)", "√3/2", "sin(60°) = √3/2"),
            ("sin(90°)", "1", "sin(90°) = 1"),
            ("cos(0°)", "1", "cos(0°) = 1"),
            ("cos(30°)", "√3/2", "cos(30°) = √3/2"),
            ("cos(45°)", "√2/2", "cos(45°) = √2/2"),
            ("cos(60°)", "1/2", "cos(60°) = 1/2"),
            ("cos(90°)", "0", "cos(90°) = 0"),
            ("tan(0°)", "0", "tan(0°) = 0"),
            ("tan(45°)", "1", "tan(45°) = 1"),
            ("tan(30°)", "√3/3", "tan(30°) = √3/3"),
            ("tan(60°)", "√3", "tan(60°) = √3"),
            ("sin²(30°) + cos²(30°)", "1", "Pythagorean identity: always = 1")
        ]

        return trig.map { t in
            var options = [t.answer]
            let wrongOptions = ["0", "1", "1/2", "√2/2", "√3/2", "√3", "√3/3", "undefined", "2", "-1"]
            for opt in wrongOptions where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            return Question(
                subject: .math,
                level: level,
                text: "What is \(t.text)?",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: t.answer) ?? 0,
                explanation: t.explanation
            )
        }
    }

    private func generateDerivativeQuestions(level: Int) -> [Question] {
        let derivatives: [(text: String, answer: String, explanation: String)] = [
            ("d/dx[x²]", "2x", "Power rule: nx^(n-1)"),
            ("d/dx[x³]", "3x²", "Power rule: 3x^(3-1) = 3x²"),
            ("d/dx[x⁴]", "4x³", "Power rule: 4x^(4-1) = 4x³"),
            ("d/dx[5x]", "5", "Derivative of ax = a"),
            ("d/dx[3x²]", "6x", "3 × 2x = 6x"),
            ("d/dx[x² + x]", "2x + 1", "Sum rule: d/dx[x²] + d/dx[x]"),
            ("d/dx[2x³]", "6x²", "2 × 3x² = 6x²"),
            ("d/dx[x⁵]", "5x⁴", "Power rule: 5x^(5-1)"),
            ("d/dx[sin(x)]", "cos(x)", "Standard derivative"),
            ("d/dx[cos(x)]", "-sin(x)", "Standard derivative"),
            ("d/dx[e^x]", "e^x", "e^x is its own derivative"),
            ("d/dx[ln(x)]", "1/x", "Standard derivative"),
            ("d/dx[x² - 3x]", "2x - 3", "Difference rule"),
            ("d/dx[4x³ + 2x]", "12x² + 2", "Sum rule"),
            ("d/dx[x + 5]", "1", "Derivative of x is 1, constant is 0")
        ]

        return derivatives.map { d in
            var options = [d.answer]
            let wrongOptions = ["x", "2x", "3x²", "x²", "cos(x)", "sin(x)", "e^x", "1/x", "6x", "4x³", "1", "0"]
            for opt in wrongOptions where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            return Question(
                subject: .math,
                level: level,
                text: "Find \(d.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: d.answer) ?? 0,
                explanation: d.explanation
            )
        }
    }

    private func generateIntegralQuestions(level: Int) -> [Question] {
        let integrals: [(text: String, answer: String, explanation: String)] = [
            ("∫x dx", "x²/2 + C", "Power rule: x^(n+1)/(n+1)"),
            ("∫x² dx", "x³/3 + C", "x^(2+1)/(2+1) = x³/3"),
            ("∫x³ dx", "x⁴/4 + C", "x^(3+1)/(3+1) = x⁴/4"),
            ("∫2x dx", "x² + C", "2 × x²/2 = x²"),
            ("∫3x² dx", "x³ + C", "3 × x³/3 = x³"),
            ("∫1 dx", "x + C", "Integral of constant"),
            ("∫5 dx", "5x + C", "5 times x"),
            ("∫cos(x) dx", "sin(x) + C", "Standard integral"),
            ("∫sin(x) dx", "-cos(x) + C", "Standard integral"),
            ("∫e^x dx", "e^x + C", "e^x integrates to itself"),
            ("∫1/x dx", "ln|x| + C", "Standard integral"),
            ("∫x⁴ dx", "x⁵/5 + C", "Power rule"),
            ("∫(x + 1) dx", "x²/2 + x + C", "Sum rule"),
            ("∫(2x + 3) dx", "x² + 3x + C", "Sum rule"),
            ("∫4x³ dx", "x⁴ + C", "4 × x⁴/4 = x⁴")
        ]

        return integrals.map { i in
            var options = [i.answer]
            let wrongOptions = ["x + C", "x² + C", "x³ + C", "2x + C", "sin(x) + C", "cos(x) + C", "e^x + C", "ln(x) + C"]
            for opt in wrongOptions where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            return Question(
                subject: .math,
                level: level,
                text: "Evaluate \(i.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: i.answer) ?? 0,
                explanation: i.explanation
            )
        }
    }

    private func generateMultivariableQuestions(level: Int) -> [Question] {
        let multivariable: [(text: String, answer: String, explanation: String)] = [
            ("∂/∂x[xy]", "y", "Treat y as constant"),
            ("∂/∂y[xy]", "x", "Treat x as constant"),
            ("∂/∂x[x²y]", "2xy", "Derivative of x², y constant"),
            ("∂/∂y[x²y]", "x²", "Derivative of y, x² constant"),
            ("∂/∂x[x² + y²]", "2x", "y² is constant"),
            ("∂/∂y[x² + y²]", "2y", "x² is constant"),
            ("∂/∂x[xy²]", "y²", "y² is constant"),
            ("∂/∂y[xy²]", "2xy", "Derivative of y²"),
            ("∂/∂x[x³y²]", "3x²y²", "Power rule in x"),
            ("∂/∂y[x³y²]", "2x³y", "Power rule in y"),
            ("∇(x² + y²) at (1,1)", "(2, 2)", "Gradient: (2x, 2y)"),
            ("∂²/∂x²[x³]", "6x", "Second derivative"),
            ("∂/∂x[xyz]", "yz", "y and z are constants"),
            ("∂/∂x[e^(xy)]", "ye^(xy)", "Chain rule"),
            ("∂/∂y[sin(xy)]", "x·cos(xy)", "Chain rule")
        ]

        return multivariable.map { m in
            var options = [m.answer]
            let wrongOptions = ["x", "y", "2x", "2y", "xy", "x²", "y²", "2xy", "(1, 1)", "(2, 2)", "0"]
            for opt in wrongOptions where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            return Question(
                subject: .math,
                level: level,
                text: "Find \(m.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: m.answer) ?? 0,
                explanation: m.explanation
            )
        }
    }

    // MARK: - Grammar Questions

    private func generateGrammarQuestionsForLevel(_ level: Int) -> [Question] {
        let allGrammar: [(text: String, options: [String], correct: Int, explanation: String)] = [
            // Homophones
            ("Which is correct?", ["Their going home.", "They're going home.", "There going home.", "Thier going home."], 1, "'They're' = 'they are'"),
            ("Select the correct sentence:", ["Your the best!", "You're the best!", "Youre the best!", "Your' the best!"], 1, "'You're' = 'you are'"),
            ("Which is correct?", ["Its raining.", "It's raining.", "Its' raining.", "Itss raining."], 1, "'It's' = 'it is'"),
            ("Choose correctly:", ["The dog wagged it's tail.", "The dog wagged its tail.", "The dog wagged its' tail.", "The dog wagged it is tail."], 1, "'Its' shows possession"),
            ("Which is correct?", ["Put it over their.", "Put it over there.", "Put it over they're.", "Put it over thier."], 1, "'There' = a place"),
            ("Select the correct form:", ["Whose coming?", "Who's coming?", "Whos coming?", "Who'se coming?"], 1, "'Who's' = 'who is'"),
            ("Which is correct?", ["Whose book is this?", "Who's book is this?", "Whos book is this?", "Who'se book is this?"], 0, "'Whose' shows possession"),

            // Subject-verb agreement
            ("Which is correct?", ["The team are winning.", "The team is winning.", "The team be winning.", "The team were winning."], 1, "Collective nouns take singular verbs"),
            ("Select correctly:", ["Everyone have opinions.", "Everyone has opinions.", "Everyone having opinions.", "Everyone had have opinions."], 1, "'Everyone' is singular"),
            ("Which is correct?", ["The news are bad.", "The news is bad.", "The news were bad.", "The news be bad."], 1, "'News' is singular"),
            ("Choose correctly:", ["Mathematics are hard.", "Mathematics is hard.", "Mathematics were hard.", "Mathematic is hard."], 1, "Subjects in -ics are singular"),
            ("Which is correct?", ["Neither is correct.", "Neither are correct.", "Neither be correct.", "Neither were correct."], 0, "'Neither' is singular"),

            // Pronoun cases
            ("Which is correct?", ["Me and him went.", "Him and I went.", "He and I went.", "He and me went."], 2, "Use 'I' as subject"),
            ("Select correctly:", ["Between you and I.", "Between you and me.", "Between I and you.", "Between me and you."], 1, "'Me' after prepositions"),
            ("Which is correct?", ["Give it to John and I.", "Give it to John and me.", "Give it to I and John.", "Give it to myself and John."], 1, "'Me' as object"),
            ("Choose correctly:", ["Us students need help.", "We students need help.", "Ourselves need help.", "Our students need help."], 1, "'We' as subject pronoun"),

            // Common errors
            ("Which is correct?", ["I could of won.", "I could have won.", "I could off won.", "I could've of won."], 1, "'Could have' not 'could of'"),
            ("Select correctly:", ["The affect was huge.", "The effect was huge.", "The affection was huge.", "The effection was huge."], 1, "'Effect' is the noun"),
            ("Which is correct?", ["Lay down and rest.", "Lie down and rest.", "Laid down and rest.", "Lied down and rest."], 1, "'Lie' = recline"),
            ("Choose correctly:", ["I accept the terms.", "I except the terms.", "I expect the terms.", "I excerpt the terms."], 0, "'Accept' = receive"),
            ("Which is correct?", ["The principle spoke.", "The principal spoke.", "The principel spoke.", "The princpal spoke."], 1, "'Principal' = person"),

            // Comparisons
            ("Which is correct?", ["More better", "Better", "Most better", "Bestest"], 1, "'Better' is already comparative"),
            ("Select correctly:", ["Less people came.", "Fewer people came.", "Lesser people came.", "Few people came."], 1, "'Fewer' for countable"),
            ("Which is correct?", ["Most unique", "Unique", "More unique", "Uniquer"], 1, "'Unique' is absolute"),

            // Verb tenses
            ("Which is correct?", ["I seen it.", "I saw it.", "I have saw it.", "I had saw it."], 1, "'Saw' is past tense"),
            ("Select correctly:", ["I have went.", "I have gone.", "I have going.", "I has gone."], 1, "'Gone' with 'have'"),
            ("Which is correct?", ["She don't know.", "She doesn't know.", "She do not know.", "She don't knows."], 1, "'Doesn't' with singular"),

            // Advanced
            ("Which is correct?", ["If I was rich...", "If I were rich...", "If I am rich...", "If I be rich..."], 1, "Subjunctive mood"),
            ("Select correctly:", ["I wish I was there.", "I wish I were there.", "I wish I am there.", "I wish I be there."], 1, "Subjunctive after 'wish'"),
            ("Which shows parallelism?", ["She likes hiking, to swim, biking.", "She likes hiking, swimming, biking.", "She likes to hike, swimming, bike.", "She likes hike, swim, bike."], 1, "Parallel structure"),
        ]

        // Select questions based on level
        let startIndex = ((level - 1) % (allGrammar.count / 15)) * 15
        let endIndex = min(startIndex + 15, allGrammar.count)

        return (startIndex..<endIndex).map { i in
            let g = allGrammar[i % allGrammar.count]
            var options = g.options
            options.shuffle()
            let correctAnswer = g.options[g.correct]
            let newCorrectIndex = options.firstIndex(of: correctAnswer) ?? 0

            return Question(
                subject: .grammar,
                level: level,
                text: g.text,
                options: options,
                correctIndex: newCorrectIndex,
                explanation: g.explanation
            )
        }
    }

    // MARK: - Helpers

    private func generateUniqueOptions(correct: Int, variance: Int) -> [String] {
        var options = Set<Int>([correct])
        var attempts = 0

        while options.count < 4 && attempts < 20 {
            let offset = (attempts % variance + 1) * (attempts % 2 == 0 ? 1 : -1)
            let wrong = max(0, correct + offset)
            options.insert(wrong)
            attempts += 1
        }

        var result = options.map { String($0) }
        result.shuffle()
        return result
    }

    private func generateFallbackQuestion(for subject: Subject, level: Int) -> Question {
        Question(
            subject: subject,
            level: level,
            text: "What is 1 + 1?",
            options: ["2", "3", "1", "4"],
            correctIndex: 0,
            explanation: "1 + 1 = 2"
        )
    }
}
