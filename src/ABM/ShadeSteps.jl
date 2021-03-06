function prune_shades!(model::ABM)
    for shade_i in model.current.shade_ids
        @inbounds model[shade_i].shade = model.pars.target_shade
    end
    model.current.costs += length(model.current.shade_ids) * model.pars.prune_cost
end

function grow_shades!(model::ABM)
    for shade_i in model.current.shade_ids
        grow_shade!(tree, model.pars.shade_g_rate)
    end
end

function grow_shade!(tree::Shade, rate::Float64)
    tree.shade += tree.shade + rate * (1.0 - tree.shade / 0.95) * tree.shade
    tree.age += 1
end
