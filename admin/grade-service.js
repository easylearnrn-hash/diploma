/**
 * ACNHS Grade Service - Supabase Integration
 * Handles saving, loading, and finalization of student grades
 */

export class GradeService {
  constructor(supabaseClient) {
    this.supabase = supabaseClient;
    this.autosaveTimeout = null;
    this.autosaveDelay = 800; // ms
  }

  /**
   * Load grades for a specific student/course/semester
   */
  async loadGrade(studentId, courseId, semester) {
    try {
      const { data, error } = await this.supabase
        .from('student_grades')
        .select('*')
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .eq('semester', semester)
        .single();

      if (error && error.code !== 'PGRST116') { // PGRST116 = no rows
        throw error;
      }

      return { success: true, data: data || null };
    } catch (error) {
      console.error('Error loading grade:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Save grade (create or update)
   */
  async saveGrade(gradeData) {
    try {
      // Check if record exists
      const existing = await this.loadGrade(
        gradeData.student_id,
        gradeData.course_id,
        gradeData.semester
      );

      // Prevent editing finalized grades
      if (existing.data && existing.data.is_finalized) {
        return {
          success: false,
          error: 'Cannot edit finalized grades. Contact super-admin for override.'
        };
      }

      const payload = {
        ...gradeData,
        updated_at: new Date().toISOString()
      };

      let result;
      if (existing.data) {
        // Update existing record
        result = await this.supabase
          .from('student_grades')
          .update(payload)
          .eq('id', existing.data.id)
          .select()
          .single();
      } else {
        // Create new record
        payload.created_at = new Date().toISOString();
        result = await this.supabase
          .from('student_grades')
          .insert(payload)
          .select()
          .single();
      }

      if (result.error) throw result.error;

      return { success: true, data: result.data };
    } catch (error) {
      console.error('Error saving grade:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Autosave with debounce
   */
  autosave(gradeData, callback) {
    clearTimeout(this.autosaveTimeout);
    
    if (callback) callback({ status: 'saving' });

    this.autosaveTimeout = setTimeout(async () => {
      const result = await this.saveGrade(gradeData);
      if (callback) {
        callback({
          status: result.success ? 'saved' : 'error',
          message: result.error || 'Saved successfully',
          data: result.data
        });
      }
    }, this.autosaveDelay);
  }

  /**
   * Finalize semester grade (locks record)
   */
  async finalizeGrade(studentId, courseId, semester, adminId) {
    try {
      const existing = await this.loadGrade(studentId, courseId, semester);

      if (!existing.data) {
        return { success: false, error: 'No grade record found to finalize.' };
      }

      if (existing.data.is_finalized) {
        return { success: false, error: 'Grade is already finalized.' };
      }

      // Validate that all required fields are present
      const required = ['final_exam', 'quiz_avg', 'standardized_avg', 'clinical_status'];
      const missing = required.filter(field => 
        existing.data[field] === null || existing.data[field] === undefined
      );

      if (missing.length > 0) {
        return {
          success: false,
          error: `Cannot finalize: Missing required fields: ${missing.join(', ')}`
        };
      }

      // Finalize the grade
      const { data, error } = await this.supabase
        .from('student_grades')
        .update({
          is_finalized: true,
          finalized_at: new Date().toISOString(),
          finalized_by: adminId,
          updated_at: new Date().toISOString()
        })
        .eq('id', existing.data.id)
        .select()
        .single();

      if (error) throw error;

      return { success: true, data };
    } catch (error) {
      console.error('Error finalizing grade:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Check if grade is finalized (read-only mode)
   */
  async isFinalized(studentId, courseId, semester) {
    const result = await this.loadGrade(studentId, courseId, semester);
    return result.data?.is_finalized || false;
  }

  /**
   * Get all grades for a student
   */
  async getStudentGrades(studentId) {
    try {
      const { data, error } = await this.supabase
        .from('student_grades')
        .select('*')
        .eq('student_id', studentId)
        .order('semester', { ascending: false });

      if (error) throw error;

      return { success: true, data: data || [] };
    } catch (error) {
      console.error('Error loading student grades:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Get all grades for a course
   */
  async getCourseGrades(courseId, semester) {
    try {
      const { data, error } = await this.supabase
        .from('student_grades')
        .select('*')
        .eq('course_id', courseId)
        .eq('semester', semester)
        .order('student_id', { ascending: true });

      if (error) throw error;

      return { success: true, data: data || [] };
    } catch (error) {
      console.error('Error loading course grades:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Build grade data object from form inputs
   */
  static buildGradeData(studentId, courseId, semester, formData, calculationResult) {
    return {
      student_id: studentId,
      course_id: courseId,
      semester: semester,
      
      // Input data
      unit_exams: formData.exams, // JSON array
      final_exam: formData.finalExam,
      quiz_avg: formData.quizAvg,
      standardized_avg: formData.stdAvg,
      clinical_status: formData.clinical,
      attendance_theory: formData.absTheory || 0,
      attendance_clinical: formData.absClinical || 0,
      
      // Calculated results
      exam_avg: calculationResult.examAvg,
      theory_final: calculationResult.theoryFinal,
      letter_grade: calculationResult.letter,
      course_outcome: calculationResult.outcome,
      progression_eligible: calculationResult.progressionOK,
      
      // Gate results
      gate_exam_passed: calculationResult.gates.exam,
      gate_final_passed: calculationResult.gates.final,
      gate_clinical_passed: calculationResult.gates.clinical,
      gate_attendance_passed: calculationResult.gates.admin,
      
      // Audit trail
      audit_log: calculationResult.audit, // JSON array
      
      // Not finalized yet
      is_finalized: false
    };
  }

  /**
   * Parse saved grade data back to form format
   */
  static parseGradeData(savedData) {
    if (!savedData) return null;

    return {
      exams: savedData.unit_exams || [],
      finalExam: savedData.final_exam,
      quizAvg: savedData.quiz_avg,
      stdAvg: savedData.standardized_avg,
      clinical: savedData.clinical_status,
      absTheory: savedData.attendance_theory || 0,
      absClinical: savedData.attendance_clinical || 0,
      
      // For display only
      calculatedResults: {
        examAvg: savedData.exam_avg,
        theoryFinal: savedData.theory_final,
        letter: savedData.letter_grade,
        outcome: savedData.course_outcome,
        progressionOK: savedData.progression_eligible,
        audit: savedData.audit_log,
        gates: {
          exam: savedData.gate_exam_passed,
          final: savedData.gate_final_passed,
          clinical: savedData.gate_clinical_passed,
          admin: savedData.gate_attendance_passed
        }
      },
      
      isFinalized: savedData.is_finalized,
      finalizedAt: savedData.finalized_at,
      finalizedBy: savedData.finalized_by
    };
  }
}
