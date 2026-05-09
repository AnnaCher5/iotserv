-record(iot, {id :: integer(),
             name :: string(),
             address :: string(),
             temperature :: number(),
             metrics = [] :: [{atom(), term()}]}).
