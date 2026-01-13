/**
 * ACNHS Grade Calculator - Pure Calculation Logic
 * Implements hard grading gates with NO rounding
 */

export class GradeCalculator {
  constructor(config = {}) {
    // Hard defaults per ACNHS policy
    this.gateExamMin = config.gateExamMin ?? 78.00;
    this.gateFinalMin = config.gateFinalMin ?? 75.00;
    this.progMin = config.progMin ?? 78.00;
    
    // Weights (must total 100%)
    this.wExams = config.wExams ?? 60.00;
    this.wFinal = config.wFinal ?? 20.00;
    this.wQuiz = config.wQuiz ?? 10.00;
    this.wStd = config.wStd ?? 10.00;
    
    // Attendance gates (optional)
    this.enableAttendance = config.enableAttendance ?? false;
    this.absTheory = config.absTheory ?? 0;
    this.absClinical = config.absClinical ?? 0;
  }

  /**
   * Validate all inputs before calculation
   * @returns {string[]} Array of error messages (empty if valid)
   */
  validate(data) {
    const errors = [];

    // Unit exams
    if (!data.exams || data.exams.length < 1) {
      errors.push("Enter at least one unit exam score.");
    } else {
      data.exams.forEach((exam, i) => {
        if (!Number.isFinite(exam.score)) {
          errors.push(`Unit exam score missing or invalid for "${exam.name}".`);
        } else if (exam.score < 0 || exam.score > 100) {
          errors.push(`"${exam.name}" score must be between 0 and 100.`);
        }
      });
    }

    // Final exam
    if (!Number.isFinite(data.finalExam)) {
      errors.push("Final exam score is required.");
    } else if (data.finalExam < 0 || data.finalExam > 100) {
      errors.push("Final exam score must be between 0 and 100.");
    }

    // Quiz average
    if (!Number.isFinite(data.quizAvg)) {
      errors.push("Quizzes/Assignments average is required.");
    } else if (data.quizAvg < 0 || data.quizAvg > 100) {
      errors.push("Quizzes/Assignments average must be between 0 and 100.");
    }

    // Standardized/OSCE
    if (!Number.isFinite(data.stdAvg)) {
      errors.push("Standardized/OSCE score is required.");
    } else if (data.stdAvg < 0 || data.stdAvg > 100) {
      errors.push("Standardized/OSCE score must be between 0 and 100.");
    }

    // Clinical status
    if (!data.clinical || (data.clinical !== "PASS" && data.clinical !== "FAIL")) {
      errors.push("Clinical status is required.");
    }

    // Weights validation
    const weightSum = this.wExams + this.wFinal + this.wQuiz + this.wStd;
    if (Math.abs(weightSum - 100) > 0.0001) {
      errors.push(`Weights must total 100%. Current total: ${weightSum.toFixed(2)}%.`);
    }

    // Attendance (if enabled)
    if (this.enableAttendance) {
      if (!Number.isInteger(this.absTheory) || this.absTheory < 0) {
        errors.push("Unexcused theory absences must be a whole number ≥ 0.");
      }
      if (!Number.isInteger(this.absClinical) || this.absClinical < 0) {
        errors.push("Unexcused clinical absences must be a whole number ≥ 0.");
      }
    }

    return errors;
  }

  /**
   * Calculate final grade with hard gates
   * @returns {Object} Grade results with audit trail
   */
  calculate(data) {
    const errors = this.validate(data);
    if (errors.length > 0) {
      return { success: false, errors };
    }

    // Calculate exam average (NO ROUNDING)
    const examAvg = data.exams.reduce((sum, exam) => sum + exam.score, 0) / data.exams.length;

    const audit = [];
    const gates = { clinical: true, exam: true, final: true, admin: true };
    let failReason = "";

    // Gate: Attendance Administrative (if enabled)
    if (this.enableAttendance) {
      // Hard rule: Clinical unexcused >= 2 → clinical FAIL
      if (this.absClinical >= 2) {
        gates.admin = false;
        gates.clinical = false;
        failReason = `FAILED: Attendance (Clinical) — Unexcused clinical absences ${this.absClinical} ≥ 2.`;
        audit.push(`Attendance Rule: Failed — ${failReason}`);
      }
      // Hard rule: Theory unexcused >= 3 → course FAIL
      else if (this.absTheory >= 3) {
        gates.admin = false;
        failReason = `FAILED: Attendance (Theory) — Unexcused theory absences ${this.absTheory} ≥ 3.`;
        audit.push(`Attendance Rule: Failed — ${failReason}`);
      } else {
        audit.push("Attendance Rule: Passed");
      }
    } else {
      audit.push("Attendance Rule: Not enforced (OFF).");
    }

    // Gate C: Clinical Status
    if (data.clinical === "FAIL") {
      gates.clinical = false;
      if (!failReason) failReason = "FAILED: Clinical Gate — Clinical status is FAIL.";
      audit.push("Gate C (Clinical): Failed — Clinical status is FAIL.");
    } else if (gates.clinical) {
      audit.push("Gate C (Clinical): Passed — Clinical status is PASS.");
    }

    // Gate A: Exam Average (NO ROUNDING)
    if (examAvg < this.gateExamMin) {
      gates.exam = false;
      if (!failReason) failReason = `FAILED: Exam Average Gate — ExamAvg ${examAvg.toFixed(2)}% is below ${this.gateExamMin.toFixed(2)}%.`;
      audit.push(`Gate A (ExamAvg): Failed — ${examAvg.toFixed(2)}% < ${this.gateExamMin.toFixed(2)}%.`);
    } else {
      audit.push(`Gate A (ExamAvg): Passed — ${examAvg.toFixed(2)}% ≥ ${this.gateExamMin.toFixed(2)}%.`);
    }

    // Gate B: Final Exam Safety (NO ROUNDING)
    if (data.finalExam < this.gateFinalMin) {
      gates.final = false;
      if (!failReason) failReason = `FAILED: Final Exam Safety Gate — Final ${data.finalExam.toFixed(2)}% is below ${this.gateFinalMin.toFixed(2)}%.`;
      audit.push(`Gate B (Final): Failed — ${data.finalExam.toFixed(2)}% < ${this.gateFinalMin.toFixed(2)}%.`);
    } else {
      audit.push(`Gate B (Final): Passed — ${data.finalExam.toFixed(2)}% ≥ ${this.gateFinalMin.toFixed(2)}%.`);
    }

    // Calculate weighted theory final (NO ROUNDING)
    const theoryFinal =
      (examAvg * (this.wExams / 100)) +
      (data.finalExam * (this.wFinal / 100)) +
      (data.quizAvg * (this.wQuiz / 100)) +
      (data.stdAvg * (this.wStd / 100));

    // Determine letter grade
    const letter = this.getLetterGrade(theoryFinal);

    // Check progression threshold (NO ROUNDING)
    const progressionOK = theoryFinal >= this.progMin;

    // Determine course outcome
    const allGatesPassed = gates.admin && gates.clinical && gates.exam && gates.final;
    let outcome = "FAIL";
    let outcomeDetail = "";

    if (allGatesPassed && progressionOK && data.clinical === "PASS") {
      outcome = "PASS";
      outcomeDetail = `PASSED: All gates passed and TheoryFinal ${theoryFinal.toFixed(2)}% ≥ ${this.progMin.toFixed(2)}%.`;
      audit.push(`Progression Threshold: Passed — ${theoryFinal.toFixed(2)}% ≥ ${this.progMin.toFixed(2)}% (C+).`);
    } else {
      if (!progressionOK) {
        audit.push(`Progression Threshold: Failed — ${theoryFinal.toFixed(2)}% < ${this.progMin.toFixed(2)}% (C+).`);
        if (!failReason) failReason = `FAILED: Progression Minimum — TheoryFinal ${theoryFinal.toFixed(2)}% is below ${this.progMin.toFixed(2)}%.`;
      } else {
        audit.push(`Progression Threshold: Passed — ${theoryFinal.toFixed(2)}% ≥ ${this.progMin.toFixed(2)}% (C+).`);
      }
      outcomeDetail = failReason || "FAILED: One or more gates not met.";
    }

    // Add summary as first audit line
    audit.unshift(outcomeDetail);

    return {
      success: true,
      examAvg,
      theoryFinal,
      letter,
      outcome,
      progressionOK,
      allGatesPassed,
      gates,
      audit,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Get letter grade based on ACNHS hard scale (NO ROUNDING)
   */
  getLetterGrade(pct) {
    if (pct >= 93.00) return "A";
    if (pct >= 90.00) return "A-";
    if (pct >= 87.00) return "B+";
    if (pct >= 83.00) return "B";
    if (pct >= 80.00) return "B-";
    if (pct >= 78.00) return "C+";
    if (pct >= 75.00) return "C";
    return "F";
  }

  /**
   * Format percentage with 2 decimals
   */
  static formatPercent(num) {
    if (!Number.isFinite(num)) return "—";
    return num.toFixed(2) + "%";
  }

  /**
   * Get current timestamp string
   */
  static getTimestamp() {
    return new Date().toLocaleString();
  }
}
