module Highs
  module FFI
    extend Fiddle::Importer

    libs = Array(Highs.ffi_lib).dup
    begin
      dlload Fiddle.dlopen(libs.shift)
    rescue Fiddle::DLError => e
      retry if libs.any?
      raise e
    end

    # https://github.com/ERGO-Code/HiGHS/blob/master/src/interfaces/highs_c_api.h

    VAR_TYPE = {
      continuous: 0,
      integer: 1,
      semi_continuous: 2,
      semi_integer: 3,
      implicit_integer: 4
    }

    OBJ_SENSE = {
      minimize: 1,
      maximize: -1
    }

    MATRIX_FORMAT = {
      colwise: 1,
      rowwise: 2
    }

    MODEL_STATUS = [
      :not_set, :load_error, :model_error, :presolve_error, :solve_error, :postsolve_error,
      :model_empty, :optimal, :infeasible, :unbounded_or_infeasible, :unbounded,
      :objective_bound, :objective_target, :time_limit, :iteration_limit, :unknown
    ]

    BASIS_STATUS = [:lower, :basic, :upper, :zero, :nonbasic]

    typealias "HighsInt", "int"
    typealias "HighsUInt", "unsigned int"

    extern "HighsInt Highs_lpCall(HighsInt num_col, HighsInt num_row, HighsInt num_nz, HighsInt a_format, HighsInt sense, double offset, double* col_cost, double* col_lower, double* col_upper, double* row_lower, double* row_upper, HighsInt* a_start, HighsInt* a_index, double* a_value, double* col_value, double* col_dual, double* row_value, double* row_dual, HighsInt* col_basis_status, HighsInt* row_basis_status, HighsInt* model_status)"
    extern "HighsInt Highs_mipCall(HighsInt num_col, HighsInt num_row, HighsInt num_nz, HighsInt a_format, HighsInt sense, double offset, double* col_cost, double* col_lower, double* col_upper, double* row_lower, double* row_upper, HighsInt* a_start, HighsInt* a_index, double* a_value, HighsInt* integrality, double* col_value, double* row_value, HighsInt* model_status)"
    extern "HighsInt Highs_qpCall(HighsInt num_col, HighsInt num_row, HighsInt num_nz, HighsInt q_num_nz, HighsInt a_format, HighsInt q_format, HighsInt sense, double offset, double* col_cost, double* col_lower, double* col_upper, double* row_lower, double* row_upper, HighsInt* a_start, HighsInt* a_index, double* a_value, HighsInt* q_start, HighsInt* q_index, double* q_value, double* col_value, double* col_dual, double* row_value, double* row_dual, HighsInt* col_basis_status, HighsInt* row_basis_status, HighsInt* model_status)"

    extern "void* Highs_create(void)"
    extern "void Highs_destroy(void* highs)"
    extern "HighsInt Highs_readModel(void* highs, char* filename)"
    extern "HighsInt Highs_writeModel(void* highs, char* filename)"
    extern "HighsInt Highs_clearModel(void* highs)"
    extern "HighsInt Highs_run(void* highs)"
    extern "HighsInt Highs_writeSolution(void* highs, char* filename)"
    extern "HighsInt Highs_writeSolutionPretty(void* highs, char* filename)"
    extern "HighsInt Highs_passLp(void* highs, HighsInt num_col, HighsInt num_row, HighsInt num_nz, HighsInt a_format, HighsInt sense, double offset, double* col_cost, double* col_lower, double* col_upper, double* row_lower, double* row_upper, HighsInt* a_start, HighsInt* a_index, double* a_value)"
    extern "HighsInt Highs_passMip(void* highs, HighsInt num_col, HighsInt num_row, HighsInt num_nz, HighsInt a_format, HighsInt sense, double offset, double* col_cost, double* col_lower, double* col_upper, double* row_lower, double* row_upper, HighsInt* a_start, HighsInt* a_index, double* a_value, HighsInt* integrality)"
    extern "HighsInt Highs_passModel(void* highs, HighsInt num_col, HighsInt num_row, HighsInt num_nz, HighsInt q_num_nz, HighsInt a_format, HighsInt q_format, HighsInt sense, double offset, double* col_cost, double* col_lower, double* col_upper, double* row_lower, double* row_upper, HighsInt* a_start, HighsInt* a_index, double* a_value, HighsInt* q_start, HighsInt* q_index, double* q_value, HighsInt* integrality)"
    extern "HighsInt Highs_passHessian(void* highs, HighsInt dim, HighsInt num_nz, HighsInt format, HighsInt* start, HighsInt* index, double* value)"
    extern "HighsInt Highs_setBoolOptionValue(void* highs, char* option, HighsInt value)"
    extern "HighsInt Highs_setIntOptionValue(void* highs, char* option, HighsInt value)"
    extern "HighsInt Highs_setDoubleOptionValue(void* highs, char* option, double value)"
    extern "HighsInt Highs_setStringOptionValue(void* highs, char* option, char* value)"
    extern "HighsInt Highs_getBoolOptionValue(void* highs, char* option, HighsInt* value)"
    extern "HighsInt Highs_getIntOptionValue(void* highs, char* option, HighsInt* value)"
    extern "HighsInt Highs_getDoubleOptionValue(void* highs, char* option, double* value)"
    extern "HighsInt Highs_getStringOptionValue(void* highs, char* option, char* value)"
    extern "HighsInt Highs_getOptionType(void* highs, char* option, HighsInt* type)"
    extern "HighsInt Highs_getSolution(void* highs, double* col_value, double* col_dual, double* row_value, double* row_dual)"
    extern "HighsInt Highs_getBasis(void* highs, HighsInt* col_status, HighsInt* row_status)"
    extern "HighsInt Highs_getModelStatus(void* highs)"
    extern "HighsInt Highs_getDualRay(void* highs, HighsInt* has_dual_ray, double* dual_ray_value)"
    extern "HighsInt Highs_getPrimalRay(void* highs, HighsInt* has_primal_ray, double* primal_ray_value)"
    extern "double Highs_getObjectiveValue(void* highs)"
    extern "HighsInt Highs_getNumCol(void* highs)"
    extern "HighsInt Highs_getNumRow(void* highs)"
  end
end
