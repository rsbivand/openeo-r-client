#' Prints a User object
#' 
#' A nice visualization for the user account information obtained by /me
#' 
#' @param x an User object that can be retrieved at \link{describe_account}
#' @param ... additional parameters (not used)
#' 
#' @export
print.User = function(x, ...) {
    cat(paste("ID:", "\t", x$user_id, "\n", sep = ""))
    
    if (!is.null(x$name)) {
        cat(paste("Name:", "\t", x$name, "\n", sep = ""))    
    }
    
    if (!is.null(x$budget)) {
        cat(paste("Budget:", "\t", x$budget, "\n", sep = ""))
    }
    
    if (!is.null(x$storage)) {
        cat("File Storage:\n")
        cat(paste("   Quota:", "\t", x$storage$quota, " Bytes", "\n", sep = ""))
        cat(paste("   Free:", "\t", x$storage$free, " Bytes", "\n", sep = ""))
    }
}


#' Pretty print an openeo process
#' 
#' Print function to visualize relevant information about an openeo process
#' 
#' @param x process info that is received on \link{list_processes} and \link{describe_process}
#' @param ... additional parameters (not used)
#' 
#' @export
print.ProcessInfo <- function(x, ...) {
    title = paste("Process:\t", x$id, sep = "")
    summary = paste("Summary:\t", x$summary, sep = "")
    description = paste("Description:\t", x$description, sep = "")
    result = paste("Returns:\t", x$returns$description, sep = "")
    
    cat(paste(title, summary, description, result, "", sep = "\n"))
    cat("\n")
    
    if (length(x$parameters) > 0) {
        parameter_names = sapply(x$parameters, function(x)x$name)
        parameter_descriptions = sapply(x$parameters, function(arg) {
            if (length(arg$description) == 1) {
                return(arg$description)
            } else if (length(arg$description) > 1) {
                return(arg$description[[1]])
            } else {
                return("")
            }
            
        })
        parameter_optional = sapply(x$parameters, function(arg) {
            if (!is.null(arg$optional)) {
                return(arg$optional)
            } else {
                return(FALSE)
            }
        })
        
        d = data.frame(Parameter = parameter_names, 
                       Description = parameter_descriptions, 
                       Optional = parameter_optional, 
                       stringsAsFactors = FALSE)
        rownames(d) <- NULL
        
        print(d)
        cat("\n")
            
    }
    
    if (length(x$process_graph) > 0) {
        cat("Stored process graph:\n")
        print(x$process_graph)
    }
}

#' @export
print.FileFormat = function(x, ...) {
    if (length(x$title) == 0) {
        cat("Format: \t\t\t",x$name,"\n",sep="")
    } else {
        cat("Format: \t\t\t",x$title,"\n",sep="")   
    }
    cat("Format ID: \t\t\t",x$name,"\n",sep="")
    
    if (length(x$description) > 0) {
        cat("\n",x$description,"\n\n")
    }
    
    cat("Applicable GIS data types: \t",paste0(x$gis_data_types,collapse=", "),"\n",sep="")
    
    param_names = names(x$parameter)
    
    if (length(param_names) > 0) {
        cat("Creation options:\n")
        params = data.frame(name=param_names,
                            descriptions = sapply(x$parameter, function(p)p$description),
                            stringsAsFactors = FALSE)
        row.names(params) = NULL
        print(params)
    }
}

#' @export
print.ServiceType = function(x, ...) {
    # name is set in list_service_types not in specification
    if (length(x$title) > 0) {
        cat("Service: \t\t",x$title,"\n",sep="")
    } else {
        cat("Service: \t\t",x$name,"\n",sep="")
    }
    
    if (length(x$description) > 0) {
        cat("\n",x$description,"\n\n",sep="")
    }
    
    
    if (length(x$configuration) > 0) {
        cat("Configuration parameter:\n")
        config_params = data.frame(name = names(x$configuration),description = sapply(x$configuration, function(cparam) {
            cparam$description
        }),stringsAsFactors = FALSE)
        row.names(config_params) = NULL
        print(config_params)
    }
    
    if (length(x$process_parameters) > 0) {
        cat("Process parameter:\n")
        process_parameters = data.frame(name = sapply(x$process_parameters, function(p)p$name), 
                                        description = sapply(x$process_parameters, function(p)p$description),
                                        stringsAsFactors = FALSE)
        row.names(process_parameters) = NULL
        print(process_parameters)
    }
    
}

#' @export
print.Collection = function(x, ...) {
    id = paste(x$id)
    if (is.null(x$title)) 
        x$title = "---"
    title = paste("Title:\t\t\t\t", x$title, sep = "")
    
    description = paste0("Description:\t\t\t", x$description)
    deprecated = if(!is.null(x$deprecated) && !as.logical(x$deprecated)) paste0("Deprecated:\t\t\t",x$deprecated) else NULL
    
    if (is.null(x$providers)) 
        x$providers = list(list(name = "---"))
    source = paste("Source:\t\t\t\t", paste(sapply(x$providers, function(p) {
        p$name
    }), sep = "", collapse = ", "), sep = "")
    
    if (length(x$summaries) > 0) {
        if (is.null(x$summaries$platform)) 
            x$summaries$platform = "---"
        platform = paste("Platform:\t\t\t", x$summaries$platform, sep = "")
        if (is.null(x$summaries$constellation)) 
            x$summaries$constellation = "---"
        constellation = paste("Constellation:\t\t\t", x$summaries$constellation, sep = "")
        if (is.null(x$summaries$instruments)) 
            x$summaries$instruments = "---"
        instrument = paste("Instrument:\t\t\t", x$summaries$instruments, sep = "")
        
        if (length(x$summaries$`proj:epsg`) > 0) {
            crs = paste("Data SRS (EPSG-code):\t\t", x$summaries$`proj:epsg`, sep = "")
        } else {
            crs = NULL
        }
        
    }
    
    
    spatial.extent = paste("(", x$extent$spatial[1], ", ", x$extent$spatial[2], "), (", x$extent$spatial[3], ", ", x$extent$spatial[4], ")", sep = "")
    extent = paste("Spatial extent (lon,lat):\t", spatial.extent, sep = "")
    
    time = tryCatch({
        paste0("Temporal extent:\t\t", paste0(lapply(x$extent$temporal, function(obj) {
            if (length(obj[[1]]) > 0 && !is.na(obj[[1]])) {
                start = format(as_datetime(obj[[1]]), format = "%Y-%m-%dT%H:%M:%SZ")
            } else {
                start = NA
            }
            
            if (length(obj[[2]]) > 0 && !is.na(obj[[2]])) {
                end = format(as_datetime(obj[[2]]), format = "%Y-%m-%dT%H:%M:%SZ")
            } else {
                end = NA
            }
            
            
            return(paste(start, "/", end))
        }), collapse = ", "))
    }, error = function(e) {
        paste("Temporal extent:\t\t***parsing error***")
    })

    
    cat(unlist(list(id, title, description,if (!is.null(deprecated)) deprecated else NULL, source, if (length(x$summaries) > 0) list(platform, constellation, instrument) else NULL, extent, if (length(x$summaries) > 0) crs else NULL, time)), sep = "\n")
    
    if (!is.null(x$summaries$`eo:bands`)) {
        cat("Bands:\n")
        print(as.data.frame(x$summaries$`eo:bands`))
    } else if (!is.null(x$summaries$`sar:bands`)) {
        cat("Bands:\n")
        print(as.data.frame(x$summaries$`sar:bands`))
    }
    
}

#' @export
print.JobList = function(x, ...) {
    showed_columns = c("id", "title", "status", "created", "updated", "costs", "budget", "plan")
    x = unname(x)
    # list to tibble
    if (length(x) > 0) {
        df = as.data.frame(x)
        
        missing_columns = showed_columns[!showed_columns %in% colnames(df)]
        if (length(missing_columns) > 0) {
            nas = rep(NA, length(missing_columns))
            names(nas) = missing_columns
            df = do.call("cbind", append(list(df), as.list(nas)))
        }
        df = df[, showed_columns]
        
    } else {
        df = data.frame(id = character(),title=character(),status = character(),
                        created = character(), updated = character(), costs=integer(),
                        budget=integer(), plan=character(),stringsAsFactors = FALSE)
    }
    
    if (nrow(df) == 0 || ncol(df) == 0) {
        message("No jobs stored on the back-end.")
        invisible(df)
    }
    
    if (isNamespaceLoaded("tibble")) {
        df = tibble::as_tibble(df)
    }
    
    print(df)
}

#' @export
print.Job = function(x, ...) {
    id = paste("Job ID:\t\t", x$id, "\n", sep = "")
    if (is.null(x$title)) 
        x$title = "---"
    title = paste("Title:\t\t", x$title, "\n", sep = "")
    if (is.null(x$description)) 
        x$description = "---"
    description = paste("Description:\t", x$description, "\n", sep = "")
    status = paste("Status:\t\t", x$status, "\n", sep = "")
    created = paste("Created:\t", x$created, "\n", sep = "")
    updated = paste("Updated:\t", x$updated, "\n", sep = "")
    
    # if (is.null(x$progress)) 
    #     x$progress = "---"
    # progress = paste("Progress:\t", x$progress, "\n", sep = "")
    
    if (is.null(x$plan)) 
        x$plan = "---"
    plan = paste("Plan:\t\t", x$plan, "\n", sep = "")
    costs = paste("Costs:\t\t", x$costs, "\n", sep = "")
    if (is.null(x$budget)) 
        x$budget = "---"
    budget = paste("Budget:\t\t", x$budget, "\n", sep = "")
    
    cat(id, title, description, status, created, updated, 
        if (!is.null(x$progress)) paste("Progress:\t", x$progress, "\n", sep = "") else NULL, 
        plan, costs, budget, sep = "")
    
    if (length(x$process) > 0) {
        process_graph = "User defined process:\n"
        cat(process_graph)
        print(x$process)
    }
    
    
    
}

#' @export
print.ServiceList = function(x, ...) {
    if (length(x) > 0) {
        df = as.data.frame(x,extract=c("id","title","description","url","type","enabled","created"))
        row.names(df) = NULL
        
        if (isNamespaceLoaded("tibble"))
            df = tibble::as_tibble(df)
        
        print(df) 
    } else {
        message("No secondary services published.")
    }
    
    
}


#' @export
print.Service = function(x, ...) {
    
    id = paste("ID:\t\t", x$id, "\n", sep = "")
    
    type = paste("Type:\t\t", x$type, "\n", sep = "")
    
    enabled = paste("Enabled:\t", x$enabled, "\n", sep = "")
    
    created = paste("Submitted:\t", x$created, "\n", sep = "")
    
    if (is.null(x$title) || is.na(x$title)) 
        x$title = "---"
    title = paste("Title:\t\t", x$title, "\n", sep = "")
    
    if (is.null(x$description) || is.na(x$description)) 
        x$description = "---"
    description = paste("Description:\t", x$description, "\n", sep = "")
    
    if (is.na(x$url)) 
        x$url = "---"
    url = paste("Endpoint:\t", x$url, "\n", sep = "")
    
    plan = paste("Plan:\t\t", x$plan, "\n", sep = "")
    
    costs = paste("Costs:\t\t", x$costs, "\n", sep = "")
    
    if (length(x$budget) == 0 || is.na(x$budget)) 
        x$budget = "---"
    budget = paste("Budget:\t\t", x$budget, "\n", sep = "")
    
    cat(id, type, enabled, title, created, description, url, plan, costs, budget, sep = "")
    
    # parameters, attributes, process_graph
    if (length(x$configuration) == 0) {
        x$configuration = "---"
        cat(paste("Configuration:\t", x$configuration, "\n", sep = ""))
    } else {
        x$configuration = toJSON(x$configuration, pretty = TRUE, auto_unbox = TRUE)
        cat(paste("Configuration:\n", x$configuration, "\n", sep = ""))
    }
    
    if (length(x$attributes) > 0) {
        x$attributes = toJSON(x$attributes, pretty = TRUE, auto_unbox = TRUE)
        cat(paste("Attributes:\n", x$attributes, "\n", sep = ""))
    }
    
    if (length(x$process) > 0) {
        if ("Process" %in% class(x$process)) {
            pg = unclass(x$process$serialize())
        } else {
            pg = x$process
        }
        
        pg = toJSON(pg, pretty = TRUE, auto_unbox = TRUE)
        cat(paste("Process graph:\n", pg, "\n", sep = ""))
    }
}

#' @export
print.JobCostsEstimation = function(x, ...) {
    header = "Job costs estimation\n"
    line = "====================\n"
    costs = paste("Costs: \t\t\t\t", x$costs, "\n", sep = "")
    duration = paste("Duration: \t\t\t", x$duration, "\n", sep = "")
    downloads = paste("Downloads for owner included: \t")
    yesno = if (x$downloads_included) 
        "yes" else "no"
    
    cat(header, line, costs, duration, downloads, yesno, sep = "")
}

#' @export
print.CollectionList = function(x, ...) {
    df = as.data.frame(x, extract = c("id", "title", "description","deprecated"))
    if (isNamespaceLoaded("tibble")) 
        print(tibble::as_tibble(df)[, c("id", "title", "description","deprecated")]) else print(df)
}

#' @export
print.Graph = function(x, ...) {
    print(graphToJSON(x))
}

#' @export
print.ProcessNode = function(x, ...) {
    node_validation = x$validate()
    
    if (is.null(node_validation)) {
        print(toJSON(x$serialize(),auto_unbox = TRUE,pretty = TRUE,force=TRUE))
    }
}

#' @export
print.Json_Graph = function(x, ...) {
    print(toJSON(x, auto_unbox = TRUE, force = TRUE, pretty = TRUE))
}

#' @export
print.OpenEOCapabilities = function(x, ...) {
    capabilities = x
    
    title = capabilities$title
    backend_version = capabilities$backend_version
    description = capabilities$description
    
    version = capabilities$api_version
    stac_version = capabilities$stac_version
    stac_id = capabilities$id
    endpoints = capabilities$endpoints
    billing = capabilities$billing  #not used right now
    
    cat(paste0("Back-end:\t\t", title), 
        paste0("Back-end version: \t", backend_version), 
        paste0("Description:\t\t", description), 
        paste0("API-version:\t\t", version),
        paste0("STAC"),
        if(length(stac_id) > 0 || is.na(stac_id)) paste0("   ID:\t\t\t",stac_id) else "   ID:\t\t\t---",
        paste0("   Version:\t\t",stac_version), sep = "\n")
        
    
    server_offering = .listObjectsToDataFrame(endpoints)
    
    if (isNamespaceLoaded("tibble")) 
        server_offering = tibble::as_tibble(server_offering)
    print(server_offering)
}

#' @export
print.ResultList = function(x, ...) {
    cat("Results for job: ",x$id,"\n")
    if (length(x$properties$expires) > 0) {
        cat("Links expire on: ",x$properties$expires,"\n")
    }
    
    # assets overview
    if (length(x$assets) > 0) {
        cat("\n")
        assets = as.data.frame(x$assets)
        
        if (isNamespaceLoaded("tibble")) {
            assets = tibble::as_tibble(assets)
        }
        
        print(assets)
    } else {
        cat("\n")
        cat("No assests found.\n")
    }
}

#' @export
print.CubeDimensions = function(x,...) {
    lapply(x,function(y) {
        print(y)
        cat("\n")
    })
}

#' @export
print.CubeDimension = function(x,...) {
    cat("Dimension:\t",x$name,"\n")
    
    if (length(x$type) > 0) {
        cat("Type:\t\t",x$type,"\n")
    }
    
    if (length(x$axis) > 0) {
        cat("Axis:\t\t",x$axis,"\n")
    }
    
    if (length(x$extent) > 0) {
        cat("Extent:\t\t",paste0("[",paste0(x$extent,collapse=","),"]"),"\n")
    }
    if (length(x$values) > 0) {
        cat("Values:\t\t",paste0("[",paste(x$values,collapse=","),"]","\n"))
    }
}

#' @export
print.Log = function(x,...) {
    void = sapply(x$logs,function(log_entry) {
        cat(paste0("[",toupper(log_entry$level),"] ",log_entry$message,"\n"))
    })
}
