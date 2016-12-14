immutable Record{Tf<:Tuple, To}
    fields::Tf
end

function Record{T<:Tuple}(t::T)
    To = Tuple{map(fieldtype, t)...}
    Record{T,To}(t)
end

@generated function tryparsenext{N,To}(r::Record{NTuple{N},To}, str, i, len)
    quote
        R = Nullable{To}
        i > len && @goto error
        state = i

        Base.@nexprs $N j->begin
            (val_j, state) = @chk1 tryparsenext(r.fields[j], str, i, len)
        end

        @label done
        return R(Base.@ntuple $N val), i

        @label error
        R(), i
    end
end