using LazyArtifacts

function make_test_data(target="chore_sample_outline")
    # we want `targets` to be mutable
    isstr = target isa String
    if isstr
        targets = [target]
    else
        # copy
        targets = Vector{String}(target)
    end
    for t in 1:length(targets)
        target = targets[t]
        dir = nothing
        # call the `artifact` string macro
        if startswith(target, "chore_sample_")
            artefact = artifact"chore_sample_output"
            dir = "chore_sample_output"
            filetype = target[length("chore_sample_")+1:end]
            if filetype ∉ ("outline", "spine")
                throw(DomainError("unknown Chore output: " * filetype))
            end
            filename = "20150701_105504@FCF_attP2_1500062@UAS_Chrimson_Venus_X_0070@t15@r_LED50_30s2x15s30s#n#n#n@100." * filetype
        elseif target == "sample_trxmat_file"
            artefact = artifact"sample_trxmat_file"
            filename = "trx.mat"
        elseif target == "sample_trxmat_file_small"
            artefact = artifact"sample_trxmat_file_small"
            filename = "trx_small.mat"
        elseif target == "sample_labels_file_trx_small"
            artefact = artifact"sample_labels_small"
            filename = "jbm_tagger.labels"
        elseif target == "sample_labels_file_nyx_small"
            artefact = artifact"sample_labels_small"
            filename = "maggotuba.labels"
        elseif target == "sample_collision_dataset"
            artefact = artifact"sample_fimtrack_tables"
            filename = "collision_sample_table.csv"
        elseif target == "sample_fimtrack_table"
            artefact = artifact"sample_fimtrack_tables"
            filename = "embl_sample_table.csv"
        elseif target == "chore_auto_labels"
            artefact = artifact"labels_with_dependencies"
            dir = "labels"
            filename = "chore_auto.labels"
        elseif target == "chore_auto_dependency"
            artefact = artifact"labels_with_dependencies"
            dir = "labels"
            filename = "20140918_170215@GMR_SS02113@UAS_Chrimson_Venus_X_0070@t15@r_LED100_30s2x15s30s#n#n#n@100.outline"
        elseif target == "trxmat_exported_labels"
            artefact = artifact"labels_with_dependencies"
            dir = "labels"
            filename = "trxmat_exported.labels"
        elseif target == "trxmat_exported_dependency"
            artefact = artifact"labels_with_dependencies"
            dir = "labels"
            filename = "trx_small.mat"
        elseif target == "fimtrack_manual_labels"
            artefact = artifact"labels_with_dependencies"
            dir = "labels"
            filename = "fimtrack_manual.labels"
        elseif target == "fimtrack_manual_dependency"
            artefact = artifact"labels_with_dependencies"
            dir = "labels"
            filename = "table.csv"
        else
            throw(DomainError("unknown artefact: " * target))
        end
        # return path to individual file instead
        if isnothing(dir)
            path = joinpath(artefact, filename)
        else
            path = joinpath(artefact, dir, filename)
        end
        targets[t] = path
    end
    if isstr
        targets = targets[1]
    end
    return targets
end
