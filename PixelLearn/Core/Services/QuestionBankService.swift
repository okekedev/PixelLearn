import Foundation

actor QuestionBankService {
    static let shared = QuestionBankService()

    private var mathQuestions: [Int: [Question]] = [:]
    private var grammarQuestions: [Int: [Question]] = [:]
    private var spellingQuestions: [Int: [Question]] = [:]
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
        case .spelling:
            questions = spellingQuestions[level] ?? []
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
        case .spelling:
            if spellingQuestions[level] == nil {
                spellingQuestions[level] = generateSpellingQuestionsForLevel(level)
            }
        case .memory:
            break
        }
    }

    func resetUsedQuestions() {
        usedQuestionIds.removeAll()
    }

    // MARK: - Math Questions

    // Emoji sets for counting questions
    private let countingEmojis = ["🍎", "🍊", "🍋", "🍇", "🍓", "🍌", "🥕", "🌽", "🍕", "🍩",
                                   "⭐", "❤️", "🌸", "🐶", "🐱", "🐸", "🦋", "🐝", "🚗", "✈️",
                                   "⚽", "🏀", "🎈", "🎁", "📚", "✏️", "🔵", "🟢", "🟡", "🔴"]

    private func generateMathQuestionsForLevel(_ level: Int) -> [Question] {
        var questions: [Question] = []

        switch level {
        // PreK - Kindergarten: Counting with emojis (Levels 1-5)
        case 1...2:
            questions = generateEmojiCountingQuestions(level: level, maxCount: 5)
        case 3...5:
            questions = generateEmojiCountingQuestions(level: level, maxCount: 10)
        // Grade 1: Simple addition with emojis (Levels 6-10)
        case 6...8:
            questions = generateEmojiAdditionQuestions(level: level, maxNum: 5)
        case 9...10:
            questions = generateEmojiAdditionQuestions(level: level, maxNum: 10)
        // Grade 1-2: Addition without emojis (Levels 11-15)
        case 11...15:
            questions = generateAdditionQuestions(level: level)
        // Grade 2: Subtraction (Levels 16-20)
        case 16...20:
            questions = generateSubtractionQuestions(level: level)
        // Grade 3: Multiplication (Levels 21-25)
        case 21...25:
            questions = generateMultiplicationQuestions(level: level)
        // Grade 3-4: Division (Levels 26-30)
        case 26...30:
            questions = generateDivisionQuestions(level: level)
        // Grade 4-5: Order of operations (Levels 31-35)
        case 31...35:
            questions = generateOrderOfOpsQuestions(level: level)
        // Grade 5-6: Fractions (Levels 36-40)
        case 36...40:
            questions = generateFractionQuestions(level: level)
        // Grade 6-7: Decimals (Levels 41-43)
        case 41...43:
            questions = generateDecimalQuestions(level: level)
        // Grade 7-8: Percentages (Levels 44-46)
        case 44...46:
            questions = generatePercentageQuestions(level: level)
        // Grade 8-9: Linear equations (Levels 47-50)
        case 47...50:
            questions = generateLinearEquationQuestions(level: level)
        // High School: Quadratics (Levels 51-54)
        case 51...54:
            questions = generateQuadraticQuestions(level: level)
        // High School: Geometry (Levels 55-57)
        case 55...57:
            questions = generateGeometryQuestions(level: level)
        // Pre-Calc: Trigonometry (Levels 58-60)
        case 58...60:
            questions = generateTrigQuestions(level: level)
        // Calculus I: Derivatives (Levels 61-63)
        case 61...63:
            questions = generateDerivativeQuestions(level: level)
        // Calculus II: Integrals (Levels 64)
        case 64:
            questions = generateIntegralQuestions(level: level)
        // Graduate: Multivariable calculus (Level 65)
        default:
            questions = generateMultivariableQuestions(level: level)
        }

        return questions
    }

    // MARK: - PreK/Kindergarten Counting

    private func generateEmojiCountingQuestions(level: Int, maxCount: Int) -> [Question] {
        var questions: [Question] = []

        for count in 1...maxCount {
            for emoji in countingEmojis.shuffled().prefix(20) {
                let emojiString = String(repeating: "\(emoji) ", count: count).trimmingCharacters(in: .whitespaces)
                let options = generateUniqueOptions(correct: count, variance: 2)

                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "How many \(emoji) are there?\n\n\(emojiString)",
                    options: options,
                    correctIndex: options.firstIndex(of: String(count)) ?? 0,
                    explanation: "There are \(count) \(emoji)"
                ))
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    // MARK: - Grade 1: Emoji Addition

    private func generateEmojiAdditionQuestions(level: Int, maxNum: Int) -> [Question] {
        var questions: [Question] = []

        for a in 1...maxNum {
            for b in 1...maxNum {
                for emoji in countingEmojis.shuffled().prefix(5) {
                    let answer = a + b
                    let emojiA = String(repeating: "\(emoji)", count: a)
                    let emojiB = String(repeating: "\(emoji)", count: b)
                    let options = generateUniqueOptions(correct: answer, variance: 3)

                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: "\(emojiA) + \(emojiB) = ?",
                        options: options,
                        correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                        explanation: "\(a) + \(b) = \(answer)"
                    ))
                }
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateAdditionQuestions(level: Int) -> [Question] {
        var questions: [Question] = []
        let difficulty = level - 10  // 1-5 for levels 11-15

        // Generate various addition problems based on difficulty
        let maxNum1 = 10 + difficulty * 10  // 20-60
        let maxNum2 = 5 + difficulty * 5     // 10-30

        // Two-digit addition
        for a in 10...maxNum1 {
            for b in 1...maxNum2 where questions.count < 50 {
                let answer = a + b
                let options = generateUniqueOptions(correct: answer, variance: 5)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(a) + \(b)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                    explanation: "\(a) + \(b) = \(answer)"
                ))
            }
        }

        // Three number addition for higher levels
        if level >= 13 {
            for a in 5...20 {
                for b in 5...15 {
                    for c in 1...10 where questions.count < 100 {
                        let answer = a + b + c
                        let options = generateUniqueOptions(correct: answer, variance: 5)
                        questions.append(Question(
                            subject: .math,
                            level: level,
                            text: "What is \(a) + \(b) + \(c)?",
                            options: options,
                            correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                            explanation: "\(a) + \(b) + \(c) = \(answer)"
                        ))
                    }
                }
            }
        }

        // Word problems
        let additionWordProblems: [(String, Int, Int)] = [
            ("Sam has %d apples. He gets %d more. How many apples does Sam have?", 0, 0),
            ("There are %d birds in a tree. %d more birds fly in. How many birds are there now?", 0, 0),
            ("Lisa has %d stickers. Her friend gives her %d more. How many stickers does Lisa have?", 0, 0),
            ("A bus has %d passengers. %d more people get on. How many passengers are on the bus?", 0, 0),
            ("Tom read %d pages yesterday and %d pages today. How many pages did he read in total?", 0, 0)
        ]

        for template in additionWordProblems {
            for a in 5...20 {
                for b in 3...15 where questions.count < 150 {
                    let answer = a + b
                    let text = String(format: template.0, a, b)
                    let options = generateUniqueOptions(correct: answer, variance: 4)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: text,
                        options: options,
                        correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                        explanation: "\(a) + \(b) = \(answer)"
                    ))
                }
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateSubtractionQuestions(level: Int) -> [Question] {
        var questions: [Question] = []
        let difficulty = level - 15  // 1-5 for levels 16-20

        // Basic subtraction with increasing difficulty
        let maxNum = 20 + difficulty * 15  // 35-95

        for a in 10...maxNum {
            for b in 1..<min(a, 30) where questions.count < 50 {
                let answer = a - b
                let options = generateUniqueOptions(correct: answer, variance: 5)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(a) - \(b)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                    explanation: "\(a) - \(b) = \(answer)"
                ))
            }
        }

        // Word problems
        let subtractionWordProblems = [
            "There were %d cookies. %d were eaten. How many are left?",
            "A store had %d toys. %d were sold. How many toys remain?",
            "Emma has %d crayons. She gives away %d. How many does she have now?",
            "A tree had %d apples. %d fell down. How many apples are still on the tree?",
            "There are %d students in class. %d go home early. How many are still in class?",
            "A farmer had %d eggs. %d broke. How many eggs are left?",
            "Jake has %d marbles. He loses %d. How many marbles does he have?",
            "The library had %d books. %d were borrowed. How many books are left?"
        ]

        for template in subtractionWordProblems {
            for a in 15...50 {
                for b in 3...min(a-1, 20) where questions.count < 100 {
                    let answer = a - b
                    let text = String(format: template, a, b)
                    let options = generateUniqueOptions(correct: answer, variance: 5)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: text,
                        options: options,
                        correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                        explanation: "\(a) - \(b) = \(answer)"
                    ))
                }
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateMultiplicationQuestions(level: Int) -> [Question] {
        var questions: [Question] = []
        let difficulty = level - 20  // 1-5 for levels 21-25

        // Full times tables 2-12
        for a in 2...12 {
            for b in 2...12 {
                let answer = a * b
                let options = generateUniqueOptions(correct: answer, variance: max(6, answer / 4))
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(a) × \(b)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                    explanation: "\(a) × \(b) = \(answer)"
                ))
            }
        }

        // Higher level: larger numbers
        if difficulty >= 3 {
            for a in [15, 20, 25] {
                for b in 2...10 where questions.count < 150 {
                    let answer = a * b
                    let options = generateUniqueOptions(correct: answer, variance: 15)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: "What is \(a) × \(b)?",
                        options: options,
                        correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                        explanation: "\(a) × \(b) = \(answer)"
                    ))
                }
            }
        }

        // Word problems
        let multiplicationWordProblems = [
            "There are %d bags with %d apples each. How many apples in total?",
            "A classroom has %d rows of desks with %d desks in each row. How many desks are there?",
            "If %d children each have %d stickers, how many stickers do they have altogether?",
            "A baker makes %d trays of cookies with %d cookies on each tray. How many cookies total?",
            "Each box contains %d pencils. How many pencils are in %d boxes?",
            "A parking lot has %d rows with %d cars in each row. How many cars are parked?"
        ]

        for template in multiplicationWordProblems {
            for a in 3...12 {
                for b in 2...10 where questions.count < 200 {
                    let answer = a * b
                    let text = String(format: template, a, b)
                    let options = generateUniqueOptions(correct: answer, variance: 8)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: text,
                        options: options,
                        correctIndex: options.firstIndex(of: String(answer)) ?? 0,
                        explanation: "\(a) × \(b) = \(answer)"
                    ))
                }
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateDivisionQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        // Full division tables
        for divisor in 2...12 {
            for quotient in 1...12 {
                let dividend = divisor * quotient
                let options = generateUniqueOptions(correct: quotient, variance: 4)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(dividend) ÷ \(divisor)?",
                    options: options,
                    correctIndex: options.firstIndex(of: String(quotient)) ?? 0,
                    explanation: "\(dividend) ÷ \(divisor) = \(quotient)"
                ))
            }
        }

        // Word problems
        let divisionWordProblems = [
            "If %d cookies are shared equally among %d friends, how many does each friend get?",
            "A farmer has %d apples to pack in boxes of %d. How many full boxes can be made?",
            "%d students need to be divided into %d equal groups. How many students in each group?",
            "A baker has %d cupcakes to put on %d plates equally. How many cupcakes per plate?",
            "If you have %d stickers and want to give %d to each friend, how many friends can you give to?",
            "A rope is %d meters long. It is cut into pieces of %d meters. How many pieces?"
        ]

        for template in divisionWordProblems {
            for quotient in 2...10 {
                for divisor in 2...10 where questions.count < 200 {
                    let dividend = quotient * divisor
                    let text = String(format: template, dividend, divisor)
                    let options = generateUniqueOptions(correct: quotient, variance: 3)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: text,
                        options: options,
                        correctIndex: options.firstIndex(of: String(quotient)) ?? 0,
                        explanation: "\(dividend) ÷ \(divisor) = \(quotient)"
                    ))
                }
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateOrderOfOpsQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let expressions: [(text: String, answer: Int, explanation: String)] = [
            // Basic PEMDAS
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
            ("8 × 2 - 4 × 3", 4, "Multiply: 8 × 2 = 16, 4 × 3 = 12, then: 16 - 12 = 4"),
            // More complex
            ("(4 + 2) × (3 + 1)", 24, "Parentheses: 6 × 4 = 24"),
            ("5 + 3 × 2 - 1", 10, "3 × 2 = 6, then 5 + 6 - 1 = 10"),
            ("(7 - 2) × (4 + 1)", 25, "Parentheses: 5 × 5 = 25"),
            ("24 ÷ 4 + 2 × 3", 12, "24 ÷ 4 = 6, 2 × 3 = 6, then 6 + 6 = 12"),
            ("(15 - 5) ÷ (3 - 1)", 5, "Parentheses: 10 ÷ 2 = 5"),
            ("3 × 3 + 2 × 2", 13, "9 + 4 = 13"),
            ("(8 + 4) ÷ 4 + 5", 8, "12 ÷ 4 = 3, then 3 + 5 = 8"),
            ("2 × 3 × 4", 24, "Left to right: 6 × 4 = 24"),
            ("18 ÷ 3 ÷ 2", 3, "Left to right: 6 ÷ 2 = 3"),
            ("(2 + 3) × (4 - 1)", 15, "Parentheses: 5 × 3 = 15"),
            ("6 × 6 - 6 ÷ 6", 35, "36 - 1 = 35"),
            ("(9 - 3) × (8 - 6)", 12, "Parentheses: 6 × 2 = 12"),
            ("4 × 5 - 3 × 5", 5, "20 - 15 = 5"),
            ("(12 + 8) ÷ (7 - 3)", 5, "20 ÷ 4 = 5"),
            ("7 + 7 × 7 - 7", 49, "7 × 7 = 49, then 7 + 49 - 7 = 49"),
            // With exponents (simplified)
            ("2 × 2 × 2 + 2", 10, "8 + 2 = 10 (2³ + 2)"),
            ("3 × 3 - 4", 5, "9 - 4 = 5 (3² - 4)"),
            ("4 × 4 ÷ 2", 8, "16 ÷ 2 = 8 (4² ÷ 2)"),
            ("5 × 5 - 5 × 4", 5, "25 - 20 = 5"),
            ("(2 × 2) × (3 × 3)", 36, "4 × 9 = 36"),
            ("10 × 10 ÷ 5", 20, "100 ÷ 5 = 20"),
            ("6 × 6 ÷ 4", 9, "36 ÷ 4 = 9"),
            ("(5 × 5) - (3 × 3)", 16, "25 - 9 = 16"),
            ("2 × 2 × 2 × 2", 16, "2⁴ = 16"),
            ("(10 - 5) × (10 - 5)", 25, "5 × 5 = 25"),
            ("100 ÷ 10 ÷ 2", 5, "10 ÷ 2 = 5"),
            ("8 × 8 - 8 × 7", 8, "64 - 56 = 8"),
            ("9 × 9 ÷ 9 + 9", 18, "81 ÷ 9 = 9, then 9 + 9 = 18"),
            ("(6 + 4) × (6 - 4)", 20, "10 × 2 = 20"),
            ("50 ÷ 5 + 5 × 5", 35, "10 + 25 = 35"),
            ("(8 - 2) × (8 + 2)", 60, "6 × 10 = 60"),
            ("3 × 4 + 4 × 5", 32, "12 + 20 = 32"),
            ("36 ÷ 6 + 6 × 6", 42, "6 + 36 = 42"),
            ("(7 + 3) × (7 - 3)", 40, "10 × 4 = 40"),
            ("5 × 6 - 6 × 4", 6, "30 - 24 = 6")
        ]

        for expr in expressions {
            let options = generateUniqueOptions(correct: expr.answer, variance: 8)
            questions.append(Question(
                subject: .math,
                level: level,
                text: "What is \(expr.text)?",
                options: options,
                correctIndex: options.firstIndex(of: String(expr.answer)) ?? 0,
                explanation: expr.explanation
            ))
        }

        // Generate additional dynamic PEMDAS questions
        for a in 2...8 {
            for b in 2...6 {
                for c in 1...5 where questions.count < 150 {
                    // a + b × c
                    let answer1 = a + b * c
                    let opts1 = generateUniqueOptions(correct: answer1, variance: 6)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: "What is \(a) + \(b) × \(c)?",
                        options: opts1,
                        correctIndex: opts1.firstIndex(of: String(answer1)) ?? 0,
                        explanation: "Multiply first: \(b) × \(c) = \(b*c), then add: \(a) + \(b*c) = \(answer1)"
                    ))

                    // (a + b) × c
                    let answer2 = (a + b) * c
                    let opts2 = generateUniqueOptions(correct: answer2, variance: 8)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: "What is (\(a) + \(b)) × \(c)?",
                        options: opts2,
                        correctIndex: opts2.firstIndex(of: String(answer2)) ?? 0,
                        explanation: "Parentheses first: \(a) + \(b) = \(a+b), then multiply: \(a+b) × \(c) = \(answer2)"
                    ))
                }
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateFractionQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let fractions: [(text: String, answer: String, explanation: String)] = [
            // Basic addition
            ("1/2 + 1/2", "1", "1/2 + 1/2 = 2/2 = 1"),
            ("1/4 + 1/4", "1/2", "1/4 + 1/4 = 2/4 = 1/2"),
            ("1/3 + 1/3", "2/3", "1/3 + 1/3 = 2/3"),
            ("1/2 + 1/4", "3/4", "2/4 + 1/4 = 3/4"),
            ("2/3 + 1/3", "1", "2/3 + 1/3 = 3/3 = 1"),
            ("1/5 + 2/5", "3/5", "1/5 + 2/5 = 3/5"),
            ("1/6 + 1/6", "1/3", "1/6 + 1/6 = 2/6 = 1/3"),
            ("1/8 + 1/8", "1/4", "1/8 + 1/8 = 2/8 = 1/4"),
            ("2/5 + 2/5", "4/5", "2/5 + 2/5 = 4/5"),
            ("1/4 + 2/4", "3/4", "1/4 + 2/4 = 3/4"),
            ("3/8 + 3/8", "3/4", "3/8 + 3/8 = 6/8 = 3/4"),
            ("1/10 + 3/10", "2/5", "1/10 + 3/10 = 4/10 = 2/5"),
            // Subtraction
            ("3/4 - 1/4", "1/2", "3/4 - 1/4 = 2/4 = 1/2"),
            ("2/3 - 1/3", "1/3", "2/3 - 1/3 = 1/3"),
            ("5/6 - 1/6", "2/3", "5/6 - 1/6 = 4/6 = 2/3"),
            ("7/8 - 3/8", "1/2", "7/8 - 3/8 = 4/8 = 1/2"),
            ("4/5 - 2/5", "2/5", "4/5 - 2/5 = 2/5"),
            ("5/8 - 1/8", "1/2", "5/8 - 1/8 = 4/8 = 1/2"),
            ("9/10 - 3/10", "3/5", "9/10 - 3/10 = 6/10 = 3/5"),
            // Multiplication
            ("1/2 × 1/2", "1/4", "1/2 × 1/2 = 1/4"),
            ("2/3 × 3/4", "1/2", "2/3 × 3/4 = 6/12 = 1/2"),
            ("1/3 × 1/3", "1/9", "1/3 × 1/3 = 1/9"),
            ("2/5 × 5/6", "1/3", "2/5 × 5/6 = 10/30 = 1/3"),
            ("3/4 × 2/3", "1/2", "3/4 × 2/3 = 6/12 = 1/2"),
            ("1/4 × 1/2", "1/8", "1/4 × 1/2 = 1/8"),
            ("2/3 × 1/2", "1/3", "2/3 × 1/2 = 2/6 = 1/3"),
            ("4/5 × 5/8", "1/2", "4/5 × 5/8 = 20/40 = 1/2"),
            // Division
            ("1/2 ÷ 1/4", "2", "1/2 ÷ 1/4 = 1/2 × 4/1 = 2"),
            ("3/4 ÷ 1/2", "3/2", "3/4 ÷ 1/2 = 3/4 × 2 = 3/2"),
            ("2/3 ÷ 1/3", "2", "2/3 ÷ 1/3 = 2/3 × 3 = 2"),
            ("1/4 ÷ 1/8", "2", "1/4 ÷ 1/8 = 1/4 × 8 = 2"),
            ("3/5 ÷ 1/5", "3", "3/5 ÷ 1/5 = 3/5 × 5 = 3"),
            // Mixed denominators
            ("3/4 + 1/2", "5/4", "3/4 + 2/4 = 5/4"),
            ("5/6 - 1/3", "1/2", "5/6 - 2/6 = 3/6 = 1/2"),
            ("2/5 + 1/10", "1/2", "4/10 + 1/10 = 5/10 = 1/2"),
            ("1/3 × 3", "1", "1/3 × 3 = 3/3 = 1"),
            ("2/5 + 3/10", "7/10", "4/10 + 3/10 = 7/10"),
            ("3/4 - 1/8", "5/8", "6/8 - 1/8 = 5/8"),
            ("1/2 + 1/6", "2/3", "3/6 + 1/6 = 4/6 = 2/3"),
            ("5/6 - 1/2", "1/3", "5/6 - 3/6 = 2/6 = 1/3"),
            // Word problems with fractions
            ("Half of a half", "1/4", "1/2 × 1/2 = 1/4"),
            ("A third of 3/4", "1/4", "1/3 × 3/4 = 3/12 = 1/4"),
            ("Double 1/4", "1/2", "2 × 1/4 = 2/4 = 1/2"),
            ("Triple 1/6", "1/2", "3 × 1/6 = 3/6 = 1/2"),
            // Equivalent fractions
            ("2/4 simplified", "1/2", "2/4 = 1/2 (divide by 2)"),
            ("3/6 simplified", "1/2", "3/6 = 1/2 (divide by 3)"),
            ("4/8 simplified", "1/2", "4/8 = 1/2 (divide by 4)"),
            ("2/6 simplified", "1/3", "2/6 = 1/3 (divide by 2)"),
            ("3/9 simplified", "1/3", "3/9 = 1/3 (divide by 3)"),
            ("4/12 simplified", "1/3", "4/12 = 1/3 (divide by 4)"),
            ("6/8 simplified", "3/4", "6/8 = 3/4 (divide by 2)"),
            ("9/12 simplified", "3/4", "9/12 = 3/4 (divide by 3)")
        ]

        let wrongOptions = ["1/3", "1/4", "2/3", "3/4", "1/2", "1", "2", "1/5", "2/5", "3/5", "1/6", "5/6", "1/8", "3/8", "5/8", "7/8", "1/9", "2/9", "1/10", "3/10", "7/10", "9/10", "3/2", "5/4", "3", "4"]

        for frac in fractions {
            var options = [frac.answer]
            for opt in wrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            questions.append(Question(
                subject: .math,
                level: level,
                text: "What is \(frac.text)?",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: frac.answer) ?? 0,
                explanation: frac.explanation
            ))
        }

        // Generate more fraction comparison questions
        let comparisonFractions = [
            ("1/2", "1/3", ">"), ("3/4", "2/3", ">"), ("1/4", "1/3", "<"),
            ("2/5", "1/2", "<"), ("3/5", "1/2", ">"), ("5/8", "1/2", ">"),
            ("2/3", "3/4", "<"), ("4/5", "3/4", ">"), ("7/8", "3/4", ">")
        ]

        for (frac1, frac2, answer) in comparisonFractions {
            let options = [">", "<", "=", "Cannot compare"]
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Which is greater?\n\(frac1) ○ \(frac2)",
                options: options,
                correctIndex: options.firstIndex(of: answer) ?? 0,
                explanation: "\(frac1) \(answer) \(frac2)"
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateDecimalQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let decimals: [(text: String, answer: String, explanation: String)] = [
            // Basic addition
            ("0.5 + 0.5", "1.0", "0.5 + 0.5 = 1.0"),
            ("0.3 + 0.7", "1.0", "0.3 + 0.7 = 1.0"),
            ("0.1 + 0.9", "1.0", "0.1 + 0.9 = 1.0"),
            ("0.4 + 0.6", "1.0", "0.4 + 0.6 = 1.0"),
            ("0.2 + 0.8", "1.0", "0.2 + 0.8 = 1.0"),
            ("1.2 + 0.8", "2.0", "1.2 + 0.8 = 2.0"),
            ("0.1 + 0.2", "0.3", "0.1 + 0.2 = 0.3"),
            ("0.25 + 0.25", "0.5", "0.25 + 0.25 = 0.5"),
            ("0.75 + 0.25", "1.0", "0.75 + 0.25 = 1.0"),
            ("1.5 + 1.5", "3.0", "1.5 + 1.5 = 3.0"),
            ("2.5 + 2.5", "5.0", "2.5 + 2.5 = 5.0"),
            ("0.6 + 0.7", "1.3", "0.6 + 0.7 = 1.3"),
            ("1.25 + 0.75", "2.0", "1.25 + 0.75 = 2.0"),
            // Subtraction
            ("2.5 - 1.5", "1.0", "2.5 - 1.5 = 1.0"),
            ("3.6 - 1.2", "2.4", "3.6 - 1.2 = 2.4"),
            ("0.6 - 0.4", "0.2", "0.6 - 0.4 = 0.2"),
            ("1.0 - 0.3", "0.7", "1.0 - 0.3 = 0.7"),
            ("2.0 - 0.5", "1.5", "2.0 - 0.5 = 1.5"),
            ("5.0 - 2.5", "2.5", "5.0 - 2.5 = 2.5"),
            ("1.5 - 0.75", "0.75", "1.5 - 0.75 = 0.75"),
            ("3.0 - 1.25", "1.75", "3.0 - 1.25 = 1.75"),
            ("4.5 - 2.0", "2.5", "4.5 - 2.0 = 2.5"),
            // Multiplication
            ("0.5 × 2", "1.0", "0.5 × 2 = 1.0"),
            ("0.25 × 4", "1.0", "0.25 × 4 = 1.0"),
            ("1.5 × 2", "3.0", "1.5 × 2 = 3.0"),
            ("0.2 × 5", "1.0", "0.2 × 5 = 1.0"),
            ("0.3 × 3", "0.9", "0.3 × 3 = 0.9"),
            ("0.4 × 5", "2.0", "0.4 × 5 = 2.0"),
            ("1.25 × 4", "5.0", "1.25 × 4 = 5.0"),
            ("2.5 × 4", "10.0", "2.5 × 4 = 10.0"),
            ("0.5 × 0.5", "0.25", "0.5 × 0.5 = 0.25"),
            ("0.1 × 10", "1.0", "0.1 × 10 = 1.0"),
            ("0.01 × 100", "1.0", "0.01 × 100 = 1.0"),
            // Division
            ("2.4 ÷ 2", "1.2", "2.4 ÷ 2 = 1.2"),
            ("4.5 ÷ 3", "1.5", "4.5 ÷ 3 = 1.5"),
            ("3.0 ÷ 1.5", "2.0", "3.0 ÷ 1.5 = 2.0"),
            ("1.0 ÷ 2", "0.5", "1.0 ÷ 2 = 0.5"),
            ("1.0 ÷ 4", "0.25", "1.0 ÷ 4 = 0.25"),
            ("5.0 ÷ 2", "2.5", "5.0 ÷ 2 = 2.5"),
            ("6.0 ÷ 4", "1.5", "6.0 ÷ 4 = 1.5"),
            ("10.0 ÷ 4", "2.5", "10.0 ÷ 4 = 2.5"),
            // Decimal to fraction conversions
            ("0.5 as a fraction", "1/2", "0.5 = 1/2"),
            ("0.25 as a fraction", "1/4", "0.25 = 1/4"),
            ("0.75 as a fraction", "3/4", "0.75 = 3/4"),
            ("0.2 as a fraction", "1/5", "0.2 = 1/5"),
            ("0.1 as a fraction", "1/10", "0.1 = 1/10"),
            ("0.125 as a fraction", "1/8", "0.125 = 1/8"),
            ("0.333... as a fraction", "1/3", "0.333... = 1/3"),
            ("0.666... as a fraction", "2/3", "0.666... = 2/3"),
            // Rounding
            ("Round 2.45 to tenths", "2.5", "2.45 rounds up to 2.5"),
            ("Round 3.14 to tenths", "3.1", "3.14 rounds down to 3.1"),
            ("Round 1.75 to ones", "2", "1.75 rounds up to 2"),
            ("Round 4.49 to ones", "4", "4.49 rounds down to 4"),
            ("Round 6.5 to ones", "7", "6.5 rounds up to 7"),
            // Place value
            ("What digit is in the tenths place of 3.14?", "1", "The 1 is in the tenths place"),
            ("What digit is in the hundredths place of 3.14?", "4", "The 4 is in the hundredths place"),
            ("What is 5 tenths as a decimal?", "0.5", "5 tenths = 0.5"),
            ("What is 25 hundredths as a decimal?", "0.25", "25 hundredths = 0.25")
        ]

        let wrongOptions = ["0.5", "1.5", "2.0", "2.5", "3.0", "0.3", "0.7", "1.2", "0.8", "4.0", "0.25", "0.75", "1.0", "1.25", "1.75", "0.1", "0.2", "0.4", "0.6", "0.9", "5.0", "10.0", "1/2", "1/4", "3/4", "1/3", "2/3", "1/5", "1/8", "1/10", "1", "2", "3", "4", "5", "6", "7"]

        for dec in decimals {
            var options = [dec.answer]
            for opt in wrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()

            questions.append(Question(
                subject: .math,
                level: level,
                text: "What is \(dec.text)?",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: dec.answer) ?? 0,
                explanation: dec.explanation
            ))
        }

        // Generate dynamic decimal questions
        for a in 1...9 {
            for b in 1...9 where questions.count < 100 {
                let decA = Double(a) / 10.0
                let decB = Double(b) / 10.0
                let sum = decA + decB
                let answerStr = String(format: "%.1f", sum)
                let opts = generateDecimalOptions(correct: answerStr)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "What is \(String(format: "%.1f", decA)) + \(String(format: "%.1f", decB))?",
                    options: opts,
                    correctIndex: opts.firstIndex(of: answerStr) ?? 0,
                    explanation: "\(String(format: "%.1f", decA)) + \(String(format: "%.1f", decB)) = \(answerStr)"
                ))
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateDecimalOptions(correct: String) -> [String] {
        var options = Set<String>([correct])
        if let val = Double(correct) {
            let variations = [val + 0.1, val - 0.1, val + 0.2, val - 0.2, val + 0.5, val - 0.5]
            for v in variations where v >= 0 && options.count < 4 {
                options.insert(String(format: "%.1f", v))
            }
        }
        while options.count < 4 {
            let random = Double.random(in: 0.1...5.0)
            options.insert(String(format: "%.1f", random))
        }
        return Array(options).shuffled()
    }

    private func generatePercentageQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        // Common percentage calculations
        let baseNumbers = [20, 40, 50, 60, 80, 100, 120, 150, 200, 250, 300, 400, 500]
        let percentages = [5, 10, 15, 20, 25, 30, 40, 50, 60, 75, 80, 90, 100]

        for base in baseNumbers {
            for pct in percentages where questions.count < 80 {
                let answer = (base * pct) / 100
                if answer > 0 && answer == (base * pct) / 100 {  // Only whole number answers
                    let opts = generateUniqueOptions(correct: answer, variance: max(5, answer / 4))
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: "What is \(pct)% of \(base)?",
                        options: opts,
                        correctIndex: opts.firstIndex(of: String(answer)) ?? 0,
                        explanation: "\(pct)% of \(base) = \(base) × \(Double(pct)/100) = \(answer)"
                    ))
                }
            }
        }

        // Word problems
        let wordProblems: [(String, Int, Int)] = [
            ("A shirt costs $%d. It is on sale for 20%% off. How much is the discount?", 50, 10),
            ("A shirt costs $%d. It is on sale for 25%% off. How much is the discount?", 80, 20),
            ("There are %d students in class. 50%% are girls. How many girls are there?", 30, 15),
            ("A test has %d questions. You got 80%% correct. How many did you get right?", 50, 40),
            ("A pizza has %d slices. You ate 25%%. How many slices did you eat?", 8, 2),
            ("A book has %d pages. You read 10%%. How many pages did you read?", 200, 20),
            ("The team scored %d points. 75%% were in the first half. How many points in the first half?", 80, 60),
            ("A garden has %d flowers. 30%% are roses. How many roses are there?", 100, 30),
            ("A car trip is %d miles. You've driven 60%%. How many miles have you driven?", 150, 90),
            ("A movie is %d minutes long. 40%% of it has passed. How many minutes have passed?", 100, 40)
        ]

        for (template, value, answer) in wordProblems {
            let text = String(format: template, value)
            let opts = generateUniqueOptions(correct: answer, variance: max(3, answer / 3))
            questions.append(Question(
                subject: .math,
                level: level,
                text: text,
                options: opts,
                correctIndex: opts.firstIndex(of: String(answer)) ?? 0,
                explanation: "The answer is \(answer)"
            ))
        }

        // Percentage conversions
        let conversions: [(text: String, answer: String, explanation: String)] = [
            ("What is 1/2 as a percent?", "50%", "1/2 = 0.5 = 50%"),
            ("What is 1/4 as a percent?", "25%", "1/4 = 0.25 = 25%"),
            ("What is 3/4 as a percent?", "75%", "3/4 = 0.75 = 75%"),
            ("What is 1/5 as a percent?", "20%", "1/5 = 0.2 = 20%"),
            ("What is 2/5 as a percent?", "40%", "2/5 = 0.4 = 40%"),
            ("What is 1/10 as a percent?", "10%", "1/10 = 0.1 = 10%"),
            ("What is 0.5 as a percent?", "50%", "0.5 = 50%"),
            ("What is 0.25 as a percent?", "25%", "0.25 = 25%"),
            ("What is 0.1 as a percent?", "10%", "0.1 = 10%"),
            ("What is 0.75 as a percent?", "75%", "0.75 = 75%"),
            ("Convert 50% to a decimal", "0.5", "50% = 0.5"),
            ("Convert 25% to a decimal", "0.25", "25% = 0.25"),
            ("Convert 10% to a decimal", "0.1", "10% = 0.1"),
            ("Convert 75% to a decimal", "0.75", "75% = 0.75"),
            ("Convert 100% to a decimal", "1.0", "100% = 1.0")
        ]

        let conversionWrongOptions = ["10%", "20%", "25%", "30%", "40%", "50%", "60%", "75%", "80%", "90%", "100%", "0.1", "0.2", "0.25", "0.3", "0.4", "0.5", "0.6", "0.75", "0.8", "1.0"]

        for conv in conversions {
            var options = [conv.answer]
            for opt in conversionWrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()
            questions.append(Question(
                subject: .math,
                level: level,
                text: conv.text,
                options: options,
                correctIndex: options.firstIndex(of: conv.answer) ?? 0,
                explanation: conv.explanation
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateLinearEquationQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        // ax = b type
        for a in 2...10 {
            for x in 1...12 where questions.count < 30 {
                let b = a * x
                let opts = generateUniqueOptions(correct: x, variance: 3)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "Solve for x: \(a)x = \(b)",
                    options: opts,
                    correctIndex: opts.firstIndex(of: String(x)) ?? 0,
                    explanation: "x = \(b) ÷ \(a) = \(x)"
                ))
            }
        }

        // x + b = c type
        for b in 3...15 {
            for x in 2...20 where questions.count < 50 {
                let c = x + b
                let opts = generateUniqueOptions(correct: x, variance: 4)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "Solve for x: x + \(b) = \(c)",
                    options: opts,
                    correctIndex: opts.firstIndex(of: String(x)) ?? 0,
                    explanation: "x = \(c) - \(b) = \(x)"
                ))
            }
        }

        // x - b = c type
        for b in 2...10 {
            for x in 5...20 where questions.count < 70 {
                let c = x - b
                if c > 0 {
                    let opts = generateUniqueOptions(correct: x, variance: 3)
                    questions.append(Question(
                        subject: .math,
                        level: level,
                        text: "Solve for x: x - \(b) = \(c)",
                        options: opts,
                        correctIndex: opts.firstIndex(of: String(x)) ?? 0,
                        explanation: "x = \(c) + \(b) = \(x)"
                    ))
                }
            }
        }

        // ax + b = c type
        let twoStepEquations: [(a: Int, b: Int, x: Int)] = [
            (2, 3, 4), (2, 5, 3), (3, 2, 4), (3, 5, 2), (4, 3, 3),
            (2, 6, 5), (3, 4, 5), (5, 2, 3), (4, 8, 2), (2, 1, 7),
            (3, 6, 3), (5, 5, 4), (2, 8, 6), (4, 4, 4), (3, 9, 3),
            (6, 2, 3), (2, 10, 5), (5, 10, 2), (4, 12, 3), (3, 12, 4)
        ]

        for eq in twoStepEquations where questions.count < 100 {
            let c = eq.a * eq.x + eq.b
            let opts = generateUniqueOptions(correct: eq.x, variance: 3)
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Solve for x: \(eq.a)x + \(eq.b) = \(c)",
                options: opts,
                correctIndex: opts.firstIndex(of: String(eq.x)) ?? 0,
                explanation: "\(eq.a)x = \(c - eq.b), x = \(eq.x)"
            ))
        }

        // ax - b = c type
        for eq in twoStepEquations where questions.count < 120 {
            let c = eq.a * eq.x - eq.b
            if c > 0 {
                let opts = generateUniqueOptions(correct: eq.x, variance: 3)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "Solve for x: \(eq.a)x - \(eq.b) = \(c)",
                    options: opts,
                    correctIndex: opts.firstIndex(of: String(eq.x)) ?? 0,
                    explanation: "\(eq.a)x = \(c + eq.b), x = \(eq.x)"
                ))
            }
        }

        // x/a = b type
        for a in 2...6 {
            for b in 2...10 where questions.count < 140 {
                let x = a * b
                let opts = generateUniqueOptions(correct: x, variance: 5)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "Solve for x: x ÷ \(a) = \(b)",
                    options: opts,
                    correctIndex: opts.firstIndex(of: String(x)) ?? 0,
                    explanation: "x = \(b) × \(a) = \(x)"
                ))
            }
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateQuadraticQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let quadratics: [(text: String, answer: String, explanation: String)] = [
            // x² = n type (perfect squares)
            ("x² = 1", "x = 1 or x = -1", "√1 = ±1"),
            ("x² = 4", "x = 2 or x = -2", "√4 = ±2"),
            ("x² = 9", "x = 3 or x = -3", "√9 = ±3"),
            ("x² = 16", "x = 4 or x = -4", "√16 = ±4"),
            ("x² = 25", "x = 5 or x = -5", "√25 = ±5"),
            ("x² = 36", "x = 6 or x = -6", "√36 = ±6"),
            ("x² = 49", "x = 7 or x = -7", "√49 = ±7"),
            ("x² = 64", "x = 8 or x = -8", "√64 = ±8"),
            ("x² = 81", "x = 9 or x = -9", "√81 = ±9"),
            ("x² = 100", "x = 10 or x = -10", "√100 = ±10"),
            // x² - n = 0 type
            ("x² - 1 = 0", "x = 1 or x = -1", "x² = 1, x = ±1"),
            ("x² - 4 = 0", "x = 2 or x = -2", "x² = 4, x = ±2"),
            ("x² - 9 = 0", "x = 3 or x = -3", "x² = 9, x = ±3"),
            ("x² - 16 = 0", "x = 4 or x = -4", "x² = 16, x = ±4"),
            ("x² - 25 = 0", "x = 5 or x = -5", "x² = 25, x = ±5"),
            ("x² - 36 = 0", "x = 6 or x = -6", "x² = 36, x = ±6"),
            // Factored form
            ("(x-1)(x-2) = 0", "x = 1 or x = 2", "Zero product property"),
            ("(x+1)(x-3) = 0", "x = -1 or x = 3", "Zero product property"),
            ("(x-2)(x-4) = 0", "x = 2 or x = 4", "Zero product property"),
            ("(x+2)(x-1) = 0", "x = -2 or x = 1", "Zero product property"),
            ("(x-3)(x+3) = 0", "x = 3 or x = -3", "Zero product property"),
            ("(x+4)(x-2) = 0", "x = -4 or x = 2", "Zero product property"),
            ("(x-5)(x+1) = 0", "x = 5 or x = -1", "Zero product property"),
            ("(x+2)(x+3) = 0", "x = -2 or x = -3", "Zero product property"),
            ("(x-1)(x-5) = 0", "x = 1 or x = 5", "Zero product property"),
            ("(x+1)(x+4) = 0", "x = -1 or x = -4", "Zero product property"),
            // Standard form (factoring)
            ("x² + x - 6 = 0", "x = 2 or x = -3", "Factors: (x-2)(x+3) = 0"),
            ("x² - 5x + 6 = 0", "x = 2 or x = 3", "Factors: (x-2)(x-3) = 0"),
            ("x² - x - 2 = 0", "x = 2 or x = -1", "Factors: (x-2)(x+1) = 0"),
            ("x² + 2x - 8 = 0", "x = 2 or x = -4", "Factors: (x-2)(x+4) = 0"),
            ("x² - 4x + 3 = 0", "x = 1 or x = 3", "Factors: (x-1)(x-3) = 0"),
            ("x² - 6x + 8 = 0", "x = 2 or x = 4", "Factors: (x-2)(x-4) = 0"),
            ("x² + 5x + 6 = 0", "x = -2 or x = -3", "Factors: (x+2)(x+3) = 0"),
            ("x² - 7x + 12 = 0", "x = 3 or x = 4", "Factors: (x-3)(x-4) = 0"),
            ("x² + 3x - 10 = 0", "x = 2 or x = -5", "Factors: (x-2)(x+5) = 0"),
            ("x² - 2x - 15 = 0", "x = 5 or x = -3", "Factors: (x-5)(x+3) = 0"),
            ("x² + 6x + 5 = 0", "x = -1 or x = -5", "Factors: (x+1)(x+5) = 0"),
            ("x² - 8x + 15 = 0", "x = 3 or x = 5", "Factors: (x-3)(x-5) = 0"),
            ("x² + 4x - 12 = 0", "x = 2 or x = -6", "Factors: (x-2)(x+6) = 0"),
            ("x² - 3x - 10 = 0", "x = 5 or x = -2", "Factors: (x-5)(x+2) = 0"),
            // Vertex form questions
            ("What is the vertex of y = x² - 4?", "(0, -4)", "Vertex at (h, k)"),
            ("What is the vertex of y = (x-2)²?", "(2, 0)", "Vertex at (h, k)"),
            ("What is the vertex of y = (x+1)² + 3?", "(-1, 3)", "Vertex at (-1, 3)"),
            ("What is the vertex of y = (x-3)² - 1?", "(3, -1)", "Vertex at (3, -1)"),
            // Direction questions
            ("Does y = x² open up or down?", "Up", "Positive coefficient means opens up"),
            ("Does y = -x² open up or down?", "Down", "Negative coefficient means opens down"),
            ("Does y = 2x² + 3 open up or down?", "Up", "Positive coefficient means opens up"),
            ("Does y = -3x² + 1 open up or down?", "Down", "Negative coefficient means opens down")
        ]

        let wrongOptions = [
            "x = 1 or x = -1", "x = 2 or x = -2", "x = 3 or x = -3", "x = 4 or x = -4",
            "x = 5 or x = -5", "x = 6 or x = -6", "x = 0 or x = 1", "x = 1 or x = 2",
            "x = 2 or x = 3", "x = 3 or x = 4", "x = 1 or x = 3", "x = 2 or x = 4",
            "x = -1 or x = 2", "x = -2 or x = 3", "x = -1 or x = 3", "x = -2 or x = 1",
            "(0, 0)", "(1, 0)", "(0, 1)", "(2, 0)", "(0, 2)", "(-1, 0)", "(0, -1)",
            "(1, 1)", "(-1, -1)", "(2, 2)", "(-2, -2)", "(3, -1)", "(-1, 3)", "(2, -4)",
            "Up", "Down", "Left", "Right"
        ]

        for quad in quadratics {
            var options = [quad.answer]
            for opt in wrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Solve: \(quad.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: quad.answer) ?? 0,
                explanation: quad.explanation
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateGeometryQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        // Rectangle areas
        for l in 2...12 {
            for w in 2...10 where questions.count < 30 {
                let area = l * w
                let opts = generateUniqueOptions(correct: area, variance: 8)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "Area of rectangle: \(l) × \(w)",
                    options: opts,
                    correctIndex: opts.firstIndex(of: String(area)) ?? 0,
                    explanation: "Area = length × width = \(l) × \(w) = \(area)"
                ))
            }
        }

        // Square areas
        for s in 2...12 {
            let area = s * s
            let opts = generateUniqueOptions(correct: area, variance: 10)
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Area of square: side = \(s)",
                options: opts,
                correctIndex: opts.firstIndex(of: String(area)) ?? 0,
                explanation: "Area = s² = \(s)² = \(area)"
            ))
        }

        // Triangle areas
        for b in [4, 6, 8, 10, 12] {
            for h in [2, 4, 6, 8, 10] {
                let area = (b * h) / 2
                let opts = generateUniqueOptions(correct: area, variance: 6)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "Triangle area: base=\(b), height=\(h)",
                    options: opts,
                    correctIndex: opts.firstIndex(of: String(area)) ?? 0,
                    explanation: "Area = (1/2) × \(b) × \(h) = \(area)"
                ))
            }
        }

        // Perimeters
        for s in 3...10 {
            let perim = 4 * s
            let opts = generateUniqueOptions(correct: perim, variance: 6)
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Perimeter of square: side = \(s)",
                options: opts,
                correctIndex: opts.firstIndex(of: String(perim)) ?? 0,
                explanation: "Perimeter = 4 × \(s) = \(perim)"
            ))
        }

        for l in 3...8 {
            for w in 2...6 where l > w {
                let perim = 2 * (l + w)
                let opts = generateUniqueOptions(correct: perim, variance: 5)
                questions.append(Question(
                    subject: .math,
                    level: level,
                    text: "Perimeter of rectangle: \(l) × \(w)",
                    options: opts,
                    correctIndex: opts.firstIndex(of: String(perim)) ?? 0,
                    explanation: "Perimeter = 2(\(l)+\(w)) = \(perim)"
                ))
            }
        }

        // Cube volumes
        for s in 2...6 {
            let vol = s * s * s
            let opts = generateUniqueOptions(correct: vol, variance: 15)
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Volume of cube: side = \(s)",
                options: opts,
                correctIndex: opts.firstIndex(of: String(vol)) ?? 0,
                explanation: "V = s³ = \(s)³ = \(vol)"
            ))
        }

        // Pythagorean theorem
        let pythagoreanTriples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25), (6,8,10), (9,12,15), (5,5,7), (4,3,5)]
        for (a, b, _) in pythagoreanTriples {
            let c2 = a*a + b*b
            let opts = generateUniqueOptions(correct: c2, variance: 20)
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Pythagorean: \(a)² + \(b)² = ?",
                options: opts,
                correctIndex: opts.firstIndex(of: String(c2)) ?? 0,
                explanation: "\(a*a) + \(b*b) = \(c2)"
            ))
        }

        // Angle questions
        let angleQuestions: [(String, Int, String)] = [
            ("Sum of angles in a triangle", 180, "Triangle angles sum to 180°"),
            ("Sum of angles in a quadrilateral", 360, "Quadrilateral angles sum to 360°"),
            ("Each angle in an equilateral triangle", 60, "180° ÷ 3 = 60°"),
            ("Each angle in a square", 90, "360° ÷ 4 = 90°"),
            ("Sum of angles in a pentagon", 540, "(5-2) × 180° = 540°"),
            ("Sum of angles in a hexagon", 720, "(6-2) × 180° = 720°"),
            ("Supplementary angle to 60°", 120, "180° - 60° = 120°"),
            ("Complementary angle to 30°", 60, "90° - 30° = 60°"),
            ("Vertical angle to 45°", 45, "Vertical angles are equal")
        ]

        for (text, answer, explanation) in angleQuestions {
            let opts = generateUniqueOptions(correct: answer, variance: 30)
            questions.append(Question(
                subject: .math,
                level: level,
                text: text,
                options: opts,
                correctIndex: opts.firstIndex(of: String(answer)) ?? 0,
                explanation: explanation
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateTrigQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let trig: [(text: String, answer: String, explanation: String)] = [
            // Basic sine values
            ("sin(0°)", "0", "sin(0°) = 0"),
            ("sin(30°)", "1/2", "sin(30°) = 1/2"),
            ("sin(45°)", "√2/2", "sin(45°) = √2/2"),
            ("sin(60°)", "√3/2", "sin(60°) = √3/2"),
            ("sin(90°)", "1", "sin(90°) = 1"),
            ("sin(180°)", "0", "sin(180°) = 0"),
            ("sin(270°)", "-1", "sin(270°) = -1"),
            ("sin(360°)", "0", "sin(360°) = 0"),
            // Basic cosine values
            ("cos(0°)", "1", "cos(0°) = 1"),
            ("cos(30°)", "√3/2", "cos(30°) = √3/2"),
            ("cos(45°)", "√2/2", "cos(45°) = √2/2"),
            ("cos(60°)", "1/2", "cos(60°) = 1/2"),
            ("cos(90°)", "0", "cos(90°) = 0"),
            ("cos(180°)", "-1", "cos(180°) = -1"),
            ("cos(270°)", "0", "cos(270°) = 0"),
            ("cos(360°)", "1", "cos(360°) = 1"),
            // Basic tangent values
            ("tan(0°)", "0", "tan(0°) = 0"),
            ("tan(30°)", "√3/3", "tan(30°) = √3/3"),
            ("tan(45°)", "1", "tan(45°) = 1"),
            ("tan(60°)", "√3", "tan(60°) = √3"),
            ("tan(90°)", "undefined", "tan(90°) is undefined"),
            ("tan(180°)", "0", "tan(180°) = 0"),
            // Radian values
            ("sin(π/6)", "1/2", "π/6 = 30°, sin = 1/2"),
            ("sin(π/4)", "√2/2", "π/4 = 45°, sin = √2/2"),
            ("sin(π/3)", "√3/2", "π/3 = 60°, sin = √3/2"),
            ("sin(π/2)", "1", "π/2 = 90°, sin = 1"),
            ("sin(π)", "0", "π = 180°, sin = 0"),
            ("cos(π/6)", "√3/2", "π/6 = 30°, cos = √3/2"),
            ("cos(π/4)", "√2/2", "π/4 = 45°, cos = √2/2"),
            ("cos(π/3)", "1/2", "π/3 = 60°, cos = 1/2"),
            ("cos(π/2)", "0", "π/2 = 90°, cos = 0"),
            ("cos(π)", "-1", "π = 180°, cos = -1"),
            // Identities
            ("sin²(30°) + cos²(30°)", "1", "Pythagorean identity: always = 1"),
            ("sin²(45°) + cos²(45°)", "1", "Pythagorean identity: always = 1"),
            ("sin²(60°) + cos²(60°)", "1", "Pythagorean identity: always = 1"),
            ("2sin(30°)cos(30°)", "√3/2", "Double angle: sin(60°) = √3/2"),
            ("cos²(45°) - sin²(45°)", "0", "Double angle: cos(90°) = 0"),
            // Inverse trig
            ("arcsin(0)", "0°", "sin(0°) = 0"),
            ("arcsin(1/2)", "30°", "sin(30°) = 1/2"),
            ("arcsin(1)", "90°", "sin(90°) = 1"),
            ("arccos(0)", "90°", "cos(90°) = 0"),
            ("arccos(1)", "0°", "cos(0°) = 1"),
            ("arctan(0)", "0°", "tan(0°) = 0"),
            ("arctan(1)", "45°", "tan(45°) = 1"),
            // SOH CAH TOA questions
            ("In a right triangle, opposite=3, hypotenuse=5. What is sin(θ)?", "3/5", "sin = opposite/hypotenuse"),
            ("In a right triangle, adjacent=4, hypotenuse=5. What is cos(θ)?", "4/5", "cos = adjacent/hypotenuse"),
            ("In a right triangle, opposite=3, adjacent=4. What is tan(θ)?", "3/4", "tan = opposite/adjacent"),
            ("In a right triangle, opposite=5, hypotenuse=13. What is sin(θ)?", "5/13", "sin = opposite/hypotenuse"),
            ("In a right triangle, adjacent=12, hypotenuse=13. What is cos(θ)?", "12/13", "cos = adjacent/hypotenuse")
        ]

        let wrongOptions = ["0", "1", "-1", "1/2", "-1/2", "√2/2", "-√2/2", "√3/2", "-√3/2", "√3", "-√3", "√3/3", "-√3/3", "undefined", "2", "0°", "30°", "45°", "60°", "90°", "180°", "3/5", "4/5", "5/13", "12/13", "3/4", "4/3"]

        for t in trig {
            var options = [t.answer]
            for opt in wrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()
            questions.append(Question(
                subject: .math,
                level: level,
                text: "What is \(t.text)?",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: t.answer) ?? 0,
                explanation: t.explanation
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateDerivativeQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let derivatives: [(text: String, answer: String, explanation: String)] = [
            // Power rule
            ("d/dx[x]", "1", "Derivative of x = 1"),
            ("d/dx[x²]", "2x", "Power rule: nx^(n-1)"),
            ("d/dx[x³]", "3x²", "Power rule: 3x^(3-1) = 3x²"),
            ("d/dx[x⁴]", "4x³", "Power rule: 4x^(4-1) = 4x³"),
            ("d/dx[x⁵]", "5x⁴", "Power rule: 5x^(5-1)"),
            ("d/dx[x⁶]", "6x⁵", "Power rule: 6x^(6-1)"),
            ("d/dx[x⁻¹]", "-x⁻²", "Power rule: -1·x^(-2)"),
            ("d/dx[x^(1/2)]", "1/(2√x)", "Power rule with fractional exponent"),
            // Constant multiples
            ("d/dx[5x]", "5", "Derivative of ax = a"),
            ("d/dx[3x²]", "6x", "3 × 2x = 6x"),
            ("d/dx[2x³]", "6x²", "2 × 3x² = 6x²"),
            ("d/dx[4x⁴]", "16x³", "4 × 4x³ = 16x³"),
            ("d/dx[7x]", "7", "Derivative of ax = a"),
            ("d/dx[-2x²]", "-4x", "-2 × 2x = -4x"),
            // Constants
            ("d/dx[5]", "0", "Derivative of a constant is 0"),
            ("d/dx[100]", "0", "Derivative of a constant is 0"),
            ("d/dx[π]", "0", "π is a constant"),
            // Sum/difference rule
            ("d/dx[x² + x]", "2x + 1", "Sum rule: d/dx[x²] + d/dx[x]"),
            ("d/dx[x² - 3x]", "2x - 3", "Difference rule"),
            ("d/dx[4x³ + 2x]", "12x² + 2", "Sum rule"),
            ("d/dx[x + 5]", "1", "Derivative of x is 1, constant is 0"),
            ("d/dx[x³ - x²]", "3x² - 2x", "Difference rule"),
            ("d/dx[x⁴ + x³ + x²]", "4x³ + 3x² + 2x", "Sum rule"),
            ("d/dx[2x² - 3x + 1]", "4x - 3", "Polynomial derivative"),
            // Trig functions
            ("d/dx[sin(x)]", "cos(x)", "Standard derivative"),
            ("d/dx[cos(x)]", "-sin(x)", "Standard derivative"),
            ("d/dx[tan(x)]", "sec²(x)", "Standard derivative"),
            ("d/dx[sec(x)]", "sec(x)tan(x)", "Standard derivative"),
            ("d/dx[csc(x)]", "-csc(x)cot(x)", "Standard derivative"),
            ("d/dx[cot(x)]", "-csc²(x)", "Standard derivative"),
            // Exponential and log
            ("d/dx[e^x]", "e^x", "e^x is its own derivative"),
            ("d/dx[ln(x)]", "1/x", "Standard derivative"),
            ("d/dx[2^x]", "2^x·ln(2)", "Exponential rule: a^x·ln(a)"),
            ("d/dx[log₁₀(x)]", "1/(x·ln(10))", "Logarithm base change"),
            // Product rule examples
            ("d/dx[x·sin(x)]", "sin(x) + x·cos(x)", "Product rule: f'g + fg'"),
            ("d/dx[x·e^x]", "e^x + x·e^x", "Product rule: e^x(1 + x)"),
            ("d/dx[x²·ln(x)]", "2x·ln(x) + x", "Product rule"),
            // Chain rule examples
            ("d/dx[sin(2x)]", "2cos(2x)", "Chain rule: cos(2x)·2"),
            ("d/dx[e^(2x)]", "2e^(2x)", "Chain rule: e^(2x)·2"),
            ("d/dx[(x+1)²]", "2(x+1)", "Chain rule: 2(x+1)·1"),
            ("d/dx[ln(2x)]", "1/x", "Chain rule: (1/2x)·2 = 1/x"),
            ("d/dx[cos(3x)]", "-3sin(3x)", "Chain rule: -sin(3x)·3"),
            // Quotient rule
            ("d/dx[1/x]", "-1/x²", "Quotient rule or power rule"),
            ("d/dx[x/(x+1)]", "1/(x+1)²", "Quotient rule"),
            // Higher derivatives
            ("d²/dx²[x³]", "6x", "Second derivative: d/dx[3x²]"),
            ("d²/dx²[x⁴]", "12x²", "Second derivative: d/dx[4x³]"),
            ("d²/dx²[sin(x)]", "-sin(x)", "Second derivative of sin"),
            ("d²/dx²[e^x]", "e^x", "Second derivative of e^x")
        ]

        let wrongOptions = ["x", "2x", "3x²", "4x³", "x²", "x³", "cos(x)", "sin(x)", "-sin(x)", "-cos(x)", "e^x", "1/x", "-1/x²", "6x", "6x²", "12x²", "1", "0", "sec²(x)", "tan(x)", "2x + 1", "2x - 3", "4x - 3", "1/(x+1)²"]

        for d in derivatives {
            var options = [d.answer]
            for opt in wrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Find \(d.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: d.answer) ?? 0,
                explanation: d.explanation
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateIntegralQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let integrals: [(text: String, answer: String, explanation: String)] = [
            // Power rule
            ("∫1 dx", "x + C", "Integral of constant"),
            ("∫x dx", "x²/2 + C", "Power rule: x^(n+1)/(n+1)"),
            ("∫x² dx", "x³/3 + C", "x^(2+1)/(2+1) = x³/3"),
            ("∫x³ dx", "x⁴/4 + C", "x^(3+1)/(3+1) = x⁴/4"),
            ("∫x⁴ dx", "x⁵/5 + C", "Power rule"),
            ("∫x⁵ dx", "x⁶/6 + C", "Power rule"),
            ("∫x⁻² dx", "-1/x + C", "∫x⁻² = x⁻¹/(-1) = -1/x"),
            ("∫√x dx", "2x^(3/2)/3 + C", "∫x^(1/2) = x^(3/2)/(3/2)"),
            // Constant multiples
            ("∫2x dx", "x² + C", "2 × x²/2 = x²"),
            ("∫3x² dx", "x³ + C", "3 × x³/3 = x³"),
            ("∫4x³ dx", "x⁴ + C", "4 × x⁴/4 = x⁴"),
            ("∫5 dx", "5x + C", "5 times x"),
            ("∫6x dx", "3x² + C", "6 × x²/2 = 3x²"),
            ("∫10x⁴ dx", "2x⁵ + C", "10 × x⁵/5 = 2x⁵"),
            // Sum rule
            ("∫(x + 1) dx", "x²/2 + x + C", "Sum rule"),
            ("∫(2x + 3) dx", "x² + 3x + C", "Sum rule"),
            ("∫(x² + x) dx", "x³/3 + x²/2 + C", "Sum rule"),
            ("∫(3x² + 2x + 1) dx", "x³ + x² + x + C", "Sum rule"),
            ("∫(x³ - x) dx", "x⁴/4 - x²/2 + C", "Difference rule"),
            // Trigonometric
            ("∫cos(x) dx", "sin(x) + C", "Standard integral"),
            ("∫sin(x) dx", "-cos(x) + C", "Standard integral"),
            ("∫sec²(x) dx", "tan(x) + C", "Standard integral"),
            ("∫csc²(x) dx", "-cot(x) + C", "Standard integral"),
            ("∫sec(x)tan(x) dx", "sec(x) + C", "Standard integral"),
            ("∫csc(x)cot(x) dx", "-csc(x) + C", "Standard integral"),
            // Exponential and logarithmic
            ("∫e^x dx", "e^x + C", "e^x integrates to itself"),
            ("∫1/x dx", "ln|x| + C", "Standard integral"),
            ("∫e^(2x) dx", "e^(2x)/2 + C", "Chain rule: divide by 2"),
            ("∫e^(-x) dx", "-e^(-x) + C", "Chain rule"),
            ("∫2^x dx", "2^x/ln(2) + C", "∫a^x = a^x/ln(a)"),
            // Substitution type
            ("∫cos(2x) dx", "sin(2x)/2 + C", "Divide by inner derivative"),
            ("∫sin(3x) dx", "-cos(3x)/3 + C", "Divide by inner derivative"),
            ("∫(2x+1)² dx", "(2x+1)³/6 + C", "u-substitution"),
            // Definite integrals
            ("∫₀¹ x dx", "1/2", "[x²/2]₀¹ = 1/2 - 0"),
            ("∫₀¹ x² dx", "1/3", "[x³/3]₀¹ = 1/3 - 0"),
            ("∫₀^π sin(x) dx", "2", "[-cos(x)]₀^π = 1-(-1) = 2"),
            ("∫₀¹ e^x dx", "e - 1", "[e^x]₀¹ = e - 1"),
            ("∫₁^e 1/x dx", "1", "[ln(x)]₁^e = 1 - 0"),
            ("∫₀² 2x dx", "4", "[x²]₀² = 4 - 0"),
            ("∫₀^(π/2) cos(x) dx", "1", "[sin(x)]₀^(π/2) = 1 - 0"),
            ("∫₁² x dx", "3/2", "[x²/2]₁² = 2 - 1/2 = 3/2"),
            // Integration by parts type answers
            ("∫x·e^x dx", "xe^x - e^x + C", "Integration by parts"),
            ("∫x·cos(x) dx", "x·sin(x) + cos(x) + C", "Integration by parts"),
            ("∫ln(x) dx", "x·ln(x) - x + C", "Integration by parts")
        ]

        let wrongOptions = ["x + C", "x² + C", "x³ + C", "x²/2 + C", "x³/3 + C", "x⁴/4 + C", "2x + C", "3x² + C", "sin(x) + C", "-sin(x) + C", "cos(x) + C", "-cos(x) + C", "e^x + C", "ln|x| + C", "tan(x) + C", "1/2", "1/3", "1", "2", "e - 1", "3/2", "4"]

        for i in integrals {
            var options = [i.answer]
            for opt in wrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Evaluate \(i.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: i.answer) ?? 0,
                explanation: i.explanation
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    private func generateMultivariableQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let multivariable: [(text: String, answer: String, explanation: String)] = [
            // Basic partial derivatives
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
            ("∂/∂x[x²y³]", "2xy³", "Power rule in x"),
            ("∂/∂y[x²y³]", "3x²y²", "Power rule in y"),
            ("∂/∂x[3xy]", "3y", "Constant multiple"),
            ("∂/∂y[3xy]", "3x", "Constant multiple"),
            ("∂/∂x[x + y]", "1", "Derivative of x is 1"),
            ("∂/∂y[x + y]", "1", "Derivative of y is 1"),
            ("∂/∂x[5x²]", "10x", "No y dependence"),
            ("∂/∂y[5x²]", "0", "No y dependence"),
            // With three variables
            ("∂/∂x[xyz]", "yz", "y and z are constants"),
            ("∂/∂y[xyz]", "xz", "x and z are constants"),
            ("∂/∂z[xyz]", "xy", "x and y are constants"),
            ("∂/∂x[x²yz]", "2xyz", "Power rule in x"),
            ("∂/∂y[x²yz]", "x²z", "y is linear"),
            ("∂/∂z[x²yz]", "x²y", "z is linear"),
            // Chain rule
            ("∂/∂x[e^(xy)]", "ye^(xy)", "Chain rule"),
            ("∂/∂y[e^(xy)]", "xe^(xy)", "Chain rule"),
            ("∂/∂x[sin(xy)]", "y·cos(xy)", "Chain rule"),
            ("∂/∂y[sin(xy)]", "x·cos(xy)", "Chain rule"),
            ("∂/∂x[ln(xy)]", "1/x", "Chain rule: y/(xy) = 1/x"),
            ("∂/∂y[ln(xy)]", "1/y", "Chain rule: x/(xy) = 1/y"),
            ("∂/∂x[(x+y)²]", "2(x+y)", "Chain rule"),
            ("∂/∂y[(x+y)²]", "2(x+y)", "Chain rule"),
            // Second derivatives
            ("∂²/∂x²[x³]", "6x", "Second derivative"),
            ("∂²/∂x²[x²y]", "2y", "Second partial in x"),
            ("∂²/∂y²[xy²]", "2x", "Second partial in y"),
            ("∂²/∂x∂y[xy]", "1", "Mixed partial"),
            ("∂²/∂x∂y[x²y²]", "4xy", "Mixed partial"),
            // Gradient
            ("∇(x² + y²) at (1,1)", "(2, 2)", "Gradient: (2x, 2y)"),
            ("∇(x² + y²) at (2,3)", "(4, 6)", "Gradient: (2x, 2y)"),
            ("∇(xy) at (1,1)", "(1, 1)", "Gradient: (y, x)"),
            ("∇(xy) at (2,3)", "(3, 2)", "Gradient: (y, x)"),
            ("∇(x² - y²) at (1,1)", "(2, -2)", "Gradient: (2x, -2y)"),
            // Divergence and curl concepts
            ("div(xi + yj) =", "2", "∂x/∂x + ∂y/∂y = 1 + 1"),
            ("div(x²i + y²j) =", "2x + 2y", "∂(x²)/∂x + ∂(y²)/∂y"),
            // Laplacian
            ("∇²(x² + y²)", "4", "∂²/∂x² + ∂²/∂y² = 2 + 2"),
            ("∇²(x²y)", "2y", "∂²/∂x²(x²y) + ∂²/∂y²(x²y) = 2y + 0")
        ]

        let wrongOptions = ["x", "y", "2x", "2y", "xy", "x²", "y²", "2xy", "3xy", "yz", "xz", "(1, 1)", "(2, 2)", "(3, 2)", "(2, 3)", "(4, 6)", "(2, -2)", "0", "1", "2", "4", "6x", "2y", "3x²y²", "2x³y", "xe^(xy)", "ye^(xy)", "1/x", "1/y", "2(x+y)", "2x + 2y", "4xy"]

        for m in multivariable {
            var options = [m.answer]
            for opt in wrongOptions.shuffled() where !options.contains(opt) && options.count < 4 {
                options.append(opt)
            }
            options.shuffle()
            questions.append(Question(
                subject: .math,
                level: level,
                text: "Find \(m.text)",
                options: Array(options.prefix(4)),
                correctIndex: options.firstIndex(of: m.answer) ?? 0,
                explanation: m.explanation
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    // MARK: - Grammar Questions

    private func generateGrammarQuestionsForLevel(_ level: Int) -> [Question] {
        switch level {
        case 1...5:
            return generatePreKGrammarQuestions(level: level)
        case 6...15:
            return generateElementaryGrammarQuestions(level: level)
        case 16...30:
            return generateMiddleSchoolGrammarQuestions(level: level)
        case 31...45:
            return generateHighSchoolGrammarQuestions(level: level)
        default:
            return generateAdvancedGrammarQuestions(level: level)
        }
    }

    // PreK-K: Basic sentence concepts with emojis
    private func generatePreKGrammarQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        // Capital letters
        let capitalQuestions: [(String, [String], Int, String)] = [
            ("Which letter is uppercase? 🔤", ["a", "A", "b", "c"], 1, "A is the uppercase letter"),
            ("Which letter is uppercase? 🔤", ["b", "c", "B", "d"], 2, "B is the uppercase letter"),
            ("Which letter is lowercase? 🔤", ["A", "B", "c", "D"], 2, "c is the lowercase letter"),
            ("Which starts a sentence?", ["dog", "The", "and", "cat"], 1, "Sentences start with capital letters"),
            ("Which is a capital letter?", ["m", "n", "P", "q"], 2, "P is the capital letter"),
        ]

        // Period recognition
        let periodQuestions: [(String, [String], Int, String)] = [
            ("What goes at the end of a sentence? 📝", [".", "a", "the", "go"], 0, "A period ends a sentence"),
            ("Which sentence is correct?", ["I like cats.", "I like cats", "i like cats.", "I like cats,"], 0, "Correct capitalization and period"),
            ("What mark ends 'I am happy'?", [".", "?", "!", ","], 0, "Statements end with a period"),
        ]

        // Question marks
        let questionQuestions: [(String, [String], Int, String)] = [
            ("What goes at the end of a question? ❓", [".", "?", "!", ","], 1, "Questions end with ?"),
            ("Which is a question?", ["I am happy.", "Are you happy?", "Happy day!", "The happy cat."], 1, "Questions ask something"),
            ("'How are you' needs what mark?", [".", "?", "!", ","], 1, "It's asking something"),
        ]

        // Exclamation marks
        let exclamationQuestions: [(String, [String], Int, String)] = [
            ("What shows excitement? 🎉", [".", "?", "!", ","], 2, "! shows excitement"),
            ("Which shows excitement?", ["I like cake.", "Do you like cake?", "I love cake!", "Cake is good."], 2, "The ! shows excitement"),
            ("'Wow' needs what mark?", [".", "?", "!", ","], 2, "'Wow' shows excitement"),
        ]

        // Naming words (nouns)
        let nounQuestions: [(String, [String], Int, String)] = [
            ("Which is a naming word? 🏷️", ["run", "cat", "big", "fast"], 1, "'Cat' names a thing"),
            ("Which names a person?", ["run", "big", "mom", "happy"], 2, "'Mom' names a person"),
            ("Which names a place?", ["jump", "park", "red", "soft"], 1, "'Park' names a place"),
            ("Which names a thing?", ["ball", "run", "happy", "big"], 0, "'Ball' names a thing"),
            ("🐕 is a...", ["action word", "naming word", "describing word", "joining word"], 1, "Dog is a naming word (noun)"),
        ]

        // Action words (verbs)
        let verbQuestions: [(String, [String], Int, String)] = [
            ("Which is an action word? 🏃", ["cat", "run", "big", "the"], 1, "'Run' is an action"),
            ("Which shows action?", ["dog", "jump", "red", "happy"], 1, "'Jump' is an action"),
            ("What can you do?", ["cat", "book", "swim", "red"], 2, "'Swim' is an action you do"),
            ("Which is something you do?", ["eat", "house", "blue", "soft"], 0, "'Eat' is an action"),
        ]

        // Color words (adjectives intro)
        let colorQuestions: [(String, [String], Int, String)] = [
            ("🔴 is what color?", ["red", "blue", "green", "yellow"], 0, "Red is the color"),
            ("🔵 is what color?", ["red", "blue", "green", "yellow"], 1, "Blue is the color"),
            ("🟢 is what color?", ["red", "blue", "green", "yellow"], 2, "Green is the color"),
            ("🟡 is what color?", ["red", "blue", "green", "yellow"], 3, "Yellow is the color"),
        ]

        // Combine all PreK questions
        for q in capitalQuestions + periodQuestions + questionQuestions + exclamationQuestions + nounQuestions + verbQuestions + colorQuestions {
            var opts = q.1
            opts.shuffle()
            let correctAnswer = q.1[q.2]
            questions.append(Question(
                subject: .grammar,
                level: level,
                text: q.0,
                options: opts,
                correctIndex: opts.firstIndex(of: correctAnswer) ?? 0,
                explanation: q.3
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    // Grades 1-3: Elementary grammar
    private func generateElementaryGrammarQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let elementaryQuestions: [(String, [String], Int, String)] = [
            // Nouns
            ("Which is a noun?", ["happy", "quickly", "table", "run"], 2, "A noun names a person, place, or thing"),
            ("Which is a common noun?", ["Sarah", "city", "Monday", "Canada"], 1, "Common nouns are not capitalized"),
            ("Which is a proper noun?", ["dog", "park", "Texas", "book"], 2, "Proper nouns are capitalized"),
            ("Plural of 'cat'?", ["cats", "cates", "caties", "cat's"], 0, "Add 's' to make plural"),
            ("Plural of 'box'?", ["boxs", "boxes", "boxies", "box's"], 1, "Add 'es' after x"),
            ("Plural of 'baby'?", ["babys", "babyes", "babies", "baby's"], 2, "Change y to ies"),
            ("Plural of 'child'?", ["childs", "childes", "children", "child's"], 2, "Irregular plural"),

            // Verbs
            ("Which is a verb?", ["happy", "dog", "jump", "red"], 2, "Verbs show action"),
            ("Past tense of 'walk'?", ["walks", "walked", "walking", "walken"], 1, "Add -ed for past tense"),
            ("Past tense of 'run'?", ["runned", "runed", "ran", "runs"], 2, "Irregular past tense"),
            ("Past tense of 'go'?", ["goed", "went", "goes", "going"], 1, "Irregular past tense"),
            ("'She ___ to school.'", ["go", "goes", "going", "gone"], 1, "She takes 'goes'"),
            ("'They ___ happy.'", ["is", "am", "are", "be"], 2, "They takes 'are'"),
            ("'I ___ a student.'", ["is", "am", "are", "be"], 1, "I takes 'am'"),

            // Adjectives
            ("Which word describes?", ["big", "run", "table", "the"], 0, "Adjectives describe nouns"),
            ("Which is an adjective?", ["quickly", "beautiful", "eat", "dog"], 1, "'Beautiful' describes"),
            ("'The ___ dog ran.'", ["quick", "quickly", "quicker", "quicken"], 0, "Adjective before noun"),
            ("Opposite of 'hot'?", ["warm", "cold", "hotter", "heat"], 1, "'Cold' is opposite"),
            ("Opposite of 'big'?", ["large", "huge", "small", "bigger"], 2, "'Small' is opposite"),

            // Pronouns
            ("Which can replace 'Sarah'?", ["he", "she", "it", "they"], 1, "'She' replaces a girl's name"),
            ("Which can replace 'the dog'?", ["he", "she", "it", "they"], 2, "'It' replaces a thing"),
            ("Which can replace 'Tom and I'?", ["he", "she", "it", "we"], 3, "'We' replaces us"),
            ("'___ is my friend.'", ["Him", "Her", "She", "They"], 2, "'She' is a subject pronoun"),

            // Articles
            ("'___ apple' (which article?)", ["a", "an", "the", "some"], 1, "'An' before vowel sounds"),
            ("'___ dog' (which article?)", ["a", "an", "the", "some"], 0, "'A' before consonant sounds"),
            ("'___ umbrella'", ["a", "an", "the", "some"], 1, "'An' before vowel sounds"),
            ("'___ hour'", ["a", "an", "the", "some"], 1, "'An' because h is silent"),

            // Simple sentences
            ("Which is a complete sentence?", ["The big dog.", "Runs fast.", "The dog runs.", "Big and brown."], 2, "Has subject and verb"),
            ("Which is NOT a sentence?", ["I am happy.", "She runs.", "The tall.", "We play."], 2, "Missing a verb"),
            ("What's missing? 'The cat ___.'", ["meowed", "big", "and", "the"], 0, "Needs a verb"),
        ]

        for q in elementaryQuestions {
            var opts = q.1
            opts.shuffle()
            let correctAnswer = q.1[q.2]
            questions.append(Question(
                subject: .grammar,
                level: level,
                text: q.0,
                options: opts,
                correctIndex: opts.firstIndex(of: correctAnswer) ?? 0,
                explanation: q.3
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    // Grades 4-6: Middle school grammar
    private func generateMiddleSchoolGrammarQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let middleQuestions: [(String, [String], Int, String)] = [
            // Subject-verb agreement
            ("'The team ___ winning.'", ["are", "is", "were", "be"], 1, "Collective nouns take singular verbs"),
            ("'Everyone ___ opinions.'", ["have", "has", "having", "had have"], 1, "'Everyone' is singular"),
            ("'The news ___ bad.'", ["are", "is", "were", "be"], 1, "'News' is singular"),
            ("'Neither ___ correct.'", ["are", "is", "were", "be"], 1, "'Neither' is singular"),
            ("'The scissors ___ sharp.'", ["is", "are", "was", "be"], 1, "'Scissors' takes plural"),

            // Pronoun cases
            ("Which is correct?", ["Me and him went.", "Him and I went.", "He and I went.", "He and me went."], 2, "Use 'I' as subject"),
            ("Which is correct?", ["Between you and I.", "Between you and me.", "Between I and you.", "Me and you."], 1, "'Me' after prepositions"),
            ("Which is correct?", ["Give it to John and I.", "Give it to John and me.", "Give it to I and John.", "Give to myself."], 1, "'Me' as object"),
            ("'___ students need help.'", ["Us", "We", "Ourselves", "Our"], 1, "'We' as subject pronoun"),

            // Homophones
            ("Which is correct?", ["Their going home.", "They're going home.", "There going home.", "Thier going."], 1, "'They're' = 'they are'"),
            ("Which is correct?", ["Your the best!", "You're the best!", "Youre the best!", "Your' best!"], 1, "'You're' = 'you are'"),
            ("Which is correct?", ["Its raining.", "It's raining.", "Its' raining.", "Itss raining."], 1, "'It's' = 'it is'"),
            ("Which is correct?", ["The dog wagged it's tail.", "The dog wagged its tail.", "Its' tail.", "It is tail."], 1, "'Its' shows possession"),
            ("Which is correct?", ["Whose coming?", "Who's coming?", "Whos coming?", "Who'se coming?"], 1, "'Who's' = 'who is'"),

            // Adverbs
            ("Which is an adverb?", ["quick", "quickly", "quicker", "quickest"], 1, "Adverbs often end in -ly"),
            ("'She ran ___.'", ["quick", "quickly", "quicker", "quickest"], 1, "Adverb modifies verb"),
            ("'He speaks ___.'", ["loud", "loudly", "louder", "loudest"], 1, "Adverb modifies how"),

            // Conjunctions
            ("Which is a conjunction?", ["happy", "and", "quickly", "dog"], 1, "Conjunctions connect"),
            ("'I like cats ___ dogs.'", ["but", "and", "or", "so"], 1, "'And' adds ideas"),
            ("'I was tired ___ I slept.'", ["but", "and", "or", "so"], 3, "'So' shows result"),

            // Prepositions
            ("Which is a preposition?", ["run", "under", "quickly", "happy"], 1, "Prepositions show position"),
            ("'The cat is ___ the table.'", ["run", "under", "quickly", "happy"], 1, "'Under' shows where"),

            // Punctuation
            ("What punctuates a list?", [".", "!", ",", "?"], 2, "Commas separate list items"),
            ("What ends a question?", [".", "!", ",", "?"], 3, "Questions end with ?"),
            ("Which needs a comma?", ["I like dogs", "Yes I do", "The big dog", "Run fast"], 1, "'Yes, I do' needs comma"),
        ]

        for q in middleQuestions {
            var opts = q.1
            opts.shuffle()
            let correctAnswer = q.1[q.2]
            questions.append(Question(
                subject: .grammar,
                level: level,
                text: q.0,
                options: opts,
                correctIndex: opts.firstIndex(of: correctAnswer) ?? 0,
                explanation: q.3
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    // Grades 7-10: High school grammar
    private func generateHighSchoolGrammarQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let highSchoolQuestions: [(String, [String], Int, String)] = [
            // Common errors
            ("Which is correct?", ["I could of won.", "I could have won.", "I could off won.", "I could've of won."], 1, "'Could have' not 'could of'"),
            ("Which is correct?", ["The affect was huge.", "The effect was huge.", "The affection was huge.", "The effection."], 1, "'Effect' is the noun"),
            ("Which is correct?", ["Lay down and rest.", "Lie down and rest.", "Laid down and rest.", "Lied down."], 1, "'Lie' = recline"),
            ("Which is correct?", ["I accept the terms.", "I except the terms.", "I expect the terms.", "I excerpt."], 0, "'Accept' = receive"),
            ("Which is correct?", ["The principle spoke.", "The principal spoke.", "The principel spoke.", "Princpal."], 1, "'Principal' = person"),

            // Comparisons
            ("Which is correct?", ["More better", "Better", "Most better", "Bestest"], 1, "'Better' is already comparative"),
            ("Which is correct?", ["Less people came.", "Fewer people came.", "Lesser people came.", "Few people."], 1, "'Fewer' for countable"),
            ("Which is correct?", ["Most unique", "Unique", "More unique", "Uniquer"], 1, "'Unique' is absolute"),

            // Verb tenses
            ("Which is correct?", ["I seen it.", "I saw it.", "I have saw it.", "I had saw it."], 1, "'Saw' is past tense"),
            ("Which is correct?", ["I have went.", "I have gone.", "I have going.", "I has gone."], 1, "'Gone' with 'have'"),
            ("Which is correct?", ["She don't know.", "She doesn't know.", "She do not know.", "She don't knows."], 1, "'Doesn't' with singular"),

            // Advanced tenses
            ("Which is past perfect?", ["I ate", "I had eaten", "I was eating", "I eat"], 1, "Had + past participle"),
            ("Which is future perfect?", ["I will eat", "I will have eaten", "I am eating", "I ate"], 1, "Will have + past participle"),
            ("Which is present progressive?", ["I eat", "I ate", "I am eating", "I had eaten"], 2, "Am/is/are + -ing"),

            // Subjunctive mood
            ("Which is correct?", ["If I was rich...", "If I were rich...", "If I am rich...", "If I be rich..."], 1, "Subjunctive mood"),
            ("Which is correct?", ["I wish I was there.", "I wish I were there.", "I wish I am there.", "I wish I be."], 1, "Subjunctive after 'wish'"),
            ("Which is correct?", ["He suggested that she goes.", "He suggested that she go.", "He suggested she going.", "Go."], 1, "Subjunctive after 'suggest'"),

            // Parallelism
            ("Which shows parallelism?", ["She likes hiking, to swim, biking.", "She likes hiking, swimming, biking.", "She likes to hike, swimming.", "Hike."], 1, "Parallel structure"),
            ("Which is parallel?", ["He ran, jumped, and was swimming.", "He ran, jumped, and swam.", "He ran, jumping, swam.", "Run."], 1, "Same verb forms"),

            // Clauses
            ("Which is a dependent clause?", ["I ran home", "When I got there", "The dog barked", "She slept"], 1, "Can't stand alone"),
            ("Which is an independent clause?", ["Because I was late", "When the bell rang", "She left early", "If it rains"], 2, "Complete thought"),

            // Active vs passive
            ("Which is passive voice?", ["The dog bit the man.", "The man was bitten by the dog.", "Dogs bite.", "Bite."], 1, "Subject receives action"),
            ("Which is active voice?", ["The cake was eaten.", "The window was broken.", "She wrote the letter.", "Was written."], 2, "Subject does action"),
        ]

        for q in highSchoolQuestions {
            var opts = q.1
            opts.shuffle()
            let correctAnswer = q.1[q.2]
            questions.append(Question(
                subject: .grammar,
                level: level,
                text: q.0,
                options: opts,
                correctIndex: opts.firstIndex(of: correctAnswer) ?? 0,
                explanation: q.3
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    // College+: Advanced grammar
    private func generateAdvancedGrammarQuestions(level: Int) -> [Question] {
        var questions: [Question] = []

        let advancedQuestions: [(String, [String], Int, String)] = [
            // Dangling modifiers
            ("Which avoids a dangling modifier?", ["Walking down the street, the trees were beautiful.", "Walking down the street, I saw beautiful trees.", "The trees, walking down the street.", "Beautiful."], 1, "Subject must match modifier"),
            ("Which is correct?", ["Hoping for a raise, the boss was asked.", "Hoping for a raise, she asked the boss.", "The boss, hoping, asked.", "Asked."], 1, "Subject performs action"),

            // Misplaced modifiers
            ("Which is clearest?", ["She only ate one cookie.", "She ate only one cookie.", "Only she ate one cookie.", "Ate."], 1, "'Only' next to what it modifies"),
            ("Which is correct?", ["He almost drove the car 100 miles.", "He drove the car almost 100 miles.", "Almost he drove.", "Drove."], 1, "'Almost' modifies '100 miles'"),

            // Who vs whom
            ("Which is correct?", ["Who did you call?", "Whom did you call?", "Who you called?", "Called."], 1, "'Whom' is object"),
            ("Which is correct?", ["To who should I speak?", "To whom should I speak?", "Who to speak?", "Speak."], 1, "'Whom' after preposition"),
            ("Which is correct?", ["Whom is calling?", "Who is calling?", "Whom calling?", "Call."], 1, "'Who' is subject"),

            // Which vs that
            ("Which is correct for essential info?", ["The car, which is red, is mine.", "The car that is red is mine.", "The red car which.", "Red."], 1, "'That' for essential clauses"),
            ("Which is correct for non-essential?", ["My car that is a Honda needs gas.", "My car, which is a Honda, needs gas.", "Honda needs gas.", "Gas."], 1, "'Which' with commas for non-essential"),

            // Semicolons
            ("When use a semicolon?", ["Between two independent clauses", "Before a list", "After 'because'", "Never"], 0, "Joins independent clauses"),
            ("Which is correct?", ["I went; but she stayed.", "I went; she stayed.", "I went: she stayed.", "Went."], 1, "No conjunction with semicolon"),

            // Colons
            ("When use a colon?", ["Before a list after complete sentence", "Between subject and verb", "After 'such as'", "Never"], 0, "After complete sentence before list"),
            ("Which is correct?", ["I need: eggs, milk, bread.", "I need the following: eggs, milk, bread.", "I need eggs: milk: bread.", "Need."], 1, "Complete sentence before colon"),

            // Comma splices
            ("Which avoids comma splice?", ["I ran, I jumped.", "I ran, and I jumped.", "Ran, jumped.", "Jump."], 1, "Use conjunction or semicolon"),
            ("Which is a comma splice?", ["I went home; I was tired.", "I went home, I was tired.", "I went home because I was tired.", "Tired."], 1, "Two clauses joined only by comma"),

            // Gerunds vs infinitives
            ("Which is a gerund?", ["to run", "running", "ran", "runs"], 1, "-ing form as noun"),
            ("Complete: 'I enjoy ___'", ["to swim", "swimming", "swim", "swam"], 1, "'Enjoy' takes gerund"),
            ("Complete: 'I want ___'", ["to go", "going", "go", "went"], 0, "'Want' takes infinitive"),

            // Appositives
            ("Which has an appositive?", ["The dog ran home.", "My dog, a beagle, ran home.", "The running dog.", "Ran."], 1, "Renames noun"),
            ("Which punctuates appositive correctly?", ["My brother John is here.", "My brother, John, is here.", "My brother: John is here.", "Brother."], 1, "Non-essential needs commas"),
        ]

        for q in advancedQuestions {
            var opts = q.1
            opts.shuffle()
            let correctAnswer = q.1[q.2]
            questions.append(Question(
                subject: .grammar,
                level: level,
                text: q.0,
                options: opts,
                correctIndex: opts.firstIndex(of: correctAnswer) ?? 0,
                explanation: q.3
            ))
        }

        return Array(questions.shuffled().prefix(100))
    }

    // MARK: - Spelling Questions

    private func generateSpellingQuestionsForLevel(_ level: Int) -> [Question] {
        switch level {
        case 1...10:
            return generateFirstLetterQuestions(level: level)
        case 11...25:
            return generateSpellWithEmojiQuestions(level: level)
        case 26...45:
            return generateSpellWordQuestions(level: level)
        default:
            return generateCorrectSpellingQuestions(level: level)
        }
    }

    // Level 1-10: What letter does this start with? (with emoji)
    private func generateFirstLetterQuestions(level: Int) -> [Question] {
        let words: [(word: String, emoji: String)] = [
            // Simple 3-4 letter words
            ("Apple", "🍎"), ("Ball", "⚽"), ("Cat", "🐱"), ("Dog", "🐶"),
            ("Egg", "🥚"), ("Fish", "🐟"), ("Goat", "🐐"), ("Hat", "🎩"),
            ("Ice", "🧊"), ("Jam", "🍯"), ("Kite", "🪁"), ("Lion", "🦁"),
            ("Moon", "🌙"), ("Nest", "🪺"), ("Orange", "🍊"), ("Pig", "🐷"),
            ("Queen", "👑"), ("Rain", "🌧️"), ("Sun", "☀️"), ("Tree", "🌳"),
            ("Umbrella", "☂️"), ("Van", "🚐"), ("Water", "💧"), ("Box", "📦"),
            ("Yarn", "🧶"), ("Zebra", "🦓"), ("Bear", "🐻"), ("Cake", "🎂"),
            ("Duck", "🦆"), ("Frog", "🐸"), ("Grapes", "🍇"), ("House", "🏠"),
            ("Igloo", "🏠"), ("Juice", "🧃"), ("Key", "🔑"), ("Lemon", "🍋"),
            ("Mouse", "🐭"), ("Nurse", "👩‍⚕️"), ("Owl", "🦉"), ("Pizza", "🍕"),
            ("Ring", "💍"), ("Star", "⭐"), ("Tiger", "🐯"), ("Violin", "🎻"),
            ("Whale", "🐋"), ("Yak", "🦬"), ("Ant", "🐜"), ("Bee", "🐝"),
            ("Corn", "🌽"), ("Deer", "🦌"), ("Fox", "🦊"), ("Gift", "🎁")
        ]

        let levelWords = words.shuffled().prefix(15)

        return levelWords.map { item in
            let firstLetter = String(item.word.prefix(1)).uppercased()
            var options = [firstLetter]
            let allLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
            let wrongLetters = allLetters.filter { $0 != firstLetter }.shuffled().prefix(3)
            options.append(contentsOf: wrongLetters)
            options.shuffle()

            return Question(
                subject: .spelling,
                level: level,
                text: "\(item.emoji)\nWhat letter does \"\(item.word)\" start with?",
                options: options,
                correctIndex: options.firstIndex(of: firstLetter) ?? 0,
                explanation: "\"\(item.word)\" starts with the letter \(firstLetter)"
            )
        }
    }

    // Level 11-25: How do you spell this? (with emoji)
    private func generateSpellWithEmojiQuestions(level: Int) -> [Question] {
        let words: [(word: String, emoji: String, wrong1: String, wrong2: String, wrong3: String)] = [
            ("Apple", "🍎", "Appel", "Aple", "Aplle"),
            ("Banana", "🍌", "Bannana", "Bananna", "Banan"),
            ("Cat", "🐱", "Kat", "Catt", "Katt"),
            ("Dog", "🐶", "Dogg", "Dawg", "Doge"),
            ("Elephant", "🐘", "Elefant", "Elephent", "Eliphant"),
            ("Fish", "🐟", "Fesh", "Phish", "Fissh"),
            ("Giraffe", "🦒", "Giraf", "Giraff", "Jiraf"),
            ("House", "🏠", "Hous", "Howse", "Houze"),
            ("Igloo", "🏠", "Iglu", "Iglue", "Eegloo"),
            ("Juice", "🧃", "Juce", "Juise", "Joose"),
            ("Kangaroo", "🦘", "Kangaro", "Kangeroo", "Kanguru"),
            ("Lemon", "🍋", "Lemmon", "Lemon", "Lemun"),
            ("Monkey", "🐵", "Munkey", "Monky", "Monkee"),
            ("Nurse", "👩‍⚕️", "Nerse", "Nurs", "Nurce"),
            ("Orange", "🍊", "Orang", "Oranje", "Ornge"),
            ("Penguin", "🐧", "Pengin", "Pengwin", "Penguine"),
            ("Queen", "👑", "Qeen", "Quene", "Kween"),
            ("Rabbit", "🐰", "Rabit", "Rabitt", "Rabbitt"),
            ("Snake", "🐍", "Snak", "Sneak", "Snaek"),
            ("Tiger", "🐯", "Tigger", "Tyger", "Tigar"),
            ("Umbrella", "☂️", "Umbrela", "Umberella", "Umbrellla"),
            ("Violin", "🎻", "Violen", "Vyolin", "Viollin"),
            ("Whale", "🐋", "Wale", "Whail", "Whaile"),
            ("Xylophone", "🎹", "Zylophone", "Xilophone", "Xylaphone"),
            ("Zebra", "🦓", "Zeebra", "Zibra", "Zebrah"),
            ("Butterfly", "🦋", "Buterfly", "Butterflye", "Buterflie"),
            ("Dolphin", "🐬", "Dolfin", "Dolphine", "Dolpin"),
            ("Flower", "🌸", "Flowr", "Flour", "Flowur"),
            ("Guitar", "🎸", "Gitar", "Guiter", "Gitarr"),
            ("Helicopter", "🚁", "Helicoptor", "Hellicopter", "Helacopter")
        ]

        let levelWords = words.shuffled().prefix(15)

        return levelWords.map { item in
            var options = [item.word, item.wrong1, item.wrong2, item.wrong3]
            options.shuffle()

            return Question(
                subject: .spelling,
                level: level,
                text: "\(item.emoji)\nHow do you spell this?",
                options: options,
                correctIndex: options.firstIndex(of: item.word) ?? 0,
                explanation: "The correct spelling is \"\(item.word)\""
            )
        }
    }

    // Level 26-45: How do you spell this word? (no emoji, harder words)
    private func generateSpellWordQuestions(level: Int) -> [Question] {
        let words: [(word: String, wrong1: String, wrong2: String, wrong3: String)] = [
            ("because", "becuase", "becouse", "becase"),
            ("believe", "beleive", "belive", "beleave"),
            ("different", "diffrent", "diferent", "differant"),
            ("friend", "freind", "frend", "freand"),
            ("thought", "thot", "thougt", "thougth"),
            ("through", "thru", "threw", "thrugh"),
            ("beautiful", "beutiful", "beautifull", "beautyful"),
            ("comfortable", "comfertable", "comfortible", "cumfortable"),
            ("definitely", "definately", "definitly", "definetly"),
            ("embarrass", "embarass", "embarras", "emberrass"),
            ("environment", "enviroment", "enviornment", "envirnoment"),
            ("experience", "experiance", "expirience", "experince"),
            ("February", "Febuary", "Febrary", "Feburary"),
            ("government", "goverment", "governmant", "govenment"),
            ("immediately", "immediatly", "imediately", "immediatley"),
            ("knowledge", "knowlege", "knowlede", "knoledge"),
            ("necessary", "neccessary", "necesary", "neccesary"),
            ("occurred", "occured", "ocurred", "occurrd"),
            ("particularly", "particuarly", "particulary", "perticularly"),
            ("receive", "recieve", "recive", "receeve"),
            ("restaurant", "restaraunt", "resturant", "restraunt"),
            ("separate", "seperate", "seprate", "separete"),
            ("successful", "succesful", "successfull", "sucessful"),
            ("surprise", "suprise", "surprize", "surpris"),
            ("tomorrow", "tommorow", "tommorrow", "tomorow"),
            ("unfortunately", "unfortunatly", "unfortunetly", "unfourtunately"),
            ("usually", "usally", "usualy", "ussually"),
            ("Wednesday", "Wensday", "Wednsday", "Wendesday"),
            ("which", "wich", "whitch", "witch"),
            ("writing", "writting", "writeing", "writng")
        ]

        let levelWords = words.shuffled().prefix(15)

        return levelWords.map { item in
            var options = [item.word, item.wrong1, item.wrong2, item.wrong3]
            options.shuffle()

            return Question(
                subject: .spelling,
                level: level,
                text: "How do you spell the word that means:\n\"\(getDefinition(for: item.word))\"",
                options: options,
                correctIndex: options.firstIndex(of: item.word) ?? 0,
                explanation: "The correct spelling is \"\(item.word)\""
            )
        }
    }

    // Level 46-65: Which is the correct spelling? (tricky words)
    private func generateCorrectSpellingQuestions(level: Int) -> [Question] {
        let words: [(word: String, wrong1: String, wrong2: String, wrong3: String)] = [
            ("accommodate", "acommodate", "accomodate", "accommadate"),
            ("acknowledgment", "acknowledgement", "acknowlegment", "acknoledgment"),
            ("acquisition", "aquisition", "acqusition", "acquisision"),
            ("amateur", "amature", "amatuer", "amatur"),
            ("apparent", "apparant", "aparent", "apparrent"),
            ("calendar", "calender", "calandar", "calander"),
            ("Caribbean", "Carribean", "Caribean", "Carribbean"),
            ("cemetery", "cemetary", "cematery", "cemetry"),
            ("colleague", "colleage", "collaegue", "collegue"),
            ("committee", "comittee", "commitee", "committe"),
            ("conscience", "concience", "consience", "conscence"),
            ("consensus", "concensus", "consensis", "consensous"),
            ("correspondence", "correspondance", "corrispondence", "corresponence"),
            ("desperate", "desparate", "desprate", "desperete"),
            ("disappear", "dissapear", "disapear", "dissappear"),
            ("discipline", "disipline", "discapline", "dicipline"),
            ("entrepreneur", "entrepeneur", "entreprenur", "entreprener"),
            ("exaggerate", "exagerate", "exaggarate", "exadgerate"),
            ("existence", "existance", "existense", "existince"),
            ("fluorescent", "flourescent", "flouresent", "flurescent"),
            ("guarantee", "guarentee", "garantee", "guarrantee"),
            ("harass", "harrass", "harras", "haras"),
            ("hierarchy", "heirarchy", "hierarcy", "heirarcy"),
            ("independent", "independant", "indipendent", "independint"),
            ("intelligence", "inteligence", "intellegence", "inteligance"),
            ("liaison", "liason", "liasion", "liasson"),
            ("lightning", "lightening", "litening", "lightnig"),
            ("maintenance", "maintainance", "maintenence", "maintanance"),
            ("maneuver", "manuever", "manoeuver", "manuver"),
            ("Mediterranean", "Mediteranean", "Mediterranian", "Mediterrenean"),
            ("millennium", "millenium", "milennium", "milleniun"),
            ("miniature", "minature", "miniture", "minituare"),
            ("miscellaneous", "miscellanous", "miscelaneous", "miscellanious"),
            ("mischievous", "mischievious", "mischevous", "mischieveous"),
            ("occasionally", "occasionaly", "occassionally", "ocassionally"),
            ("occurrence", "occurence", "occurance", "occurrance"),
            ("parliament", "parliment", "parlimant", "parlaiment"),
            ("perseverance", "perseverence", "perserverance", "persaverance"),
            ("phenomenon", "phenomemon", "phenomenom", "phenominon"),
            ("playwright", "playwrite", "playright", "playwrigt"),
            ("possession", "posession", "possesion", "posesion"),
            ("precede", "procede", "presede", "preceed"),
            ("privilege", "priviledge", "privelege", "privlege"),
            ("pronunciation", "pronounciation", "prononciation", "pronuciation"),
            ("questionnaire", "questionaire", "questionairre", "questionnare"),
            ("recommend", "recomend", "reccomend", "recommand"),
            ("reference", "refrence", "referance", "refference"),
            ("relevant", "relevent", "relavent", "revelant"),
            ("rhythm", "rythm", "rythym", "rhythym"),
            ("schedule", "scedule", "schedual", "shedule"),
            ("supersede", "supercede", "superceed", "superseed"),
            ("tendency", "tendancy", "tendancy", "tendencey"),
            ("thorough", "thorogh", "thurough", "thourough"),
            ("tyranny", "tyrrany", "tyrany", "tyrranny"),
            ("vacuum", "vaccum", "vacume", "vaccuum"),
            ("vicious", "viscious", "visious", "vicsious"),
            ("weird", "wierd", "wired", "werid")
        ]

        let levelWords = words.shuffled().prefix(15)

        return levelWords.map { item in
            var options = [item.word, item.wrong1, item.wrong2, item.wrong3]
            options.shuffle()

            return Question(
                subject: .spelling,
                level: level,
                text: "Which is the correct spelling?",
                options: options,
                correctIndex: options.firstIndex(of: item.word) ?? 0,
                explanation: "The correct spelling is \"\(item.word)\""
            )
        }
    }

    private func getDefinition(for word: String) -> String {
        let definitions: [String: String] = [
            "because": "for the reason that",
            "believe": "to accept as true",
            "different": "not the same",
            "friend": "a person you like and trust",
            "thought": "an idea in your mind",
            "through": "from one end to another",
            "beautiful": "very pretty or attractive",
            "comfortable": "feeling relaxed and at ease",
            "definitely": "without any doubt",
            "embarrass": "to make someone feel awkward",
            "environment": "the natural world around us",
            "experience": "something that happens to you",
            "February": "the second month of the year",
            "government": "the group that runs a country",
            "immediately": "right now, without delay",
            "knowledge": "information and understanding",
            "necessary": "needed or required",
            "occurred": "happened or took place",
            "particularly": "especially or specifically",
            "receive": "to get something given to you",
            "restaurant": "a place to eat meals",
            "separate": "to divide or keep apart",
            "successful": "achieving a goal or doing well",
            "surprise": "something unexpected",
            "tomorrow": "the day after today",
            "unfortunately": "sadly or unluckily",
            "usually": "most of the time",
            "Wednesday": "the fourth day of the week",
            "which": "asking about a choice",
            "writing": "putting words on paper"
        ]
        return definitions[word] ?? word
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
