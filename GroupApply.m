function GroupApply(Col, Table, Func)
    unique_ids = unique(Table.(Col));
    for ii = 1:length(unique_ids)
        id = unique_ids(ii);
        Func(id, Table(Table.(Col) == unique_ids(ii), :))
    end
end