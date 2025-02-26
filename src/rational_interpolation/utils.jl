"""
    function eval_derivs(polynomial_system, interpolant::Interpolant,
                        y_function_name,
                        inputs::Vector{ModelingToolkit.Equation},
                        identifiability_result;
                        method = :homotopy)

This function evaluates the derivatives of the interpolated function `y_function_name` using the `interpolant` object.
    Derivatives are substituted into the polynomial system.
"""
function eval_derivs(polynomial_system, interpolant::Interpolant,
                     y_function_name,
                     inputs::Vector{ModelingToolkit.Equation},
                     identifiability_result;
                     method = :homotopy)
    if isequal(method, :homotopy)
        for (y_func, y_deriv_order) in pairs(identifiability_result["Y_eq"])
            if occursin(y_function_name, string(y_func))
                y_derivs_vals = Dict(ParameterEstimation.nemo2hc(y_func) => interpolant.dIdt[y_deriv_order] *
                                                                            factorial(y_deriv_order))
                polynomial_system = HomotopyContinuation.evaluate(ParameterEstimation.nemo2hc.(polynomial_system),
                                                                  y_derivs_vals)
            end
        end
        for (u_funct, u_deriv_order) in pairs(identifiability_result["u_variables"])
            t = arguments(inputs[1].lhs)[1]
            tau = Taylor1(u_deriv_order)
            for input_eq in inputs
                u_function_name = replace(string(input_eq.lhs), "(t)" => "")
                if occursin(u_function_name, string(u_funct))
                    u_derivs_vals = Dict(ParameterEstimation.nemo2hc(u_funct) => substitute(input_eq.rhs,
                                                                                            Dict(t => tau))[u_deriv_order] *
                                                                                 factorial(u_deriv_order))
                    polynomial_system = HomotopyContinuation.evaluate(ParameterEstimation.nemo2hc.(polynomial_system),
                                                                      u_derivs_vals)
                end
            end
        end
    elseif isequal(method, :msolve)
        y_derivs = Vector{SIAN.Nemo.fmpq_mpoly}()
        y_vals = Vector{SIAN.Nemo.fmpq}()
        u_derivs = Vector{SIAN.Nemo.fmpq_mpoly}()
        u_vals = Vector{SIAN.Nemo.fmpq}()
        for (y_func, y_deriv_order) in pairs(identifiability_result["Y_eq"])
            if occursin(y_function_name, string(y_func))
                push!(y_derivs, y_func)
                push!(y_vals,
                      rationalize(Float64(interpolant.dIdt[y_deriv_order] *
                                          factorial(y_deriv_order))))
            end
        end
        for (u_funct, u_deriv_order) in pairs(identifiability_result["u_variables"])
            tau = Taylor1(u_deriv_order)
            for input_eq in inputs
                u_function_name = replace(string(input_eq.lhs), "(t)" => "")
                if occursin(u_function_name, string(u_funct))
                    push!(u_derivs, u_funct)
                    push!(u_vals,
                          rationalize(Float64(substitute(input_eq.rhs,
                                                         Dict(t => tau))[u_deriv_order] *
                                              factorial(u_deriv_order))))
                end
            end
        end
        polynomial_system = [SIAN.Nemo.evaluate(poly, y_derivs, y_vals)
                             for poly in polynomial_system]
    end
    return polynomial_system
end
